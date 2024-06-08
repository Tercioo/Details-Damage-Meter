
do
	local Details	= 	_G.Details
	local _
	local addonName, Details222 = ...
	local pairs = pairs
	local ipairs = ipairs
	local unpack = table.unpack or _G.unpack
	local GetSpellInfo = Details222.GetSpellInfo
	local UnitClass = UnitClass
	local UnitGUID = UnitGUID

	local CONST_UNKNOWN_CLASS_COORDS = {0.75, 1, 0.75, 1}
	local CONST_DEFAULT_COLOR = {1, 1, 1, 1}

	local roles = {
		DAMAGER = {421/512, 466/512, 381/512, 427/512},
		HEALER = {467/512, 512/512, 381/512, 427/512},
		TANK = {373/512, 420/512, 381/512, 427/512},
		NONE = {0, 50/512, 110/512, 150/512},
	}

	---return a table containing information about the texture to use for the actor icon
	---@param actorObject actor
	---@return texturetable
	function Details:GetActorIcon(actorObject)
		---@type instance
		local instance = Details:GetInstance(1)

		local spec = actorObject:Spec()
		if (spec and spec > 0) then
			---@type string
			local fileName

			--get the spec icon file currently in use
			if (instance) then
				fileName = instance.row_info.spec_file
			else
				fileName = Details.instance_defaults.row_info.spec_file
			end

			local left, right, top, bottom = unpack(Details.class_specs_coords[spec])

			local textureTable = {
				texture = fileName,
				coords = {left = left, right = right, top = top, bottom = bottom},
				size = {height = 16, width = 16},
			}

			return textureTable
		end

		local class = actorObject:Class() or "UNKNOW"
		local left, right, top, bottom = unpack(Details.class_coords[class])

		---@type string
		local fileName
			--get the spec icon file currently in use
			if (instance) then
				fileName = instance.row_info.icon_file
			else
				fileName = Details.instance_defaults.row_info.icon_file
			end

		local textureTable = {
			texture = fileName,
			coords = {left = left, right = right, top = top, bottom = bottom},
			size = {height = 16, width = 16},
		}

		return textureTable
	end

	---return the path to a texture file and the texture coordinates
	---@return string, number, number, number, number
	function Details:GetUnknownClassIcon()
		return [[Interface\AddOns\Details\images\classes_small]], unpack(CONST_UNKNOWN_CLASS_COORDS)
	end

	---return a path to a texture file
	---@param iconType "spec"|"class"
	---@param bWithAlpha boolean
	---@return string texturePath
	function Details:GetIconTexture(iconType, bWithAlpha)
		iconType = string.lower(iconType)

		if (iconType == "spec") then
			if (bWithAlpha) then
				return [[Interface\AddOns\Details\images\spec_icons_normal_alpha]]
			else
				return [[Interface\AddOns\Details\images\spec_icons_normal]]
			end
		else --if is class
			if (bWithAlpha) then
				return [[Interface\AddOns\Details\images\classes_small_alpha]]
			else
				return [[Interface\AddOns\Details\images\classes_small]]
			end
		end
	end

	---attempt to get the class of an actor by its name, if the actor isn't found, it searches the overall data for the actor
	---@param actorName string
	---@return string className, number left, number right, number top, number bottom, number red, number green, number blue, number alpha
	function Details:GetClass(actorName)
		local unitClass = Details:GetUnitClass(actorName)

		if (unitClass) then
			local left, right, top, bottom = unpack(Details.class_coords[unitClass])
			local r, g, b = unpack(Details.class_colors[unitClass])
			return unitClass, left, right, top, bottom, r or 1, g or 1, b or 1, 1
		else
			local overallCombatObject = Details:GetCombat(DETAILS_SEGMENTID_OVERALL)
			for containerId = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
				local actorContainer = overallCombatObject:GetContainer(containerId)
				local actorObject = actorContainer:GetActor(actorName)

				if (actorObject) then
					unitClass = actorObject:Class()
					if (unitClass) then
						--found the class of the actor
						local left, right, top, bottom = unpack(Details.class_coords[unitClass] or CONST_UNKNOWN_CLASS_COORDS)
						local r, g, b = unpack(Details.class_colors[unitClass])
						return unitClass, left, right, top, bottom, r or 1, g or 1, b or 1, 1
					end
				end
			end

			return "UNKNOW", 0.75, 1, 0.75, 1, 1, 1, 1, 1
		end
	end


	--note: this could return the coords and color as well to match Details:GetClass()
	---attempt to get the spec of an actor by its name, if the actor isn't found, it searches the overall data for the actor
	---@param actorName string
	---@return number|nil
	function Details:GetSpecFromActorName(actorName)
		local GUID = UnitGUID(actorName)
		local spec = Details:GetSpecByGUID(GUID)

		if (spec) then
			return spec
		end

		local overallCombatObject = Details:GetCombat(DETAILS_SEGMENTID_OVERALL)
		for containerId = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
			local actorContainer = overallCombatObject:GetContainer(containerId)
			local actorObject = actorContainer:GetActor(actorName)

			if (actorObject) then
				spec = actorObject:Spec()
				if (spec) then
					return spec
				end
			end
		end
	end

	---return the path to a texture file and the texture coordinates
	---@param role string
	---@return string texturePath, number left, number right, number top, number bottom
	function Details:GetRoleIcon(role)
		return [[Interface\AddOns\Details\images\icons2]], unpack(roles[role])
	end

	---return the path to a texture file and the texture coordinates for the given class
	---@param class string
	---@return string texturePath, number left, number right, number top, number bottom
	function Details:GetClassIcon(class)
		if (self.classe) then
			class = self.classe

		elseif (type(class) == "table" and class.classe) then
			class = class.classe

		elseif (type(class) == "string") then
			class = class

		else
			class = "UNKNOW"
		end

		if (class == "UNKNOW") then
			return [[Interface\LFGFRAME\LFGROLE_BW]], 0.25, 0.5, 0, 1

		elseif (class == "UNGROUPPLAYER") then
			return [[Interface\ICONS\Achievement_Character_Orc_Male]], 0, 1, 0, 1

		elseif (class == "PET") then
			return [[Interface\AddOns\Details\images\classes_small]], 0.25, 0.49609375, 0.75, 1

		else
			return [[Interface\AddOns\Details\images\classes_small]], unpack(Details.class_coords[class])
		end
	end

	---return the path to a texture file and the texture coordinates for the given spec
	---@param spec number
	---@param useAlpha boolean
	---@return string texturePath, number left, number right, number top, number bottom
	function Details:GetSpecIcon(spec, useAlpha)
		if (not spec or spec == 0) then
			--this returns the icon for "unknown" spec (gotten from the class icon file)
			return [[Interface\AddOns\Details\images\classes_small]], unpack(Details.class_coords["UNKNOW"])
		end

		if (useAlpha) then
			return [[Interface\AddOns\Details\images\spec_icons_normal_alpha]], unpack(Details.class_specs_coords [spec])
		else
			return [[Interface\AddOns\Details\images\spec_icons_normal]], unpack(Details.class_specs_coords[spec])
		end
	end

	---return the red, green, blue and alpha values for the given class
	---@param class string
	---@return number red, number green, number blue, number alpha
	function Details:GetClassColor(class)
		if (self.classe) then
			return unpack(Details.class_colors[self.classe] or CONST_DEFAULT_COLOR)

		elseif (type(class) == "table" and class.classe) then
			return unpack(Details.class_colors[class.classe] or CONST_DEFAULT_COLOR)

		elseif (type(class) == "string") then
			return unpack(Details.class_colors[class] or CONST_DEFAULT_COLOR)

		elseif (self.color) then
			return unpack(self.color)
		else
			return unpack(CONST_DEFAULT_COLOR)
		end
	end

	---get the spec or class texture and coordinates for the given player name and combat object, if the actor isn't found return unknown icon
	---@param playerName string
	---@param combatObject combat
	---@return string texturePath, number left, number right, number top, number bottom
	function Details:GetPlayerIcon(playerName, combatObject)
		combatObject = combatObject or Details:GetCurrentCombat()

		local texturePath, left, right, top, bottom

		---@type actor
		local playerObject = combatObject:GetActor(DETAILS_ATTRIBUTE_DAMAGE, playerName)
		if (not playerObject or not playerObject.spec) then
			---@type actor
			playerObject = combatObject:GetActor(DETAILS_ATTRIBUTE_HEAL, playerName)
		end

		if (playerObject) then
			local spec = playerObject.spec
			if (spec) then
				texturePath = [[Interface\AddOns\Details\images\spec_icons_normal]]
				left, right, top, bottom = unpack(Details.class_specs_coords[spec])

			elseif (playerObject.classe) then
				texturePath = [[Interface\AddOns\Details\images\classes_small]]
				left, right, top, bottom = unpack(Details.class_coords[playerObject.classe or "UNKNOW"])
			end
		end

		if (not texturePath) then
			texturePath = [[Interface\AddOns\Details\images\classes_small]]
			left, right, top, bottom = unpack(Details.class_coords["UNKNOW"])
		end

		return texturePath, left, right, top, bottom
	end

	---return specId if it exists in the spec cache
	---@param unitSerial string this is also called GUID
	---@return number|nil
	function Details:GetSpecByGUID(unitSerial)
		return Details.cached_specs[unitSerial]
	end

	local specNamesToId = {}
	function Details:BuildSpecsNameCache()
		if (DetailsFramework.IsDragonflightAndBeyond()) then
			---@type table<class, table<specializationid, boolean>>
			local classSpecList = DetailsFramework.ClassSpecs
			---@number
			local numClasses = GetNumClasses()

			for i = 1, numClasses do
				local classInfo = C_CreatureInfo.GetClassInfo(i)
				local localizedClassName = classInfo.className
				local classTag = classInfo.classFile

				local specIdsList = classSpecList[classTag]
				if (specIdsList) then
					for specId in pairs(specIdsList) do
						local specId2, specName = GetSpecializationInfoByID(specId)
						if (specId2 and specName) then
							specNamesToId[specName .. " " .. localizedClassName] = specId2
						end
					end
				end
			end
		end
	end


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	---comment
	---@param payload table
	---@return any
	function Details:GuessClass(payload)
		---@type actor, actorcontainer, number
		local actorObject, actorContainer, attempts = payload[1], payload[2], payload[3]

		if (not actorObject or actorObject.__destroyed) then
			return false
		end

		local spellContainerNames = actorObject:GetSpellContainerNames() --1x Details/functions/playerclass.lua:293: attempt to call method 'GetSpellContainerNames' (a nil value)
		for i = 1, #spellContainerNames do
			local spellContainer = actorObject:GetSpellContainer(spellContainerNames[i])
			if (spellContainer) then
				for spellId in spellContainer:ListSpells() do
					local class = Details.ClassSpellList[spellId]
					if (class) then
						actorObject.classe = class
						actorObject.guessing_class = nil

						if (actorContainer) then
							actorContainer.need_refresh = true
						end

						if (actorObject.minha_barra and type(actorObject.minha_barra) == "table") then
							actorObject.minha_barra.minha_tabela = nil
							Details:ScheduleWindowUpdate(2, true)
						end

						return class
					end
				end
			end
		end

		local class = Details:GetClass(actorObject:Name())
		if (class and class ~= "UNKNOW") then
			actorObject.classe = class
			actorObject.need_refresh = true
			actorObject.guessing_class = nil

			if (actorContainer) then
				actorContainer.need_refresh = true
			end

			if (actorObject.minha_barra and type(actorObject.minha_barra) == "table") then
				actorObject.minha_barra.minha_tabela = nil
				Details:ScheduleWindowUpdate(2, true)
			end

			return class
		end

		if (attempts and attempts < 10) then
			payload[3] = attempts + 1 --thanks @Farmbuyer on curseforge
			--_detalhes:ScheduleTimer("GuessClass", 2, {Actor, container, tries+1})
			Details:ScheduleTimer("GuessClass", 2, payload) --passing the same table instead of creating a new one
		end

		return false
	end

	---comment
	---@param payload table
	---@return any
	function Details:GuessSpec(payload)
		---@type actor, actorcontainer, number
		local actorObject, actorContainer, attempts = payload[1], payload[2], payload[3]
		if (not actorObject or actorObject.__destroyed) then
			return false
		end

		local actorSpec

		--attempt the obvious
		if (actorObject.spec) then
			actorSpec = actorObject.spec
		end

		local specSpellList = Details.SpecSpellList

		--attempt to get from OpenRaid
		if (not actorSpec) then
			local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
			if (openRaidLib) then
				local unitInfo = openRaidLib.GetUnitInfo(actorObject:Name()) --1x Details/functions/playerclass.lua:368: attempt to call method 'Name' (a nil value)
				if (unitInfo and unitInfo.specId and unitInfo.specId ~= 0) then
					actorSpec = unitInfo.specId
				end
			end
		end

		--attempt to get from the spec cache
		if (not actorSpec) then
			actorSpec = Details.cached_specs[actorObject.serial]
		end

		--attempt to get spec from tooltip
		if (not actorSpec and DetailsFramework:IsDragonflightAndBeyond()) then
			local tooltipData = C_TooltipInfo.GetHyperlink("unit:" .. actorObject.serial)
			if (tooltipData and tooltipData.lines) then
				for i = 1, #tooltipData.lines do
					local thisLineData = tooltipData.lines[i]
					local text = thisLineData.leftText
					if (text and thisLineData.type == 0) then
						local specId = specNamesToId[text]
						if (specId and type(specId) == "number") then
							actorSpec = specId
						end
					end
				end
			end
		end

		--attempt to get from the spells the actor used in the current combat
		if (not actorSpec) then
			local currentCombatObject = Details:GetCurrentCombat()

			if (currentCombatObject.__destroyed) then
				--schedule made before a destroy combat call, but not cancelled
				return
			end

			for containerId = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
				if (actorSpec) then
					break
				end

				---@type actorcontainer
				local currentActorContainer = currentCombatObject:GetContainer(containerId)
				---@type actor
				local currentActorObject = currentActorContainer:GetActor(actorObject:Name())

				if (currentActorObject) then
					--iterate among all spells the actor used
					if (not actorSpec) then
						local spellContainerNames = currentActorObject:GetSpellContainerNames()
						for i = 1, #spellContainerNames do
							local spellContainer = currentActorObject:GetSpellContainer(spellContainerNames[i])
							if (spellContainer) then
								for spellId in spellContainer:ListSpells() do
									local spec = specSpellList[spellId]
									if (spec) then
										actorSpec = spec
										break
									end
								end
							end
						end
					end
				end
			end
		end

		--attempt to get from overall combat object
		if (not actorSpec) then
			local overallCombatObject = Details:GetCombat(DETAILS_SEGMENTID_OVERALL)
			for containerId = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
				if (actorSpec) then
					break
				end

				local overallActorContainer = overallCombatObject:GetContainer(containerId)
				local overallActorObject = overallActorContainer:GetActor(actorObject:Name())
				if (overallActorObject) then
					if (overallActorObject.spec and overallActorObject.spec ~= 0) then
						actorSpec = overallActorObject.spec
						break
					end

					--iterate among all spells the actor used
					if (not actorSpec) then
						local spellContainerNames = overallActorObject:GetSpellContainerNames()
						for i = 1, #spellContainerNames do
							local spellContainer = overallActorObject:GetSpellContainer(spellContainerNames[i])
							if (spellContainer) then
								for spellId in spellContainer:ListSpells() do
									local spec = specSpellList[spellId]
									if (spec) then
										actorSpec = spec
										break
									end
								end
							end
						end
					end
				end
			end
		end

		if (actorSpec) then
			Details.cached_specs[actorObject.serial] = actorSpec
			actorObject:SetSpecId(actorSpec)
			actorObject.classe = Details.SpecIDToClass[actorSpec] or actorObject.classe
			actorObject.guessing_spec = nil

			if (actorContainer) then
				actorContainer.need_refresh = true
			end

			if (actorObject.minha_barra and type(actorObject.minha_barra) == "table") then
				actorObject.minha_barra.minha_tabela = nil
				Details:ScheduleWindowUpdate(2, true)
			end

			return actorSpec
		end

		if (Details.streamer_config.quick_detection) then
			if (attempts and attempts < 30) then
				payload[3] = attempts + 1
				Details:ScheduleTimer("GuessSpec", 1, payload) --todo: replace schedule from ace3 and use our own
			end
		else
			if (attempts and attempts < 4) then
				payload[3] = attempts + 1
				Details:ScheduleTimer("GuessSpec", 4, payload)
			end
		end

		return false
	end

	function Details:ReGuessSpec(t) --deprecated
		local actorObject, container = t[1], t[2]
		local SpecSpellList = Details.SpecSpellList

		---@type combat
		local combatObject = Details:GetCurrentCombat()

		--get from the spell cast list
		if (combatObject) then
			local spellCastTable = combatObject:GetSpellCastTable(actorObject.nome)

			for spellName in pairs(spellCastTable) do
				local _, _, _, _, _, _, spellid = GetSpellInfo(spellName)
				local spec = SpecSpellList[spellid]
				if (spec) then
					Details.cached_specs[actorObject.serial] = spec

					actorObject:SetSpecId(spec)
					actorObject.classe = Details.SpecIDToClass[spec] or actorObject.classe
					actorObject.guessing_spec = nil

					Details:SendEvent("UNIT_SPEC", nil, actorObject:GetUnitId(), spec, actorObject.serial)

					if (container) then
						container.need_refresh = true
					end

					if (actorObject.minha_barra and type(actorObject.minha_barra) == "table") then
						actorObject.minha_barra.minha_tabela = nil
						Details:ScheduleWindowUpdate (2, true)
					end

					return spec
				end
			end

		else
			if (actorObject.spells) then
				for spellid, _ in pairs(actorObject.spells._ActorTable) do
					local spec = SpecSpellList [spellid]
					if (spec) then
						if (spec ~= actorObject.spec) then
							Details.cached_specs [actorObject.serial] = spec

							actorObject:SetSpecId(spec)
							actorObject.classe = Details.SpecIDToClass [spec] or actorObject.classe

							Details:SendEvent("UNIT_SPEC", nil, actorObject:GetUnitId(), spec, actorObject.serial)

							if (container) then
								container.need_refresh = true
							end

							if (actorObject.minha_barra and type(actorObject.minha_barra) == "table") then
								actorObject.minha_barra.minha_tabela = nil
								Details:ScheduleWindowUpdate (2, true)
							end

							return spec
						else
							break
						end
					end
				end

				if (actorObject.classe == "HUNTER") then
					local container_misc = Details.tabela_vigente[4]
					local index = container_misc._NameIndexTable [actorObject.nome]
					if (index) then
						local misc_actor = container_misc._ActorTable [index]
						local buffs = misc_actor.buff_uptime_spells and misc_actor.buff_uptime_spells._ActorTable
						if (buffs) then
							for spellid, spell in pairs(buffs) do
								local spec = SpecSpellList [spellid]
								if (spec) then
									if (spec ~= actorObject.spec) then
										Details.cached_specs [actorObject.serial] = spec

										actorObject:SetSpecId(spec)
										actorObject.classe = Details.SpecIDToClass [spec] or actorObject.classe

										Details:SendEvent("UNIT_SPEC", nil, actorObject:GetUnitId(), spec, actorObject.serial)

										if (container) then
											container.need_refresh = true
										end

										if (actorObject.minha_barra and type(actorObject.minha_barra) == "table") then
											actorObject.minha_barra.minha_tabela = nil
											Details:ScheduleWindowUpdate (2, true)
										end

										return spec
									else
										break
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
