--[[ detect actor class ]]

do

	local Details	= 	_G.Details
	local _
	local addonName, Details222 = ...
	local pairs = pairs
	local ipairs = ipairs
	local unpack = table.unpack or _G.unpack

	local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
	local unknown_class_coords = {0.75, 1, 0.75, 1}

	function Details:GetUnknownClassIcon()
		return [[Interface\AddOns\Details\images\classes_small]], unpack(unknown_class_coords)
	end

	function Details:GetIconTexture (iconType, withAlpha)
		iconType = string.lower(iconType)

		if (iconType == "spec") then
			if (withAlpha) then
				return [[Interface\AddOns\Details\images\spec_icons_normal_alpha]]
			else
				return [[Interface\AddOns\Details\images\spec_icons_normal]]
			end

		elseif (iconType == "class") then
			if (withAlpha) then
				return [[Interface\AddOns\Details\images\classes_small_alpha]]
			else
				return [[Interface\AddOns\Details\images\classes_small]]
			end
		end
	end

	-- try get the class from actor name
	function Details:GetClass(name)
		local _, class = UnitClass (name)

		if (not class) then
			for index, container in ipairs(Details.tabela_overall) do
				local index = container._NameIndexTable [name]
				if (index) then
					local actor = container._ActorTable [index]
					if (actor.classe ~= "UNGROUPPLAYER") then
						local left, right, top, bottom = unpack(Details.class_coords [actor.classe] or unknown_class_coords)
						local r, g, b = unpack(Details.class_colors [actor.classe])
						return actor.classe, left, right, top, bottom, r or 1, g or 1, b or 1
					end
				end
			end

			return "UNKNOW", 0.75, 1, 0.75, 1, 1, 1, 1, 1
		else
			local left, right, top, bottom = unpack(Details.class_coords [class])
			local r, g, b = unpack(Details.class_colors [class])
			return class, left, right, top, bottom, r or 1, g or 1, b or 1
		end
	end

	local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

	local roles = {
		DAMAGER = {421/512, 466/512, 381/512, 427/512},
		HEALER = {467/512, 512/512, 381/512, 427/512},
		TANK = {373/512, 420/512, 381/512, 427/512},
		NONE = {0, 50/512, 110/512, 150/512},
	}
	function Details:GetRoleIcon (role)
		return [[Interface\AddOns\Details\images\icons2]], unpack(roles [role])
	end

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

	function Details:GetSpecIcon(spec, useAlpha)
		if (spec) then
			if (spec == 0) then
				return [[Interface\AddOns\Details\images\classes_small]], unpack(Details.class_coords["UNKNOW"])
			end

			if (useAlpha) then
				return [[Interface\AddOns\Details\images\spec_icons_normal_alpha]], unpack(Details.class_specs_coords [spec])
			else
				return [[Interface\AddOns\Details\images\spec_icons_normal]], unpack(Details.class_specs_coords [spec])
			end
		end
	end

	local default_color = {1, 1, 1, 1}
	function Details:GetClassColor (class)
		if (self.classe) then
			return unpack(Details.class_colors [self.classe] or default_color)

		elseif (type(class) == "table" and class.classe) then
			return unpack(Details.class_colors [class.classe] or default_color)

		elseif (type(class) == "string") then
			return unpack(Details.class_colors [class] or default_color)

		elseif (self.color) then
			return unpack(self.color)
		else
			return unpack(default_color)
		end
	end

	function Details:GetPlayerIcon (playerName, segment)
		segment = segment or Details.tabela_vigente

		local texture
		local L, R, T, B

		local playerObject = segment (1, playerName)
		if (not playerObject or not playerObject.spec) then
			playerObject = segment (2, playerName)
		end

		if (playerObject) then
			local spec = playerObject.spec
			if (spec) then
				texture = [[Interface\AddOns\Details\images\spec_icons_normal]]
				L, R, T, B = unpack(Details.class_specs_coords [spec])
			else
				texture = [[Interface\AddOns\Details\images\classes_small]]
				L, R, T, B = unpack(Details.class_coords [playerObject.classe or "UNKNOW"])
			end
		else
			texture = [[Interface\AddOns\Details\images\classes_small]]
			L, R, T, B = unpack(Details.class_coords ["UNKNOW"])
		end

		return texture, L, R, T, B
	end

	function Details:GuessClass (t)

		local Actor, container, tries = t[1], t[2], t[3]

		if (not Actor) then
			return false
		end

		if (Actor.spells) then --correcao pros containers misc, precisa pegar os diferentes tipos de containers de  l�
			for spellid, _ in pairs(Actor.spells._ActorTable) do
				local class = Details.ClassSpellList [spellid]
				if (class) then
					Actor.classe = class
					Actor.guessing_class = nil

					if (container) then
						container.need_refresh = true
					end

					if (Actor.minha_barra and type(Actor.minha_barra) == "table") then
						Actor.minha_barra.minha_tabela = nil
						Details:ScheduleWindowUpdate (2, true)
					end

					return class
				end
			end
		end

		if (not Actor.nome) then
			if (not Details.NoActorNameWarning) then
				print("==============")
				Details:Msg("Unhandled Exception: Actor has no name, ContainerID: ", container.tipo)
				Details:Msg("After the current combat, reset data and use /reload.")
				Details:Msg("Report this issue to the Author: Actor with no name, container: ", container.tipo)
				print("==============")
				Details.NoActorNameWarning = true
			end
			return
		end

		local class = Details:GetClass(Actor.nome)
		if (class and class ~= "UNKNOW") then
			Actor.classe = class
			Actor.need_refresh = true
			Actor.guessing_class = nil

			if (container) then
				container.need_refresh = true
			end

			if (Actor.minha_barra and type(Actor.minha_barra) == "table") then
				Actor.minha_barra.minha_tabela = nil
				Details:ScheduleWindowUpdate (2, true)
			end

			return class
		end

		if (tries and tries < 10) then
			t[3] = tries + 1 --thanks @Farmbuyer on curseforge
			--_detalhes:ScheduleTimer("GuessClass", 2, {Actor, container, tries+1})
			Details:ScheduleTimer("GuessClass", 2, t) --passing the same table instead of creating a new one
		end

		return false
	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	function Details:GetSpecByGUID (unitSerial)
		return Details.cached_specs [unitSerial]
	end

	-- try get the spec from actor name
	function Details:GetSpec (name)

		local guid = UnitGUID(name)
		if (guid) then
			local spec = Details.cached_specs [guid]
			if (spec) then
				return spec
			end
		end

		for index, container in ipairs(Details.tabela_overall) do
			local index = container._NameIndexTable [name]
			if (index) then
				local actor = container._ActorTable [index]
				return actor and actor.spec
			end
		end

	end

	function Details:GetUnitId(unitName)
		unitName = unitName or self.nome
		if (openRaidLib) then
			local unitId = openRaidLib.GetUnitID(unitName)
			if (unitId) then
				return unitId
			end
		end

		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do
				local unitId = "raid" .. i
				if (GetUnitName(unitId, true) == unitName) then
					return unitId
				end
			end

		elseif (IsInGroup()) then
			for i = 1, GetNumGroupMembers() -1 do
				local unitId = "party" .. i
				if (GetUnitName(unitId, true) == unitName) then
					return unitId
				end
			end
			if (UnitName("player") == unitName) then
				return "player"
			end
		end
	end

	function Details:ReGuessSpec (t)
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

	function Details:GuessSpec(t)
		local Actor, container, tries = t[1], t[2], t[3]
		if (not Actor) then
			return false
		end

		local SpecSpellList = Details.SpecSpellList
		--get from the spec cache
		local spec = Details.cached_specs [Actor.serial]
		if (spec) then
			Actor:SetSpecId(spec)
			Actor.classe = Details.SpecIDToClass [spec] or Actor.classe

			Actor.guessing_spec = nil

			if (container) then
				container.need_refresh = true
			end

			if (Actor.minha_barra and type(Actor.minha_barra) == "table") then
				Actor.minha_barra.minha_tabela = nil
				Details:ScheduleWindowUpdate (2, true)
			end

			return spec
		end

		--get from the spell cast list
		if (Details.tabela_vigente) then
			local spellCastTable = Details.tabela_vigente:GetSpellCastTable(Actor.nome)

			for spellName, _ in pairs(spellCastTable) do
				local _, _, _, _, _, _, spellid = GetSpellInfo(spellName)
				local spec = SpecSpellList[spellid]
				if (spec) then
					Details.cached_specs [Actor.serial] = spec

					Actor:SetSpecId(spec)
					Actor.classe = Details.SpecIDToClass [spec] or Actor.classe

					Details:SendEvent("UNIT_SPEC", nil, Actor:GetUnitId(), spec, Actor.serial)

					Actor.guessing_spec = nil

					if (container) then
						container.need_refresh = true
					end

					if (Actor.minha_barra and type(Actor.minha_barra) == "table") then
						Actor.minha_barra.minha_tabela = nil
						Details:ScheduleWindowUpdate (2, true)
					end

					return spec
				end
			end

			if (Actor.spells) then --correcao pros containers misc, precisa pegar os diferentes tipos de containers de  l�
				for spellid, _ in pairs(Actor.spells._ActorTable) do
					local spec = SpecSpellList [spellid]
					if (spec) then
						Details.cached_specs [Actor.serial] = spec

						Actor:SetSpecId(spec)
						Actor.classe = Details.SpecIDToClass [spec] or Actor.classe
						Actor.guessing_spec = nil

						Details:SendEvent("UNIT_SPEC", nil, Actor:GetUnitId(), spec, Actor.serial)

						if (container) then
							container.need_refresh = true
						end

						if (Actor.minha_barra and type(Actor.minha_barra) == "table") then
							Actor.minha_barra.minha_tabela = nil
							Details:ScheduleWindowUpdate (2, true)
						end

						return spec
					end
				end
			end
		else

			if (Actor.spells) then --correcao pros containers misc, precisa pegar os diferentes tipos de containers de  l�
				for spellid, _ in pairs(Actor.spells._ActorTable) do
					local spec = SpecSpellList [spellid]
					if (spec) then
						Details.cached_specs [Actor.serial] = spec

						Actor:SetSpecId(spec)
						Actor.classe = Details.SpecIDToClass [spec] or Actor.classe
						Actor.guessing_spec = nil

						Details:SendEvent("UNIT_SPEC", nil, Actor:GetUnitId(), spec, Actor.serial)

						if (container) then
							container.need_refresh = true
						end

						if (Actor.minha_barra and type(Actor.minha_barra) == "table") then
							Actor.minha_barra.minha_tabela = nil
							Details:ScheduleWindowUpdate (2, true)
						end

						return spec
					end
				end
			end
		end

		if (Actor.classe == "HUNTER") then
			local container_misc = Details.tabela_vigente[4]
			local index = container_misc._NameIndexTable [Actor.nome]
			if (index) then
				local misc_actor = container_misc._ActorTable [index]
				local buffs = misc_actor.buff_uptime_spells and misc_actor.buff_uptime_spells._ActorTable
				if (buffs) then
					for spellid, spell in pairs(buffs) do
						local spec = SpecSpellList [spellid]
						if (spec) then

							Details.cached_specs [Actor.serial] = spec

							Actor:SetSpecId(spec)
							Actor.classe = Details.SpecIDToClass [spec] or Actor.classe
							Actor.guessing_spec = nil

							Details:SendEvent("UNIT_SPEC", nil, Actor:GetUnitId(), spec, Actor.serial)

							if (container) then
								container.need_refresh = true
							end

							if (Actor.minha_barra and type(Actor.minha_barra) == "table") then
								Actor.minha_barra.minha_tabela = nil
								Details:ScheduleWindowUpdate (2, true)
							end

							return spec
						end
					end
				end
			end
		end

		local spec = Details:GetSpec (Actor.nome)
		if (spec) then

			Details.cached_specs [Actor.serial] = spec

			Actor:SetSpecId(spec)
			Actor.classe = Details.SpecIDToClass [spec] or Actor.classe
			Actor.need_refresh = true
			Actor.guessing_spec = nil

			if (container) then
				container.need_refresh = true
			end

			if (Actor.minha_barra and type(Actor.minha_barra) == "table") then
				Actor.minha_barra.minha_tabela = nil
				Details:ScheduleWindowUpdate (2, true)
			end

			return spec
		end

		if (Details.streamer_config.quick_detection) then
			if (tries and tries < 30) then
				t[3] = tries + 1
				Details:ScheduleTimer("GuessSpec", 1, t)
			end
		else
			if (tries and tries < 10) then
				t[3] = tries + 1
				Details:ScheduleTimer("GuessSpec", 3, t)
			end
		end

		return false
	end

end


function Details:AddColorString (player_name, class)
	--check if the class colors exists
	local classColors = _G.RAID_CLASS_COLORS
	if (classColors) then
		local color = classColors [class]
		--check if the player name is valid
		if (type(player_name) == "string" and color) then
			player_name = "|c" .. color.colorStr .. player_name .. "|r"
			return player_name
		end
	end

	--if failed, return the player name without modifications
	return player_name
end

function Details:AddRoleIcon (player_name, role, size)
	--check if is a valid role
	local roleIcon = Details.role_texcoord [role]
	if (type(player_name) == "string" and roleIcon and role ~= "NONE") then
		--add the role icon
		size = size or 14
		player_name = "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" .. size .. ":" .. size .. ":0:0:256:256:" .. roleIcon .. "|t " .. player_name
		return player_name
	end

	return player_name
end

function Details:AddClassOrSpecIcon (playerName, class, spec, iconSize, useAlphaIcons)

	local size = iconSize or 16

	if (spec) then
		local specString = ""
		local L, R, T, B = unpack(Details.class_specs_coords [spec])
		if (L) then
			if (useAlphaIcons) then
				specString = "|TInterface\\AddOns\\Details\\images\\spec_icons_normal_alpha:" .. size .. ":" .. size .. ":0:0:512:512:" .. (L * 512) .. ":" .. (R * 512) .. ":" .. (T * 512) .. ":" .. (B * 512) .. "|t"
			else
				specString = "|TInterface\\AddOns\\Details\\images\\spec_icons_normal:" .. size .. ":" .. size .. ":0:0:512:512:" .. (L * 512) .. ":" .. (R * 512) .. ":" .. (T * 512) .. ":" .. (B * 512) .. "|t"
			end
			return specString .. " " .. playerName
		end
	end

	if (class) then
		local classString = ""
		local L, R, T, B = unpack(Details.class_coords [class])
		if (L) then
			local imageSize = 128
			if (useAlphaIcons) then
				classString = "|TInterface\\AddOns\\Details\\images\\classes_small_alpha:" .. size .. ":" .. size .. ":0:0:" .. imageSize .. ":" .. imageSize .. ":" .. (L * imageSize) .. ":" .. (R * imageSize) .. ":" .. (T * imageSize) .. ":" .. (B * imageSize) .. "|t"
			else
				classString = "|TInterface\\AddOns\\Details\\images\\classes_small:" .. size .. ":" .. size .. ":0:0:" .. imageSize .. ":" .. imageSize .. ":" .. (L * imageSize) .. ":" .. (R * imageSize) .. ":" .. (T * imageSize) .. ":" .. (B * imageSize) .. "|t"
			end
			return classString .. " " .. playerName
		end
	end

	return playerName
end
