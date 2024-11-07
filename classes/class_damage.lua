
--Damage Class
--a damage object is created inside an actor container
--an actor container is created inside a combat object
--combat objects has 4 actor containers: damage, healing, energy, utility
--these containers are indexed within the combat object table: combatObject[1] = damage container, combatObject[2] = healing container, combatObject[3] = energy container, combatObject[4] = utility container


--damage object
	local Details = _G.Details
	local Loc = LibStub("AceLocale-3.0"):GetLocale( "Details" )
	local Translit = LibStub("LibTranslit-1.0")
	local gump = Details.gump
	local _ = nil
	local detailsFramework = DetailsFramework
	local addonName, Details222 = ...

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--local pointers

	local format = string.format --lua local
	local tinsert = table.insert --lua local
	local setmetatable = setmetatable --lua local
	local _getmetatable = getmetatable --lua local
	local ipairs = ipairs --lua local
	local pairs = pairs --lua local
	local abs = math.abs --lua local
	local bitBand = bit.band --lua local
	local unpack = unpack --lua local
	local type = type --lua local
	local GameTooltip = GameTooltip --api local
	local IsInRaid = IsInRaid --api local
	local IsInGroup = IsInGroup --api local
    local GetSpellLink = GetSpellLink or C_Spell.GetSpellLink --api local

	local CONST_MELEE_SPELLID = 6603
	local CONST_AUTOSHOT_SPELLID = 75

	local GetSpellInfo = Details222.GetSpellInfo --api local
	local _GetSpellInfo = Details.getspellinfo --details api
	local stringReplace = Details.string.replace --details api

	--show more information about spells
	local debugmode = false

	local GetSpellTexture = GetSpellTexture or C_Spell.GetSpellTexture

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants

	local spellContainerClass	= 	Details.container_habilidades
	local damageClass	=	Details.atributo_damage
	local atributo_misc		=	Details.atributo_misc
	local container_damage	=	Details.container_type.CONTAINER_DAMAGE_CLASS

	local modo_ALL = Details.modos.all
	local class_type = Details.atributos.dano

	local ignoredEnemyNpcsTable = Details.IgnoredEnemyNpcsTable
	local ToKFunctions = Details.ToKFunctions
	local selectedToKFunction = ToKFunctions[1]
	local formatTooltipNumber = ToKFunctions[8]
	local bUsingCustomLeftText = false
	local bUsingCustomRightText = false
	local tooltipMaximizedMethod = 1

	--templates
	local byspell_tooltip_background = {value = 100, color = {0.1960, 0.1960, 0.1960, 0.9097}, texture = [[Interface\AddOns\Details\images\bar_background_dark]]}
	local enemies_background = {value = 100, color = {0.1960, 0.1960, 0.1960, 0.8697}, texture = "Interface\\AddOns\\Details\\images\\bar_background2"}
	Details.tooltip_key_overlay1 = {1, 1, 1, .2}
	Details.tooltip_key_overlay2 = {1, 1, 1, .5}
	local headerColor = {1, 0.9, 0.0, 1}
	local spectator = "Commentator"
	Details._spectator = spectator

	local is_player_class = Details.player_class
	local numbertostring = detailsFramework.CatchString
	local koKRStart = numbertostring(234) --rectangle
	Details.tooltip_key_size_width = 24
	Details.tooltip_key_size_height = 10

	local breakdownWindowFrame = Details.BreakdownWindowFrame

	local keyName

	local ntable = {} --temp
	local vtable = {} --temp
	local tooltip_void_zone_temp = {} --temp
	local bs_table = {} --temp
	local bs_index_table = {} --temp
	local bs_tooltip_table
	local frags_tooltip_table
	local tooltip_temp_table = {}

	--damage mixin
	local damageClassMixin = {}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--exported functions

function Details:CreateActorLastEventTable() --[[exported]]
		local t = { {}, {}, {}, {}, {}, {}, {}, {} }
		t.n = 1
	return t
end

function damageClass:CreateFFTable(targetName) --[[exported]]
	local newTable = {total = 0, spells = {}}
	self.friendlyfire[targetName] = newTable
	return newTable
end

function Details:CreateActorAvoidanceTable(noOverall) --[[exported]]
	if (noOverall) then
		local avoidanceTable = {["ALL"] = 0, ["DODGE"] = 0, ["PARRY"] = 0, ["HITS"] = 0, ["ABSORB"] = 0, --quantas vezes foi dodge, parry, quandos hits tomou, quantos absorbs teve
			["FULL_HIT"] = 0, ["FULL_ABSORBED"] = 0, ["PARTIAL_ABSORBED"] = 0, --full hit full absorbed and partial absortion
			["FULL_HIT_AMT"] = 0, ["PARTIAL_ABSORB_AMT"] = 0, ["ABSORB_AMT"] = 0, ["FULL_ABSORB_AMT"] = 0, --amounts
			["BLOCKED_HITS"] = 0, ["BLOCKED_AMT"] = 0, --amount of hits blocked - amout of damage mitigated
		}
		return avoidanceTable
	else
		local avoidanceTable = {
			overall = {["ALL"] = 0, ["DODGE"] = 0, ["PARRY"] = 0, ["HITS"] = 0, ["ABSORB"] = 0, --quantas vezes foi dodge, parry, quandos hits tomou, quantos absorbs teve
			["FULL_HIT"] = 0, ["FULL_ABSORBED"] = 0, ["PARTIAL_ABSORBED"] = 0, --full hit full absorbed and partial absortion
			["FULL_HIT_AMT"] = 0, ["PARTIAL_ABSORB_AMT"] = 0, ["ABSORB_AMT"] = 0, ["FULL_ABSORB_AMT"] = 0, --amounts
			["BLOCKED_HITS"] = 0, ["BLOCKED_AMT"] = 0, --amount of hits blocked - amout of damage mitigated
		}
		}
		return avoidanceTable
	end
end

function Details.SortGroup(container, keyName2) --[[exported]]
	keyName = keyName2
	return table.sort(container, Details.SortKeyGroup)
end

function Details.SortKeyGroup(table1, table2) --[[exported]]
	if (table1.grupo and table2.grupo) then
		return table1[keyName] > table2[keyName]

	elseif(table1.grupo and not table2.grupo) then
		return true

	elseif(not table1.grupo and table2.grupo) then
		return false

	else
		return table1[keyName] > table2[keyName]
	end
end


function Details.SortKeySimple(table1, table2) --[[exported]]
	return table1[keyName] > table2[keyName]
end

---sort by real time dps
---@param actor1 actor
---@param actor2 actor
---@return boolean
function Details.SortByRealTimeDps(actor1, actor2)
	return(actor1.last_dps_realtime or 0) >(actor2.last_dps_realtime or 0)
end


function Details:ContainerSort(container, amount, keyName2) --[[exported]]
	keyName = keyName2
	table.sort(container,  Details.SortKeySimple)

	if (amount) then
		for i = amount, 1, -1 do --de tr�s pra frente
			if (container[i][keyName] < 1) then
				amount = amount-1
			else
				break
			end
		end

		return amount
	end
end

---return true if the actor is a friendly npc
---@return boolean
function Details:IsFriendlyNpc() --[[exported]]
	local flag = self.flag_original
	if (flag) then
		if (bitBand(flag, 0x00000008) ~= 0) then
			if (bitBand(flag, 0x00000010) ~= 0) then
				if (bitBand(flag, 0x00000800) ~= 0) then
					return true
				end
			end
		end
	end
	return false
end

function Details:IsEnemy() --[[exported]]
	if (self.flag_original) then
		if (bitBand(self.flag_original, 0x00000060) ~= 0) then
			local npcId = Details:GetNpcIdFromGuid(self.serial)
			if (ignoredEnemyNpcsTable[npcId]) then
				return false
			end
			return true
		end
	end
	return false
end

function Details:GetSpellList() --[[exported]]
	return self.spells._ActorTable
end


function Details:GetTimeInCombat(petOwner) --[[exported]]
	if (petOwner) then
		if (Details.time_type == 1 or not petOwner.grupo) then
			return self:Tempo()
		elseif(Details.time_type == 2 or Details.use_realtimedps) then
			return self:GetCombatTime()
		end
	else
		if (Details.time_type == 1) then
			return self:Tempo()
		elseif(Details.time_type == 2 or Details.use_realtimedps) then
			return self:GetCombatTime()
		end
	end
end


--enemies(sort function)
local sortEnemies = function(t1, t2)
	local a = bitBand(t1.flag_original, 0x00000060)
	local b = bitBand(t2.flag_original, 0x00000060)

	if (a ~= 0 and b ~= 0) then
		local npcid1 = Details:GetNpcIdFromGuid(t1.serial)
		local npcid2 = Details:GetNpcIdFromGuid(t2.serial)

		if (not ignoredEnemyNpcsTable[npcid1] and not ignoredEnemyNpcsTable[npcid2]) then
			return t1.damage_taken > t2.damage_taken

		elseif(ignoredEnemyNpcsTable[npcid1] and not ignoredEnemyNpcsTable[npcid2]) then
			return false

		elseif(not ignoredEnemyNpcsTable[npcid1] and ignoredEnemyNpcsTable[npcid2]) then
			return true
		else
			return t1.damage_taken > t2.damage_taken
		end

	elseif(a ~= 0 and b == 0) then
		return true

	elseif(a == 0 and b ~= 0) then
		return false
	end

	return false
end

function Details:ContainerSortEnemies(container, amount, keyName2) --[[exported]]
	keyName = keyName2

	table.sort(container, sortEnemies)

	local total = 0

	for index, player in ipairs(container) do
		local npcid1 = Details:GetNpcIdFromGuid(player.serial)
		--p rint(player.nome, npcid1, ignored_enemy_npcs [npcid1])
		if (bitBand(player.flag_original, 0x00000060) ~= 0 and not ignoredEnemyNpcsTable [npcid1]) then --� um inimigo
			total = total + player [keyName]
		else
			amount = index-1
			break
		end
	end

	return amount, total
end

function Details:TooltipForCustom(barra) --[[exported]]
	GameCooltip:AddLine(Loc ["STRING_LEFT_CLICK_SHARE"])
	return true
end

--[[ Void Zone Sort]]
local void_zone_sort = function(t1, t2)
	if (t1.damage == t2.damage) then
		return t1.nome <= t2.nome
	else
		return t1.damage > t2.damage
	end
end


function Details.Sort1(table1, table2) --[[exported]]
	return table1[1] > table2[1]
end

function Details.Sort2(table1, table2) --[[exported]]
	return table1[2] > table2[2]
end

function Details.Sort3(table1, table2) --[[exported]]
	return table1[3] > table2[3]
end

function Details.Sort4(table1, table2) --[[exported]]
	return table1[4] > table2[4]
end

function Details.Sort4Reverse(table1, table2) --[[exported]]
	if (not table2) then
		return true
	end
	return table1[4] < table2[4]
end

function Details:GetTextColor(instanceObject, textSide)
	local actorObject = self
	textSide = textSide or "left"

	local bUseClassColor = false
	if (textSide == "left") then
		bUseClassColor = instanceObject.row_info.textL_class_colors
	elseif(textSide == "right") then
		bUseClassColor = instanceObject.row_info.textR_class_colors
	end

	if (bUseClassColor) then
		local actorClass = actorObject.classe or "UNKNOW"
		if (actorClass == "UNKNOW") then
			return unpack(instanceObject.row_info.fixed_text_color)
		else
			return unpack(Details.class_colors[actorClass])
		end
	else
		return unpack(instanceObject.row_info.fixed_text_color)
	end
end

function Details:GetBarColor(actor) --[[exported]]
	actor = actor or self

	if (actor.monster) then
		return unpack(Details.class_colors.ENEMY)

	elseif(actor.customColor) then
		return unpack(actor.customColor)

	elseif(actor.spellicon) then
		return 0.729, 0.917, 1

	elseif(actor.owner) then
		return unpack(Details.class_colors[actor.owner.classe or "UNKNOW"])

	elseif(actor.arena_team and Details.color_by_arena_team) then
		if (actor.arena_team == 0) then
			return unpack(Details.class_colors.ARENA_GREEN)
		else
			return unpack(Details.class_colors.ARENA_YELLOW)
		end

	else
		if (not is_player_class[actor.classe] and actor.flag_original and bitBand(actor.flag_original, 0x00000020) ~= 0) then --neutral
			return unpack(Details.class_colors.NEUTRAL)

		elseif(actor.color) then
			return unpack(actor.color)

		else
			return unpack(Details.class_colors[actor.classe or "UNKNOW"])
		end
	end
end

function Details:GetSpellLink(spellid) --[[exported]]
	if (type(spellid) ~= "number") then
		return spellid
	end

	if (spellid == 1) then --melee
		return GetSpellLink(CONST_MELEE_SPELLID)

	elseif(spellid == 2) then --autoshot
		return GetSpellLink(CONST_AUTOSHOT_SPELLID)

	elseif(spellid > 10) then
		return GetSpellLink(spellid)
	else
		local spellname = _GetSpellInfo(spellid)
		return spellname
	end
end

function Details:GameTooltipSetSpellByID(spellId) --[[exported]]
	if (spellId == 1) then
		GameTooltip:SetSpellByID(CONST_MELEE_SPELLID)

	elseif(spellId == 2) then
		GameTooltip:SetSpellByID(CONST_AUTOSHOT_SPELLID)

	elseif(spellId > 10) then
		GameTooltip:SetSpellByID(spellId)

	else
		GameTooltip:SetSpellByID(spellId)
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--class ~constructor

	---create a new actorObject and set the metatable to the actor prototype
	---this function is called from within an actorContainer when it needs to create a new actorObject for a new actor
	---actorObject is a ordinary table with the actor attributes and a metatable to inherit the functions from Details object
	---@return table
	function damageClass:NovaTabela() --create new actorObject
		local alphabetical = Details:GetOrderNumber()

		--constructor: creates a table with the actor attributes and then set the metatable to the actor prototype
		local newDamageActor = {
			--type of the actor
			tipo = class_type,

			--total: amount of damage done
			total = alphabetical,
			total_extra = 0,
			--totalabsorbed: amount of damage done absorbed by shields
			totalabsorbed = alphabetical,
			--total_without_pet: amount of damage done without pet damage
			total_without_pet = alphabetical,
			--custom: used by custom scripts, works more like a cache
			custom = 0,

			--damage_taken: amount of damage the actor took during the combat
			damage_taken = alphabetical,
			--damage_from: table with actor names as keys and boolean true as value
			damage_from = {},

			--dps_started: is false until this actor does damage
			dps_started = false,
			--last_event: the time when the actor as last edited by a damage effect: suffered damage, did damage
			last_event = 0,
			--on_hold: if the actor is idle, doing nothing during combat, on_hold is true
			on_hold = false,
			--delay: the time when the actor went idle
			delay = 0,
			--caches
			last_value = nil,
			last_dps = 0, --cache of the latest dps value calculated for this actor
			last_dps_realtime = 0, --cache of the latest real time dps value calculated for this actor
			--start_time: the time when the actor started to do damage
			start_time = 0,
			--end_time: the time when the actor stopped to do damage
			end_time = nil,

			--table indexed with pet names
			pets = {},
			--table where key is the raid target flags and the value is the damage done to that target
			raid_targets = {},

			--friendlyfire_total: amount of damage done to friendly players
			friendlyfire_total = 0,
			--friendlyfire: table where key is a player name and value is a table with .total: damage inflicted and .spells a table with spell names as keys and damage done as value
			friendlyfire = {},

			--targets: table where key is the target name(actor name) and the value is the amount of damage done to that target
			targets = {},
			--spells: spell container
			spells = spellContainerClass:NovoContainer(container_damage)
		}

		setmetatable(newDamageActor, damageClass)
		detailsFramework:Mixin(newDamageActor, Details222.Mixins.ActorMixin)
		detailsFramework:Mixin(newDamageActor, damageClassMixin)

		return newDamageActor
	end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--special cases

	---calculate real time dps for each actor within the passed table
	---@param tableWithActors actor[]
	---@return number
	function damageClass:RefreshDpsRealTime(tableWithActors)
		local totalRealTime = 0
		local timeSample = Details222.CurrentDPS.GetTimeSample()

		for _, actorObject in ipairs(tableWithActors) do
			---@cast actorObject actordamage
			---@type details_currentdps_actorcache
			local realTimeDPS = Details222.CurrentDPS.Cache[actorObject.serial]
			if (realTimeDPS) then
				realTimeDPS = realTimeDPS.totalDamage / timeSample
				actorObject.last_dps_realtime = realTimeDPS
				totalRealTime = totalRealTime + realTimeDPS
			end
		end

		return totalRealTime
	end

	--dps(calculate dps for actors)
	---@param tableWithActors table
	---@param combatTime combattime
	---@return number, number
	function damageClass:ContainerRefreshDps(tableWithActors, combatTime)
		local total = 0
		local totalRealTime = 0

		local bIsEffectiveTime = Details.time_type == 2
		local bOrderDpsByRealTime = Details.CurrentDps.CanSortByRealTimeDps()
		local timeSample = Details222.CurrentDPS.GetTimeSample()

		if (bIsEffectiveTime or not Details:CaptureGet("damage")) then
			for _, actorObject in ipairs(tableWithActors) do
				---@cast actorObject actordamage
				if (actorObject.grupo) then
					actorObject.last_dps = actorObject.total / combatTime
				else
					actorObject.last_dps = actorObject.total / actorObject:Tempo()
				end

				if (bOrderDpsByRealTime) then
					---@type details_currentdps_actorcache
					local realTimeDPS = Details222.CurrentDPS.Cache[actorObject.serial]
					if (realTimeDPS) then
						realTimeDPS = realTimeDPS.totalDamage / timeSample
						actorObject.last_dps_realtime = realTimeDPS
						totalRealTime = totalRealTime + realTimeDPS
					end
				end

				total = total + actorObject.last_dps
			end
		else
			for _, actorObject in ipairs(tableWithActors) do
				actorObject.last_dps = actorObject.total / actorObject:Tempo()
				total = total + actorObject.last_dps

				if (bOrderDpsByRealTime) then
					local realTimeDPS = Details222.CurrentDPS.Cache[actorObject.serial] or 0
					actorObject.last_dps_realtime = realTimeDPS
					totalRealTime = totalRealTime + realTimeDPS
				end
			end
		end

		return total, totalRealTime
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--damage taken by spell

	function Details:ToolTipBySpell(instance, tabela, thisLine, keydown)

		local GameCooltip = GameCooltip
		local combat = instance.showing
		local from_spell = tabela [1] --spellid
		local from_spellname
		if (from_spell) then
			from_spellname = select(1, GetSpellInfo(from_spell))
		end

		--get a list of all damage actors
		local AllDamageCharacters = combat:GetActorList(DETAILS_ATTRIBUTE_DAMAGE)

		--hold the targets
		local Targets = {}
		local total = 0
		local top = 0

		local is_custom_spell = false
		for _, spellcustom in ipairs(Details.savedCustomSpells) do
			if (spellcustom[1] == from_spell) then
				is_custom_spell = true
			end
		end

		for index, character in ipairs(AllDamageCharacters) do

			if (is_custom_spell) then
				for playername, ff_table in pairs(character.friendlyfire) do
					if (ff_table.spells [from_spell]) then
						local damage_actor = combat(1, playername)
						local heal_actor = combat(2, playername)

						if ((damage_actor or heal_actor) and((damage_actor and damage_actor:IsPlayer()) or(heal_actor and heal_actor:IsPlayer()))) then

							local got

							for index, t in ipairs(Targets) do
								if (t[1] == playername) then
									t[2] = t[2] + ff_table.spells [from_spell]
									total = total + ff_table.spells [from_spell]
									if (t[2] > top) then
										top = t[2]
									end
									got = true
									break
								end
							end

							if (not got) then
								Targets [#Targets+1] = {playername, ff_table.spells [from_spell]}
								total = total + ff_table.spells [from_spell]
								if (ff_table.spells [from_spell] > top) then
									top = ff_table.spells [from_spell]
								end
							end
						end
					end
				end
			else
				for playername, ff_table in pairs(character.friendlyfire) do
					for spellid, amount in pairs(ff_table.spells) do
						local spellname = select(1, GetSpellInfo(spellid))
						if (spellname == from_spellname) then
							local damage_actor = combat(1, playername)
							local heal_actor = combat(2, playername)
							if ((damage_actor or heal_actor) and((damage_actor and damage_actor:IsPlayer()) or(heal_actor and heal_actor:IsPlayer()))) then
								local got
								for index, t in ipairs(Targets) do
									if (t[1] == playername) then
										t[2] = t[2] + amount
										total = total + amount
										if (t[2] > top) then
											top = t[2]
										end
										got = true
										break
									end
								end

								if (not got) then
									Targets [#Targets+1] = {playername, amount}
									total = total + amount
									if (amount > top) then
										top = amount
									end
								end
							end
						end
					end
				end
			end

			--search actors which used the spell shown in the bar
			local spell = character.spells._ActorTable [from_spell]

			if (spell) then
				for targetname, amount in pairs(spell.targets) do

					local got = false
					local damage_actor = combat(1, targetname)
					local heal_actor = combat(2, targetname)

					if ((damage_actor or heal_actor) and((damage_actor and damage_actor:IsPlayer()) or(heal_actor and heal_actor:IsPlayer()) ) ) then
						for index, t in ipairs(Targets) do
							if (t[1] == targetname) then
								t[2] = t[2] + amount
								total = total + amount
								if (t[2] > top) then
									top = t[2]
								end
								got = true
								break
							end
						end

						if (not got) then
							Targets [#Targets+1] = {targetname, amount}
							total = total + amount
							if (amount > top) then
								top = amount
							end
						end
					end
				end
			end

			if (not is_custom_spell) then
				for spellid, spell in pairs(character.spells._ActorTable) do
					if (spellid ~= from_spell) then
						local spellname = select(1, GetSpellInfo(spellid))
						if (spellname == from_spellname) then
							for targetname, amount in pairs(spell.targets) do

								local got = false
								local damage_actor = combat(1, targetname)
								local heal_actor = combat(2, targetname)

								if ((damage_actor or heal_actor) and((damage_actor and damage_actor:IsPlayer()) or(heal_actor and heal_actor:IsPlayer()) ) ) then
									for index, t in ipairs(Targets) do
										if (t[1] == targetname) then
											t[2] = t[2] + amount
											total = total + amount
											if (t[2] > top) then
												top = t[2]
											end
											got = true
											break
										end
									end

									if (not got) then
										Targets [#Targets+1] = {targetname, amount}
										total = total + amount
										if (amount > top) then
											top = amount
										end
									end
								end
							end
						end
					end
				end
			end
		end

		table.sort(Targets, Details.Sort2)
		bs_tooltip_table = Targets
		bs_tooltip_table.damage_total = total

		--Details:FormatCooltipForSpells()
		GameCooltip:SetOption("StatusBarTexture", "Interface\\AddOns\\Details\\images\\bar_serenity")

		local spellname, _, spellicon = select(1, _GetSpellInfo(from_spell))
		--GameCooltip:AddLine(spellname .. " " .. Loc ["STRING_CUSTOM_ATTRIBUTE_DAMAGE"], nil, nil, headerColor, nil, 10)
		--GameCooltip:AddIcon(spellicon, 1, 1, 14, 14, 0.078125, 0.921875, 0.078125, 0.921875)
		--GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_shift]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay2)
		--Details:AddTooltipHeaderStatusbar(1, 1, 1, 0.5)

		local top = Targets[1] and Targets[1][2]

		local iconSize = Details.DefaultTooltipIconSize
		GameCooltip:SetOption("AlignAsBlizzTooltip", false)
		GameCooltip:SetOption("AlignAsBlizzTooltipFrameHeightOffset", -6)
		GameCooltip:SetOption("YSpacingMod", -6)
		Details:AddRoundedCornerToTooltip()

		for index, t in ipairs(Targets) do
			GameCooltip:AddLine(Details:GetOnlyName(t[1]), Details:ToK(t[2]) .. "(" .. format("%.1f", t[2]/total*100) .. "%)")
			local class, _, _, _, _, r, g, b = Details:GetClass(t[1])

			GameCooltip:AddStatusBar(t[2]/top*100, 1, r, g, b, 0.8, false,  byspell_tooltip_background)

			if (class) then
				local specID = Details:GetSpec(t[1])
				if (specID) then
					local texture, l, r, t, b = Details:GetSpecIcon(specID, false)
					GameCooltip:AddIcon(texture, 1, 1, iconSize, iconSize, l, r, t, b)
				else
					local texture, l, r, t, b = Details:GetClassIcon(class)
					GameCooltip:AddIcon("Interface\\AddOns\\Details\\images\\classes_small_alpha", 1, 1,iconSize,iconSize, l, r, t, b)
				end

			elseif(t[1] == Loc ["STRING_TARGETS_OTHER1"]) then
				GameCooltip:AddIcon("Interface\\AddOns\\Details\\images\\classes_small_alpha", 1, 1,iconSize,iconSize, 0.25, 0.49609375, 0.75, 1)
			end
		end

		GameCooltip:AddLine(" ")
		Details:AddTooltipReportLineText()

		GameCooltip:SetOwner(thisLine)
		GameCooltip:Show()
	end

	local function RefreshBarraBySpell(tabela, barra, instancia)
		damageClass:AtualizarBySpell(tabela, tabela.minha_barra, barra.colocacao, instancia)
	end

	local on_switch_DTBS_show = function(instance)
		instance:TrocaTabela(instance, true, 1, 8)
		return true
	end

	local DTBS_search_code = [[
		---@type combat, table, instance
		local combatObject, instanceContainer, instanceObject = ...

		--declade the values to return
		local totalDamage, topDamage, amount = 0, 0, 0

		---@type {key1: actorname, key2: number, key3: actor}[]
		local damageTakenFrom = {}

		local spellId = @SPELLID@
		local spellName
		if (spellId) then
			spellName = select(1, Details.GetSpellInfo(spellId))
		end

		---@type actorcontainer
		local damageContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		---@type actorcontainer
		local healContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_HEAL)

		local bIsCustomSpell = false
		for _, customSpellObject in ipairs(Details.savedCustomSpells) do
			if (customSpellObject[1] == spellId) then
				bIsCustomSpell = true
			end
		end

		for index, actorObject in damageContainer:ListActors() do
			---@cast actorObject actordamage

			--> handle friendly fire spell damage taken
			if (actorObject:IsPlayer()) then
				if (bIsCustomSpell) then --if the spell has been modified, check only by its spellId, as it can't get other spells with the same name
					for playerName, friendlyFireTable in pairs(actorObject.friendlyfire) do
						---@cast friendlyFireTable friendlyfiretable
						if (friendlyFireTable.spells[spellId]) then
							---@type actordamage
							local damageActor = damageContainer:GetActor(playerName)
							---@type actorheal
							local healingActor = healContainer:GetActor(playerName)

							if ((damageActor and damageActor:IsPlayer()) or(healingActor and healingActor:IsPlayer())) then
								local got

								for index, damageTakenTable in ipairs(damageTakenFrom) do
									if (damageTakenTable[1] == playerName) then
										damageTakenTable[2] = damageTakenTable[2] + friendlyFireTable.spells[spellId]
										if (damageTakenTable[2] > topDamage) then
											topDamage = damageTakenTable[2]
										end
										got = true
										break
									end
								end

								if (not got) then
									---@type {key1: actorname, key2: number, key3: actor}
									local damageTakenTable = {playerName, friendlyFireTable.spells[spellId], damageActor or healingActor}
									damageTakenFrom[#damageTakenFrom+1] = damageTakenTable
									if (friendlyFireTable.spells[spellId] > topDamage) then
										topDamage = friendlyFireTable.spells[spellId]
									end
								end
							end
						end
					end
				else
					for playerName, friendlyFireTable in pairs(actorObject.friendlyfire) do
						---@cast friendlyFireTable friendlyfiretable
						for ffSpellId, damageAmount in pairs(friendlyFireTable.spells) do
							local ffSpellName = select(1, Details.GetSpellInfo(ffSpellId))
							if (ffSpellName == spellName) then
								---@type actordamage
								local damageActor = damageContainer:GetActor(playerName)
								---@type actorheal
								local healingActor = healContainer:GetActor(playerName)

								if ((damageActor and damageActor:IsPlayer()) or(healingActor and healingActor:IsPlayer())) then
									local got
									for index, damageTakenTable in ipairs(damageTakenFrom) do
										if (damageTakenTable[1] == playerName) then
											damageTakenTable[2] = damageTakenTable[2] + damageAmount
											if (damageTakenTable[2] > topDamage) then
												topDamage = damageTakenTable[2]
											end
											got = true
											break
										end
									end

									if (not got) then
										---@type {key1: actorname, key2: number, key3: actor}
										local damageTakenTable = {playerName, damageAmount, damageActor or healingActor}
										damageTakenFrom[#damageTakenFrom+1] = damageTakenTable
										if (damageAmount > topDamage) then
											topDamage = damageAmount
										end
									end
								end
							end
						end
					end
				end
			end

			--> handle regular damage taken from spells
			---@type spelltable
			local spellTable = actorObject:GetSpell(spellId)

			if (spellTable) then
				for targetName, damageAmount in pairs(spellTable.targets) do
					local got = false

					---@type actordamage
					local damageActor = damageContainer:GetActor(targetName)
					---@type actorheal
					local healingActor = healContainer:GetActor(targetName)

					if ((damageActor and damageActor:IsPlayer()) or(healingActor and healingActor:IsPlayer())) then
						for index, damageTakenTable in ipairs(damageTakenFrom) do
							if (damageTakenTable[1] == targetName) then
								damageTakenTable[2] = damageTakenTable[2] + damageAmount
								if (damageTakenTable[2] > topDamage) then
									topDamage = damageTakenTable[2]
								end
								got = true
								break
							end
						end

						if (not got) then
							---@type {key1: actorname, key2: number, key3: actor}
							local damageTakenTable = {targetName, damageAmount, damageActor or healingActor}
							damageTakenFrom[#damageTakenFrom+1] = damageTakenTable
							if (damageAmount > topDamage) then
								topDamage = damageAmount
							end
						end
					end
				end
			end

			if (not bIsCustomSpell) then
				for thisSpellId, spellTable in pairs(actorObject.spells._ActorTable) do
					if (thisSpellId ~= spellId) then --this is invalid
						local spellname = select(1, Details.GetSpellInfo(thisSpellId))
						if (spellname == spellName) then
							for targetName, damageAmount in pairs(spellTable.targets) do
								local got = false

								---@type actordamage
								local damageActor = damageContainer:GetActor(targetName)
								---@type actorheal
								local healingActor = healContainer:GetActor(targetName)

								if ((damageActor and damageActor:IsPlayer()) or(healingActor and healingActor:IsPlayer())) then
									for index, damageTakenTable in ipairs(damageTakenFrom) do
										if (damageTakenTable[1] == targetName) then
											damageTakenTable[2] = damageTakenTable[2] + damageAmount
											if (damageTakenTable[2] > topDamage) then
												topDamage = damageTakenTable[2]
											end
											got = true
											break
										end
									end

									if (not got) then
										---@type {key1: actorname, key2: number, key3: actor}
										local damageTakenTable = {targetName, damageAmount, damageActor or healingActor}
										damageTakenFrom[#damageTakenFrom+1] = damageTakenTable
										if (damageAmount > topDamage) then
											topDamage = damageAmount
										end
									end
								end
							end
						end
					end
				end
			end
		end

		table.sort(damageTakenFrom, Details.Sort2)

		for index, damageTakenTable in ipairs(damageTakenFrom) do
			instanceContainer:AddValue(damageTakenTable[3], damageTakenTable[2]) --actorObject, amountDamage
			totalDamage = totalDamage + damageTakenTable[2] --amountDamage
			amount = amount + 1
		end

		return totalDamage, topDamage, amount
	]]

	local function ShowDTBSInWindow(spell, instance) --for hold shift key and click, show players which took damage from this spell
		local spellname, _, icon = _GetSpellInfo(spell [1])
		local custom_name = spellname .. " - " .. Loc ["STRING_CUSTOM_DTBS"] .. ""

		--check if already exists
		for index, CustomObject in ipairs(Details.custom) do
			if (CustomObject:GetName() == custom_name) then
				--fix for not saving funcs on logout
				if (not CustomObject.OnSwitchShow) then
					CustomObject.OnSwitchShow = on_switch_DTBS_show
				end
				return instance:TrocaTabela(instance.segmento, 5, index)
			end
		end

		--create a custom for this spell
		local new_custom_object = {
			name = custom_name,
			icon = icon,
			attribute = false,
			author = Details.playername,
			desc = spellname .. " " .. Loc ["STRING_CUSTOM_DTBS"],
			source = false,
			target = false,
			script = false,
			tooltip = false,
			temp = true,
			notooltip = true,
			OnSwitchShow = on_switch_DTBS_show,
		}

		local new_code = DTBS_search_code
		new_code = new_code:gsub("@SPELLID@", spell [1])
		new_custom_object.script = new_code

		tinsert(Details.custom, new_custom_object)
		setmetatable(new_custom_object, Details.atributo_custom)
		new_custom_object.__index = Details.atributo_custom

		return instance:TrocaTabela(instance.segmento, 5, #Details.custom)
	end

	local DTBS_format_name = function(player_name) return Details:GetOnlyName(player_name) end
	local DTBS_format_amount = function(amount) return Details:ToK(amount) .. "(" .. format("%.1f", amount / bs_tooltip_table.damage_total * 100) .. "%)" end

	function damageClass:ReportSingleDTBSLine(spell, instance, ShiftKeyDown, ControlKeyDown)
		if (ControlKeyDown) then
			local spellname, _, spellicon = _GetSpellInfo(spell[1])
			return Details:OpenAuraPanel(spell[1], spellname, spellicon)
		elseif(ShiftKeyDown) then
			return ShowDTBSInWindow(spell, instance)
		end

		local spelllink = Details:GetSpellLink(spell [1])
		local report_table = {"Details!: " .. Loc ["STRING_CUSTOM_DTBS"] .. " " .. spelllink}

		Details:FormatReportLines(report_table, bs_tooltip_table, DTBS_format_name, DTBS_format_amount)

		return Details:Reportar(report_table, {_no_current = true, _no_inverse = true, _custom = true})
	end

	function damageClass:AtualizarBySpell(tabela, whichRowLine, colocacao, instance)
		tabela ["byspell"] = true --marca que esta tabela � uma tabela de frags, usado no controla na hora de montar o tooltip
		local thisLine = instance.barras [whichRowLine] --pega a refer�ncia da barra na janela

		if (not thisLine) then
			print("DEBUG: problema com <instance.thisLine> "..whichRowLine .. " " .. colocacao)
			return
		end

		thisLine.minha_tabela = tabela

		local spellName, _, spellIcon = _GetSpellInfo(tabela[1])

		tabela.nome = spellName --evita dar erro ao redimencionar a janela
		tabela.minha_barra = whichRowLine
		thisLine.colocacao = colocacao

		if (not _getmetatable(tabela)) then
			setmetatable(tabela, {__call = RefreshBarraBySpell})
			tabela._custom = true
		end

		local total = instance.showing.totals.by_spell
		local porcentagem

		if (instance.row_info.percent_type == 1) then
			porcentagem = format("%.1f", tabela [2] / total * 100)

		elseif(instance.row_info.percent_type == 2) then
			porcentagem = format("%.1f", tabela [2] / instance.top * 100)
		end

		thisLine.lineText1:SetText(colocacao .. ". " .. spellName)

		local bars_show_data = instance.row_info.textR_show_data

		local spell_damage = tabela[2] -- spell_damage passar por uma ToK function, precisa ser number
		if (not bars_show_data [1]) then
			spell_damage = tabela[2] --damage taken by spell n�o tem PS, ent�o � obrigado a passar o dano total
		end

		if (not bars_show_data[3]) then
			porcentagem = ""
		else
			porcentagem = porcentagem .. "%"
		end

		local bars_brackets = instance:GetBarBracket()

		if (instance.use_multi_fontstrings) then
			instance:SetInLineTexts(thisLine, "",(spell_damage and selectedToKFunction(_, spell_damage) or ""), porcentagem)
		else
			thisLine.lineText4:SetText((spell_damage and selectedToKFunction(_, spell_damage) or "") .. bars_brackets[1] .. porcentagem .. bars_brackets[2])
		end

		thisLine.lineText1:SetTextColor(1, 1, 1, 1)
		thisLine.lineText2:SetTextColor(1, 1, 1, 1)
		thisLine.lineText3:SetTextColor(1, 1, 1, 1)
		thisLine.lineText4:SetTextColor(1, 1, 1, 1)

		thisLine.lineText1:SetSize(thisLine:GetWidth() - thisLine.lineText4:GetStringWidth() - 20, 15)

		if (colocacao == 1) then
			thisLine:SetValue(100)
		else
			thisLine:SetValue(tabela[2] / instance.top * 100)
		end

		if (thisLine.hidden or thisLine.fading_in or thisLine.faded) then
			Details.FadeHandler.Fader(thisLine, "out")
		end

		if (instance.row_info.texture_class_colors) then
			if (tabela [3] > 1) then
				local r, g, b = Details:GetSpellSchoolColor(tabela[3])
				thisLine.textura:SetVertexColor(r, g, b)
			else
				local r, g, b = Details:GetSpellSchoolColor(0)
				thisLine.textura:SetVertexColor(r, g, b)
			end
		end

		thisLine.icone_classe:SetTexture(spellIcon)
		thisLine.icone_classe:SetTexCoord(0.078125, 0.921875, 0.078125, 0.921875)
		thisLine.icone_classe:SetVertexColor(1, 1, 1)
		if (thisLine.mouse_over and not instance.baseframe.isMoving) then
			local classIcon = thisLine:GetClassIcon()
			thisLine.iconHighlight:SetTexture(classIcon:GetTexture())
			thisLine.iconHighlight:SetTexCoord(classIcon:GetTexCoord())
			thisLine.iconHighlight:SetVertexColor(classIcon:GetVertexColor())
		end

	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--frags

	function Details:ToolTipFrags(instancia, frag, thisLine, keydown)

		local name = frag [1]
		local GameCooltip = GameCooltip

		--mantendo a fun��o o mais low level poss�vel
		local damage_container = instancia.showing [1]

		local frag_actor = damage_container._ActorTable [damage_container._NameIndexTable [ name ]]

		if (frag_actor) then

			local damage_taken_table = {}

			local took_damage_from = frag_actor.damage_from
			local total_damage_taken = frag_actor.damage_taken
			local total = 0

			for aggressor, _ in pairs(took_damage_from) do

				local damager_actor = damage_container._ActorTable [damage_container._NameIndexTable [ aggressor ]]

				if (damager_actor and not damager_actor.owner) then --checagem por causa do total e do garbage collector que n�o limpa os names que deram dano
					local target_amount = damager_actor.targets [name]
					if (target_amount) then
						damage_taken_table [#damage_taken_table+1] = {aggressor, target_amount, damager_actor.classe}
						total = total + target_amount
					end
				end
			end

			table.sort(damage_taken_table, Details.Sort2)

			local iconSize = Details.DefaultTooltipIconSize
			GameCooltip:SetOption("AlignAsBlizzTooltip", false)
			GameCooltip:SetOption("AlignAsBlizzTooltipFrameHeightOffset", -6)
			GameCooltip:SetOption("YSpacingMod", -6)
			Details:AddRoundedCornerToTooltip()

			local min = 6
			local ismaximized = false
			--always maximized
			if (true or keydown == "shift" or tooltipMaximizedMethod == 2 or tooltipMaximizedMethod == 3) then
				min = 99
				ismaximized = true
			end

			local top = damage_taken_table[1] and damage_taken_table[1][2]
			frags_tooltip_table = damage_taken_table
			frags_tooltip_table.damage_total = total

			local lineHeight = Details.tooltip.line_height

			if (#damage_taken_table > 0) then
				for i = 1, math.min(min, #damage_taken_table) do
					local t = damage_taken_table [i]

					GameCooltip:AddLine(Details:GetOnlyName(t[1]), formatTooltipNumber(_, t[2]) .. "(" .. format("%.1f", t[2] / total * 100) .. "%)")
					local classe = t[3]
					if (not classe) then
						classe = "UNKNOW"
					end

					if (classe == "UNKNOW") then
						GameCooltip:AddIcon("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, iconSize, iconSize, .25, .5, 0, 1)
					else

						local specID = Details:GetSpec(t[1])
						if (specID) then
							local texture, l, r, t, b = Details:GetSpecIcon(specID, false)
							GameCooltip:AddIcon(texture, 1, 1, iconSize, iconSize, l, r, t, b)
						else
							GameCooltip:AddIcon([[Interface\AddOns\Details\images\classes_small_alpha]], nil, nil, iconSize, iconSize, unpack(Details.class_coords [classe]))
						end
					end

					local _, _, _, _, _, r, g, b = Details:GetClass(t[1])
					GameCooltip:AddStatusBar(t[2] / top * 100, 1, r, g, b, 1, false, enemies_background)
				end
			else
				GameCooltip:AddLine(Loc ["STRING_NO_DATA"], nil, 1, "white")
				GameCooltip:AddIcon(instancia.row_info.icon_file, nil, nil, 14, 14, unpack(Details.class_coords ["UNKNOW"]))
			end

			GameCooltip:AddLine(" ")
			Details:AddTooltipReportLineText()

			GameCooltip:SetOption("StatusBarTexture", "Interface\\AddOns\\Details\\images\\bar_serenity")
			GameCooltip:ShowCooltip()
		end
	end

	local function RefreshBarraFrags(tabela, barra, instancia)
		damageClass:AtualizarFrags(tabela, tabela.minha_barra, barra.colocacao, instancia)
	end

	function damageClass:AtualizarFrags(tabela, whichRowLine, colocacao, instancia)

		tabela ["frags"] = true --marca que esta tabela � uma tabela de frags, usado no controla na hora de montar o tooltip
		local thisLine = instancia.barras [whichRowLine] --pega a refer�ncia da barra na janela

		if (not thisLine) then
			print("DEBUG: problema com <instancia.thisLine> "..whichRowLine.." "..rank)
			return
		end

		local previousData = thisLine.minha_tabela

		thisLine.minha_tabela = tabela

		tabela.nome = tabela [1] --evita dar erro ao redimencionar a janela
		tabela.minha_barra = whichRowLine
		thisLine.colocacao = colocacao

		if (not _getmetatable(tabela)) then
			setmetatable(tabela, {__call = RefreshBarraFrags})
			tabela._custom = true
		end

		local total = instancia.showing.totals.frags_total
		local porcentagem

		if (instancia.row_info.percent_type == 1) then
			porcentagem = format("%.1f", tabela [2] / total * 100)
		elseif(instancia.row_info.percent_type == 2) then
			porcentagem = format("%.1f", tabela [2] / instancia.top * 100)
		end

		thisLine.lineText1:SetText(colocacao .. ". " .. tabela [1])

		local bars_show_data = instancia.row_info.textR_show_data
		local bars_brackets = instancia:GetBarBracket()

		local total_frags = tabela [2]
		if (not bars_show_data [1]) then
			total_frags = ""
		end
		if (not bars_show_data [3]) then
			porcentagem = ""
		else
			porcentagem = porcentagem .. "%"
		end

		--
		if (instancia.use_multi_fontstrings) then
			instancia:SetInLineTexts(thisLine, "", total_frags, porcentagem)
		else
			thisLine.lineText4:SetText(total_frags .. bars_brackets[1] .. porcentagem .. bars_brackets[2])
		end

		thisLine.lineText1:SetSize(thisLine:GetWidth() - thisLine.lineText4:GetStringWidth() - 20, 15)

		if (colocacao == 1) then
			thisLine:SetValue(100)
		else
			thisLine:SetValue(tabela [2] / instancia.top * 100)
		end

		thisLine.lineText1:SetTextColor(1, 1, 1, 1)
		thisLine.lineText4:SetTextColor(1, 1, 1, 1)

		if (thisLine.hidden or thisLine.fading_in or thisLine.faded) then
			Details.FadeHandler.Fader(thisLine, "out")
		end

		Details:SetBarColors(thisLine, instancia, unpack(Details.class_colors [tabela [3]]))

		if (tabela [3] == "UNKNOW" or tabela [3] == "UNGROUPPLAYER" or tabela [3] == "ENEMY") then
			thisLine.icone_classe:SetTexture([[Interface\AddOns\Details\images\classes_plus]])
			thisLine.icone_classe:SetTexCoord(0.50390625, 0.62890625, 0, 0.125)
			thisLine.icone_classe:SetVertexColor(1, 1, 1)
		else
			thisLine.icone_classe:SetTexture(instancia.row_info.icon_file)
			thisLine.icone_classe:SetTexCoord(unpack(Details.class_coords [tabela [3]]))
			thisLine.icone_classe:SetVertexColor(1, 1, 1)
		end

		if (thisLine.mouse_over and not instancia.baseframe.isMoving) then --precisa atualizar o tooltip
			local classIcon = thisLine:GetClassIcon()
			thisLine.iconHighlight:SetTexture(classIcon:GetTexture())
			thisLine.iconHighlight:SetTexCoord(classIcon:GetTexCoord())
			thisLine.iconHighlight:SetVertexColor(classIcon:GetVertexColor())
		end

	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--void zones
	local on_switch_AVZ_show = function(instance)
		instance:TrocaTabela(instance, true, 1, 7)
		return true
	end

	local AVZ_search_code = [[
		--get the parameters passed
		local combat, instance_container, instance = ...
		--declade the values to return
		local total, top, amount = 0, 0, 0

		local actor_name = "@ACTORNAME@"
		local actor = combat(4, actor_name)

		if (not actor) then
			return 0, 0, 0
		end

		local damage_actor = combat(1, actor.damage_twin)

		local habilidade
		local alvos

		if (damage_actor) then
			habilidade = damage_actor.spells._ActorTable [actor.damage_spellid]
		end
		if (habilidade) then
			alvos = habilidade.targets
		end

		local container = actor.debuff_uptime_targets
		local tooltip_void_zone_temp = {}

		for target_name, debuff_table in pairs(container) do
			if (alvos) then
				local damage_alvo = alvos [target_name]
				if (damage_alvo) then
					debuff_table.damage = damage_alvo
				else
					debuff_table.damage = 0
				end
			else
				debuff_table.damage = 0
			end
		end

		local i = 1
		for target_name, debuff_table in pairs(container) do
			local t = tooltip_void_zone_temp [i]
			if (not t) then
				t = {}
				tinsert(tooltip_void_zone_temp, t)
			end

			local target_actor = combat(1, target_name) or combat(2, target_name) or combat(4, target_name)
			t[1] = target_name
			t[2] = debuff_table.damage
			t[3] = debuff_table
			t[4] = target_actor

			i = i + 1
		end

		--sort no container:
		table.sort(tooltip_void_zone_temp, Details.sort_tooltip_void_zones)

		for index, t in ipairs(tooltip_void_zone_temp) do
			instance_container:AddValue(t[4], t[2])

			local custom_actor = instance_container:GetActorTable(t[4])
			custom_actor.uptime = t[3].uptime

			total = total + t[2]
			amount = amount + 1
			if (t[2] > top) then
				top = t[2]
			end
		end

		return total, top, amount
	]]

	local AVZ_total_code = [[
		local value, top, total, combat, instance, custom_actor = ...
		local uptime = custom_actor.uptime or 0

		local minutos, segundos = floor(uptime / 60), floor(uptime % 60)
		if (minutos > 0) then
			uptime = "" .. minutos .. "m " .. segundos .. "s" .. ""
		else
			uptime = "" .. segundos .. "s" .. ""
		end

		return Details:ToK2(value) .. " - " .. uptime .. " "
	]]

	local function ShowVoidZonesInWindow(actor, instance)

		local spellid = tooltip_void_zone_temp.spellid

		local spellname, _, icon = _GetSpellInfo(spellid)
		local custom_name = spellname .. " - " .. Loc ["STRING_ATTRIBUTE_DAMAGE_DEBUFFS_REPORT"] .. ""

		--check if already exists
		for index, CustomObject in ipairs(Details.custom) do
			if (CustomObject:GetName() == custom_name) then
				--fix for not saving funcs on logout
				if (not CustomObject.OnSwitchShow) then
					CustomObject.OnSwitchShow = on_switch_AVZ_show
				end
				return instance:TrocaTabela(instance.segmento, 5, index)
			end
		end

		--create a custom for this spell
		local new_custom_object = {
			name = custom_name,
			icon = icon,
			attribute = false,
			author = Details.playername,
			desc = spellname .. " " .. Loc ["STRING_ATTRIBUTE_DAMAGE_DEBUFFS_REPORT"],
			source = false,
			target = false,
			script = false,
			tooltip = false,
			temp = true,
			notooltip = true,
			OnSwitchShow = on_switch_AVZ_show,
		}

		local new_code = AVZ_search_code
		new_code = new_code:gsub("@ACTORNAME@", actor.nome)
		new_custom_object.script = new_code

		local new_total_code = AVZ_total_code
		new_total_code = new_total_code:gsub("@ACTORNAME@", actor.nome)
		new_total_code = new_total_code:gsub("@SPELLID@", spellid)
		new_custom_object.total_script = new_total_code

		tinsert(Details.custom, new_custom_object)
		setmetatable(new_custom_object, Details.atributo_custom)
		new_custom_object.__index = Details.atributo_custom

		return instance:TrocaTabela(instance.segmento, 5, #Details.custom)
	end

	function damageClass:ReportSingleVoidZoneLine(actor, instance, ShiftKeyDown, ControlKeyDown)

		local spellid = tooltip_void_zone_temp.spellid

		if (ControlKeyDown) then
			local spellname, _, spellicon = _GetSpellInfo(spellid)
			return Details:OpenAuraPanel(spellid, spellname, spellicon)
		elseif(ShiftKeyDown) then
			return ShowVoidZonesInWindow(actor, instance)
		end

		local spelllink = Details:GetSpellLink(spellid)
		local report_table = {"Details!: " .. spelllink .. " " .. Loc ["STRING_ATTRIBUTE_DAMAGE_DEBUFFS_REPORT"]}

		local t = {}
		for index, void_table in ipairs(tooltip_void_zone_temp) do
			--ir� reportar dano zero tamb�m
			if (void_table[1] and type(void_table[1]) == "string" and void_table[2] and void_table[3] and type(void_table[3]) == "table") then
				local actor_table = {Details:GetOnlyName(void_table[1])}
				local m, s = math.floor(void_table[3].uptime / 60), math.floor(void_table[3].uptime % 60)
				if (m > 0) then
					actor_table [2] = formatTooltipNumber(_, void_table[3].damage) .. "(" .. m .. "m " .. s .. "s" .. ")"
				else
					actor_table [2] = formatTooltipNumber(_, void_table[3].damage) .. "(" .. s .. "s" .. ")"
				end
				t [#t+1] = actor_table
			end
		end

		Details:FormatReportLines(report_table, t)

		return Details:Reportar(report_table, {_no_current = true, _no_inverse = true, _custom = true})
	end

	local sort_tooltip_void_zones = function(tabela1, tabela2)
		if (tabela1 [2] > tabela2 [2]) then
			return true
		elseif(tabela1 [2] == tabela2 [2]) then
			if (tabela1[1] ~= "" and tabela2[1] ~= "") then
				return tabela1 [3].uptime > tabela2 [3].uptime
			elseif(tabela1[1] ~= "") then
				return true
			elseif(tabela2[1] ~= "") then
				return false
			end
		else
			return false
		end
	end
	Details.sort_tooltip_void_zones = sort_tooltip_void_zones


	function Details:ToolTipVoidZones(instancia, actor, barra, keydown)

		local damage_actor = instancia.showing[1]:PegarCombatente(_, actor.damage_twin)
		local habilidade
		local alvos

		if (damage_actor) then
			habilidade = damage_actor.spells._ActorTable [actor.damage_spellid]
		end

		if (habilidade) then
			alvos = habilidade.targets
		end

		local container = actor.debuff_uptime_targets

		for target_name, debuff_table in pairs(container) do
			if (alvos) then
				local damage_alvo = alvos [target_name]
				if (damage_alvo) then
					debuff_table.damage = damage_alvo
				else
					debuff_table.damage = 0
				end
			else
				debuff_table.damage = 0
			end
		end

		for i = 1, #tooltip_void_zone_temp do
			local t = tooltip_void_zone_temp [i]
			t[1] = ""
			t[2] = 0
			t[3] = 0
		end

		local i = 1
		for target_name, debuff_table in pairs(container) do
			local t = tooltip_void_zone_temp [i]
			if (not t) then
				t = {}
				tinsert(tooltip_void_zone_temp, t)
			end

			t[1] = target_name
			t[2] = debuff_table.damage
			t[3] = debuff_table

			i = i + 1
		end

		--sort no container:
		table.sort(tooltip_void_zone_temp, sort_tooltip_void_zones)

		--monta o cooltip
		local GameCooltip = GameCooltip

		local spellname, _, spellicon = _GetSpellInfo(actor.damage_spellid)
		--Details:AddTooltipSpellHeaderText(spellname .. " " .. Loc ["STRING_VOIDZONE_TOOLTIP"], headerColor, #tooltip_void_zone_temp, spellicon, 0.078125, 0.921875, 0.078125, 0.921875)
		--Details:AddTooltipHeaderStatusbar(1, 1, 1, 0.5)
		--GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_shift]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay2)

		--for target_name, debuff_table in pairs(container) do
		local first = tooltip_void_zone_temp [1] and tooltip_void_zone_temp [1][3]
		if (type(first) == "table") then
			first = first.damage
		end

		tooltip_void_zone_temp.spellid = actor.damage_spellid
		tooltip_void_zone_temp.current_actor = actor

		local iconSize = Details.DefaultTooltipIconSize
		GameCooltip:SetOption("AlignAsBlizzTooltip", false)
		GameCooltip:SetOption("AlignAsBlizzTooltipFrameHeightOffset", -6)
		GameCooltip:SetOption("YSpacingMod", -6)
		Details:AddRoundedCornerToTooltip()

		--local lineHeight = Details.tooltip.line_height

		for index, t in ipairs(tooltip_void_zone_temp) do

			if (t[3] == 0) then
				break
			end

			local debuff_table = t[3]

			local minutos, segundos = math.floor(debuff_table.uptime / 60), math.floor(debuff_table.uptime % 60)
			if (minutos > 0) then
				GameCooltip:AddLine(Details:GetOnlyName(t[1]), formatTooltipNumber(_, debuff_table.damage) .. "(" .. minutos .. "m " .. segundos .. "s" .. ")")
			else
				GameCooltip:AddLine(Details:GetOnlyName(t[1]), formatTooltipNumber(_, debuff_table.damage) .. "(" .. segundos .. "s" .. ")")
			end

			local classe = Details:GetClass(t[1])
			if (classe) then
				local specID = Details:GetSpec(t[1])
				if (specID) then
					local texture, l, r, t, b = Details:GetSpecIcon(specID, false)
					GameCooltip:AddIcon(texture, 1, 1, iconSize, iconSize, l, r, t, b)
				else
					GameCooltip:AddIcon([[Interface\AddOns\Details\images\classes_small_alpha]], nil, nil, iconSize, iconSize, unpack(Details.class_coords [classe]))
				end
			else
				GameCooltip:AddIcon("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, iconSize, iconSize, .25, .5, 0, 1)
			end

			local _, _, _, _, _, r, g, b = Details:GetClass(t[1])
			if (first == 0) then
				first = 0.0000000001
			end
			GameCooltip:AddStatusBar(debuff_table.damage / first * 100, 1, r, g, b, 1, false, enemies_background)
			--Details:AddTooltipBackgroundStatusbar()

		end

		GameCooltip:AddLine(" ")
		Details:AddTooltipReportLineText()

		GameCooltip:SetOption("StatusBarTexture", "Interface\\AddOns\\Details\\images\\bar_serenity")

		GameCooltip:ShowCooltip()

	end

	local function RefreshBarraVoidZone(tabela, barra, instancia)
		tabela:AtualizarVoidZone(tabela.minha_barra, barra.colocacao, instancia)
	end

	function atributo_misc:AtualizarVoidZone(whichRowLine, colocacao, instancia)
		--pega a refer�ncia da barra na janela
		local thisLine = instancia.barras[whichRowLine]

		if (not thisLine) then
			return
		end

		self._refresh_window = RefreshBarraVoidZone

		local previousData = thisLine.minha_tabela

		thisLine.minha_tabela = self

		self.minha_barra = whichRowLine
		thisLine.colocacao = colocacao

		local total = instancia.showing.totals.voidzone_damage

		local combat_time = instancia.showing:GetCombatTime()
		local dps = math.floor(self.damage / combat_time)

		local formated_damage = selectedToKFunction(_, self.damage)
		local formated_dps = selectedToKFunction(_, dps)

		local porcentagem

		if (instancia.row_info.percent_type == 1) then
			total = max(total, 0.0001)
			porcentagem = format("%.1f", self.damage / total * 100)

		elseif(instancia.row_info.percent_type == 2) then
			local top = max(instancia.top, 0.0001)
			porcentagem = format("%.1f", self.damage / top * 100)
		end

		local bars_show_data = instancia.row_info.textR_show_data
		local bars_brackets = instancia:GetBarBracket()
		local bars_separator = instancia:GetBarSeparator()

		if (not bars_show_data [1]) then
			formated_damage = ""
		end

		if (not bars_show_data [2]) then
			formated_dps = ""
		end

		if (not bars_show_data [3]) then
			porcentagem = ""
		else
			porcentagem = porcentagem .. "%"
		end

		local rightText = formated_damage .. bars_brackets[1] .. formated_dps .. bars_separator .. porcentagem .. bars_brackets[2]
		if (bUsingCustomRightText) then
			thisLine.lineText4:SetText(stringReplace(instancia.row_info.textR_custom_text, formated_damage, formated_dps, porcentagem, self, instancia.showing, instancia, rightText))
		else
			if (instancia.use_multi_fontstrings) then
				instancia:SetInLineTexts(thisLine, formated_damage, formated_dps, porcentagem)
			else
				thisLine.lineText4:SetText(rightText)
			end
		end

		thisLine.lineText1:SetText(colocacao .. ". " .. self.nome)
		thisLine.lineText1:SetSize(thisLine:GetWidth() - thisLine.lineText4:GetStringWidth() - 20, 15)

		thisLine.lineText1:SetTextColor(1, 1, 1, 1)
		thisLine.lineText4:SetTextColor(1, 1, 1, 1)

		thisLine:SetValue(100)

		if (thisLine.hidden or thisLine.fading_in or thisLine.faded) then
			Details.FadeHandler.Fader(thisLine, "out")
		end

		local _, _, icon = GetSpellInfo(self.damage_spellid)
		local spellSchoolColor = Details.spells_school[self.spellschool] and Details.spells_school[self.spellschool].decimals
		if (not spellSchoolColor) then
			spellSchoolColor = Details.spells_school[1]
		end

		Details:SetBarColors(thisLine, instancia, unpack(spellSchoolColor))

		thisLine.icone_classe:SetTexture(icon)
		thisLine.icone_classe:SetTexCoord(0.078125, 0.921875, 0.078125, 0.921875)
		thisLine.icone_classe:SetVertexColor(1, 1, 1)

		if (thisLine.mouse_over and not instancia.baseframe.isMoving) then
			local classIcon = thisLine:GetClassIcon()
			thisLine.iconHighlight:SetTexture(classIcon:GetTexture())
			thisLine.iconHighlight:SetTexCoord(classIcon:GetTexCoord())
			thisLine.iconHighlight:SetVertexColor(classIcon:GetVertexColor())
			--need call a refresh function
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--main refresh function

--~refresh
---@param instanceObject instance
---@param combatObject combat
---@param bForceUpdate boolean
---@param bExportData boolean
function damageClass:RefreshWindow(instanceObject, combatObject, bForceUpdate, bExportData)
	---@type actorcontainer
	local damageContainer = combatObject[class_type] --o que esta sendo mostrado -> [1] - dano [2] - cura --pega o container com ._NameIndexTable ._ActorTable

	--print("updating the main window")

	--not have something to show
	if (#damageContainer._ActorTable < 1) then
		if (Details.debug and false) then
			Details.showing_ActorTable_Timer = Details.showing_ActorTable_Timer or 0
			if (time() > Details.showing_ActorTable_Timer) then
				Details:Msg("(debug) nothing to show -> #showing._ActorTable < 1")
				Details.showing_ActorTable_Timer = time() + 5
			end
		end

		--colocado isso recentemente para fazer as barras de dano sumirem na troca de atributo
		return Details:HideBarsNotInUse(instanceObject, damageContainer), "", 0, 0
	end

	--total
	local total = 0
	--top actor #1
	instanceObject.top = 0

	local isUsingCache = false
	local subAttribute = instanceObject.sub_atributo
	local actorTableContent = damageContainer._ActorTable
	local amount = #actorTableContent
	local windowMode = instanceObject.modo

	--pega qual a sub key que ser� usada --sub keys
	if (bExportData) then
		if (type(bExportData) == "boolean") then
			if (subAttribute == 1) then --DAMAGE DONE
				keyName = "total"

			elseif(subAttribute == 2) then --DPS
				keyName = "last_dps"

			elseif(subAttribute == 3) then --DAMAGE TAKEN
				keyName = "damage_taken"
				if (Details.damage_taken_everything) then
					windowMode = modo_ALL
				end

			elseif(subAttribute == 4) then --FRIENDLY FIRE
				keyName = "friendlyfire_total"

			elseif(subAttribute == 5) then --FRAGS
				keyName = "frags"

			elseif(subAttribute == 6) then --ENEMIES
				keyName = "enemies"

			elseif(subAttribute == 7) then --AURAS VOIDZONES
				keyName = "voidzones"

			elseif(subAttribute == 8) then --BY SPELL
				keyName = "damage_taken_by_spells"
			end
		else
			keyName = bExportData.key
			windowMode = bExportData.modo
		end

	elseif(instanceObject.atributo == 5) then --custom
		keyName = "custom"
		total = combatObject.totals [instanceObject.customName]

	else
		if (subAttribute == 1) then --DAMAGE DONE
			keyName = "total"

		elseif(subAttribute == 2) then --DPS
			keyName = "last_dps"

		elseif(subAttribute == 3) then --DAMAGE TAKEN
			keyName = "damage_taken"
			if (Details.damage_taken_everything) then
				windowMode = modo_ALL
			end

		elseif(subAttribute == 4) then --FRIENDLY FIRE
			keyName = "friendlyfire_total"

		elseif(subAttribute == 5) then --FRAGS
			keyName = "frags"

		elseif(subAttribute == 6) then --ENEMIES
			keyName = "enemies"

		elseif(subAttribute == 7) then --AURAS VOIDZONES
			keyName = "voidzones"

		elseif(subAttribute == 8) then --BY SPELL
			keyName = "damage_taken_by_spells"
		end
	end

	if (keyName == "frags") then
		local frags = instanceObject.showing.frags
		local frags_total_kills = 0
		local index = 0

		for fragName, fragAmount in pairs(frags) do
			local fragged_actor = damageContainer._NameIndexTable [fragName] --get index
			if (fragged_actor) then
				fragged_actor = damageContainer._ActorTable [fragged_actor] --get object
				if (fragged_actor) then
					index = index + 1
					local actor_classe = fragged_actor.classe

					if (fragged_actor and fragged_actor.monster) then
						actor_classe = "ENEMY"
					elseif(not actor_classe) then
						actor_classe = "UNGROUPPLAYER"
					end

					if (ntable [index]) then
						ntable [index] [1] = fragName
						ntable [index] [2] = fragAmount
						ntable [index] [3] = actor_classe
					else
						ntable [index] = {fragName, fragAmount, actor_classe}
					end

					frags_total_kills = frags_total_kills + fragAmount
				end
			end
		end

		local tsize = #ntable
		if (index < tsize) then
			for i = index+1, tsize do
				ntable [i][2] = 0
			end
		end

		instanceObject.top = 0
		if (tsize > 0) then
			table.sort(ntable, Details.Sort2)
			instanceObject.top = ntable [1][2]
		end

		total = index

		if (bExportData) then
			local export = {}
			for i = 1, index do
				export [i] = {ntable[i][1], ntable[i][2], ntable[i][3]}
			end
			return export
		end

		if (total < 1) then
			instanceObject:EsconderScrollBar()
			return Details:EndRefresh(instanceObject, total, combatObject, damageContainer) --retorna a tabela que precisa ganhar o refresh
		end

		combatObject.totals.frags_total = frags_total_kills

		instanceObject:RefreshScrollBar(total)

		local whichRowLine = 1
		local lineContainer = instanceObject.barras

		for i = instanceObject.barraS[1], instanceObject.barraS[2], 1 do
			damageClass:AtualizarFrags(ntable[i], whichRowLine, i, instanceObject)
			whichRowLine = whichRowLine+1
		end

		return Details:EndRefresh(instanceObject, total, combatObject, damageContainer) --retorna a tabela que precisa ganhar o refresh

	elseif(keyName == "damage_taken_by_spells") then
		local bs_index, total = 0, 0
		Details:Destroy(bs_index_table)

		local combat = combatObject
		local AllDamageCharacters = combat:GetActorList(DETAILS_ATTRIBUTE_DAMAGE)

		--do a loop amoung the actors
		for index, character in ipairs(AllDamageCharacters) do

			--is the actor a player?
			if (character:IsPlayer()) then

				for source_name, _ in pairs(character.damage_from) do

					local source = combat(1, source_name)

					if (source) then
						--came from an enemy
						if (not source:IsPlayer()) then

							local AllSpells = source:GetSpellList()
							for spellid, spell in pairs(AllSpells) do
								local on_player = spell.targets [character.nome]

								if (on_player and on_player >= 1) then

									local spellname = _GetSpellInfo(spellid)
									if (spellname) then
										local has_index = bs_index_table [spellname]
										local this_spell
										if (has_index) then
											this_spell = bs_table [has_index]
										else
											bs_index = bs_index + 1
											this_spell = bs_table [bs_index]
											if (this_spell) then
												this_spell [1] = spellid
												this_spell [2] = 0
												this_spell [3] = spell.spellschool or Details.spell_school_cache [select(1, GetSpellInfo(spellid))] or 1
												bs_index_table [spellname] = bs_index
											else
												this_spell = {spellid, 0, spell.spellschool or Details.spell_school_cache [select(1, GetSpellInfo(spellid))] or 1}
												bs_table [bs_index] = this_spell
												bs_index_table [spellname] = bs_index
											end
										end
										this_spell [2] = this_spell [2] + on_player
										total = total + on_player
									else
										error("error - no spell id for DTBS " .. spellid)
									end
								end
							end

						elseif(source:IsGroupPlayer()) then -- friendly fire

							local AllSpells = source.friendlyfire [character.nome] and source.friendlyfire [character.nome].spells
							if (AllSpells) then -- se n�o existir pode ter vindo de um pet, talvez
								for spellid, on_player in pairs(AllSpells) do
									if (on_player and on_player >= 1) then

										local spellname = _GetSpellInfo(spellid)
										if (spellname) then
											local has_index = bs_index_table [spellname]
											local this_spell
											if (has_index) then
												this_spell = bs_table [has_index]
											else
												bs_index = bs_index + 1
												this_spell = bs_table [bs_index]
												if (this_spell) then
													this_spell [1] = spellid
													this_spell [2] = 0
													this_spell [3] = Details.spell_school_cache [select(1, GetSpellInfo(spellid))] or 1
													bs_index_table [spellname] = bs_index
												else
													this_spell = {spellid, 0, Details.spell_school_cache [select(1, GetSpellInfo(spellid))] or 1}
													bs_table [bs_index] = this_spell
													bs_index_table [spellname] = bs_index
												end
											end
											this_spell [2] = this_spell [2] + on_player
											total = total + on_player
										else
											--error("error - no spell id for DTBS friendly fire " .. spellid)
										end
									end
								end
							end
						end
					end
				end
			end
		end

		local tsize = #bs_table
		if (bs_index < tsize) then
			for i = bs_index+1, tsize do
				bs_table [i][2] = 0
			end
		end

		instanceObject.top = 0
		if (tsize > 0) then
			table.sort(bs_table, Details.Sort2)
			instanceObject.top = bs_table [1][2]
		end

		local total2 = bs_index

		if (bExportData) then
			local export = {}
			for i = 1, bs_index do
				-- spellid, total, spellschool
				export [i] = {spellid = bs_table[i][1], damage = bs_table[i][2], spellschool = bs_table[i][3]}
			end
			return total, "damage", instanceObject.top, bs_index, export
		end

		if (bs_index < 1) then
			instanceObject:EsconderScrollBar()
			return Details:EndRefresh(instanceObject, bs_index, combatObject, damageContainer) --retorna a tabela que precisa ganhar o refresh
		end

		combatObject.totals.by_spell = total

		instanceObject:RefreshScrollBar(bs_index)

		local whichRowLine = 1
		local lineContainer = instanceObject.barras

		for i = instanceObject.barraS[1], instanceObject.barraS[2], 1 do
			damageClass:AtualizarBySpell(bs_table[i], whichRowLine, i, instanceObject)
			whichRowLine = whichRowLine+1
		end

		return Details:EndRefresh(instanceObject, bs_index, combatObject, damageContainer)

	elseif(keyName == "voidzones") then
		local index = 0
		local misc_container = combatObject [4]
		local voidzone_damage_total = 0

		for _, actor in ipairs(misc_container._ActorTable) do
			if (actor.boss_debuff) then
				index = index + 1

				--pega no container de dano o actor respons�vel por aplicar o debuff
				local twin_damage_actor = damageContainer._NameIndexTable [actor.damage_twin] or damageContainer._NameIndexTable ["[*] " .. actor.damage_twin]

				if (twin_damage_actor) then
					local index = twin_damage_actor
					twin_damage_actor = damageContainer._ActorTable [twin_damage_actor]

					local spell = twin_damage_actor.spells._ActorTable [actor.damage_spellid]

					if (spell) then

						--fix spell, sometimes there is two spells with the same name, one is the cast and other is the debuff
						if (spell.total == 0 and not actor.damage_spellid_fixed) then
							local curname = _GetSpellInfo(actor.damage_spellid)
							for spellid, spelltable in pairs(twin_damage_actor.spells._ActorTable) do
								if (spelltable.total > spell.total) then
									local name = _GetSpellInfo(spellid)
									if (name == curname) then
										actor.damage_spellid = spellid
										spell = spelltable
									end
								end
							end
							actor.damage_spellid_fixed = true
						end

						actor.damage = spell.total
						voidzone_damage_total = voidzone_damage_total + spell.total

					elseif(not actor.damage_spellid_fixed) then --not
						--fix spell, if the spellid passed for debuff uptime is actully the spell id of a ability and not if the aura it self
						actor.damage_spellid_fixed = true
						local found = false
						for spellid, spelltable in pairs(twin_damage_actor.spells._ActorTable) do
							local name = _GetSpellInfo(spellid)
							if (actor.damage_twin:find(name)) then
								actor.damage = spelltable.total
								voidzone_damage_total = voidzone_damage_total + spelltable.total
								actor.damage_spellid = spellid
								found = true
								break
							end
						end

						if (not found) then
							actor.damage = 0
						end
					else
						actor.damage = 0
					end
				else
					actor.damage = 0
				end

				vtable [index] = actor
			end
		end

		local tsize = #vtable
		if (index < tsize) then
			for i = index+1, tsize do
				vtable [i] = nil
			end
		end

		if (tsize > 0 and vtable[1]) then
			table.sort(vtable, void_zone_sort)
			instanceObject.top = vtable [1].damage
		end
		total = index

		if (bExportData) then
			for _, t in ipairs(vtable) do
				t.report_name = Details:GetSpellLink(t.damage_spellid)
			end
			return voidzone_damage_total, "damage", instanceObject.top, total, vtable, "report_name"
		end

		if (total < 1) then
			instanceObject:EsconderScrollBar()
			return Details:EndRefresh(instanceObject, total, combatObject, damageContainer) --retorna a tabela que precisa ganhar o refresh
		end

		combatObject.totals.voidzone_damage = voidzone_damage_total

		instanceObject:RefreshScrollBar(total)

		local whichRowLine = 1
		local lineContainer = instanceObject.barras

		for i = instanceObject.barraS[1], instanceObject.barraS[2], 1 do
			vtable[i]:AtualizarVoidZone(whichRowLine, i, instanceObject)
			whichRowLine = whichRowLine+1
		end

		return Details:EndRefresh(instanceObject, total, combatObject, damageContainer) --retorna a tabela que precisa ganhar o refresh

	else
	--/run Details:Dump(Details:GetCurrentCombat():GetActor(1, "Injured Steelspine 1"))
		if (keyName == "enemies") then
			amount, total = Details:ContainerSortEnemies(actorTableContent, amount, "damage_taken")

			--remove actors with zero damage taken
			local newAmount = 0
			for i = 1, #actorTableContent do
				if (actorTableContent[i].damage_taken < 1) then
					newAmount = i-1
					break
				end
			end

			--if all units shown are enemies and all have damage taken, check if newAmount is zero and #conteudo has value bigger than 0
			if (newAmount == 0 and #actorTableContent > 0) then
				amount = amount
			else
				amount = newAmount
			end

			--keyName = "damage_taken"
			--result of the first actor
			instanceObject.top = actorTableContent[1] and actorTableContent[1][keyName]

		elseif(windowMode == DETAILS_MODE_ALL) then --mostrando ALL
			--faz o sort da categoria e retorna o amount corrigido
			if (subAttribute == 2) then
				local combat_time = instanceObject.showing:GetCombatTime()
				total = damageClass:ContainerRefreshDps(actorTableContent, combat_time)
			else
				--pega o total ja aplicado na tabela do combate
				total = combatObject.totals[class_type]
			end

			amount = Details:ContainerSort(actorTableContent, amount, keyName)

			--grava o total
			instanceObject.top = actorTableContent[1][keyName]

		elseif(windowMode == DETAILS_MODE_GROUP) then --mostrando GROUP
			if (Details.in_combat and instanceObject.segmento == 0 and not bExportData) then
				isUsingCache = true
			end

			if (isUsingCache) then
				actorTableContent = Details.cache_damage_group

				if (#actorTableContent < 1) then
					if (Details.debug and false) then
						Details.showing_ActorTable_Timer2 = Details.showing_ActorTable_Timer2 or 0
						if (time() > Details.showing_ActorTable_Timer2) then
							Details:Msg("(debug) nothing to show -> #conteudo < 1(using cache)")
							Details.showing_ActorTable_Timer2 = time()+5
						end
					end

					return Details:HideBarsNotInUse(instanceObject, damageContainer), "", 0, 0
				end

				local bOrderDpsByRealTime = Details.CurrentDps.CanSortByRealTimeDps()

				if (subAttribute == 2) then --dps
					local combatTime = combatObject:GetCombatTime()
					local realTimeTotal = 0
					total, realTimeTotal = damageClass:ContainerRefreshDps(actorTableContent, combatTime)

					if (bOrderDpsByRealTime) then
						total = realTimeTotal
					end

				elseif(subAttribute == 1) then --damage done
					if (bOrderDpsByRealTime) then
						total = damageClass:RefreshDpsRealTime(actorTableContent)
					end
				end

				if (bOrderDpsByRealTime) then
					table.sort(actorTableContent, Details.SortByRealTimeDps)

					if (actorTableContent[1]["last_dps_realtime"] < 1) then
						amount = 0
					else
						instanceObject.top = actorTableContent[1].last_dps_realtime
						amount = #actorTableContent
					end
				else
					table.sort(actorTableContent, Details.SortKeySimple)
					if (actorTableContent[1][keyName] < 1) then
						amount = 0
					else
						instanceObject.top = actorTableContent[1][keyName]
						amount = #actorTableContent
					end

					if (subAttribute ~= 2) then --other than dps because dps already did the iteration and the total is already calculated
						for i = 1, amount do
							total = total + actorTableContent[i][keyName]
						end
					end
				end
			else
				if (subAttribute == 2) then --dps
					local combatTime = combatObject:GetCombatTime()
					damageClass:ContainerRefreshDps(actorTableContent, combatTime)
				end
				table.sort(actorTableContent, Details.SortKeyGroup)
			end

			--
			if (not isUsingCache) then
				for index, player in ipairs(actorTableContent) do
					if (player.grupo) then --� um player e esta em grupo
						if (player[keyName] < 1) then --dano menor que 1, interromper o loop
							amount = index - 1
							break
						end

						total = total + player[keyName]
					else
						amount = index-1
						break
					end
				end

				instanceObject.top = actorTableContent[1] and actorTableContent[1][keyName]
			end

		end
	end

	--refaz o mapa do container
	if (not isUsingCache) then
		damageContainer:remapear()
	end

	if (bExportData) then
		return total, keyName, instanceObject.top, amount
	end

	if (amount < 1) then --n�o h� barras para mostrar
		if (bForceUpdate) then
			if (instanceObject.modo == 2) then --group
				for i = 1, instanceObject.rows_fit_in_window  do
					Details.FadeHandler.Fader(instanceObject.barras [i], "in", Details.fade_speed)
				end
			end
		end
		instanceObject:EsconderScrollBar() --precisaria esconder a scroll bar

		if (Details.debug and false) then
			Details.showing_ActorTable_Timer2 = Details.showing_ActorTable_Timer2 or 0
			if (time() > Details.showing_ActorTable_Timer2) then
				Details:Msg("(debug) nothing to show -> amount < 1")
				Details.showing_ActorTable_Timer2 = time()+5
			end
		end

		return Details:EndRefresh(instanceObject, total, combatObject, damageContainer) --retorna a tabela que precisa ganhar o refresh
	end

	instanceObject:RefreshScrollBar(amount)

	local whichRowLine = 1
	local lineContainer = instanceObject.barras
	local percentageType = instanceObject.row_info.percent_type
	local barsShowData = instanceObject.row_info.textR_show_data
	local barsBrackets = instanceObject:GetBarBracket()
	local barsSeparator = instanceObject:GetBarSeparator()
	local baseframe = instanceObject.baseframe
	local useAnimations = Details.is_using_row_animations and(not baseframe.isStretching and not bForceUpdate and not baseframe.isResizing)

	if (total == 0) then
		total = 0.00000001
	end

	local myPos
	local following = instanceObject.following.enabled and subAttribute ~= 6

	if (following) then
		if (isUsingCache) then
			local pname = Details.playername
			for i, actor in ipairs(actorTableContent) do
				if (actor.nome == pname) then
					myPos = i
					break
				end
			end
		else
			myPos = damageContainer._NameIndexTable [Details.playername]
		end
	end

	local combatTime = instanceObject.showing:GetCombatTime()
	bUsingCustomLeftText = instanceObject.row_info.textL_enable_custom_text
	bUsingCustomRightText = instanceObject.row_info.textR_enable_custom_text

	local useTotalBar = false
	if (instanceObject.total_bar.enabled) then
		useTotalBar = true

		if (instanceObject.total_bar.only_in_group and(not IsInGroup() and not IsInRaid())) then
			useTotalBar = false
		end

		if (subAttribute > 4) then --enemies, frags, void zones
			useTotalBar = false
		end
	end

	if (subAttribute == 2) then --dps
		instanceObject.player_top_dps = actorTableContent [1].last_dps
		instanceObject.player_top_dps_threshold = instanceObject.player_top_dps -(instanceObject.player_top_dps * 0.65)
	end

	local totalBarIsShown

	if (instanceObject.bars_sort_direction == 1) then --top to bottom
		if (useTotalBar and instanceObject.barraS[1] == 1) then
			whichRowLine = 2
			local iterLast = instanceObject.barraS[2]
			if (iterLast == instanceObject.rows_fit_in_window) then
				iterLast = iterLast - 1
			end

			local row1 = lineContainer [1]
			row1.minha_tabela = nil
			row1.lineText1:SetText(Loc ["STRING_TOTAL"])

			if (instanceObject.use_multi_fontstrings) then
				row1.lineText2:SetText("")
				row1.lineText3:SetText(Details:ToK2(total))
				row1.lineText4:SetText(Details:ToK(total / combatTime))
			else
				row1.lineText4:SetText(Details:ToK2(total) .. "(" .. Details:ToK(total / combatTime) .. ")")
			end

			row1:SetValue(100)
			local r, g, b = unpack(instanceObject.total_bar.color)
			row1.textura:SetVertexColor(r, g, b)
			row1.icone_classe:SetTexture(instanceObject.total_bar.icon)
			row1.icone_classe:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)

			Details.FadeHandler.Fader(row1, "out")
			totalBarIsShown = true

			if (following and myPos and myPos+1 > instanceObject.rows_fit_in_window and instanceObject.barraS[2] < myPos+1) then
				for i = instanceObject.barraS[1], iterLast-1, 1 do
					if (actorTableContent[i]) then
						actorTableContent[i]:RefreshLine(instanceObject, lineContainer, whichRowLine, i, total, subAttribute, bForceUpdate, keyName, combatTime, percentageType, useAnimations, barsShowData, barsBrackets, barsSeparator)
						whichRowLine = whichRowLine+1
					end
				end
				actorTableContent[myPos]:RefreshLine(instanceObject, lineContainer, whichRowLine, myPos, total, subAttribute, bForceUpdate, keyName, combatTime, percentageType, useAnimations, barsShowData, barsBrackets, barsSeparator)
				whichRowLine = whichRowLine+1
			else
				for i = instanceObject.barraS[1], iterLast, 1 do
					if (actorTableContent[i]) then
						actorTableContent[i]:RefreshLine(instanceObject, lineContainer, whichRowLine, i, total, subAttribute, bForceUpdate, keyName, combatTime, percentageType, useAnimations, barsShowData, barsBrackets, barsSeparator)
						whichRowLine = whichRowLine+1
					end
				end
			end

		else
			if (following and myPos and myPos > instanceObject.rows_fit_in_window and instanceObject.barraS[2] < myPos) then
				for i = instanceObject.barraS[1], instanceObject.barraS[2]-1, 1 do
					if (actorTableContent[i]) then
						actorTableContent[i]:RefreshLine(instanceObject, lineContainer, whichRowLine, i, total, subAttribute, bForceUpdate, keyName, combatTime, percentageType, useAnimations, barsShowData, barsBrackets, barsSeparator)
						whichRowLine = whichRowLine+1
					end
				end

				actorTableContent[myPos]:RefreshLine(instanceObject, lineContainer, whichRowLine, myPos, total, subAttribute, bForceUpdate, keyName, combatTime, percentageType, useAnimations, barsShowData, barsBrackets, barsSeparator)
				whichRowLine = whichRowLine+1
			else
				for i = instanceObject.barraS[1], instanceObject.barraS[2], 1 do
					if (actorTableContent[i]) then

						actorTableContent[i]:RefreshLine(instanceObject, lineContainer, whichRowLine, i, total, subAttribute, bForceUpdate, keyName, combatTime, percentageType, useAnimations, barsShowData, barsBrackets, barsSeparator)
						whichRowLine = whichRowLine+1
					end
				end
			end
		end

	elseif(instanceObject.bars_sort_direction == 2) then --bottom to top
		if (useTotalBar and instanceObject.barraS[1] == 1) then
			whichRowLine = 2
			local iter_last = instanceObject.barraS[2]
			if (iter_last == instanceObject.rows_fit_in_window) then
				iter_last = iter_last - 1
			end

			local row1 = lineContainer [1]
			row1.minha_tabela = nil
			row1.lineText1:SetText(Loc ["STRING_TOTAL"])

			if (instanceObject.use_multi_fontstrings) then
				row1.lineText2:SetText("")
				row1.lineText3:SetText(Details:ToK2(total))
				row1.lineText4:SetText(Details:ToK(total / combatTime))
			else
				row1.lineText4:SetText(Details:ToK2(total) .. "(" .. Details:ToK(total / combatTime) .. ")")
			end

			row1:SetValue(100)
			local r, g, b = unpack(instanceObject.total_bar.color)
			row1.textura:SetVertexColor(r, g, b)

			row1.icone_classe:SetTexture(instanceObject.total_bar.icon)
			row1.icone_classe:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)

			Details.FadeHandler.Fader(row1, "out")
			totalBarIsShown = true

			if (following and myPos and myPos+1 > instanceObject.rows_fit_in_window and instanceObject.barraS[2] < myPos+1) then
				actorTableContent[myPos]:RefreshLine(instanceObject, lineContainer, whichRowLine, myPos, total, subAttribute, bForceUpdate, keyName, combatTime, percentageType, useAnimations, barsShowData, barsBrackets, barsSeparator)
				whichRowLine = whichRowLine+1
				for i = iter_last-1, instanceObject.barraS[1], -1 do
					if (actorTableContent[i]) then
						actorTableContent[i]:RefreshLine(instanceObject, lineContainer, whichRowLine, i, total, subAttribute, bForceUpdate, keyName, combatTime, percentageType, useAnimations, barsShowData, barsBrackets, barsSeparator)
						whichRowLine = whichRowLine+1
					end
				end
			else
				for i = iter_last, instanceObject.barraS[1], -1 do
					if (actorTableContent[i]) then
						actorTableContent[i]:RefreshLine(instanceObject, lineContainer, whichRowLine, i, total, subAttribute, bForceUpdate, keyName, combatTime, percentageType, useAnimations, barsShowData, barsBrackets, barsSeparator)
						whichRowLine = whichRowLine+1
					end
				end
			end
		else
			if (following and myPos and myPos > instanceObject.rows_fit_in_window and instanceObject.barraS[2] < myPos) then
				actorTableContent[myPos]:RefreshLine(instanceObject, lineContainer, whichRowLine, myPos, total, subAttribute, bForceUpdate, keyName, combatTime, percentageType, useAnimations, barsShowData, barsBrackets, barsSeparator)
				whichRowLine = whichRowLine+1
				for i = instanceObject.barraS[2]-1, instanceObject.barraS[1], -1 do
					if (actorTableContent[i]) then
						actorTableContent[i]:RefreshLine(instanceObject, lineContainer, whichRowLine, i, total, subAttribute, bForceUpdate, keyName, combatTime, percentageType, useAnimations, barsShowData, barsBrackets, barsSeparator)
						whichRowLine = whichRowLine+1
					end
				end
			else
				for i = instanceObject.barraS[2], instanceObject.barraS[1], -1 do
					if (actorTableContent[i]) then
						actorTableContent[i]:RefreshLine(instanceObject, lineContainer, whichRowLine, i, total, subAttribute, bForceUpdate, keyName, combatTime, percentageType, useAnimations, barsShowData, barsBrackets, barsSeparator)
						whichRowLine = whichRowLine+1
					end
				end
			end
		end

	end

	if (totalBarIsShown) then
		instanceObject:RefreshScrollBar(amount + 1)
	else
		instanceObject:RefreshScrollBar(amount)
	end

	if (useAnimations) then
		instanceObject:PerformAnimations(whichRowLine - 1)
	end

	--beta, hidar barras n�o usadas durante um refresh for�ado
	if (bForceUpdate) then
		if (instanceObject.modo == 2) then --group
			for i = whichRowLine, instanceObject.rows_fit_in_window  do
				Details.FadeHandler.Fader(instanceObject.barras [i], "in", Details.fade_speed)
			end
		end
	end

	Details.LastFullDamageUpdate = Details._tempo

	instanceObject:AutoAlignInLineFontStrings()

	return Details:EndRefresh(instanceObject, total, combatObject, damageContainer) --retorna a tabela que precisa ganhar o refresh
end

--self is instance
function Details:AutoAlignInLineFontStrings()
	--if this instance is using in line texts, check the min distance and the length of strings to make them more spread appart
	if (self.use_multi_fontstrings and self.use_auto_align_multi_fontstrings) then
		local maxStringLength_StringFour = 0
		local maxStringLength_StringThree = 0
		local profileOffsetString3 = self.fontstrings_text3_anchor
		local profileOffsetString2 = self.fontstrings_text2_anchor
		local profileYOffset = self.row_info.text_yoffset

		Details.CacheInLineMaxDistance = Details.CacheInLineMaxDistance or {}
		Details.CacheInLineMaxDistance[self:GetId()] = Details.CacheInLineMaxDistance[self:GetId()] or {[2] = profileOffsetString2, [3] = profileOffsetString3}

		--space between string4 and string3(usually dps is 4 and total value is 3)
		for lineId = 1, self:GetNumLinesShown() do
			local thisLine = self:GetLine(lineId)
			if (thisLine) then
				--check strings 3 and 4
				if (thisLine.lineText4:GetText() ~= "" and thisLine.lineText3:GetText() ~= "") then
					--the length of the far right string determines the space between it and the next string in the left
					local stringLength = thisLine.lineText4:GetStringWidth()
					maxStringLength_StringFour = stringLength > maxStringLength_StringFour and stringLength or maxStringLength_StringFour
				end

				--check strings 2 and 3
				if (thisLine.lineText2:GetText() ~= "" and thisLine.lineText3:GetText() ~= "") then
					--the length of the middle string determines the space between it and the next string in the left
					local stringLength = thisLine.lineText3:GetStringWidth()
					maxStringLength_StringThree = stringLength > maxStringLength_StringThree and stringLength or maxStringLength_StringThree
				end
			end
		end

		--if the length bigger than the min distance? calculate for string4 to string3 distance
		if ((maxStringLength_StringFour > 0) and(maxStringLength_StringFour + 5 > profileOffsetString3)) then
			local newOffset = maxStringLength_StringFour + 5

			--check if the current needed min distance is bigger than the distance stored in the cache
			local currentCacheMaxValue = Details.CacheInLineMaxDistance[self:GetId()][3]
			if (currentCacheMaxValue < newOffset) then
				currentCacheMaxValue = newOffset
				Details.CacheInLineMaxDistance[self:GetId()][3] = currentCacheMaxValue
			else
				--if not, use the distance value cached to avoid jittering in the string
				newOffset = currentCacheMaxValue
			end

			--update the lines
			for lineId = 1, self:GetNumLinesShown() do
				local thisLine = self:GetLine(lineId)
				if (thisLine) then
					thisLine.lineText3:SetPoint("right", thisLine.statusbar, "right", -newOffset, profileYOffset)
				end
			end
		end

		--check if there's length in the third string, also the third string cannot have a length if the second string is empty
		if (maxStringLength_StringThree > 0) then
			local newOffset = maxStringLength_StringThree + maxStringLength_StringFour + 14
			if (newOffset >= profileOffsetString2) then
				--check if the current needed min distance is bigger than the distance stored in the cache
				local currentCacheMaxValue = Details.CacheInLineMaxDistance[self:GetId()][2]
				if (currentCacheMaxValue < newOffset) then
					currentCacheMaxValue = newOffset
					Details.CacheInLineMaxDistance[self:GetId()][2] = currentCacheMaxValue
				else
					--if not, use the distance value cached to avoid jittering in the string
					newOffset = currentCacheMaxValue
				end

				--update the lines
				for lineId = 1, self:GetNumLinesShown() do
					local thisLine = self:GetLine(lineId)
					if (thisLine) then
						thisLine.lineText2:SetPoint("right", thisLine.statusbar, "right", -newOffset, profileYOffset)
					end
				end
			end
		end

		--reduce the size of the actor name string based on the total size of all strings in the right side
		for lineId = 1, self:GetNumLinesShown() do
			local thisLine = self:GetLine(lineId)

			--check if there's something showing in this line
			--check if the line is shown and if the text exists for sanitization
			if (thisLine and thisLine.minha_tabela and thisLine:IsShown() and thisLine.lineText1:GetText()) then
				local playerNameFontString = thisLine.lineText1
				local text2 = thisLine.lineText2
				local text3 = thisLine.lineText3
				local text4 = thisLine.lineText4

				local totalWidth = text2:GetStringWidth() + text3:GetStringWidth() + text4:GetStringWidth()
				totalWidth = totalWidth + 40 - self.fontstrings_text_limit_offset

				DetailsFramework:TruncateTextSafe(playerNameFontString, self.cached_bar_width - totalWidth) --this avoid truncated strings with ...

				--these commented lines are for to create a cache and store the name already truncated there to safe performance
				--local truncatedName = playerNameFontString:GetText()
				--local actorObject = thisLine.minha_tabela
				--actorObject.name_cached = truncatedName
				--actorObject.name_cached_time = GetTime()
			end
		end
	end
end

--handle internal details! events
local eventListener = Details:CreateEventListener()
eventListener:RegisterEvent("COMBAT_PLAYER_ENTER", function(eventName, combatObject)
	if (Details.CacheInLineMaxDistance) then
		Details:Destroy(Details.CacheInLineMaxDistance)

		for i = 1, 10 do
			C_Timer.After(i, function()
				Details:Destroy(Details.CacheInLineMaxDistance)
			end)
		end
	end
end)

local classColor_Red, classColor_Green, classColor_Blue

-- ~texts
--[[exported]] function Details:SetInLineTexts(thisLine, valueText, perSecondText, percentText)
	--set defaults
	local instance = self
	valueText = valueText or ""
	perSecondText = perSecondText or ""
	percentText = percentText or ""

	if ((Details.use_realtimedps or(Details.combat_log.evoker_show_realtimedps and Details.playerspecid == 1473)) and Details.in_combat) then --real time
		if (thisLine:GetActor()) then
			local actorSerial = thisLine:GetActor().serial
			local currentDps = Details.CurrentDps.GetCurrentDps(actorSerial)
			if (currentDps and currentDps > 0) then
				currentDps = Details:ToK2(currentDps)
			end
			perSecondText = currentDps
		end
	end

	--check if the instance is showing total, dps and percent
	local instanceSettings = instance.row_info
	if (not instanceSettings.textR_show_data[3]) then --percent text disabled on options panel
		local attributeId = instance:GetDisplay()
		if (attributeId ~= 5) then --not custom
			percentText = ""
		end
	end

	--parse information
	if (percentText ~= "") then --has percent text
		thisLine.lineText4:SetText(percentText)

		if (perSecondText ~= "") then --has dps?
			thisLine.lineText3:SetText(perSecondText) --set dps
			thisLine.lineText2:SetText(valueText) --set amount
		else
			thisLine.lineText3:SetText(valueText) --set amount
			thisLine.lineText2:SetText("") --clear
		end
	else --no percent text
		if (perSecondText ~= "") then --has dps and no percent
			thisLine.lineText4:SetText(perSecondText) --set dps
			thisLine.lineText3:SetText(valueText) --set amount
			thisLine.lineText2:SetText("") --clear
		else --no dps and not percent
			thisLine.lineText4:SetText(valueText) --set dps
			thisLine.lineText3:SetText("") --clear
			thisLine.lineText2:SetText("") --clear
		end
	end
end

-- ~atualizar ~barra ~update
function damageClass:RefreshLine(instanceObject, lineContainer, whichRowLine, rank, total, subAttribute, bForceRefresh, keyName, combatTime, percentageType, bUseAnimations, bars_show_data, bars_brackets, bars_separator)
	local thisLine = lineContainer[whichRowLine]

	if (not thisLine) then
		print("DEBUG: problema com <instance.thisLine> "..whichRowLine.." "..rank)
		return
	end

	local previousData = thisLine.minha_tabela
	thisLine.minha_tabela = self --store references
	self.minha_barra = thisLine --store references

	thisLine.colocacao = rank
	self.colocacao = rank

	local damageTotal = self.total --total damage of this actor
	local dps
	local percentString
	local percentNumber

	--calc the percent amount base on the percent type
	if (percentageType == 1) then
		percentString = format("%.1f", self[keyName] / total * 100)

	elseif(percentageType == 2) then
		percentString = format("%.1f", self[keyName] / instanceObject.top * 100)
	end

	local currentCombat = instanceObject:GetCombat()

	if (currentCombat:GetCombatType() == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
		if (Details.mythic_plus.mythicrun_time_type == 1) then
			--total time in combat, activity time
			combatTime = currentCombat:GetCombatTime()
		elseif(Details.mythic_plus.mythicrun_time_type == 2) then
			--elapsed time of the run
			combatTime = currentCombat:GetRunTime()
		end

		dps = damageTotal / combatTime
		self.last_dps = dps
	else
		--calculate the actor dps
		if ((Details.time_type == 2 and self.grupo) or not Details:CaptureGet("damage") or instanceObject.segmento == -1 or Details.use_realtimedps) then
			if (Details.use_realtimedps and Details.in_combat) then
				local currentDps = self.last_dps_realtime
				if (currentDps) then
					dps = currentDps
				end
			end

			if (not dps) then
				if (instanceObject.segmento == -1 and combatTime == 0) then
					local actor = currentCombat(1, self.nome)
					if (actor) then
						local combatTime = actor:Tempo()
						dps = damageTotal / combatTime
						self.last_dps = dps
					else
						dps = damageTotal / combatTime
						self.last_dps = dps
					end
				else
					dps = damageTotal / combatTime
					self.last_dps = dps
				end
			end
		else
			if (not self.on_hold) then
				dps = damageTotal/self:Tempo() --calcula o dps deste objeto
				self.last_dps = dps --salva o dps dele
			else
				if (self.last_dps == 0) then --n�o calculou o dps dele ainda mas entrou em standby
					dps = damageTotal/self:Tempo()
					self.last_dps = dps
				else
					dps = self.last_dps
				end
			end
		end
	end

	--right text
	if (subAttribute == 1) then --damage done
		dps = math.floor(dps)
		local formatedDamage = selectedToKFunction(_, damageTotal)
		local formatedDps = selectedToKFunction(_, dps)
		thisLine.ps_text = formatedDps

		if (not bars_show_data[1]) then
			formatedDamage = ""
		end

		if (not bars_show_data[2]) then
			formatedDps = ""
		end

		if (not bars_show_data[3]) then
			percentString = ""
		else
			percentString = percentString .. "%"
		end

		local rightText = formatedDamage .. bars_brackets[1] .. formatedDps .. bars_separator .. percentString .. bars_brackets[2]

		if (bUsingCustomRightText) then
			thisLine.lineText4:SetText(stringReplace(instanceObject.row_info.textR_custom_text, formatedDamage, formatedDps, percentString, self, instanceObject.showing, instanceObject, rightText))
		else
			if (instanceObject.use_multi_fontstrings) then
				instanceObject:SetInLineTexts(thisLine, formatedDamage, formatedDps, percentString)
			else
				thisLine.lineText4:SetText(rightText)
			end
		end

		if (Details.CurrentDps.CanSortByRealTimeDps()) then
			percentNumber = math.floor((self.last_dps_realtime / instanceObject.top) * 100)
		else
			percentNumber = math.floor((damageTotal/instanceObject.top) * 100)
		end

	elseif(subAttribute == 2) then --dps
		local raw_dps = dps
		dps = math.floor(dps)

		local formated_damage = selectedToKFunction(_, damageTotal)
		local formated_dps = selectedToKFunction(_, dps)
		thisLine.ps_text = formated_dps

		local diff_from_topdps

		if (rank > 1) then
			diff_from_topdps = instanceObject.player_top_dps - raw_dps
		end

		local rightText
		if (diff_from_topdps) then
			local threshold = diff_from_topdps / instanceObject.player_top_dps_threshold * 100
			if (threshold < 100) then
				threshold = abs(threshold - 100)
			else
				threshold = 5
			end

			local rr, gg, bb = Details:percent_color( threshold )

			rr, gg, bb = Details:hex(math.floor(rr*255)), Details:hex(math.floor(gg*255)), "28"
			local color_percent = "" .. rr .. gg .. bb .. ""

			if (not bars_show_data [1]) then
				formated_dps = ""
			end
			if (not bars_show_data [2]) then
				color_percent = ""
			else
				color_percent = bars_brackets[1] .. "|cFFFF4444-|r|cFF" .. color_percent .. selectedToKFunction(_, math.floor(diff_from_topdps)) .. "|r" .. bars_brackets[2]
			end

			rightText = formated_dps .. color_percent

		else
			local icon = "  |TInterface\\GROUPFRAME\\UI-Group-LeaderIcon:14:14:0:0:16:16:0:16:0:16|t "
			if (not bars_show_data [1]) then
				formated_dps = ""
			end
			if (not bars_show_data [2]) then
				icon = ""
			end

			rightText = formated_dps .. icon
		end

		if (bUsingCustomRightText) then
			thisLine.lineText4:SetText(stringReplace(instanceObject.row_info.textR_custom_text, formated_dps, formated_damage, percentString, self, instanceObject.showing, instanceObject, rightText))
		else
			if (instanceObject.use_multi_fontstrings) then
				--instance:SetInLineTexts(thisLine, formated_damage, formated_dps, porcentagem)
				instanceObject:SetInLineTexts(thisLine, rightText)
			else
				thisLine.lineText4:SetText(rightText)
			end
		end

		percentNumber = math.floor((dps/instanceObject.top) * 100)

	elseif(subAttribute == 3) then --damage taken
		local dtps = self.damage_taken / combatTime

		local formated_damage_taken = selectedToKFunction(_, self.damage_taken)
		local formated_dtps = selectedToKFunction(_, dtps)
		thisLine.ps_text = formated_dtps

		if (not bars_show_data [1]) then
			formated_damage_taken = ""
		end
		if (not bars_show_data [2]) then
			formated_dtps = ""
		end
		if (not bars_show_data [3]) then
			percentString = ""
		else
			percentString = percentString .. "%"
		end

		local rightText = formated_damage_taken .. bars_brackets[1] .. formated_dtps .. bars_separator .. percentString .. bars_brackets[2]
		if (bUsingCustomRightText) then
			thisLine.lineText4:SetText(stringReplace(instanceObject.row_info.textR_custom_text, formated_damage_taken, formated_dtps, percentString, self, instanceObject.showing, instanceObject, rightText))
		else
			if (instanceObject.use_multi_fontstrings) then
				instanceObject:SetInLineTexts(thisLine, formated_damage_taken, formated_dtps, percentString)
			else
				thisLine.lineText4:SetText(rightText)
			end
		end

		percentNumber = math.floor((self.damage_taken/instanceObject.top) * 100)

	elseif(subAttribute == 4) then --friendly fire
		local formated_friendly_fire = selectedToKFunction(_, self.friendlyfire_total)

		if (not bars_show_data [1]) then
			formated_friendly_fire = ""
		end
		if (not bars_show_data [3]) then
			percentString = ""
		else
			percentString = percentString .. "%"
		end

		local rightText = formated_friendly_fire .. bars_brackets[1] .. percentString ..  bars_brackets[2]
		if (bUsingCustomRightText) then
			thisLine.lineText4:SetText(stringReplace(instanceObject.row_info.textR_custom_text, formated_friendly_fire, "", percentString, self, instanceObject.showing, instanceObject, rightText))
		else
			if (instanceObject.use_multi_fontstrings) then
				instanceObject:SetInLineTexts(thisLine, "", formated_friendly_fire, percentString)
			else
				thisLine.lineText4:SetText(rightText)
			end
		end
		percentNumber = math.floor((self.friendlyfire_total/instanceObject.top) * 100)

	elseif(subAttribute == 6) then --enemies
		local dtps = self.damage_taken / combatTime

		local formatedDamageTaken = selectedToKFunction(_, self.damage_taken)
		local formatedDtps = selectedToKFunction(_, dtps)
		thisLine.ps_text = formatedDtps

		if (not bars_show_data[1]) then
			formatedDamageTaken = ""
		end
		if (not bars_show_data[2]) then
			formatedDtps = ""
		end
		if (not bars_show_data[3]) then
			percentString = ""
		else
			percentString = percentString .. "%"
		end

		local rightText = formatedDamageTaken .. bars_brackets[1] .. formatedDtps .. bars_separator .. percentString .. bars_brackets[2]
		if (bUsingCustomRightText) then
			thisLine.lineText4:SetText(stringReplace(instanceObject.row_info.textR_custom_text, formatedDamageTaken, formatedDtps, percentString, self, instanceObject.showing, instanceObject, rightText))
		else
			if (instanceObject.use_multi_fontstrings) then
				instanceObject:SetInLineTexts(thisLine, formatedDamageTaken, formatedDtps, percentString)
			else
				thisLine.lineText4:SetText(rightText)
			end
		end

		percentNumber = math.floor((self.damage_taken/instanceObject.top) * 100)
	end

	--need tooltip update?
	if (thisLine.mouse_over and not instanceObject.baseframe.isMoving) then
		gump:UpdateTooltip(whichRowLine, thisLine, instanceObject)
	end

	if (self.need_refresh) then
		self.need_refresh = false
		bForceRefresh = true
	end

	classColor_Red, classColor_Green, classColor_Blue = self:GetBarColor()

	return self:RefreshLineValue(thisLine, instanceObject, previousData, bForceRefresh, percentNumber, bUseAnimations, total, instanceObject.top)
end

---show an extra statusbar on the line, after the main statusbar ~extra ~statusbar
---@param thisLine table
---@param amount valueamount
---@param extraAmount valueamount
---@param totalAmount valueamount
---@param topAmount valueamount
---@param instanceObject instance
---@param onEnterFunc function?
---@param onLeaveFunc function?
function Details:ShowExtraStatusbar(thisLine, amount, extraAmount, totalAmount, topAmount, instanceObject, onEnterFunc, onLeaveFunc)
	local extraStatusbar = thisLine.extraStatusbar
	if (extraAmount and extraAmount > 0 and instanceObject.atributo == 1 and instanceObject.sub_atributo == 1) then
		local initialOffset = 0
		local icon_offset_x, icon_offset_y = unpack(instanceObject.row_info.icon_offset)

		local bIsUsingBarStartAfterIcon = instanceObject.row_info.start_after_icon
		if (bIsUsingBarStartAfterIcon) then
			initialOffset = thisLine.icone_classe:GetWidth() + icon_offset_x
		end

		local statusBarWidth = thisLine.statusbar:GetWidth()
		local percent = amount / topAmount
		local fillTheGapWidth = percent * 4

		local startExtraStatusbarOffset = percent * statusBarWidth
		local extraStatusbarWidth = statusBarWidth *(extraAmount / topAmount)

		extraStatusbar:ClearAllPoints()
		extraStatusbar:SetHeight(thisLine:GetHeight())

		if (bIsUsingBarStartAfterIcon) then
			extraStatusbar:SetPoint("topleft", thisLine.icone_classe, "topright", startExtraStatusbarOffset - fillTheGapWidth, 0)
		else
			extraStatusbar:SetPoint("topleft", thisLine, "topleft",(statusBarWidth * percent) - fillTheGapWidth, 0)
		end

		--check if the extra bar will be bigger than the window
		local windowWidth = instanceObject:GetSize()
		local lineWidth = thisLine:GetWidth() *(amount/topAmount)
		local maxExtraBarWidth = windowWidth - lineWidth - initialOffset

		if (extraStatusbarWidth > maxExtraBarWidth) then
			extraStatusbarWidth = maxExtraBarWidth
		end

		extraStatusbar:SetWidth(extraStatusbarWidth)
		extraStatusbar:SetFrameLevel(thisLine:GetFrameLevel() + 1)

		extraStatusbar.OnEnterCallback = onEnterFunc
		extraStatusbar.OnLeaveCallback = onLeaveFunc

		if (Details.combat_log.calc_evoker_damage) then
			extraStatusbar:SetAlpha(0.2)
			extraStatusbar.defaultAlpha = 0.2
		else
			extraStatusbar:SetAlpha(0.7)
			extraStatusbar.defaultAlpha = 0.7
		end
		extraStatusbar:Show()
	else
		extraStatusbar:Hide()
	end
end

--when the script detect the extrastatusbar need to be show, it will call this function
local handleShowExtraStatusbar = function(thisLine, self, instance, previousData, isForceRefresh, percent, bUseAnimations, totalValue, topValue)
	if (self.spec == 1473 and self.augmentedSpellsContainer) then
		--prepare the extra bar to show the damage prediction to augmented evoker
		local onEnterFunc = damageClass.PredictedAugSpellsOnEnter
		local onLeaveFunc = damageClass.PredictedAugSpellsOnLeave

		Details:ShowExtraStatusbar(thisLine, self.total, self.total_extra, totalValue, topValue, instance, onEnterFunc, onLeaveFunc)
		thisLine.extraStatusbar.augmentedSpellsContainer = self.augmentedSpellsContainer

		thisLine.extraStatusbar.actorName = self:Name()

		---@cast instance instance
		thisLine.extraStatusbar.instanceId = instance:GetId()
	else
		Details:ShowExtraStatusbar(thisLine, self.total, self.total_extra, totalValue, topValue, instance)
	end
end

function Details:RefreshLineValue(thisLine, instance, previousData, isForceRefresh, percent, bUseAnimations, totalValue, topValue) --[[exported]]
	thisLine.extraStatusbar:Hide()

	if (thisLine.colocacao == 1) then
		thisLine.animacao_ignorar = true

		if (not previousData or previousData ~= thisLine.minha_tabela or isForceRefresh) then
			thisLine:SetValue(100)

			if (thisLine.hidden or thisLine.fading_in or thisLine.faded) then
				Details.FadeHandler.Fader(thisLine, "out")
			end

			return self:RefreshBarra(thisLine, instance)
		else
			return
		end
	else
		if (thisLine.hidden or thisLine.fading_in or thisLine.faded) then
			--setando o valor  mesmo com anima��es pq o barra esta hidada com o value do �ltimo actor que ela mostrou
			if (bUseAnimations and self.spec ~= 1473) then
				thisLine.animacao_fim = percent
				thisLine:SetValue(percent)
			else
				thisLine:SetValue(percent)
				thisLine.animacao_ignorar = true
			end

			Details.FadeHandler.Fader(thisLine, "out")

			if (self.total_extra and self.total_extra > 0) then
				if (self.spec == 1473) then
					if (Details.combat_log.calc_evoker_damage) then
						handleShowExtraStatusbar(thisLine, self, instance, previousData, isForceRefresh, percent, bUseAnimations, totalValue, topValue)
					end
				else
					handleShowExtraStatusbar(thisLine, self, instance, previousData, isForceRefresh, percent, bUseAnimations, totalValue, topValue)
				end
			end

			return self:RefreshBarra(thisLine, instance)
		else
			--agora esta comparando se a tabela da barra � diferente da tabela na atualiza��o anterior
			if (not previousData or previousData ~= thisLine.minha_tabela or isForceRefresh) then --aqui diz se a barra do jogador mudou de posi��o ou se ela apenas ser� atualizada
				if (bUseAnimations and self.spec ~= 1473) then
					thisLine.animacao_fim = percent
				else
					thisLine:SetValue(percent)
					thisLine.animacao_ignorar = true
				end

				thisLine.last_value = percent --reseta o ultimo valor da barra

				if (self.total_extra and self.total_extra > 0) then
					if (self.spec == 1473) then
						if (Details.combat_log.calc_evoker_damage) then
							handleShowExtraStatusbar(thisLine, self, instance, previousData, isForceRefresh, percent, bUseAnimations, totalValue, topValue)
						end
					else
						handleShowExtraStatusbar(thisLine, self, instance, previousData, isForceRefresh, percent, bUseAnimations, totalValue, topValue)
					end
				end

				return self:RefreshBarra(thisLine, instance)

			elseif(percent ~= thisLine.last_value) then
				--apenas atualizar
				if (bUseAnimations and self.spec ~= 1473) then
					thisLine.animacao_fim = percent
				else
					thisLine:SetValue(percent)
				end
				thisLine.last_value = percent

				if (self.total_extra and self.total_extra > 0) then
					if (self.spec == 1473) then
						if (Details.combat_log.calc_evoker_damage) then
							handleShowExtraStatusbar(thisLine, self, instance, previousData, isForceRefresh, percent, bUseAnimations, totalValue, topValue)
						end
					else
						Details:ShowExtraStatusbar(thisLine, self.total, self.total_extra, totalValue, topValue, instance)
					end
				end

				return self:RefreshBarra(thisLine, instance)
			else
				if (self.total_extra and self.total_extra > 0) then
					if (self.spec == 1473) then
						if (Details.combat_log.calc_evoker_damage) then
							handleShowExtraStatusbar(thisLine, self, instance, previousData, isForceRefresh, percent, bUseAnimations, totalValue, topValue)
						end
					else
						handleShowExtraStatusbar(thisLine, self, instance, previousData, isForceRefresh, percent, bUseAnimations, totalValue, topValue)
					end
				end
			end
		end
	end
end

local setLineTextSize = function(line, instance)
	if (instance.bars_inverted) then
		line.lineText4:SetSize(instance.cached_bar_width - line.lineText1:GetStringWidth() - 20, 15)
	else
		line.lineText1:SetSize(instance.cached_bar_width - line.lineText4:GetStringWidth() - 20, 15)
	end
end


function Details:SetBarLeftText(bar, instance, enemy, arenaEnemy, arenaAlly, usingCustomLeftText) --[[exported]]
	local barNumber = ""
	if (instance.row_info.textL_show_number) then
		barNumber = bar.colocacao .. ". "
	end

	if (instance.row_info.textL_translit_text) then
		if (not self.transliteratedName) then
			--translate cyrillic alphabet to western alphabet by Vardex(https://github.com/Vardex May 22, 2019)
			self.transliteratedName = Translit:Transliterate(self.displayName, "!")
		end
		self.displayName = self.transliteratedName or self.displayName
	end

	if (enemy) then
		if (arenaEnemy) then
			if (instance.row_info.show_arena_role_icon) then
				--show arena role icon
				local sizeOffset = instance.row_info.arena_role_icon_size_offset
				local leftText = barNumber .. "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" ..(instance.row_info.height + sizeOffset)..":"..(instance.row_info.height + sizeOffset) .. ":0:0:256:256:" .. Details.role_texcoord [self.role or "NONE"] .. "|t " .. self.displayName
				if (usingCustomLeftText) then
					bar.lineText1:SetText(stringReplace(instance.row_info.textL_custom_text, bar.colocacao, self.displayName, "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" ..(instance.row_info.height + sizeOffset)..":"..(instance.row_info.height + sizeOffset) .. ":0:0:256:256:" .. Details.role_texcoord [self.role or "NONE"] .. "|t ", self, instance.showing, instance, leftText))
				else
					bar.lineText1:SetText(leftText)
				end
			else
				--don't show arena role icon
				local leftText = barNumber .. self.displayName
				if (usingCustomLeftText) then
					bar.lineText1:SetText(stringReplace(instance.row_info.textL_custom_text, bar.colocacao, self.displayName, " ", self, instance.showing, instance, leftText))
				else
					bar.lineText1:SetText(leftText)
				end
			end
		else
			if (instance.row_info.show_faction_icon) then
				local sizeOffset = instance.row_info.faction_icon_size_offset
				if (Details.faction_against == "Horde") then
					local leftText = barNumber .. "|TInterface\\AddOns\\Details\\images\\icones_barra:" ..(instance.row_info.height + sizeOffset)..":"..(instance.row_info.height + sizeOffset) .. ":0:0:256:32:0:32:0:32|t"..self.displayName
					if (usingCustomLeftText) then
						bar.lineText1:SetText(stringReplace(instance.row_info.textL_custom_text, bar.colocacao, self.displayName, "|TInterface\\AddOns\\Details\\images\\icones_barra:" ..(instance.row_info.height + sizeOffset)..":"..(instance.row_info.height + sizeOffset) .. ":0:0:256:32:0:32:0:32|t", self, instance.showing, instance, leftText))
					else
						bar.lineText1:SetText(leftText) --seta o texto da esqueda -- HORDA
					end
				else --alliance
					local leftText = barNumber .. "|TInterface\\AddOns\\Details\\images\\icones_barra:" ..(instance.row_info.height + sizeOffset)..":"..(instance.row_info.height + sizeOffset) .. ":0:0:256:32:32:64:0:32|t"..self.displayName
					if (usingCustomLeftText) then
						bar.lineText1:SetText(stringReplace(instance.row_info.textL_custom_text, bar.colocacao, self.displayName, "|TInterface\\AddOns\\Details\\images\\icones_barra:" ..(instance.row_info.height + sizeOffset)..":"..(instance.row_info.height + sizeOffset) .. ":0:0:256:32:32:64:0:32|t", self, instance.showing, instance, leftText))
					else
						bar.lineText1:SetText(leftText) --seta o texto da esqueda -- ALLY
					end
				end
			else
				--don't show faction icon
				local leftText = barNumber .. self.displayName
				if (usingCustomLeftText) then
					bar.lineText1:SetText(stringReplace(instance.row_info.textL_custom_text, bar.colocacao, self.displayName, " ", self, instance.showing, instance, leftText))
				else
					bar.lineText1:SetText(leftText)
				end
			end
		end
	else
		if (arenaAlly and instance.row_info.show_arena_role_icon) then
			local sizeOffset = instance.row_info.arena_role_icon_size_offset
			local leftText = barNumber .. "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" ..(instance.row_info.height + sizeOffset)..":"..(instance.row_info.height + sizeOffset) .. ":0:0:256:256:" .. Details.role_texcoord [self.role or "NONE"] .. "|t " .. self.displayName
			if (usingCustomLeftText) then
				bar.lineText1:SetText(stringReplace(instance.row_info.textL_custom_text, bar.colocacao, self.displayName, "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" ..(instance.row_info.height + sizeOffset)..":"..(instance.row_info.height + sizeOffset) .. ":0:0:256:256:" .. Details.role_texcoord [self.role or "NONE"] .. "|t ", self, instance.showing, instance, leftText))
			else
				bar.lineText1:SetText(leftText)
			end
		else
			local leftText = barNumber .. self.displayName
			if (usingCustomLeftText) then
				bar.lineText1:SetText(stringReplace(instance.row_info.textL_custom_text, bar.colocacao, self.displayName, "", self, instance.showing, instance, leftText))
			else
				bar.lineText1:SetText(leftText) --seta o texto da esqueda
			end
		end
	end

	setLineTextSize(bar, instance)
end

function Details:SetBarColors(bar, instance, r, g, b, a) --[[exported]] --~colors
	a = a or 1

	local bUseClassColor = instance.row_info.texture_class_colors

	if (self.customColor) then
		bar.textura:SetVertexColor(r, g, b, a)

	elseif(bUseClassColor) then
		if (self.classe == "UNGROUPPLAYER") then
			if (self.spec) then
				local specId, specName, specDescription, specIcon, specRole, specClass = DetailsFramework.GetSpecializationInfoByID(self.spec)
				if (specClass) then
					self.classe = specClass
				end
			end
		end
		bar.textura:SetVertexColor(r, g, b, a)
	else
		r, g, b, a = unpack(instance.row_info.fixed_texture_color)
		bar.textura:SetVertexColor(r, g, b, a)
	end

	if (instance.row_info.texture_background_class_color) then
		bar.background:SetVertexColor(r, g, b, a)
	end

	if (instance.row_info.textL_class_colors) then
		local textColor_Red, textColor_Green, textColor_Blue = self:GetTextColor(instance, "left")
		bar.lineText1:SetTextColor(textColor_Red, textColor_Green, textColor_Blue) --the r, g, b color passed are the color used on the bar, so if the bar is not using class color, the text is painted with the fixed color for the bar
	end

	if (instance.row_info.textR_class_colors) then
		local textColor_Red, textColor_Green, textColor_Blue = self:GetTextColor(instance, "right")
		bar.lineText2:SetTextColor(textColor_Red, textColor_Green, textColor_Blue)
		bar.lineText3:SetTextColor(textColor_Red, textColor_Green, textColor_Blue)
		bar.lineText4:SetTextColor(textColor_Red, textColor_Green, textColor_Blue)
	end

	if (instance.row_info.backdrop.use_class_colors) then
		--get the alpha from the border color
		local alpha = instance.row_info.backdrop.color[4]
		if (not bUseClassColor) then
			r, g, b = self:GetClassColor()
		end
		bar.lineBorder:SetVertexColor(r, g, b, alpha)
	end
end

---set the icon of the actor spec, class, pet, enemy, custom icom, spellicon, etc.
---@param self actor
---@param texture texture
---@param instance instance
---@param class string
function Details:SetClassIcon(texture, instance, class) --[[exported]] --~icons
	local customIcon
	if (Details.immersion_unit_special_icons) then
		customIcon = Details.Immersion.GetIcon(self.aID)
	end

	--set the size offset of the icon
	local iconSizeOffset = instance.row_info.icon_size_offset
	local iconSize = instance.row_info.height
	local newIconSize = iconSize + iconSizeOffset
	texture:SetSize(newIconSize, newIconSize)

	if (customIcon) then
		texture:SetTexture(customIcon[1])
		texture:SetTexCoord(unpack(customIcon[2]))
		texture:SetVertexColor(1, 1, 1)

	elseif(self.spellicon) then
		texture:SetTexture(self.spellicon)
		texture:SetTexCoord(0.078125, 0.921875, 0.078125, 0.921875)

	elseif(class == "UNKNOW") then
		texture:SetTexture([[Interface\AddOns\Details\images\classes_plus]])
		texture:SetTexCoord(0.50390625, 0.62890625, 0, 0.125)
		texture:SetVertexColor(1, 1, 1)

	elseif(class == "UNGROUPPLAYER") then
		if (self.spec) then
			if (instance and instance.row_info.use_spec_icons) then
				if (self.spec and Details.class_specs_coords[self.spec]) then
					texture:SetTexture(instance.row_info.spec_file)
					texture:SetTexCoord(unpack(Details.class_specs_coords[self.spec]))
					texture:SetVertexColor(1, 1, 1)
					return
				end
			end
		end

		local englishClass
		if (self.serial ~= "") then
			local bResult, sResult = pcall(function() local lClass, eClass = GetPlayerInfoByGUID(self.serial or "") return eClass end) --will error with: nil, table and boolean
			if (bResult) then
				englishClass = sResult
			else
				local bIncludeStackTrace = true
				--[[GLOBAL]] DETAILS_FAILED_ACTOR = Details:GenerateActorInfo(self, sResult, bIncludeStackTrace) --avoid the game gc and details gc from destroying the actor info
				Details:Msg("Bug happend on GetPlayerInfoByGUID() class_damage.lua:3419. Use command '/details bug' to report.")
				englishClass = "UNKNOW"
			end
		end

		if (englishClass) then
			texture:SetTexture(instance.row_info.icon_file or [[Interface\AddOns\Details\images\classes_small]])
			texture:SetTexCoord(unpack(Details.class_coords[englishClass]))
			texture:SetVertexColor(1, 1, 1)
			return
		end

		if (self.enemy) then
			if (Details.faction_against == "Horde") then
				texture:SetTexture("Interface\\ICONS\\Achievement_Character_Troll_Male")
				texture:SetTexCoord(0.05, 0.95, 0.05, 0.95)
			else
				texture:SetTexture("Interface\\ICONS\\Achievement_Character_Nightelf_Female")
				texture:SetTexCoord(0.05, 0.95, 0.05, 0.95)
			end
		else
			if (Details.faction_against == "Horde") then
				texture:SetTexture("Interface\\ICONS\\Achievement_Character_Nightelf_Female")
				texture:SetTexCoord(0.05, 0.95, 0.05, 0.95)
			else
				texture:SetTexture("Interface\\ICONS\\Achievement_Character_Troll_Male")
				texture:SetTexCoord(0.05, 0.95, 0.05, 0.95)
			end
		end

		texture:SetVertexColor(1, 1, 1)

	elseif(class == "PET") then
		texture:SetTexture(instance and instance.row_info.icon_file or [[Interface\AddOns\Details\images\classes_small]])
		texture:SetTexCoord(0.25, 0.49609375, 0.75, 1)
		classColor_Red, classColor_Green, classColor_Blue = DetailsFramework:ParseColors(classColor_Red, classColor_Green, classColor_Blue)
		texture:SetVertexColor(classColor_Red, classColor_Green, classColor_Blue)

	else
		if (instance and instance.row_info.use_spec_icons) then
			if (self.spec and Details.class_specs_coords[self.spec]) then
				texture:SetTexture(instance.row_info.spec_file)
				texture:SetTexCoord(unpack(Details.class_specs_coords[self.spec]))
				texture:SetVertexColor(1, 1, 1)
			else
				texture:SetTexture(instance.row_info.icon_file or [[Interface\AddOns\Details\images\classes_small]])
				texture:SetTexCoord(unpack(Details.class_coords[class]))
				texture:SetVertexColor(1, 1, 1)
			end
		else
			texture:SetTexture(instance and instance.row_info.icon_file or [[Interface\AddOns\Details\images\classes_small]])
			texture:SetTexCoord(unpack(Details.class_coords[class]))
			texture:SetVertexColor(1, 1, 1)
		end
	end
end


function Details:RefreshBarra(thisLine, instance, fromResize) --[[exported]]
	local class, enemy, arenaEnemy, arenaAlly = self.classe, self.enemy, self.arena_enemy, self.arena_ally

	if (not class) then
		Details:Msg("Warning, actor without a class:", self.nome, self.flag_original, self.serial)
		self.classe = "UNKNOW"
		class = "UNKNOW"
	end

	if (fromResize) then
		classColor_Red, classColor_Green, classColor_Blue = self:GetBarColor()
	end

	--icon
	self:SetClassIcon(thisLine.icone_classe, instance, class)

	if (thisLine.mouse_over) then
		local classIcon = thisLine:GetClassIcon()
		thisLine.iconHighlight:SetTexture(classIcon:GetTexture())
		thisLine.iconHighlight:SetTexCoord(classIcon:GetTexCoord())
		thisLine.iconHighlight:SetVertexColor(classIcon:GetVertexColor())
	end

	--texture color
	self:SetBarColors(thisLine, instance, classColor_Red, classColor_Green, classColor_Blue)

	--left text
	self:SetBarLeftText(thisLine, instance, enemy, arenaEnemy, arenaAlly, bUsingCustomLeftText)
end

---~aug ~evoker
---@param self table extraStatusbar frame
function damageClass.PredictedAugSpellsOnEnter(self)
	if (Details.show_aug_predicted_spell_damage) then
		---@type spellcontainer
		local spellContainer = self.augmentedSpellsContainer

		GameCooltip:Preset(2)
		---@type instance
		local instanceObject = Details:GetInstance(self.instanceId)
		---@type combat
		local combatObject = instanceObject:GetCombat()

		for spellId, spellTable in spellContainer:ListSpells() do
			local spellName, _, spellTexture = GetSpellInfo(spellId)
			if (spellName) then
				GameCooltip:AddLine(spellName, Details:Format(spellTable.total))
				GameCooltip:AddIcon(spellTexture, 1, 1, 14, 14)

				local spellsAugmented = {}

				--the damage sources are added into the targets table for recycling
				---@type table<actorname, valueamount>
				local sources = spellTable.targets
				for sourceName, sourceAmount in pairs(sources) do
					spellsAugmented[#spellsAugmented+1] = {sourceName, sourceAmount}
				end

				table.sort(spellsAugmented, Details.Sort2)

				for i = 1, math.min(#spellsAugmented, 5) do
					local sourceName, sourceAmount = unpack(spellsAugmented[i])
					GameCooltip:AddLine(sourceName, Details:Format(sourceAmount), 1, "yellow", "yellow", 10)
					local actorObject = combatObject:GetActor(1, sourceName)
					if (actorObject) then
						local actorIcon = Details:GetActorIcon(actorObject)
						if (actorIcon) then
							GameCooltip:AddIcon(actorIcon.texture, 1, 1, 14, 14, actorIcon.coords.left, actorIcon.coords.right, actorIcon.coords.top, actorIcon.coords.bottom)
						else
							GameCooltip:AddIcon([[Interface\COMMON\Indicator-Gray]], 1, 1, 14, 14)
						end
					end
				end

				GameCooltip:AddLine(" ")
				GameCooltip:AddIcon("", 1, 1, 5, 5)
			end
		end
	else
		---@type instance
		local instanceObject = Details:GetInstance(self.instanceId)
		---@type combat
		local combatObject = instanceObject:GetCombat()

		local combatTime = combatObject:GetCombatTime()

		---@type actorname
		local actorName = self.actorName

		---@type actorcontainer
		local utilityContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_MISC)

		---@type table<spellid, table<spellid, number, actorname, actorname, class, boolean>>
		local buffUptimeTable = {}

		local iconSize = 22
		local iconBorderInfo = Details.tooltip.icon_border_texcoord

		local CONST_SPELLID_EBONMIGHT = 395152
		local CONST_SPELLID_PRESCIENCE = 410089
		local CONST_SPELLID_BLACKATTUNEMENT = 403264
		local CONST_SPELLID_BLISTERING_SCALES = 360827

		local ebonMightSpellName, _, ebonMightSpellIcon = Details.GetSpellInfo(CONST_SPELLID_EBONMIGHT)
		local _, _, ebonMightOnSelfIcon = Details.GetSpellInfo(395296)

		---@type actor[]
		local augmentationEvokers = {}

		local thisEvokerObject = utilityContainer:GetActor(actorName)

		--prescience and ebon might updatime on each actor
		for _, actorUtilityObject in utilityContainer:ListActors() do
			---@type spellcontainer
			local receivedBuffs = actorUtilityObject.received_buffs_spells

			--check if the actor is an augmentation evoker
			if (actorUtilityObject.spec == 1473) then
				augmentationEvokers[#augmentationEvokers+1] = actorUtilityObject
				if (actorUtilityObject:Name() == actorName) then
					thisEvokerObject = actorUtilityObject
				end
			end

			if (receivedBuffs and actorUtilityObject:IsPlayer() and actorUtilityObject:IsGroupPlayer()) then
				for sourceNameSpellId, spellTable in receivedBuffs:ListSpells() do
					local sourceName, spellId = strsplit("@", sourceNameSpellId)
					if (sourceName == actorName) then
						spellId = tonumber(spellId)
						local spellName, _, spellIcon = Details.GetSpellInfo(spellId)

						if (spellName and spellId) then
							sourceName = detailsFramework:RemoveRealmName(sourceName)
							local targetName = actorUtilityObject:Name()
							targetName = detailsFramework:RemoveRealmName(targetName)

							local uptime = spellTable.uptime or 0
							local bCanShowOnTooltip = true
							buffUptimeTable[spellId] = buffUptimeTable[spellId] or {}
							table.insert(buffUptimeTable[spellId], {spellId, uptime, sourceName, targetName, actorUtilityObject:Class(), bCanShowOnTooltip})
						end
					end
				end
			end
		end

		for spellId, buffTable in pairs(buffUptimeTable) do
			local totalUptime = 0
			for i = 1, #buffTable do
				totalUptime = totalUptime + buffTable[i][2]
			end
			table.sort(buffTable, Details.Sort2)
		end

		Details:FormatCooltipForSpells()
		Details:AddTooltipSpellHeaderText(Loc ["STRING_SPELLS"], headerColor, #buffUptimeTable, Details.tooltip_spell_icon.file, unpack(Details.tooltip_spell_icon.coords))
		Details:AddTooltipHeaderStatusbar(.1, .1, .1, 0.834)

		--add the total combat time into the tooltip
		local combatTimeMinutes, combatTimeSeconds = math.floor(combatTime / 60), math.floor(combatTime % 60)
		GameCooltip:AddLine("Combat Time", combatTimeMinutes .. "m " .. combatTimeSeconds .. "s" .. "(" .. format("%.1f", 100) .. "%)")
		GameCooltip:AddIcon([[Interface\TARGETINGFRAME\UnitFrameIcons]], nil, nil, iconSize, iconSize, iconBorderInfo.L, iconBorderInfo.R, iconBorderInfo.T, iconBorderInfo.B)
		Details:AddTooltipBackgroundStatusbar(false, 100, true, "darkgreen")

		GameCooltip:AddLine("", "")
		GameCooltip:AddIcon("", nil, nil, 1, 1)

		--show the caster evoker ebonmight uptime on the tooltip
		local thisEvokerEbonMightSpellTable = thisEvokerObject.buff_uptime_spells:GetSpell(395296)
		local evokerEbonMightUptime = thisEvokerEbonMightSpellTable and thisEvokerEbonMightSpellTable.uptime
		local ebonMightColor = "saddlebrown"

		if (evokerEbonMightUptime) then
			local minutes, seconds = math.floor(evokerEbonMightUptime / 60), math.floor(evokerEbonMightUptime % 60)
			local percent = evokerEbonMightUptime / combatTime * 100

			if (minutes > 0) then
				GameCooltip:AddLine(ebonMightSpellName .. "(self)", minutes .. "m " .. seconds .. "s" .. "(" .. format("%.1f", percent) .. "%)")
				Details:AddTooltipBackgroundStatusbar(false, percent, true, ebonMightColor)
			else
				GameCooltip:AddLine(ebonMightSpellName .. "(self)", seconds .. "s" .. "(" .. format("%.1f", percent) .. "%)")
				Details:AddTooltipBackgroundStatusbar(false, percent, true, ebonMightColor)
			end

			GameCooltip:AddIcon(ebonMightOnSelfIcon, nil, nil, iconSize, iconSize, iconBorderInfo.L, iconBorderInfo.R, iconBorderInfo.T, iconBorderInfo.B)
		end

		local ebonMightTable = buffUptimeTable[CONST_SPELLID_EBONMIGHT]

		--all ebon mights
		for i = 1, #ebonMightTable do
			local thisEbonMightTable = ebonMightTable[i]
			local uptime = thisEbonMightTable[2]
			local evokerName = thisEbonMightTable[3]
			local targetName = thisEbonMightTable[4]
			local targetClass = thisEbonMightTable[5]

			local spellName = ebonMightSpellName

			if (evokerName) then
				targetName = detailsFramework:AddClassColorToText(targetName, targetClass)
				targetName = detailsFramework:AddClassIconToText(targetName, targetName, targetClass)
				spellName = spellName .. " [" .. targetName .. " ]"
			end

			local minutes, seconds = math.floor(uptime / 60), math.floor(uptime % 60)
			if (uptime > 0) then
				local uptimePercent = uptime / combatTime * 100
				GameCooltip:AddLine(spellName, minutes .. "m " .. seconds .. "s" .. "(" .. format("%.1f", uptimePercent) .. "%)")
				GameCooltip:AddIcon(ebonMightSpellIcon, nil, nil, iconSize, iconSize, iconBorderInfo.L, iconBorderInfo.R, iconBorderInfo.T, iconBorderInfo.B)
				Details:AddTooltipBackgroundStatusbar(false, uptimePercent, true, ebonMightColor)
			end
		end

		GameCooltip:AddLine("", "")
		GameCooltip:AddIcon("", nil, nil, 1, 1)

		for i = 1, #augmentationEvokers do --black attunement
			local actorObject = augmentationEvokers[i]
			if (actorObject:Name() == actorName) then
				local buffUptimeSpellContainer = actorObject:GetSpellContainer("buff")
				if (buffUptimeSpellContainer) then
					local spellTable = buffUptimeSpellContainer:GetSpell(403264)
					if (spellTable) then
						local uptime = spellTable.uptime
						local spellName, _, spellIcon = _GetSpellInfo(CONST_SPELLID_BLACKATTUNEMENT)
						local uptimePercent = uptime / combatTime * 100

						if (uptime <= combatTime) then
							local minutes, seconds = math.floor(uptime / 60), math.floor(uptime % 60)
							if (minutes > 0) then
								GameCooltip:AddLine(spellName, minutes .. "m " .. seconds .. "s" .. "(" .. format("%.1f", uptimePercent) .. "%)")
								Details:AddTooltipBackgroundStatusbar(false, uptimePercent, true, "darkgreen")
							else
								GameCooltip:AddLine(spellName, seconds .. "s" .. "(" .. format("%.1f", uptimePercent) .. "%)")
								Details:AddTooltipBackgroundStatusbar(false, uptimePercent, true, "darkgreen")
							end

							GameCooltip:AddIcon(spellIcon, nil, nil, iconSize, iconSize, iconBorderInfo.L, iconBorderInfo.R, iconBorderInfo.T, iconBorderInfo.B)
						end
					end

					local spellTable = buffUptimeSpellContainer:GetSpell(CONST_SPELLID_BLISTERING_SCALES)
					if (spellTable) then
						local uptime = spellTable.uptime
						local spellName, _, spellIcon = _GetSpellInfo(CONST_SPELLID_BLISTERING_SCALES)
						local uptimePercent = uptime / combatTime * 100

						if (uptime <= combatTime) then
							local minutes, seconds = math.floor(uptime / 60), math.floor(uptime % 60)
							if (minutes > 0) then
								GameCooltip:AddLine(spellName, minutes .. "m " .. seconds .. "s" .. "(" .. format("%.1f", uptimePercent) .. "%)")
								Details:AddTooltipBackgroundStatusbar(false, uptimePercent, true, "darkgreen")
							else
								GameCooltip:AddLine(spellName, seconds .. "s" .. "(" .. format("%.1f", uptimePercent) .. "%)")
								Details:AddTooltipBackgroundStatusbar(false, uptimePercent, true, "darkgreen")
							end

							GameCooltip:AddIcon(spellIcon, nil, nil, iconSize, iconSize, iconBorderInfo.L, iconBorderInfo.R, iconBorderInfo.T, iconBorderInfo.B)
						end
					end
				end
			end
		end

		GameCooltip:AddLine("", "")
		GameCooltip:AddIcon("", nil, nil, 1, 1)

		--add the buff uptime into the tooltip
		local allPrescienceTargets = buffUptimeTable[CONST_SPELLID_PRESCIENCE]
		if (allPrescienceTargets and #allPrescienceTargets > 0) then
			for i = 1, math.min(30, #allPrescienceTargets) do
				local uptimeTable = allPrescienceTargets[i]

				local spellId = uptimeTable[1]
				local uptime = uptimeTable[2]
				local sourceName = uptimeTable[3]
				local targetName = uptimeTable[4]
				local targetClass = uptimeTable[5]
				local bCanShow = uptimeTable[6]

				local uptimePercent = uptime / combatTime * 100

				if (uptime > 0 and uptimePercent < 99.5 and bCanShow) then
					local spellName, _, spellIcon = _GetSpellInfo(spellId)

					if (sourceName) then
						targetName = detailsFramework:AddClassColorToText(targetName, targetClass)
						targetName = detailsFramework:AddClassIconToText(targetName, targetName, targetClass)
						spellName = spellName .. " [" .. targetName .. " ]"
					end

					if (uptime <= combatTime) then
						local minutes, seconds = math.floor(uptime / 60), math.floor(uptime % 60)
						if (minutes > 0) then
							GameCooltip:AddLine(spellName, minutes .. "m " .. seconds .. "s" .. "(" .. format("%.1f", uptimePercent) .. "%)")
							Details:AddTooltipBackgroundStatusbar(false, uptimePercent, true, sourceName and "darkgreen")
						else
							GameCooltip:AddLine(spellName, seconds .. "s" .. "(" .. format("%.1f", uptimePercent) .. "%)")
							Details:AddTooltipBackgroundStatusbar(false, uptimePercent, true, sourceName and "darkgreen")
						end

						GameCooltip:AddIcon(spellIcon, nil, nil, iconSize, iconSize, iconBorderInfo.L, iconBorderInfo.R, iconBorderInfo.T, iconBorderInfo.B)
					end
				end
			end
		else
			GameCooltip:AddLine(Loc ["STRING_NO_SPELL"])
		end

		local evokerObject = combatObject:GetActor(DETAILS_ATTRIBUTE_MISC, actorName)

		GameCooltip:AddLine(" ")
		GameCooltip:AddIcon(" ", 1, 1, 10, 10)

		if (evokerObject) then
			GameCooltip:AddLine("Prescience Uptime by Amount of Applications")
			local prescienceData = evokerObject.cleu_prescience_time

			if (prescienceData) then
				prescienceData = prescienceData.stackTime
				local totalTimeWithPrescienceUp = 0

				for amountOfPrescienceApplied, time in ipairs(prescienceData) do
					totalTimeWithPrescienceUp = totalTimeWithPrescienceUp + time
				end

				for amountOfPrescienceApplied, time in ipairs(prescienceData) do
					if (time > 0) then
						local uptimePercent = time / combatTime * 100
						local timeString = detailsFramework:IntegerToTimer(time)
						GameCooltip:AddLine("Presciece Applied: " .. amountOfPrescienceApplied, timeString .. "(" .. format("%.1f", uptimePercent) .. "%)")
						--5199639 prescience icon
						GameCooltip:AddIcon([[Interface\AddOns\Details\images\spells\prescience_time]], nil, nil, iconSize, iconSize)
						Details:AddTooltipBackgroundStatusbar(false, time/totalTimeWithPrescienceUp*100, true, "green")
					end
				end
			end
		end

		--iterate among all the actors and find which one are healers, then get the amount of mana the evoker restored for that healer
		---@type actorcontainer
		local resourcesContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_ENERGY)
		local manaRestoredToHealers = {}

		for index, actorObject in resourcesContainer:ListActors() do
			if (actorObject.spec == 1473) then --this is an aug evoker
				local spellContainer = actorObject:GetSpellContainer("spell")
				--local spellContainer = actorObject.spells
				if (spellContainer) then
					local sourceOfMagic = spellContainer:GetSpell(372571)
					if (sourceOfMagic) then
						for targetName, restoredAmount in pairs(sourceOfMagic.targets) do
							manaRestoredToHealers[#manaRestoredToHealers+1] = {targetName, restoredAmount}
						end
					end
				end
			end
		end

		if (#manaRestoredToHealers > 0) then
			GameCooltip:AddLine(" ")
			GameCooltip:AddIcon(" ", 1, 1, 10, 10)
			GameCooltip:AddLine("Mana Restored to Healers:")

			table.sort(manaRestoredToHealers, Details.Sort2)

			for i = 1, math.min(10, #manaRestoredToHealers) do
				local targetName, restoredAmount = unpack(manaRestoredToHealers[i])
				local targetActorObject = combatObject(DETAILS_ATTRIBUTE_ENERGY, targetName)

				if (targetActorObject) then
					local targetClass = targetActorObject:GetActorClass()
					local targetName = detailsFramework:AddClassColorToText(targetName, targetClass)
					targetName = detailsFramework:AddClassIconToText(targetName, targetName, targetClass)

					GameCooltip:AddLine(targetName, Details:Format(restoredAmount))

					local spellIcon = GetSpellTexture(372571)
					GameCooltip:AddIcon(spellIcon, nil, nil, iconSize, iconSize, iconBorderInfo.L, iconBorderInfo.R, iconBorderInfo.T, iconBorderInfo.B)
					Details:AddTooltipBackgroundStatusbar(false, 100, true, "dodgerblue")
				end
			end
		end
	end

	GameCooltip:AddLine("feature under test, can't disable atm")
	GameCooltip:AddIcon([[Interface\BUTTONS\UI-GROUPLOOT-PASS-DOWN]], nil, nil, 16, 16)

	--GameCooltip:SetOption("LeftBorderSize", -5)
	--GameCooltip:SetOption("RightBorderSize", 5)
	--GameCooltip:SetOption("RightTextMargin", 0)
	GameCooltip:SetOption("VerticalOffset", 0)
	--GameCooltip:SetOption("AlignAsBlizzTooltip", true)
	GameCooltip:SetOption("AlignAsBlizzTooltipFrameHeightOffset", 0)
	GameCooltip:SetOption("LineHeightSizeOffset", 0)
	GameCooltip:SetOption("VerticalPadding", 0)

	GameCooltip:ShowCooltip(self, "tooltip")
end

function damageClass.PredictedAugSpellsOnLeave(self)
	GameCooltip:Hide()
	--extraStatusbar.defaultAlpha
end

--------------------------------------------- // TOOLTIPS // ---------------------------------------------

---------TOOLTIPS BIFURCA��O
-- ~tooltip
function damageClass:ToolTip(instance, numero, barra, keydown)
	--seria possivel aqui colocar o icone da classe dele?

	if (instance.atributo == 5) then --custom
		return self:TooltipForCustom(barra)
	else
		if (instance.sub_atributo == 1 or instance.sub_atributo == 2) then --damage done or Dps or enemy
			return self:ToolTip_DamageDone(instance, numero, barra, keydown)

		elseif(instance.sub_atributo == 3) then --damage taken
			return self:ToolTip_DamageTaken(instance, numero, barra, keydown)

		elseif(instance.sub_atributo == 6) then --enemies
			return self:ToolTip_Enemies(instance, numero, barra, keydown)

		elseif(instance.sub_atributo == 4) then --friendly fire
			return self:ToolTip_FriendlyFire(instance, numero, barra, keydown)
		end
	end
end

--tooltip locals
local r, g, b
local barAlha = .6
Details222.commprefixes = "Comm"

---------DAMAGE DONE & DPS

function damageClass:ToolTip_DamageDone(instancia, numero, barra, keydown)
	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack(Details.class_colors [owner.classe])
	else
		if (not Details.class_colors [self.classe]) then
			return print("Details!: error class not found:", self.classe, "for", self.nome)
		end
		r, g, b = unpack(Details.class_colors [self.classe])
	end

	local combatObject = instancia:GetShowingCombat()

	--habilidades
	local icon_size = Details.tooltip.icon_size
	local icon_border = Details.tooltip.icon_border_texcoord

	do
		--TOP HABILIDADES

			--get variables
			--local ActorDamage = self.total_without_pet --mostrando os pets no tooltip
			local ActorDamage = self.total
			local ActorDamageWithPet = self.total
			if (ActorDamage == 0) then
				ActorDamage = 0.00000001
			end

			local ActorSkillsContainer = self.spells._ActorTable
			local ActorSkillsSortTable = {}

			local reflectionSpells = {}

			--get time type
			local meu_tempo
			if (Details.time_type == 1 or not self.grupo) then
				meu_tempo = self:Tempo()
			elseif(Details.time_type == 2 or Details.use_realtimedps) then
				meu_tempo = instancia.showing:GetCombatTime()
			end

			if (not meu_tempo) then
				meu_tempo = instancia.showing:GetCombatTime()
				if (Details.time_type == 3) then --time type 3 is deprecated
					Details.time_type = 2
				end
			end

			--add actor spells
			for _spellid, _skill in pairs(ActorSkillsContainer) do
				ActorSkillsSortTable [#ActorSkillsSortTable+1] = {_spellid, _skill.total, _skill.total/meu_tempo}
				if (_skill.isReflection) then
					reflectionSpells[#reflectionSpells+1] = _skill
				end
			end

			--add actor pets
			for petIndex, petName in ipairs(self:Pets()) do
				local petActor = instancia.showing[class_type]:PegarCombatente(nil, petName)
				if (petActor) then
					for _spellid, _skill in pairs(petActor:GetActorSpells()) do
						local formattedPetName = petName:gsub((" <.*"), "")
						if (instancia.row_info.textL_translit_text) then
							formattedPetName = Translit:Transliterate(formattedPetName, "!")
						end
						ActorSkillsSortTable [#ActorSkillsSortTable+1] = {_spellid, _skill.total, _skill.total/meu_tempo, formattedPetName}
					end
				end
			end
			--sort
			table.sort(ActorSkillsSortTable, Details.Sort2)

		--TOP INIMIGOS
			--get variables
			local ActorTargetsSortTable = {}

			--add
			for targetName, amount in pairs(self.targets) do
				local targetActorObject = combatObject(DETAILS_ATTRIBUTE_DAMAGE, targetName)
				local npcId = targetActorObject and targetActorObject.aID
				npcId = tonumber(npcId or 0)
				ActorTargetsSortTable[#ActorTargetsSortTable+1] = {targetName, amount, npcId}
			end
			--sort
			table.sort(ActorTargetsSortTable, Details.Sort2)

			--tooltip stuff
			local tooltip_max_abilities = Details.tooltip.tooltip_max_abilities

			local is_maximized = false
			if (keydown == "shift" or tooltipMaximizedMethod == 2 or tooltipMaximizedMethod == 3) then
				tooltip_max_abilities = 99
				is_maximized = true
			end

		--MOSTRA HABILIDADES
			--Details:AddTooltipSpellHeaderText(Loc ["STRING_SPELLS"], headerColor, #ActorSkillsSortTable, Details.tooltip_spell_icon.file, unpack(Details.tooltip_spell_icon.coords))

			if (is_maximized) then
				--highlight shift key
				--GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_shift]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay2)
				--Details:AddTooltipHeaderStatusbar(r, g, b, 1)
			else
				--GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_shift]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay1)
				--Details:AddTooltipHeaderStatusbar(r, g, b, barAlha)
			end

			GameCooltip:SetOption("AlignAsBlizzTooltip", false)
			GameCooltip:SetOption("YSpacingMod", -6)
			local iconSize = Details.DefaultTooltipIconSize

			local topAbility = ActorSkillsSortTable [1] and ActorSkillsSortTable [1][2] or 0.0001

			if (#ActorSkillsSortTable > 0) then
				for i = 1, math.min(tooltip_max_abilities, #ActorSkillsSortTable) do

					local SkillTable = ActorSkillsSortTable [i]

					local spellID = SkillTable [1]
					local totalDamage = SkillTable [2]
					local totalDPS = SkillTable [3]
					local petName = SkillTable [4]

					local nome_magia, _, icone_magia = _GetSpellInfo(spellID)
					if (petName) then
						if (not nome_magia) then
							spellID = spellID or "spellId?"
							nome_magia = "|cffffaa00" .. spellID .. " " .. "(|cFFCCBBBB" .. petName .. "|r)"
						else
							nome_magia = nome_magia .. "(|cFFCCBBBB" .. petName .. "|r)"
						end
					end

					local percent = format("%.1f", totalDamage/ActorDamage*100)
					if (string.len(percent) < 4) then
						percent = percent  .. "0"
					end

					if (instancia.sub_atributo == 1 or instancia.sub_atributo == 6) then
						GameCooltip:AddLine(nome_magia, formatTooltipNumber(_, totalDamage) .."  ("..percent.."%)")
					else
						GameCooltip:AddLine(nome_magia, formatTooltipNumber(_, math.floor(totalDPS)) .."  ("..percent.."%)")
					end

					GameCooltip:AddIcon(icone_magia, nil, nil, iconSize, iconSize, icon_border.L, icon_border.R, icon_border.T, icon_border.B)
					Details:AddTooltipBackgroundStatusbar(false, totalDamage/topAbility*100)
				end
			else
				GameCooltip:AddLine(Loc ["STRING_NO_SPELL"])
			end

		--spell reflected
			if (#reflectionSpells > 0) then
				--small blank space
				Details:AddTooltipSpellHeaderText("", headerColor, 1, false, 0.1, 0.9, 0.1, 0.9, true) --add a space
				Details:AddTooltipSpellHeaderText("Spells Reflected", headerColor, 1, select(3, _GetSpellInfo(reflectionSpells[1].id)), 0.1, 0.9, 0.1, 0.9) --localize-me
				Details:AddTooltipHeaderStatusbar(r, g, b, barAlha)

				for i = 1, #reflectionSpells do
					local _spell = reflectionSpells[i]
					local extraInfo = _spell.extra
					for spellId, damageDone in pairs(extraInfo) do
						local spellName, _, spellIcon = _GetSpellInfo(spellId)

						if (spellName) then
							GameCooltip:AddLine(spellName, formatTooltipNumber(_, damageDone) .. " (" .. math.floor(damageDone / self.total * 100) .. "%)")
							Details:AddTooltipBackgroundStatusbar(false, damageDone / self.total * 100)
							GameCooltip:AddIcon(spellIcon, 1, 1, iconSize, iconSize, 0.1, 0.9, 0.1, 0.9)
						end
					end
				end
			end

		--targets(enemies)
			local topEnemy = ActorTargetsSortTable[1] and ActorTargetsSortTable[1][2] or 0
			if (instancia.sub_atributo == 1 or instancia.sub_atributo == 6) then
				--small blank space
				Details:AddTooltipSpellHeaderText("", headerColor, 1, false, 0.1, 0.9, 0.1, 0.9, true)

				Details:AddTooltipSpellHeaderText(Loc ["STRING_TARGETS"], headerColor, #ActorTargetsSortTable, [[Interface\Addons\Details\images\icons]], 0, 0.03125, 0.126953125, 0.15625)

				local max_targets = Details.tooltip.tooltip_max_targets
				local is_maximized = false
				if (keydown == "ctrl" or tooltipMaximizedMethod == 2 or tooltipMaximizedMethod == 4) then
					max_targets = 99
					is_maximized = true
				end

				if (is_maximized) then
					--highlight
					GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay2)
					Details:AddTooltipHeaderStatusbar(r, g, b, 1)
				else
					GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay1)
					Details:AddTooltipHeaderStatusbar(r, g, b, barAlha)
				end

				for i = 1, math.min(max_targets, #ActorTargetsSortTable) do
					local enemyTable = ActorTargetsSortTable[i]
					GameCooltip:AddLine(enemyTable[1], formatTooltipNumber(_, enemyTable[2]) .." ("..format("%.1f", enemyTable[2] / ActorDamageWithPet * 100).."%)")

					local portraitTexture-- = Details222.Textures.GetPortraitTextureForNpcID(enemyTable[3]) --disabled atm
					if (portraitTexture) then
						GameCooltip:AddIcon(portraitTexture, 1, 1, icon_size.W, icon_size.H)
					else
						GameCooltip:AddIcon([[Interface\PetBattles\PetBattle-StatIcons]], nil, nil, icon_size.W, icon_size.H, 0, 0.5, 0, 0.5, {.7, .7, .7, 1}, nil, true)
					end

					Details:AddTooltipBackgroundStatusbar(false, enemyTable[2] / topEnemy * 100)
				end
			end
	end

	--PETS
	local instance = instancia
	local combatObject = instance:GetShowingCombat()

	local myPets = self.pets
	if (#myPets > 0) then --teve ajudantes
		local petAmountWithSameName = {} --armazena a quantidade de pets iguais
		local petDamageTable = {} --armazena o dano total de cada objeto

		--small blank space
		Details:AddTooltipSpellHeaderText("", headerColor, 1, false, 0.1, 0.9, 0.1, 0.9, true)

		for index, petName in ipairs(myPets) do
			if (not petAmountWithSameName[petName]) then
				petAmountWithSameName[petName] = 1
				local damageContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
				local petActorObject = damageContainer:GetActor(petName)

				if (petActorObject) then
					local petDamageDone = petActorObject.total_without_pet
					local petSpells = petActorObject:GetSpellList()
					local petSpellsSorted = {}

					--local timeInCombat = petActorObject:GetTimeInCombat(self)
					local timeInCombat = 0
					if (Details.time_type == 1 or not self.grupo) then
						timeInCombat = petActorObject:Tempo()
					elseif(Details.time_type == 2 or Details.use_realtimedps) then
						timeInCombat = petActorObject:GetCombatTime()
					end

					petDamageTable[#petDamageTable+1] = {petName, petActorObject.total_without_pet, petActorObject.total_without_pet / timeInCombat}

					for spellId, spellTable in pairs(petSpells) do
						local spellName, rank, spellIcon = _GetSpellInfo(spellId)
						tinsert(petSpellsSorted, {spellId, spellTable.total, spellTable.total / petDamageDone * 100, {spellName, rank, spellIcon}})
					end

					table.sort(petSpellsSorted, Details.Sort2)

					local petTargets = {}
					petSpells = petActorObject.targets
					for targetName, spellDamageDone in pairs(petSpells) do
						tinsert(petTargets, {targetName, spellDamageDone, spellDamageDone / petDamageDone * 100})
					end
					table.sort(petTargets,Details.Sort2)
				end
			else
				petAmountWithSameName[petName] = petAmountWithSameName[petName] + 1
			end
		end

		local petHeaderAdded = false

		table.sort(petDamageTable, Details.Sort2)

		local ismaximized = false
		if (keydown == "alt" or tooltipMaximizedMethod == 2 or tooltipMaximizedMethod == 5) then
			ismaximized = true
		end

		local topPetDamageDone = petDamageTable[1] and petDamageTable[1][2] or 0

		for index, damageTable in ipairs(petDamageTable) do
			if (damageTable [2] > 0 and(index <= Details.tooltip.tooltip_max_pets or ismaximized)) then
				if (not petHeaderAdded) then
					petHeaderAdded = true
					Details:AddTooltipSpellHeaderText(Loc ["STRING_PETS"], headerColor, #petDamageTable, [[Interface\COMMON\friendship-heart]], 0.21875, 0.78125, 0.09375, 0.6875)

					if (ismaximized) then
						GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_alt]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay2)
						Details:AddTooltipHeaderStatusbar(r, g, b, 1)
					else
						GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_alt]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay1)
						Details:AddTooltipHeaderStatusbar(r, g, b, barAlha)
					end
				end

				local petName = damageTable[1]
				local petDamageDone = damageTable[2]
				local petDPS = damageTable[3]

				petName = damageTable[1]:gsub(("%s%<.*"), "")

				if (instance.row_info.textL_translit_text) then
					petName = Translit:Transliterate(petName, "!")
				end

				if (instancia.sub_atributo == 1) then
					GameCooltip:AddLine(petName, formatTooltipNumber(_, petDamageDone) .. " (" .. math.floor(petDamageDone/self.total*100) .. "%)")
				else
					GameCooltip:AddLine(petName, formatTooltipNumber(_, math.floor(petDPS)) .. " (" .. math.floor(petDamageDone/self.total*100) .. "%)")
				end

				Details:AddTooltipBackgroundStatusbar(false, petDamageDone / topPetDamageDone * 100)

				GameCooltip:AddIcon([[Interface\AddOns\Details\images\classes_small_alpha]], 1, 1, icon_size.W, icon_size.H, 0.25/2, 0.49609375/2, 0.75/2, 1/2)
			end
		end
	end

	--~Phases
	local segment = instancia:GetShowingCombat()
	if (segment and self.grupo) then
		local bossInfo = segment:GetBossInfo()
		local phasesInfo = segment:GetPhases()
		if (bossInfo and phasesInfo) then
			if (#phasesInfo > 1) then

				--small blank space
				Details:AddTooltipSpellHeaderText("", headerColor, 1, false, 0.1, 0.9, 0.1, 0.9, true)

				Details:AddTooltipSpellHeaderText("Damage Per Phase", headerColor, 1, [[Interface\Garrison\orderhall-missions-mechanic8]], 11/64, 53/64, 11/64, 53/64) --localize-me
				Details:AddTooltipHeaderStatusbar(r, g, b, barAlha)

				local playerPhases = {}
				local totalDamage = 0

				for phase, playersTable in pairs(phasesInfo.damage) do --each phase

					local allPlayers = {} --all players for this phase
					for playerName, amount in pairs(playersTable) do
						tinsert(allPlayers, {playerName, amount})
						totalDamage = totalDamage + amount
					end
					table.sort(allPlayers, function(a, b) return a[2] > b[2] end)

					local myRank = 0
					for i = 1, #allPlayers do
						if (allPlayers [i] [1] == self.nome) then
							myRank = i
							break
						end
					end

					tinsert(playerPhases, {phase, playersTable [self.nome] or 0, myRank,(playersTable [self.nome] or 0) / totalDamage * 100})
				end

				table.sort(playerPhases, function(a, b) return a[1] < b[1] end)

				for i = 1, #playerPhases do
					--[1] Phase Number [2] Amount Done [3] Rank [4] Percent
					GameCooltip:AddLine("|cFFF0F0F0Phase|r " .. playerPhases [i][1], formatTooltipNumber(_, playerPhases [i][2]) .. "  (|cFFFFFF00#" .. playerPhases [i][3] ..  "|r,  " .. format("%.1f", playerPhases [i][4]) .. "%)")
					GameCooltip:AddIcon([[Interface\Garrison\orderhall-missions-mechanic9]], 1, 1, 14, 14, 11/64, 53/64, 11/64, 53/64)
					Details:AddTooltipBackgroundStatusbar()
				end
			end
		end
	end

	return true
end

local on_switch_show_enemies = function(instance)
	instance:TrocaTabela(instance, true, 1, 6)
	return true
end

local on_switch_show_frags = function(instance)
	instance:TrocaTabela(instance, true, 1, 5)
	return true
end

local ENEMIES_format_name = function(player) if (player == 0) then return false end return Details:GetOnlyName(player.nome) end
local ENEMIES_format_amount = function(amount) if (amount <= 0) then return false end return Details:ToK(amount) .. "(" .. format("%.1f", amount / tooltip_temp_table.damage_total * 100) .. "%)" end

function damageClass:ReportEnemyDamageTaken(actor, instance, ShiftKeyDown, ControlKeyDown, fromFrags)

	--can open the breakdown window now
	--this function is deprecated

	if (ShiftKeyDown) then
		local inimigo = actor.nome
		local custom_name = inimigo .. " -" .. Loc ["STRING_CUSTOM_ENEMY_DT"]

		--procura se j� tem um custom:
		for index, CustomObject in ipairs(Details.custom) do
			if (CustomObject:GetName() == custom_name) then
				--fix for not saving funcs on logout
				if (not CustomObject.OnSwitchShow) then
					CustomObject.OnSwitchShow = fromFrags and on_switch_show_frags or on_switch_show_enemies
				end
				return instance:TrocaTabela(instance.segmento, 5, index)
			end
		end

		--criar um custom para este actor.
		local new_custom_object = {
			name = custom_name,
			icon = [[Interface\ICONS\Pet_Type_Undead]],
			attribute = "damagedone",
			author = Details.playername,
			desc = inimigo .. " Damage Taken",
			source = "[raid]",
			target = inimigo,
			script = false,
			tooltip = false,
			temp = true,
			OnSwitchShow = fromFrags and on_switch_show_frags or on_switch_show_enemies,
		}

		tinsert(Details.custom, new_custom_object)
		setmetatable(new_custom_object, Details.atributo_custom)
		new_custom_object.__index = Details.atributo_custom

		return instance:TrocaTabela(instance.segmento, 5, #Details.custom)
	end

	if (true) then return end

	local report_table = {"Details!: " .. actor.nome .. " - " .. Loc ["STRING_ATTRIBUTE_DAMAGE_TAKEN"]}

	Details:FormatReportLines(report_table, tooltip_temp_table, ENEMIES_format_name, ENEMIES_format_amount)

	return Details:Reportar(report_table, {_no_current = true, _no_inverse = true, _custom = true})
end

local FRAGS_format_name = function(player_name) return Details:GetOnlyName(player_name) end
local FRAGS_format_amount = function(amount) return Details:ToK(amount) .. "(" .. format("%.1f", amount / frags_tooltip_table.damage_total * 100) .. "%)" end

function damageClass:ReportSingleFragsLine(frag, instance, ShiftKeyDown, ControlKeyDown)
	if (not frags_tooltip_table) then --some cases a friendly object is getting threat as neutral, example is Druid's Efflorescense
		return
	end

	if (ShiftKeyDown) then
		return damageClass:ReportEnemyDamageTaken(frag, instance, ShiftKeyDown, ControlKeyDown, true)
	end

	local report_table = {"Details!: " .. frag [1] .. " - " .. Loc ["STRING_ATTRIBUTE_DAMAGE_TAKEN"]}

	Details:FormatReportLines(report_table, frags_tooltip_table, FRAGS_format_name, FRAGS_format_amount)

	return Details:Reportar(report_table, {_no_current = true, _no_inverse = true, _custom = true})
end

---@param self actor
---@param instanceObject instance
function damageClass:ToolTip_Enemies(instanceObject, numero, barra, keydown)
	--check if the actor has an owner, if it does, it's a pet
	local ownerObject = self.owner
	if (ownerObject and ownerObject.classe) then
		r, g, b = unpack(Details.class_colors[ownerObject.classe])
	else
		r, g, b = unpack(Details.class_colors[self.classe])
	end

	local combatObject = instanceObject:GetCombat()
	local enemyName = self:Name()

	Details:Destroy(tooltip_temp_table) --fix for translit bug report, 'player' is nil

	--enemy damage taken
	local i = 1
	local damageTaken = 0
	---@type actorcontainer
	local damageContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

	---@type number, actor
	for idx, actor in damageContainer:ListActors() do
		if (actor:IsGroupPlayer() and actor.targets[enemyName]) then
			---@type table<actor, number>
			local agressorsTable = tooltip_temp_table[i]

			if (not agressorsTable) then
				tooltip_temp_table[i] = {}
				agressorsTable = tooltip_temp_table[i]
			end

			agressorsTable[1] = actor
			agressorsTable[2] =(actor.targets[enemyName]) or 0
			damageTaken = damageTaken + agressorsTable[2]

			i = i + 1
		end
	end

	for o = i, #tooltip_temp_table do
		local t = tooltip_temp_table[o]
		t[2] = 0
		t[1] = 0
	end

	table.sort(tooltip_temp_table, Details.Sort2)

	--build the tooltip
	local top =(tooltip_temp_table[1] and tooltip_temp_table[1][2]) or 0
	tooltip_temp_table.damage_total = damageTaken

	local iconSize = Details.DefaultTooltipIconSize
	GameCooltip:SetOption("AlignAsBlizzTooltip", false)
	GameCooltip:SetOption("YSpacingMod", -6)

	for o = 1, i-1 do
		local actorAggressor = tooltip_temp_table[o][1]
		local damageDone = tooltip_temp_table[o][2]
		local playerName = Details:GetOnlyName(actorAggressor:name())

		GameCooltip:AddLine(playerName .. " ", formatTooltipNumber(_, damageDone) .."(" .. format("%.1f",(damageDone / damageTaken) * 100) .. "%)")

		local classe = actorAggressor:class()
		if (not classe) then
			classe = "UNKNOW"
		end

		if (classe == "UNKNOW") then
			GameCooltip:AddIcon("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, iconSize, iconSize, .25, .5, 0, 1)
		else
			local specID = actorAggressor.spec
			if (specID) then
				local texture, l, r, t, b = Details:GetSpecIcon(specID, false)
				GameCooltip:AddIcon(texture, 1, 1, iconSize, iconSize, l, r, t, b)
			else
				GameCooltip:AddIcon(instanceObject.row_info.icon_file, nil, nil, iconSize, iconSize, unpack(Details.class_coords [classe]))
			end
		end

		local r, g, b = unpack(Details.class_colors[classe])
		GameCooltip:AddStatusBar(damageDone/top*100, 1, r, g, b, 1, false, enemies_background)
	end

	GameCooltip:SetOption("StatusBarTexture", "Interface\\AddOns\\Details\\images\\bar_serenity")

	--damage done and heal
	GameCooltip:AddLine(" ")
	GameCooltip:AddLine(Loc ["STRING_ATTRIBUTE_DAMAGE_ENEMIES_DONE"], formatTooltipNumber(_, math.floor(self.total)))
	local half = 0.00048828125
	GameCooltip:AddIcon(instanceObject:GetSkinTexture(), 1, 1, 14, 14, 0.005859375 + half, 0.025390625 - half, 0.3623046875, 0.3818359375)
	GameCooltip:AddStatusBar(0, 1, r, g, b, 1, false, enemies_background)

	local heal_actor = instanceObject.showing(2, self.nome)
	if (heal_actor) then
		GameCooltip:AddLine(Loc ["STRING_ATTRIBUTE_HEAL_ENEMY"], formatTooltipNumber(_, math.floor(heal_actor.heal_enemy_amt)))
	else
		GameCooltip:AddLine(Loc ["STRING_ATTRIBUTE_HEAL_ENEMY"], 0)
	end
	GameCooltip:AddIcon(instanceObject:GetSkinTexture(), 1, 1, 14, 14, 0.037109375 + half, 0.056640625 - half, 0.3623046875, 0.3818359375)
	GameCooltip:AddStatusBar(0, 1, r, g, b, 1, false, enemies_background)

	GameCooltip:AddLine(" ")
	Details:AddTooltipReportLineText()

	return true
end

---------DAMAGE TAKEN
function damageClass:ToolTip_DamageTaken(instance, numero, barra, keydown)
	--if the object has a owner, it's a pet
	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack(Details.class_colors[owner.classe])
	else
		r, g, b = unpack(Details.class_colors[self.classe])
	end

	local damageTakenFrom = self.damage_from
	local totalDamageTaken = self.damage_taken
	local actorName = self:Name()

	local combatObject = instance:GetShowingCombat()
	local damageContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

	---@type {key1:actorname, key2:valueamount, key3:class, key4:actor}
	local damageTakenDataSorted = {}
	local mainAttribute, subAttribute = instance:GetDisplay()

	if (subAttribute == DETAILS_SUBATTRIBUTE_ENEMIES) then
		for _, actorObject in damageContainer:ListActors() do
			if (actorObject:IsGroupPlayer() and actorObject.targets[actorName]) then
				damageTakenDataSorted [#damageTakenDataSorted+1] = {
					actorName,
					actorObject.targets[actorName],
					actorObject:Class(),
					actorObject
				}
			end
		end
	else
		for enemyName, _ in pairs(damageTakenFrom) do --who damaged the player
			--get the aggressor
			local enemyActorObject = damageContainer:GetActor(enemyName)
			if (enemyActorObject) then
				---@type {key1:actorname, key2:valueamount, key3:class, key4:actor}
				local damageTakenTable
				local damageInflictedByThisEnemy = enemyActorObject.targets[actorName]

				if (damageInflictedByThisEnemy) then
					if (enemyActorObject:IsPlayer() or enemyActorObject:IsNeutralOrEnemy()) then
						damageTakenTable = {enemyName, damageInflictedByThisEnemy, enemyActorObject:Class(), enemyActorObject}
						damageTakenDataSorted[#damageTakenDataSorted+1] = damageTakenTable
					end
				end

				--special cases - monk stagger
				if (enemyName == actorName and self:Class() == "MONK") then
					local friendlyFire = enemyActorObject.friendlyfire[enemyName]
					if (friendlyFire and friendlyFire.total > 0) then
						local staggerDamage = friendlyFire.spells[124255] or 0
						if (staggerDamage > 0) then
							if (damageTakenTable) then
								damageTakenTable[2] = damageTakenTable[2] + staggerDamage
							else
								damageTakenDataSorted[#damageTakenDataSorted+1] = {enemyName, staggerDamage, "MONK", enemyActorObject}
							end
						end
					end
				end
			end
		end
	end

	local maxDataAllowed = #damageTakenDataSorted
	if (maxDataAllowed > 10) then
		maxDataAllowed = 10
	end

	local bIsMaximized = false
	if (keydown == "shift" or tooltipMaximizedMethod == 2 or tooltipMaximizedMethod == 3 or instance.sub_atributo == 6 or Details.damage_taken_everything) then
		maxDataAllowed = #damageTakenDataSorted
		bIsMaximized = true
	end

	if (subAttribute == DETAILS_SUBATTRIBUTE_ENEMIES) then
		--Details:AddTooltipSpellHeaderText(Loc ["STRING_DAMAGE_TAKEN_FROM"], headerColor, #damageTakenDataSorted, [[Interface\Buttons\UI-MicroStream-Red]], 0.1875, 0.8125, 0.15625, 0.78125)
	else
		--Details:AddTooltipSpellHeaderText(Loc ["STRING_FROM"], headerColor, #damageTakenDataSorted, [[Interface\Addons\Details\images\icons]], 0.126953125, 0.1796875, 0, 0.0546875)
	end

	if (bIsMaximized) then
		--highlight
		--GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_shift]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay2)
		--if (subAttribute == DETAILS_SUBATTRIBUTE_ENEMIES) then
		--	GameCooltip:AddStatusBar(100, 1, 0.7, g, b, 1)
		--else
		--	Details:AddTooltipHeaderStatusbar(r, g, b, 1)
		--end
	else
		--GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_shift]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay1)
		--if (subAttribute == DETAILS_SUBATTRIBUTE_ENEMIES) then
		--	GameCooltip:AddStatusBar(100, 1, 0.7, 0, 0, barAlha)
		--else
		--	Details:AddTooltipHeaderStatusbar(r, g, b, barAlha)
		--end
	end

	--local iconSize = Details.tooltip.icon_size
	local iconBorderTexCoord = Details.tooltip.icon_border_texcoord

	GameCooltip:SetOption("AlignAsBlizzTooltip", false)
	GameCooltip:SetOption("AlignAsBlizzTooltipFrameHeightOffset", -6)
	GameCooltip:SetOption("YSpacingMod", -6)
	local iconSize = Details.DefaultTooltipIconSize

	-- create a full list of incoming damage, before adding any lines to the tooltip, so we can sort them appropriately

	---@class cooltip_icon
	---@field key1 textureid
	---@field key2 number 1 for main tooltip frame, 2 for the secondary frame
	---@field key3 number 1 for the left side, 2 for the right size
	---@field key4 width
	---@field key5 height
	---@field key6 coordleft
	---@field key7 coordright
	---@field key8 coordtop
	---@field key9 coordbottom

	---@type {key1:valueamount, key2:table<string, string>, key3:cooltip_icon}
	local lines_to_add = {}

	for i = 1, maxDataAllowed do
		local enemyActorObject = damageTakenDataSorted[i][4]

		--only shows damage from enemies or from the player it self
		--the player it self can only be placed on the list by the iteration above
		--the iteration doesnt check friendly fire for all actors, only a few cases like Monk Stagger

		if (enemyActorObject:IsNeutralOrEnemy() or enemyActorObject:Name() == self:Name()) then
			---@type {key1:spellid, key2:valueamount, key:actorname}
			local spellTargetDamageList = {}

			for spellId, spellTable in pairs(enemyActorObject.spells._ActorTable) do
				local damageOnTarget = spellTable.targets[self:Name()]
				if (damageOnTarget) then
					tinsert(spellTargetDamageList, {spellId, damageOnTarget, enemyActorObject:Name()})
				end
			end

			--friendly fire
			local friendlyFire = enemyActorObject.friendlyfire[self:Name()]
			if (friendlyFire) then
				for spellId, valueAmount in pairs(friendlyFire.spells) do
					table.insert(spellTargetDamageList, {spellId, valueAmount, enemyActorObject:Name()})
				end
			end

			for _, spell in ipairs(spellTargetDamageList) do
				local spellId, valueAmount, thisActorName = unpack(spell)

				local spellName, _, spellIcon = _GetSpellInfo(spellId)
				local addTextArgs = {spellName .. "(|cFFFFFF00" .. thisActorName .. "|r)", Details:Format(valueAmount) .. "(" .. string.format("%.1f",(valueAmount / totalDamageTaken) * 100) .. "%)"}
				---@type cooltip_icon
				local addIconArgs = {spellIcon, 1, 1, iconSize, iconSize, iconBorderTexCoord.L, iconBorderTexCoord.R, iconBorderTexCoord.T, iconBorderTexCoord.B}

				tinsert(lines_to_add, {
					valueAmount,
					addTextArgs,
					addIconArgs
				})
			end
		else
			---@type actorname, valueamount, class, actor
			local thisAggrossorTable = damageTakenDataSorted[i]
			local actorName = thisAggrossorTable[1]
			local amount = thisAggrossorTable[2]
			local class = thisAggrossorTable[3]
			local actorObject = thisAggrossorTable[4]

			---@type {key1:actorname, key2:string, key3:nil, key4:color}
			local addLineArgs
			---@type cooltip_icon
			local addIconArgs

			local aggressorName = Details:GetOnlyName(actorName)
			if (bIsMaximized and actorName:find(Details.playername)) then
				addLineArgs = {aggressorName, Details:Format(amount) .. "("..string.format("%.1f",(amount / totalDamageTaken) * 100) .. "%)", nil, "yellow"}
			else
				addLineArgs = {aggressorName, Details:Format(amount) .. "("..string.format("%.1f",(amount / totalDamageTaken) * 100) .. "%)"}
			end

			if (not class) then
				class = "UNKNOW"
			end

			if (class == "UNKNOW") then
				addIconArgs = {"Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, iconSize, iconSize, .25, .5, 0, 1}
			else
				addIconArgs= {instance.row_info.icon_file, nil, nil, iconSize, iconSize, unpack(Details.class_coords [class])}
			end
			tinsert(lines_to_add, {amount, addLineArgs, addIconArgs})
		end
	end

	table.sort(lines_to_add, Details.Sort1)

	for _, line in ipairs(lines_to_add) do
		GameCooltip:AddLine(unpack(line[2]))
		GameCooltip:AddIcon(unpack(line[3]))
		Details:AddTooltipBackgroundStatusbar()
	end

	if (subAttribute == DETAILS_SUBATTRIBUTE_ENEMIES) then
		GameCooltip:AddLine(" ")
		GameCooltip:AddLine(Loc ["STRING_ATTRIBUTE_DAMAGE_DONE"], formatTooltipNumber(_, math.floor(self.total)))
		local half = 0.00048828125
		GameCooltip:AddIcon(instance:GetSkinTexture(), 1, 1, iconSize, iconSize, 0.005859375 + half, 0.025390625 - half, 0.3623046875, 0.3818359375)
		Details:AddTooltipBackgroundStatusbar()

		local heal_actor = instance.showing(2, self.nome)
		if (heal_actor) then
			GameCooltip:AddLine(Loc ["STRING_ATTRIBUTE_HEAL_DONE"], formatTooltipNumber(_, math.floor(heal_actor.heal_enemy_amt)))
		else
			GameCooltip:AddLine(Loc ["STRING_ATTRIBUTE_HEAL_DONE"], 0)
		end
		GameCooltip:AddIcon(instance:GetSkinTexture(), 1, 1, iconSize, iconSize, 0.037109375 + half, 0.056640625 - half, 0.3623046875, 0.3818359375)
		Details:AddTooltipBackgroundStatusbar()
	end

	return true
end

---------FRIENDLY FIRE
function damageClass:ToolTip_FriendlyFire(instancia, numero, barra, keydown)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack(Details.class_colors [owner.classe])
	else
		r, g, b = unpack(Details.class_colors [self.classe])
	end

	local FriendlyFire = self.friendlyfire
	local FriendlyFireTotal = self.friendlyfire_total
	local combat = instancia:GetShowingCombat()

	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type]

	local icon_size = Details.tooltip.icon_size
	local icon_border = Details.tooltip.icon_border_texcoord
	local lineHeight = Details.tooltip.line_height

	local DamagedPlayers = {}
	local Skills = {}

	for target_name, ff_table in pairs(FriendlyFire) do
		local actor = combat(1, target_name)
		if (actor) then
			DamagedPlayers [#DamagedPlayers+1] = {target_name, ff_table.total, actor.classe}
			for spellid, amount in pairs(ff_table.spells) do
				Skills [spellid] =(Skills [spellid] or 0) + amount
			end
		end
	end

	table.sort(DamagedPlayers, Details.Sort2)

	Details:AddTooltipSpellHeaderText(Loc ["STRING_TARGETS"], headerColor, #DamagedPlayers, Details.tooltip_target_icon.file, unpack(Details.tooltip_target_icon.coords))

	local ismaximized = false
	if (keydown == "shift" or tooltipMaximizedMethod == 2 or tooltipMaximizedMethod == 3) then
		GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_shift]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay2)
		Details:AddTooltipHeaderStatusbar(r, g, b, 1)
		ismaximized = true
	else
		GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_shift]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay1)
		Details:AddTooltipHeaderStatusbar(r, g, b, barAlha)
	end

	local max_abilities = Details.tooltip.tooltip_max_abilities
	if (ismaximized) then
		max_abilities = 99
	end

	for i = 1, math.min(max_abilities, #DamagedPlayers) do
		local classe = DamagedPlayers[i][3]
		if (not classe) then
			classe = "UNKNOW"
		end

		GameCooltip:AddLine(Details:GetOnlyName(DamagedPlayers[i][1]), formatTooltipNumber(_, DamagedPlayers[i][2]).."("..format("%.1f", DamagedPlayers[i][2]/FriendlyFireTotal*100).."%)")
		GameCooltip:AddIcon("Interface\\AddOns\\Details\\images\\espadas", nil, nil, lineHeight, lineHeight)
		Details:AddTooltipBackgroundStatusbar()

		if (classe == "UNKNOW") then
			GameCooltip:AddIcon("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, lineHeight, lineHeight, unpack(Details.class_coords ["UNKNOW"]))
		else
			local specID = Details:GetSpec(DamagedPlayers[i][1])
			if (specID) then
				local texture, l, r, t, b = Details:GetSpecIcon(specID, false)
				GameCooltip:AddIcon(texture, 1, 1, lineHeight, lineHeight, l, r, t, b)
			else
				GameCooltip:AddIcon("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, lineHeight, lineHeight, unpack(Details.class_coords [classe]))
			end
		end

	end

	Details:AddTooltipSpellHeaderText(Loc ["STRING_SPELLS"], headerColor, 1, Details.tooltip_spell_icon.file, unpack(Details.tooltip_spell_icon.coords))

	local ismaximized = false
	if (keydown == "ctrl" or tooltipMaximizedMethod == 2 or tooltipMaximizedMethod == 4) then
		GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay2)
		Details:AddTooltipHeaderStatusbar(r, g, b, 1)
		ismaximized = true
	else
		GameCooltip:AddIcon([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay1)
		Details:AddTooltipHeaderStatusbar(r, g, b, barAlha)
	end

	local max_abilities2 = Details.tooltip.tooltip_max_abilities
	if (ismaximized) then
		max_abilities2 = 99
	end

	--spells usadas no friendly fire
	local SpellsInOrder = {}
	for spellID, amount in pairs(Skills) do
		SpellsInOrder [#SpellsInOrder+1] = {spellID, amount}
	end
	table.sort(SpellsInOrder, Details.Sort2)

	for i = 1, math.min(max_abilities2, #SpellsInOrder) do
		local nome, _, icone = _GetSpellInfo(SpellsInOrder[i][1])
		GameCooltip:AddLine(nome, formatTooltipNumber(_, SpellsInOrder[i][2]).."("..format("%.1f", SpellsInOrder[i][2]/FriendlyFireTotal*100).."%)")
		GameCooltip:AddIcon(icone, nil, nil, icon_size.W, icon_size.H, icon_border.L, icon_border.R, icon_border.T, icon_border.B)
		Details:AddTooltipBackgroundStatusbar()
	end

	return true
end


--------------------------------------------- // JANELA DETALHES // ---------------------------------------------


---------DETALHES BIFURCA��O ~detalhes ~detailswindow ~bi
function damageClass:MontaInfo()
	if (breakdownWindowFrame.sub_atributo == 1 or breakdownWindowFrame.sub_atributo == 2 or breakdownWindowFrame.sub_atributo == 6) then --damage done & dps
		return self:MontaInfoDamageDone() --has new code for the new destails window | left scroll and 6 blocks implemented
	elseif(breakdownWindowFrame.sub_atributo == 3) then --damage taken
		return self:MontaInfoDamageTaken() --has new code for the new destails window | left and right scrolls implemented
	elseif(breakdownWindowFrame.sub_atributo == 4) then --friendly fire
		return self:MontaInfoFriendlyFire() --has new code for the new destails window | left scroll implemeneted(need to implemente the right scroll yet)
	end
end

---------DETALHES bloco da direita BIFURCA��O
function damageClass:MontaDetalhes(spellid, barra, instancia) --these functions were used to fill the 5 blocks from the old breakdown window
	if (breakdownWindowFrame.sub_atributo == 1 or breakdownWindowFrame.sub_atributo == 2) then
		return self:MontaDetalhesDamageDone(spellid, barra, instancia) --deprecated

	elseif(breakdownWindowFrame.sub_atributo == 3) then
		return self:MontaDetalhesDamageTaken(spellid, barra, instancia)

	elseif(breakdownWindowFrame.sub_atributo == 4) then
		return self:MontaDetalhesFriendlyFire(spellid, barra, instancia)

	elseif(breakdownWindowFrame.sub_atributo == 6) then
		if (bitBand(self.flag_original, 0x00000400) ~= 0) then --� um jogador
			return self:MontaDetalhesDamageDone(spellid, barra, instancia) --deprecated
		end
		return self:MontaDetalhesEnemy(spellid, barra, instancia)
	end
end

local friendlyFireSpellSourcesHeadersAllowed = {icon = true, name = true, rank = true, amount = true, persecond = true, percent = true}
---when hovering over the player name in the breakdown window, this function will be called to build a the list of spells used to inflict damage on that player
---@param friendlyFireAggressorActor actordamage
---@param targetName string
function damageClass.BuildFriendlySpellListFromAgressor(friendlyFireAggressorActor, targetName)
	---@type combat
	local combatObject = Details:GetCombatFromBreakdownWindow()

	---@type friendlyfiretable
	local friendlyFireTable = friendlyFireAggressorActor.friendlyfire[targetName]

	local totalDamage = friendlyFireTable.total
	local spellsUsed = friendlyFireTable.spells

	--create the table which will be returned with the data
	---@type {topValue: number, totalValue: number, headersAllowed: table, combatTime: number}
	local resultTable = {topValue = 0, totalValue = totalDamage, headersAllowed = friendlyFireSpellSourcesHeadersAllowed, combatTime = combatObject:GetCombatTime()}

	--iterate among the spells used by the aggressorActor
	for spellId, amountDamage in pairs(spellsUsed) do
		--add the spell to the list
		local spellName = GetSpellInfo(spellId)
		resultTable[#resultTable+1] = {spellId = spellId, total = amountDamage, petName = "", spellScholl = Details.spell_school_cache[spellName] or 1}
	end

	return resultTable
end

------ Friendly Fire
local friendlyFireHeadersAllowed = {icon = true, name = true, rank = true, amount = true, persecond = true, percent = true}
---build the friendly fire list, the list contains players who were damaged by this actor.
function damageClass:MontaInfoFriendlyFire() --~friendlyfire ~friendly ~ff
	---@type actordamage
	local actorObject = self
	---@type instance
	local instance = breakdownWindowFrame.instancia
	---@type combat
	local combatObject = instance:GetCombat()
	---@type string
	local actorName = actorObject:Name()

	---@type number
	local friendlyFireTotal = actorObject.friendlyfire_total
	---@type table<string, friendlyfiretable>
	local damagedPlayers = actorObject.friendlyfire --players which got hit by this actor
	---@type actorcontainer
	local damageContainer = combatObject:GetContainer(class_type)

	local resultTable = {}

	for targetName, friendlyFireTable in pairs(damagedPlayers) do
		local amountOfFriendlyFire = friendlyFireTable.total
		if (amountOfFriendlyFire > 0) then
			---@type actordamage this is an actor who was damaged by the friendly fire of the actorObject
			local targetActorObject = damageContainer:GetActor(targetName)
			if (targetActorObject) then
				---@type texturetable
				local iconTable = Details:GetActorIcon(targetActorObject)

				---@type {name: string, amount: number, icon: texturetable, class: string}
				local ffTable = {name = targetName, total = amountOfFriendlyFire, icon = iconTable, class = targetActorObject:Class()}

				resultTable[#resultTable+1] = ffTable
			end
		end
	end

	resultTable.totalValue = friendlyFireTotal
	resultTable.combatTime = combatObject:GetCombatTime()
	resultTable.headersAllowed = friendlyFireHeadersAllowed

	Details222.BreakdownWindow.SendGenericData(resultTable, actorObject, combatObject, instance)

	if true then return end
	do
		local instancia = breakdownWindowFrame.instancia
		local combat = instancia:GetShowingCombat()
		local barras = breakdownWindowFrame.barras1
		local barras2 = breakdownWindowFrame.barras2
		local barras3 = breakdownWindowFrame.barras3

		local FriendlyFireTotal = self.friendlyfire_total

		local DamagedPlayers = {}
		local Skills = {}

		for target_name, ff_table in pairs(self.friendlyfire) do

			local actor = combat(1, target_name)
			if (actor) then
				tinsert(DamagedPlayers, {target_name, ff_table.total, ff_table.total / FriendlyFireTotal * 100, actor.classe})

				for spellid, amount in pairs(ff_table.spells) do
					Skills [spellid] =(Skills [spellid] or 0) + amount
				end
			end
		end

		table.sort(DamagedPlayers, Details.Sort2)

		local amt = #DamagedPlayers
		gump:JI_AtualizaContainerBarras(amt)

		local FirstPlaceDamage = DamagedPlayers [1] and DamagedPlayers [1][2] or 0

		for index, tabela in ipairs(DamagedPlayers) do
			local barra = barras [index]

			if (not barra) then
				barra = gump:CriaNovaBarraInfo1(instancia, index)
				barra.textura:SetStatusBarColor(1, 1, 1, 1)
				barra.on_focus = false
			end

			if (not breakdownWindowFrame.mostrando_mouse_over) then
				if (tabela[1] == self.detalhes) then --tabela [1] = NOME = NOME que esta na caixa da direita
					if (not barra.on_focus) then --se a barra n�o tiver no foco
						barra.textura:SetStatusBarColor(129/255, 125/255, 69/255, 1)
						barra.on_focus = true
						if (not breakdownWindowFrame.mostrando) then
							breakdownWindowFrame.mostrando = barra
						end
					end
				else
					if (barra.on_focus) then
						barra.textura:SetStatusBarColor(1, 1, 1, 1) --volta a cor antiga
						barra:SetAlpha(.9) --volta a alfa antiga
						barra.on_focus = false
					end
				end
			end

			if (index == 1) then
				barra.textura:SetValue(100)
			else
				barra.textura:SetValue(tabela[2]/FirstPlaceDamage*100)
			end

			barra.lineText1:SetText(index .. instancia.divisores.colocacao .. Details:GetOnlyName(tabela[1])) --seta o texto da esqueda
			barra.lineText4:SetText(Details:comma_value(tabela[2]) .. "(" .. format("%.1f", tabela[3]) .."%)") --seta o texto da direita

			local classe = tabela[4]
			if (not classe) then
				classe = "MONSTER"
			end

			barra.icone:SetTexture(breakdownWindowFrame.instancia.row_info.icon_file)

			if (Details.class_coords [classe]) then
				barra.icone:SetTexCoord(unpack(Details.class_coords [classe]))
			else
				barra.icone:SetTexture("")
			end

			local color = Details.class_colors [classe]
			if (color) then
				barra.textura:SetStatusBarColor(unpack(color))
			else
				barra.textura:SetStatusBarColor(1, 1, 1)
			end

			barra.minha_tabela = self
			barra.show = tabela[1]
			barra:Show()

			if (self.detalhes and self.detalhes == barra.show) then
				self:MontaDetalhes(self.detalhes, barra, instancia)
			end
		end

		local SkillTable = {}
		for spellid, amt in pairs(Skills) do
			local nome, _, icone = _GetSpellInfo(spellid)
			SkillTable [#SkillTable+1] = {nome, amt, amt/FriendlyFireTotal*100, icone}
		end

		table.sort(SkillTable, Details.Sort2)

		amt = #SkillTable
		if (amt < 1) then
			return
		end

		gump:JI_AtualizaContainerAlvos(amt)

		FirstPlaceDamage = SkillTable [1] and SkillTable [1][2] or 0

		for index, tabela in ipairs(SkillTable) do
			local barra = barras2 [index]

			if (not barra) then
				barra = gump:CriaNovaBarraInfo2(instancia, index)
				barra.textura:SetStatusBarColor(1, 1, 1, 1)
			end

			if (index == 1) then
				barra.textura:SetValue(100)
			else
				barra.textura:SetValue(tabela[2]/FirstPlaceDamage*100)
			end

			barra.lineText1:SetText(index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
			barra.lineText4:SetText(Details:comma_value(tabela[2]) .."(" ..format("%.1f", tabela[3]) .. ")") --seta o texto da direita
			barra.icone:SetTexture(tabela[4])

			barra.minha_tabela = nil --desativa o tooltip

			barra:Show()
		end
	end
end

local damageTakenSpellSourcesHeadersAllowed = {icon = true, name = true, rank = true, amount = true, persecond = true, percent = true}
function damageClass.BuildDamageTakenSpellListFromAgressor(targetActor, aggressorActor)
	--target actor name
	local targetActorName = targetActor:Name()

	---@type combat
	local combatObject = Details:GetCombatFromBreakdownWindow()

	--get the list of spells from the aggressorActor and check each one to see if it was casted on the targetActor
	---@type spellcontainer
	local spellContainer = aggressorActor:GetSpellContainer("spell")

	--create the table which will be returned with the data
	---@type {topValue: number, totalValue: number, headersAllowed: table, combatTime: number}
	local resultTable = {topValue = 0, totalValue = 0, headersAllowed = damageTakenSpellSourcesHeadersAllowed, combatTime = combatObject:GetCombatTime()}

	for spellId, spellTable in spellContainer:ListSpells() do
		---@cast spellTable spelltable
		for targetName, amount in pairs(spellTable.targets) do
			if (targetName == targetActorName) then
				--add the spell to the list
				resultTable[#resultTable+1] = {spellId = spellId, total = amount, petName = "", spellScholl = spellTable.spellschool}
				resultTable.totalValue = resultTable.totalValue + amount
			end
		end
	end

	--iterate among the pets of the aggressorActor and get the spells casted by them
	---@type table<number, actorname>
	local petTable = aggressorActor.pets

	for i = 1, #petTable do
		local petName = petTable[i]
		local petActorObject = combatObject:GetActor(DETAILS_ATTRIBUTE_DAMAGE, petName)
		if (petActorObject) then
			---@type spellcontainer
			local petSpellContainer = petActorObject:GetSpellContainer("spell")

			for spellId, spellTable in petSpellContainer:ListSpells() do
				for targetName, amount in pairs(spellTable.targets) do
					if (targetName == targetActorName) then
						--add the spell to the list
						resultTable[#resultTable+1] = {spellId = spellId, total = amount, petName = petName, spellScholl = spellTable.spellschool}
						resultTable.totalValue = resultTable.totalValue + amount
					end
				end
			end
		end
	end

	return resultTable
end

------ Damage Taken
local damageTakenHeadersAllowed = {icon = true, name = true, rank = true, amount = true, persecond = true, percent = true}
function damageClass:MontaInfoDamageTaken()
	---@type actordamage
	local actorObject = self
	---@type instance
	local instance = breakdownWindowFrame.instancia
	---@type combat
	local combatObject = instance:GetCombat()
	---@type string
	local actorName = actorObject:Name()

	---@type number
	local damageTakenTotal = actorObject.damage_taken
	---@type table<string, boolean>
	local damageTakenFrom = actorObject.damage_from
	---@type actorcontainer
	local damageContainer = combatObject:GetContainer(class_type)

	local resultTable = {}

	---@type string
	for aggressorName in pairs(damageTakenFrom) do
		local aggressorActor = damageContainer:GetActor(aggressorName)
		if (aggressorActor) then
			---@type table<string, number>
			local targets = aggressorActor:GetTargets()
			---@type number|nil
			local amountOfDamage = targets[actorName]
			if (amountOfDamage) then
				---@type texturetable
				local iconTable = Details:GetActorIcon(aggressorActor)

				---@type {name: string, amount: number, icon: texturetable}
				local damageTakenTable = {name = aggressorName, total = amountOfDamage, icon = iconTable, class = aggressorActor:Class()}

				resultTable[#resultTable+1] = damageTakenTable
			end
		end
	end

	resultTable.totalValue = damageTakenTotal
	resultTable.combatTime = combatObject:GetCombatTime()
	resultTable.headersAllowed = damageTakenHeadersAllowed

	Details222.BreakdownWindow.SendGenericData(resultTable, actorObject, combatObject, instance)
end

--[[exported]] function Details:UpdadeInfoBar(row, index, spellId, name, value, formattedValue, max, percent, icon, detalhes, texCoords, spellSchool, class)
	if (index == 1) then
		row.textura:SetValue(100)
	else
		max = math.max(max, 0.001)
		row.textura:SetValue(value / max * 100)
	end

	if (type(index) == "number") then
		if (debugmode) then
			row.lineText1:SetText(index .. ". " .. name .. "(" .. spellId .. ")")
		else
			row.lineText1:SetText(index .. ". " .. name)
		end
	else
		row.lineText1:SetText(name)
	end

	row.lineText1.text = row.lineText1:GetText()

	if (formattedValue) then
		row.lineText4:SetText(formattedValue .. "(" .. format("%.1f", percent) .."%)")
	end

	row.lineText1:SetSize(row:GetWidth() - row.lineText4:GetStringWidth() - 40, 15)

	if (icon) then
		row.icone:SetTexture(icon)
		if (icon == "Interface\\AddOns\\Details\\images\\classes_small") then
			row.icone:SetTexCoord(0.25, 0.49609375, 0.75, 1)
		else
			row.icone:SetTexCoord(0, 1, 0, 1)
		end
	else
		row.icone:SetTexture("")
	end

	if (not row.IconUpBorder) then
		row.IconUpBorder = CreateFrame("frame", nil, row,"BackdropTemplate")
		row.IconUpBorder:SetAllPoints(row.icone)
		row.IconUpBorder:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		row.IconUpBorder:SetBackdropBorderColor(0, 0, 0, 0.75)
	end

	if (texCoords) then
		row.icone:SetTexCoord(unpack(texCoords))
	else
		local iconBorder = Details.tooltip.icon_border_texcoord
		row.icone:SetTexCoord(iconBorder.L, iconBorder.R, iconBorder.T, iconBorder.B)
	end

	row.minha_tabela = self
	row.show = spellId
	row:Show()

	if (spellSchool) then
		local schoolColor = Details.spells_school[spellSchool]
		if (schoolColor and schoolColor.decimals) then
			row.textura:SetStatusBarColor(schoolColor.decimals[1], schoolColor.decimals[2], schoolColor.decimals[3])
		else
			row.textura:SetStatusBarColor(1, 1, 1)
		end

	elseif(class) then
		local color = Details.class_colors[class]
		if (color and class ~= "UNKNOW") then
			row.textura:SetStatusBarColor(unpack(color))
		else
			row.textura:SetStatusBarColor(1, 1, 1)
		end
	else
		if (spellId == 98021) then --spirit linkl
			row.textura:SetStatusBarColor(1, 0.4, 0.4)
		else
			row.textura:SetStatusBarColor(1, 1, 1)
		end
	end

	if (detalhes and self.detalhes and self.detalhes == spellId and breakdownWindowFrame.showing == index) then
		self:MontaDetalhes(row.show, row, breakdownWindowFrame.instancia)
	end
end

--lock into a line after clicking on it
--[[exported]] function Details:FocusLock(row, spellId) --will be deprecated
	if (not breakdownWindowFrame.mostrando_mouse_over) then
		if (spellId == self.detalhes) then --tabela [1] = spellid = spellid que esta na caixa da direita
			if (not row.on_focus) then --se a barra n�o tiver no foco
				row.textura:SetStatusBarColor(129/255, 125/255, 69/255, 1)
				row.on_focus = true
				if (not breakdownWindowFrame.mostrando) then
					breakdownWindowFrame.mostrando = row
				end
			end
		else
			if (row.on_focus) then
				row.textura:SetStatusBarColor(1, 1, 1, 1) --volta a cor antiga
				row:SetAlpha(.9) --volta a alfa antiga
				row.on_focus = false
			end
		end
	end
end

local wipeSpellCache = function() --deprecated
	Details:Destroy(Details222.PlayerBreakdown.DamageSpellsCache)
end

local addToSpellCache = function(unitGUID, spellName, spellTable) --deprecated
	local unitSpellCache = Details222.PlayerBreakdown.DamageSpellsCache[unitGUID]
	if (not unitSpellCache) then
		unitSpellCache = {}
		Details222.PlayerBreakdown.DamageSpellsCache[unitGUID] = unitSpellCache
	end

	local spellCache = Details222.PlayerBreakdown.DamageSpellsCache[unitGUID][spellName]
	if (not spellCache) then
		spellCache = {}
		Details222.PlayerBreakdown.DamageSpellsCache[unitGUID][spellName] = spellCache
	end

	table.insert(spellCache, spellTable)
end

local getSpellDetails = function(unitGUID, spellName) --deprecated
	local unitCachedSpells = Details222.PlayerBreakdown.DamageSpellsCache[unitGUID]
	local spellsTableForSpellName = unitCachedSpells and unitCachedSpells[spellName]

	if (spellsTableForSpellName) then --should always be valid
		if (#spellsTableForSpellName > 1) then
			local t = spellsTableForSpellName
			local spellId = t[1].id
			local newSpellTable = Details222.DamageSpells.CreateSpellTable(spellId)

			newSpellTable.n_min = 99999999
			newSpellTable.c_min = 99999999
			newSpellTable.n_max = 0
			newSpellTable.c_max = 0

			for i = 1, #t do
				for key, value in pairs(t[i]) do
					if (type(value) == "number") then
						if (key == "n_min" or key == "c_min") then
							if (value < newSpellTable[key]) then
								newSpellTable[key] = value
							end

						elseif(key == "n_max" or key == "c_max") then
							if (value > newSpellTable[key]) then
								newSpellTable[key] = value
							end

						elseif(key ~= "id" and key ~= "spellschool") then
							newSpellTable[key] =(newSpellTable[key] or 0) + value
						end
					end
				end
			end

			return newSpellTable
		else
			--there's only one table, so return the first
			return spellsTableForSpellName[1]
		end
	end
end

--[=
_detalhes.string_size = UIParent:CreateFontString(nil, "overlay", "GameFontNormal")
_detalhes.string_size:SetText("MMMMMMMMMMMM") --12 M's - max playername in width
_detalhes.string_size_default = _detalhes.string_size:GetStringWidth()
Details.numbertostring = numbertostring
--]=]

--I guess this fills the list of spells in the topleft scrollBar in the summary tab
--the goal of this function is to build a list of spells the actor used and send the data to Details! which will delivery to the summary tab actived
--so the script only need to build the list of spells and send it to Details!
------ Damage Done & Dps
function damageClass:MontaInfoDamageDone()
	---@type actor
	local actorObject = self
	---@type instance
	local instance = breakdownWindowFrame.instancia
	---@type combat
	local combatObject = instance:GetCombat()
	---@type number
	local diff, diffEngName = combatObject:GetDifficulty()
	---@type string
	local playerName = actorObject:Name()

	local attribute, subAttribute = instance:GetDisplay()

	--guild ranking on a boss
	--check if is a raid encounter and if is heroic or mythic
	do
		if (diff and(diff == 15 or diff == 16)) then --this might give errors
			local db = Details.OpenStorage()
			if (db) then
				---@type details_storage_unitresult, details_encounterkillinfo
				local bestRank, encounterTable = Details222.storage.GetBestFromPlayer(diffEngName, combatObject:GetBossInfo().id, "DAMAGER", playerName, true)
				if (bestRank) then
					--discover which are the player position in the guild rank
					local rankPosition = Details222.storage.GetUnitGuildRank(diffEngName, combatObject:GetBossInfo().id, "DAMAGER", playerName, true)
					local text1 = playerName .. " Guild Rank on " ..(combatObject:GetBossInfo().name or "") .. ": |cFFFFFF00" ..(rankPosition or "x") .. "|r Best Dps: |cFFFFFF00" .. Details:ToK2((bestRank.total or SMALL_NUMBER) / encounterTable.elapsed) .. "|r(" .. encounterTable.date:gsub(".*%s", "") .. ")"
					breakdownWindowFrame:SetStatusbarText(text1, 10, "gray")
				else
					breakdownWindowFrame:SetStatusbarText()
				end
			else
				breakdownWindowFrame:SetStatusbarText()
			end
		else
			breakdownWindowFrame:SetStatusbarText()
		end
	end

	---@type breakdownspelldatalist
	local breakdownSpellDataList = {}

	---@type number
	local totalDamageWithoutPet = actorObject.total_without_pet
	---@type number
	local actorTotal = actorObject.total
	---@type table<number, spelltable>
	local actorSpells = actorObject:GetSpellList()

	wipeSpellCache()

	--get time
	local actorCombatTime
	if (Details.time_type == 1 or not actorObject.grupo) then
		actorCombatTime = actorObject:Tempo()
	elseif(Details.time_type == 2 or Details.use_realtimedps) then
		actorCombatTime = breakdownWindowFrame.instancia.showing:GetCombatTime()
	end

	--actor spells
	---@type table<string, number>
	local alreadyAdded = {}

	local bShouldMergePlayerSpells = Details.breakdown_spell_tab.nest_players_spells_with_same_name

	---@type number, spelltable
	for spellId, spellTable in pairs(actorSpells) do
		spellTable.ChartData = nil --~ChartData

		---@type string
		local spellName = _GetSpellInfo(spellId)

		if (spellName) then
			---@type number in which index the spell with the same name was stored
			local index = alreadyAdded[spellName]
			if (index and bShouldMergePlayerSpells) then
				---@type spelltableadv
				local bkSpellData = breakdownSpellDataList[index]

				bkSpellData.spellTables[#bkSpellData.spellTables+1] = spellTable

				---@type bknesteddata
				local nestedData = {spellId = spellId, spellTable = spellTable, actorName = "", value = 0}
				bkSpellData.nestedData[#bkSpellData.nestedData+1] = nestedData
				bkSpellData.bCanExpand = true
			else
				---@type spelltableadv
				local bkSpellData = {
					id = spellId,
					spellschool = spellTable.spellschool,
					bIsExpanded = Details222.BreakdownWindow.IsSpellExpanded(spellId),
					bCanExpand = false,

					spellTables = {spellTable},
					nestedData = {{spellId = spellId, spellTable = spellTable, actorName = "", value = 0}},
				}

				detailsFramework:Mixin(bkSpellData, Details.SpellTableMixin)
				breakdownSpellDataList[#breakdownSpellDataList+1] = bkSpellData
				alreadyAdded[spellName] = #breakdownSpellDataList
			end
		end
	end

	--pets spells
	local bShouldMergeSpellsWithThePet = Details.breakdown_spell_tab.nest_pet_spells_by_caster
	local bShouldMergePetSpells = Details.breakdown_spell_tab.nest_pet_spells_by_name

	local actorPets = actorObject:GetPets()
	for _, petName in ipairs(actorPets) do
		---@type actor
		local petActor = combatObject(DETAILS_ATTRIBUTE_DAMAGE, petName)
		if (petActor) then --PET
			--get the amount of spells the pet used, if the pet used only one there`s no reason to nest one spell with the pet
			local petSpellContainer = petActor:GetSpellContainer("spell")

			if (bShouldMergeSpellsWithThePet and petSpellContainer:HasTwoOrMoreSpells()) then
				---@type spelltableadv
				local bkSpellData = {
					bIsActorHeader = true, --tag this spelltable as an actor header, when the actor is the header it will nest the spells use by this actor
					actorName = petName,
					npcId = petActor.aID,
					id = 0,
					spellschool = 0,
					bIsExpanded = Details222.BreakdownWindow.IsSpellExpanded(petName),
					spellTables = {}, --populated below with the spells the pet used
					nestedData = {}, --there's none data here in the main bar as the first bar is the pet name
					bCanExpand = true,
					actorIcon = [[Interface\AddOns\Details\images\pets\pet_icon_1]],
				}
				detailsFramework:Mixin(bkSpellData, Details.SpellTableMixin)

				--output
				breakdownSpellDataList[#breakdownSpellDataList+1] = bkSpellData

				--fill here the spellTables using the actor abilities
				--all these spells belong to the current actor in the loop
				for spellId, spellTable in petSpellContainer:ListSpells() do
					local spellName, _, spellIcon = GetSpellInfo(spellId)
					if (spellName) then
						bkSpellData.spellTables[#bkSpellData.spellTables+1] = spellTable
						---@type bknesteddata
						local nestedData = {spellId = spellId, spellTable = spellTable, actorName = petName, value = 0, bIsActorHeader = true} --value to be defined
						bkSpellData.nestedData[#bkSpellData.nestedData+1] = nestedData
					end
				end
			else
				local spells = petActor:GetSpellList()
				--all these spells belong to the current pet in the loop
				for spellId, spellTable in pairs(spells) do
					---@cast spellId number
					---@cast spellTable spelltable

					spellTable.ChartData = nil
					--PET
					---@type string
					local spellName = _GetSpellInfo(spellId)
					if (spellName) then
						---@type number in which index the spell with the same name was stored
						local index = alreadyAdded[spellName]
						if (index and bShouldMergePetSpells) then --PET
							---@type spelltableadv
							local bkSpellData = breakdownSpellDataList[index]

							bkSpellData.spellTables[#bkSpellData.spellTables+1] = spellTable

							---@type bknesteddata
							local nestedData = {spellId = spellId, spellTable = spellTable, actorName = petName, value = 0}
							bkSpellData.nestedData[#bkSpellData.nestedData+1] = nestedData
							bkSpellData.bCanExpand = true
						else --PET
							---@type spelltableadv
							local bkSpellData = {
								id = spellId,
								actorName = petName,
								npcId = petActor.aID,
								spellschool = spellTable.spellschool,
								bIsExpanded = Details222.BreakdownWindow.IsSpellExpanded(spellId),
								bCanExpand = false,

								spellTables = {spellTable},
								nestedData = {{spellId = spellId, spellTable = spellTable, actorName = petName, value = 0}},
							}

							detailsFramework:Mixin(bkSpellData, Details.SpellTableMixin)
							breakdownSpellDataList[#breakdownSpellDataList+1] = bkSpellData
							alreadyAdded[spellName] = #breakdownSpellDataList
						end
					end
				end
			end
		end
	end

	--copy the keys from the spelltable and add them to the spelltableadv
	--repeated spells will be summed
	for i = 1, #breakdownSpellDataList do
		---@type spelltableadv
		local bkSpellData = breakdownSpellDataList[i]
		Details.SpellTableMixin.SumSpellTables(bkSpellData.spellTables, bkSpellData)
		--Details:Destroy(bkSpellData, "spellTables") --temporary fix for BuildSpellTargetFromBreakdownSpellData, that function need to use bkSpellData.nestedData
	end

	breakdownSpellDataList.totalValue = actorTotal
	breakdownSpellDataList.combatTime = actorCombatTime

	Details:Destroy(alreadyAdded)

	--send to the breakdown window
	Details222.BreakdownWindow.SendSpellData(breakdownSpellDataList, actorObject, combatObject, instance)

	--targets

	---an array of breakdowntargettable
	---@type breakdowntargettablelist
	local targetList = {}

	local targetTotalValue = 0

	local targetsTable = self:GetTargets()
	for targetName, amount in pairs(targetsTable) do
		---@class breakdowntargettable
		local bkTargetData = {
			name = targetName,
			total = amount,
			overheal = 0,
		}
		targetTotalValue = targetTotalValue + amount
		tinsert(targetList, bkTargetData)
	end

	targetList.totalValue = targetTotalValue
	targetList.combatTime = actorCombatTime

	Details222.BreakdownWindow.SendTargetData(targetList, actorObject, combatObject, instance)

	if 1 then return end

	--to be deprecated and removed:

	--gump:JI_AtualizaContainerBarras(#actorSpellsSorted + 1)

	local max_ = breakdownSpellDataList[1] and breakdownSpellDataList[1][2] or 0 --dano que a primeiro magia vez
	local barra

	--aura bar
	if (false) then --disabled for now
		barra = allLines [1]
		if (not barra) then
			barra = gump:CriaNovaBarraInfo1(instance, 1)
		end
		self:UpdadeInfoBar(barra, "", -51, "Auras", max_, false, max_, 100, [[Interface\BUTTONS\UI-GroupLoot-DE-Up]], true, nil, nil)
		barra.textura:SetStatusBarColor(Details.gump:ParseColors("purple"))
	end

	--spell bars
	for index, tabela in ipairs(breakdownSpellDataList) do

		--index = index + 1 --with the aura bar
		index = index
		barra = allLines [index]
		if (not barra) then
			barra = gump:CriaNovaBarraInfo1(instance, index)
		end

		barra.other_actor = tabela [6]

		local name = tabela[4]

		if (breakdownWindowFrame.sub_atributo == 2) then
			local formated_value = selectedToKFunction(_, math.floor(tabela[2]/actorCombatTime))
			self:UpdadeInfoBar(barra, index, tabela[1], name, tabela[2], formated_value, max_, tabela[3], tabela[5], true, nil, tabela [7])
		else
			local formated_value = selectedToKFunction(_, math.floor(tabela[2]))
			self:UpdadeInfoBar(barra, index, tabela[1], name, tabela[2], formated_value, max_, tabela[3], tabela[5], true, nil, tabela [7])
		end

		self:FocusLock(barra, tabela[1])
	end

	--targets
	if (instance.sub_atributo == DETAILS_SUBATTRIBUTE_ENEMIES) then
		local totalDamageTaken = self.damage_taken
		local damageTakenFrom = self.damage_from
		local combatObject = instance:GetShowingCombat()
		local damageContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		local barras = breakdownWindowFrame.barras2
		local enemyTable = {}
		local targetName = self:Name()

		local enemyActorObject
		for enemyName in pairs(damageTakenFrom) do
			enemyActorObject = damageContainer:GetActor(enemyName)
			if (enemyActorObject) then
				local damageDoneToTarget = enemyActorObject.targets[targetName]
				if (damageDoneToTarget) then
					local npcId = DetailsFramework:GetNpcIdFromGuid(enemyActorObject:GetGUID())
					enemyTable[#enemyTable+1] = {enemyName, damageDoneToTarget, damageDoneToTarget / totalDamageTaken * 100, enemyActorObject:Class(), npcId}
				end
			end
		end

		local enemyAmount = #enemyTable

		if (enemyAmount < 1) then
			return true
		end

		gump:JI_AtualizaContainerAlvos(enemyAmount)

		table.sort(enemyTable, Details.Sort2)

		local topDamage = enemyTable[1] and enemyTable[1][2] or 0

		local thisLine
		for index, thisEnemyTable in ipairs(enemyTable) do
			thisLine = barras[index]

			if (not thisLine) then --se a barra n�o existir, criar ela ent�o
				thisLine = gump:CriaNovaBarraInfo2(instance, index)
				thisLine.textura:SetStatusBarColor(1, 1, 1, 1) --isso aqui � a parte da sele��o e descele��o
			end

			if (index == 1) then
				thisLine.textura:SetValue(100)
			else
				thisLine.textura:SetValue(thisEnemyTable[2] / topDamage * 100)
			end

			thisLine.lineText1:SetText(index .. ". " .. Details:GetOnlyName(thisEnemyTable[1])) --left text
			thisLine.lineText4:SetText(Details:comma_value(thisEnemyTable[2]) .. "(" .. format("%.1f", thisEnemyTable[3]) .. "%)") --right text

			thisLine.icone:SetTexture([[Interface\AddOns\Details\images\classes_small_alpha]]) --class icon

			local texCoords = Details.class_coords[thisEnemyTable[4]]
			if (not texCoords) then
				texCoords = Details.class_coords["UNKNOW"]
			end
			thisLine.icone:SetTexCoord(unpack(texCoords))

			local color = Details.class_colors[thisEnemyTable[4]]
			if (color) then
				thisLine.textura:SetStatusBarColor(unpack(color))
			else
				thisLine.textura:SetStatusBarColor(1, 1, 1)
			end

			Details:name_space_info(thisLine)

			if (thisLine.mouse_over) then --atualizar o tooltip
				if (thisLine.isAlvo) then
					GameTooltip:Hide()
					GameTooltip:SetOwner(thisLine, "ANCHOR_TOPRIGHT")
					if (not thisLine.minha_tabela:MontaTooltipDamageTaken(thisLine, index)) then
						return
					end
					GameTooltip:Show()
				end
			end

			thisLine.minha_tabela = self --grava o jogador na tabela
			thisLine.nome_inimigo = thisEnemyTable[1] --salva o nome do inimigo na barra --isso � necess�rio?

			-- no rank do spell id colocar o que?
			thisLine.spellid = "enemies"

			thisLine:Show() --mostra a barra
		end
	else
		local combatObject = instance:GetShowingCombat()
		local damageContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		local allActorTargets = {}

		--table with actor names and damage done which the player caused damage to
		local targetsTable = self.targets
		for targetName, damageDone in pairs(targetsTable) do
			tinsert(allActorTargets, {targetName, damageDone, damageDone / totalDamageWithoutPet * 100})
		end

		table.sort(allActorTargets, Details.Sort2)

		local enemyAmount = #allActorTargets
		if (enemyAmount < 1) then
			return
		end

		gump:JI_AtualizaContainerAlvos(enemyAmount)

		local topDamage = allActorTargets[1] and allActorTargets[1][2] or 0

		local barra
		for index, targetTable in ipairs(allActorTargets) do
			barra = breakdownWindowFrame.barras2[index]

			if (not barra) then
				barra = gump:CriaNovaBarraInfo2(instance, index)
				barra.textura:SetStatusBarColor(1, 1, 1, 1)
			end

			if (index == 1) then
				barra.textura:SetValue(100)
			else
				barra.textura:SetValue(targetTable[2] / topDamage * 100)
			end

			local targetName = targetTable[1]
			local targetActorObject = damageContainer:GetActor(targetName)

			if (targetActorObject) then
				local npcId = DetailsFramework:GetNpcIdFromGuid(targetActorObject:GetGUID())
				local portraitTexture -- = Details222.Textures.GetPortraitTextureForNpcID(npcId) disabled
				if (portraitTexture) then
					Details222.Textures.FormatPortraitAsTexture(portraitTexture, barra.icone)
				else
					targetActorObject:SetClassIcon(barra.icone, instance, targetActorObject.classe)
				end
			else
				barra.icone:SetTexture([[Interface\AddOns\Details\images\classes_small_alpha]]) --CLASSE
				local texCoords = Details.class_coords ["ENEMY"]
				barra.icone:SetTexCoord(unpack(texCoords))
			end

			barra.textura:SetStatusBarColor(1, 0.8, 0.8)
			barra.textura:SetStatusBarColor(1, 1, 1, 1)

			barra.lineText1:SetText(index .. ". " .. Details:GetOnlyName(targetName))

			if (breakdownWindowFrame.sub_atributo == 2) then
				barra.lineText4:SetText(Details:comma_value( math.floor(targetTable[2]/actorCombatTime)) .. "(" .. format("%.1f", targetTable[3]) .. "%)")
			else
				barra.lineText4:SetText(selectedToKFunction(_, targetTable[2]) .."(" .. format("%.1f", targetTable[3]) .. "%)")
			end

			if (barra.mouse_over) then --atualizar o tooltip
				if (barra.isAlvo) then
					if (not barra.minha_tabela:MontaTooltipAlvos(barra, index, instance)) then
						return
					end
				end
			end

			barra.minha_tabela = self --grava o jogador na tabela
			barra.nome_inimigo = targetTable [1] --salva o nome do inimigo na barra --isso � necess�rio?

			-- no rank do spell id colocar o que?
			barra.spellid = targetTable[5]
			barra:Show()
		end
	end
end


------ Detalhe Info Friendly Fire
function damageClass:MontaDetalhesFriendlyFire(nome, barra)

	local barras = breakdownWindowFrame.barras3
	local instancia = breakdownWindowFrame.instancia

	local tabela_do_combate = breakdownWindowFrame.instancia.showing
	local showing = tabela_do_combate [class_type] --o que esta sendo mostrado -> [1] - dano [2] - cura --pega o container com ._NameIndexTable ._ActorTable

	local friendlyfire = self.friendlyfire

	local ff_table = self.friendlyfire [nome] --assumindo que nome � o nome do Alvo que tomou dano // bastaria pegar a tabela de habilidades dele
	if (not ff_table) then
		return
	end
	local total = ff_table.total

	local minhas_magias = {}

	for spellid, amount in pairs(ff_table.spells) do --da foreach em cada spellid do container
		local nome, _, icone = _GetSpellInfo(spellid)
		tinsert(minhas_magias, {spellid, amount, amount / total * 100, nome, icone})
	end

	table.sort(minhas_magias, Details.Sort2)

	local max_ = minhas_magias[1] and minhas_magias[1][2] or 0 --dano que a primeiro magia vez
	local lastIndex = 1
	local barra
	for index, tabela in ipairs(minhas_magias) do
		lastIndex = index
		barra = barras [index]

		if (not barra) then --se a barra n�o existir, criar ela ent�o
			barra = gump:CriaNovaBarraInfo3(instancia, index)
			barra.textura:SetStatusBarColor(1, 1, 1, 1) --isso aqui � a parte da sele��o e descele��o
		end

		barra.show = tabela[1]

		if (index == 1) then
			barra.textura:SetValue(100)
		else
			barra.textura:SetValue(tabela[2]/max_*100) --muito mais rapido...
		end

		barra.lineText1:SetText(index..instancia.divisores.colocacao..tabela[4]) --seta o texto da esqueda
		barra.lineText4:SetText(Details:comma_value(tabela[2]) .. " " .. instancia.divisores.abre .. format("%.1f", tabela[3]) .. "%" .. instancia.divisores.fecha) --seta o texto da direita

		barra.icone:SetTexture(tabela[5])
		barra.icone:SetTexCoord(0, 1, 0, 1)

		barra:Show() --mostra a barra

		if (index == 15) then
			break
		end
	end

	for i = lastIndex+1, #barras do
		barras[i]:Hide()
	end

end

-- detalhes info enemies
function damageClass:MontaDetalhesEnemy(spellid, barra)

	local container = breakdownWindowFrame.instancia.showing[1]
	local barras = breakdownWindowFrame.barras3
	local instancia = breakdownWindowFrame.instancia

	local other_actor = barra.other_actor
	if (other_actor) then
		self = other_actor
	end

	if (barra.lineText1:IsTruncated()) then
		Details:CooltipPreset(2)
		GameCooltip:SetOption("FixedWidth", nil)
		GameCooltip:AddLine(barra.lineText1.text)
		GameCooltip:SetOwner(barra, "bottomleft", "topleft", 5, -10)
		GameCooltip:ShowCooltip()
	end

	local spell = self.spells:PegaHabilidade(spellid)

	local targets = spell.targets
	local target_pool = {}

	for target_name, amount in pairs(targets) do
		local classe
		local this_actor = breakdownWindowFrame.instancia.showing(1, target_name)
		if (this_actor) then
			classe = this_actor.classe or "UNKNOW"
		else
			classe = "UNKNOW"
		end

		target_pool [#target_pool+1] = {target_name, amount, classe}
	end

	table.sort(target_pool, Details.Sort2)

	local max_ = target_pool [1] and target_pool [1][2] or 0

	local lastIndex = 1
	local barra
	for index, tabela in ipairs(target_pool) do
		lastIndex = index
		barra = barras [index]

		if (not barra) then --se a barra n�o existir, criar ela ent�o
			barra = gump:CriaNovaBarraInfo3(instancia, index)
			barra.textura:SetStatusBarColor(1, 1, 1, 1) --isso aqui � a parte da sele��o e descele��o
		end

		barra.show = tabela[1]

		if (index == 1) then
			barra.textura:SetValue(100)
		else
			barra.textura:SetValue(tabela[2]/max_*100) --muito mais rapido...
		end

		barra.lineText1:SetText(index .. ". " .. Details:GetOnlyName(tabela [1])) --seta o texto da esqueda
		Details:name_space_info(barra)

		if (spell.total > 0) then
			barra.lineText4:SetText(Details:comma_value(tabela[2]) .."(".. format("%.1f", tabela[2] / spell.total * 100) .."%)") --seta o texto da direita
		else
			barra.lineText4:SetText(tabela[2] .."(0%)") --seta o texto da direita
		end

		local texCoords = Details.class_coords [tabela[3]]
		if (not texCoords) then
			texCoords = Details.class_coords ["UNKNOW"]
		end

		local color = Details.class_colors [tabela[3]]
		if (color) then
			barra.textura:SetStatusBarColor(unpack(color))
		else
			barra.textura:SetStatusBarColor(1, 1, 1, 1)
		end

		barra.icone:SetTexture("Interface\\AddOns\\Details\\images\\classes_small_alpha")
		barra.icone:SetTexCoord(unpack(texCoords))

		barra:Show() --mostra a barra

		if (index == 15) then
			break
		end
	end

	for i = lastIndex+1, #barras do
		barras[i]:Hide()
	end


end

------ Detalhe Info Damage Taken
function damageClass:MontaDetalhesDamageTaken(nome, barra)

	local barras = breakdownWindowFrame.barras3
	local instancia = breakdownWindowFrame.instancia

	local tabela_do_combate = breakdownWindowFrame.instancia.showing
	local showing = tabela_do_combate [class_type] --o que esta sendo mostrado -> [1] - dano [2] - cura --pega o container com ._NameIndexTable ._ActorTable

	local este_agressor = showing._ActorTable[showing._NameIndexTable[nome]]

	if (not este_agressor ) then
		return
	end

	local conteudo = este_agressor.spells._ActorTable --pairs[] com os IDs das magias

	local actor = breakdownWindowFrame.jogador.nome

	local total = este_agressor.targets [actor] or 0

	local minhas_magias = {}

	for spellid, tabela in pairs(conteudo) do --da foreach em cada spellid do container
		local este_alvo = tabela.targets [actor]
		if (este_alvo) then --esta magia deu dano no actor
			local spell_nome, rank, icone = _GetSpellInfo(spellid)
			tinsert(minhas_magias, {spellid, este_alvo, este_alvo/total*100, spell_nome, icone})
		end
	end

	table.sort(minhas_magias, Details.Sort2)

	--local amt = #minhas_magias
	--gump:JI_AtualizaContainerBarras(amt)

	local max_ = minhas_magias[1] and minhas_magias[1][2] or 0 --dano que a primeiro magia vez

	local lastIndex = 1
	local barra
	for index, tabela in ipairs(minhas_magias) do
		lastIndex = index
		barra = barras [index]

		if (not barra) then --se a barra n�o existir, criar ela ent�o
			barra = gump:CriaNovaBarraInfo3(instancia, index)
			barra.textura:SetStatusBarColor(1, 1, 1, 1) --isso aqui � a parte da sele��o e descele��o
		end

		barra.show = tabela[1]

		if (index == 1) then
			barra.textura:SetValue(100)
		else
			barra.textura:SetValue(tabela[2]/max_*100)
		end

		barra.lineText1:SetText(index .. "." .. tabela[4]) --seta o texto da esqueda
		Details:name_space_info(barra)

		barra.lineText4:SetText(Details:comma_value(tabela[2]) .." ".. instancia.divisores.abre ..format("%.1f", tabela[3]) .."%".. instancia.divisores.fecha) --seta o texto da direita

		barra.icone:SetTexture(tabela[5])
		barra.icone:SetTexCoord(0, 1, 0, 1)

		barra:Show() --mostra a barra

		if (index == 15) then
			break
		end
	end

	for i = lastIndex+1, #barras do
		barras[i]:Hide()
	end
end

------ Detalhe Info Damage Done e Dps
local defensesTable = {c = {1, 1, 1, 0.5}, p = 0}
local normalTable = {c = {1, 1, 1, 0.5}, p = 0}
local criticalTable = {c = {1, 1, 1, 0.5}, p = 0}
local columnSizes = {67,95,67,111,109,109,101,110,116,97,116,111,114}
Details.column_sizes = columnSizes
local dataTable = {}
local t1, t2, t3, t4 = {}, {}, {}, {}
local maxPercent = 100

---called from the spell breakdown when a spellbar is hovered over
---@param spellBar breakdownspellbar
---@param spellBlockContainer breakdownspellblockframe
---@param blockIndex number
---@param summaryBlock breakdownspellblock
---@param spellId number
---@param combatTime number
---@param actorName string
---@param spellTable spelltableadv
---@param trinketData trinketdata
---@param combatObject combat
function damageClass:BuildSpellDetails(spellBar, spellBlockContainer, blockIndex, summaryBlock, spellId, combatTime, actorName, spellTable, trinketData, combatObject)
	---@type number
	local totalHits = spellTable.counter

	--damage section showing damage done sub section
	blockIndex = blockIndex + 1

	do --update the texts in the summary block
		local blockLine1, blockLine2, blockLine3 = summaryBlock:GetLines()

		local totalCasts = spellBar.amountCasts > 0 and spellBar.amountCasts or "(?)"
		blockLine1.leftText:SetText(Loc ["STRING_CAST"] .. ": " .. totalCasts) --total amount of casts

		local trinketProcs = combatObject:GetTrinketProcsForPlayer(actorName)

		if (trinketData[spellId] and trinketProcs) then
			local trinketProcData = trinketProcs[actorName]
			if (trinketProcData) then
				local trinketProc = trinketProcData[spellId]
				if (trinketProc) then
					blockLine1.leftText:SetText("Procs: " .. trinketProc.total)
				end
			end

		elseif(Details.GetItemSpellInfo(spellId)) then
			blockLine1.leftText:SetText("Uses: " .. totalCasts)
		end

		blockLine1.rightText:SetText(Loc ["STRING_HITS"]..": " .. totalHits) --hits and uptime

		blockLine2.leftText:SetText(Loc ["STRING_DAMAGE"]..": " .. Details:Format(spellTable.total)) --total damage
		blockLine2.rightText:SetText(Details:GetSpellSchoolFormatedName(spellTable.spellschool)) --spell school

		blockLine3.leftText:SetText(Loc ["STRING_AVERAGE"] .. ": " .. Details:Format(spellBar.average)) --average damage
		if (spellBar.perSecond and spellBar.perSecond > 0) then
			blockLine3.rightText:SetText(Loc ["STRING_DPS"] .. ": " .. Details:CommaValue(spellBar.perSecond)) --dps
		else
			blockLine3.rightText:SetText(Loc ["STRING_DPS"] .. ": " .. Details:CommaValue(spellTable.total / combatTime)) --dps
		end
	end

	local emporwerSpell = spellTable.e_total
	if (emporwerSpell) then
		local empowerLevelSum = spellTable.e_total --total sum of empower levels
		local empowerAmount = spellTable.e_amt --amount of casts with empower
		local empowerAmountPerLevel = spellTable.e_lvl --{[1] = 4; [2] = 9; [3] = 15}
		local empowerDamagePerLevel = spellTable.e_dmg --{[1] = 54548745, [2] = 74548745}

		---@type breakdownspellblock
		local empowerBlock = spellBlockContainer:GetBlock(blockIndex)
		blockIndex = blockIndex + 1

		local level1AverageDamage = "0"
		local level2AverageDamage = "0"
		local level3AverageDamage = "0"
		local level4AverageDamage = "0"
		local level5AverageDamage = "0"

		if (empowerDamagePerLevel[1]) then
			level1AverageDamage = Details:Format(empowerDamagePerLevel[1] / empowerAmountPerLevel[1])
		end
		if (empowerDamagePerLevel[2]) then
			level2AverageDamage = Details:Format(empowerDamagePerLevel[2] / empowerAmountPerLevel[2])
		end
		if (empowerDamagePerLevel[3]) then
			level3AverageDamage = Details:Format(empowerDamagePerLevel[3] / empowerAmountPerLevel[3])
		end
		if (empowerDamagePerLevel[4]) then
			level4AverageDamage = Details:Format(empowerDamagePerLevel[4] / empowerAmountPerLevel[4])
		end
		if (empowerDamagePerLevel[5]) then
			level5AverageDamage = Details:Format(empowerDamagePerLevel[5] / empowerAmountPerLevel[5])
		end

		empowerBlock:Show()
		empowerBlock:SetValue(100)

		empowerBlock.sparkTexture:SetPoint("left", empowerBlock, "left", empowerBlock:GetWidth() + Details.breakdown_spell_tab.blockspell_spark_offset, 0)
		empowerBlock:SetColor(0.200, 0.576, 0.498, 0.6)

		local blockLine1, blockLine2, blockLine3 = empowerBlock:GetLines()
		blockLine1.leftText:SetText("Spell Empower Average Level: " .. string.format("%.2f", empowerLevelSum / empowerAmount))

		if (level1AverageDamage ~= "0") then
			blockLine2.leftText:SetText("#1 Avg: " .. level1AverageDamage .. "(" ..(empowerAmountPerLevel[1] or 0) .. ")")
		end

		if (level2AverageDamage ~= "0") then
			blockLine2.centerText:SetText("#2 Avg: " .. level2AverageDamage .. "(" ..(empowerAmountPerLevel[2] or 0) .. ")")
		end

		if (level3AverageDamage ~= "0") then
			blockLine2.rightText:SetText("#3 Avg: " .. level3AverageDamage .. "(" ..(empowerAmountPerLevel[3] or 0) .. ")")
		end

		if (level4AverageDamage ~= "0") then
			blockLine3.leftText:SetText("#4 Avg: " .. level4AverageDamage .. "(" ..(empowerAmountPerLevel[4] or 0) .. ")")
		end

		if (level5AverageDamage ~= "0") then
			blockLine3.rightText:SetText("#5 Avg: " .. level5AverageDamage .. "(" ..(empowerAmountPerLevel[5] or 0) .. ")")
		end
	end

	--check if there's normal hits and build the block
	---@type number
	local normalHitsAmt = spellTable.n_amt

	if (normalHitsAmt > 0) then
		---@type breakdownspellblock
		local normalHitsBlock = spellBlockContainer:GetBlock(blockIndex)
		normalHitsBlock:Show()
		blockIndex = blockIndex + 1

		local percent = normalHitsAmt / math.max(totalHits, 0.0001) * 100
		normalHitsBlock:SetValue(percent)
		normalHitsBlock.sparkTexture:SetPoint("left", normalHitsBlock, "left", percent / 100 * normalHitsBlock:GetWidth() + Details.breakdown_spell_tab.blockspell_spark_offset, 0)

		local blockLine1, blockLine2, blockLine3 = normalHitsBlock:GetLines()
		blockLine1.leftText:SetText(Loc ["STRING_NORMAL_HITS"])
		blockLine1.rightText:SetText(normalHitsAmt .. " [|cFFC0C0C0" .. string.format("%.1f", normalHitsAmt / math.max(totalHits, 0.0001) * 100) .. "%|r]")

		blockLine2.leftText:SetText(Loc ["STRING_MINIMUM_SHORT"] .. ": " .. Details:CommaValue(spellTable.n_min))
		blockLine2.rightText:SetText(Loc ["STRING_MAXIMUM_SHORT"] .. ": " .. Details:CommaValue(spellTable.n_max))

		local normalAverage = spellTable.n_total / math.max(normalHitsAmt, 0.0001)
		blockLine3.leftText:SetText(Loc ["STRING_AVERAGE"] .. ": " .. Details:CommaValue(normalAverage))

		local tempo =(combatTime * spellTable.n_total) / math.max(spellTable.total, 0.001)
		local normalAveragePercent = spellBar.average / normalAverage * 100
		local normalTempoPercent = normalAveragePercent * tempo / 100
		blockLine3.rightText:SetText(Loc ["STRING_DPS"] .. ": " .. Details:CommaValue(spellTable.n_total / normalTempoPercent))
	end

	---@type number
	local criticalHitsAmt = spellTable.c_amt
	if (criticalHitsAmt > 0) then
		---@type breakdownspellblock
		local critHitsBlock = spellBlockContainer:GetBlock(blockIndex)
		critHitsBlock:Show()
		blockIndex = blockIndex + 1

		local percent = Details.SpellTableMixin.GetCritPercent(spellTable)
		critHitsBlock:SetValue(percent)
		critHitsBlock.sparkTexture:SetPoint("left", critHitsBlock, "left", percent / 100 * critHitsBlock:GetWidth() + Details.breakdown_spell_tab.blockspell_spark_offset, 0)

		local blockLine1, blockLine2, blockLine3 = critHitsBlock:GetLines()
		blockLine1.leftText:SetText(Loc ["STRING_CRITICAL_HITS"])
		blockLine1.rightText:SetText(criticalHitsAmt .. " [|cFFC0C0C0" .. string.format("%.1f", criticalHitsAmt / math.max(totalHits, 0.0001) * 100) .. "%|r]")

		blockLine2.leftText:SetText(Loc ["STRING_MINIMUM_SHORT"] .. ": " .. Details:CommaValue(spellTable.c_min))
		blockLine2.rightText:SetText(Loc ["STRING_MAXIMUM_SHORT"] .. ": " .. Details:CommaValue(spellTable.c_max))

		local critAverage = Details.SpellTableMixin.GetCritAverage(spellTable)
		blockLine3.leftText:SetText(Loc ["STRING_AVERAGE"] .. ": " .. Details:CommaValue(critAverage))

		local tempo =(combatTime * spellTable.c_total) / math.max(spellTable.total, 0.001)
		local critAveragePercent = spellBar.average / critAverage * 100
		local critTempoPercent = critAveragePercent * tempo / 100
		blockLine3.rightText:SetText(Loc ["STRING_DPS"] .. ": " .. Details:CommaValue(spellTable.c_total / critTempoPercent))
	end

	--missing hits
	local semiDodgeAmount = spellTable.g_amt + spellTable.b_amt --glancing and blocking
	local fullDodgeAmount = spellTable["DODGE"] or 0
	local parryAmount = spellTable["PARRY"] or 0
	local missedHitsAmount = spellTable["MISS"] or 0

	local hitErrorsAmount = parryAmount + fullDodgeAmount + missedHitsAmount

	if (semiDodgeAmount > 0 or hitErrorsAmount > 0) then
		---@type breakdownspellblock
		local defensesBlock = spellBlockContainer:GetBlock(blockIndex)
		defensesBlock:Show()
		blockIndex = blockIndex + 1

		local percent =(semiDodgeAmount + hitErrorsAmount) / spellTable.counter * 100
		defensesBlock:SetValue(percent)
		defensesBlock.sparkTexture:SetPoint("left", defensesBlock, "left", percent / 100 * defensesBlock:GetWidth() + Details.breakdown_spell_tab.blockspell_spark_offset, 0)

		local blockLine1, blockLine2, blockLine3 = defensesBlock:GetLines()
		blockLine1.leftText:SetText(Loc ["STRING_DEFENSES"])
		blockLine1.rightText:SetText((semiDodgeAmount + hitErrorsAmount) .. " / " .. format("%.1f", percent) .. "%")

		if (missedHitsAmount > 0) then
			blockLine2.leftText:SetText("Miss" .. ": " .. missedHitsAmount)
		end
		if (parryAmount > 0) then
			blockLine2.centerText:SetText(Loc ["STRING_PARRY"] .. ": " .. parryAmount)
		end
		if (fullDodgeAmount > 0) then
			blockLine2.rightText:SetText(Loc ["STRING_DODGE"] .. ": " .. fullDodgeAmount)
		end
		if (spellTable.b_amt > 0) then
			blockLine3.leftText:SetText(Loc ["STRING_BLOCKED"] .. ": " .. spellTable.b_amt)
		end
		if (spellTable.g_amt > 0) then
			blockLine3.rightText:SetText(Loc ["STRING_GLANCING"] .. ": " .. spellTable.g_amt)
		end
	end

	if (trinketData[spellId]) then
		---@type trinketdata
		local trinketInfo = trinketData[spellId]

		local minTime = trinketInfo.minTime
		local maxTime = trinketInfo.maxTime
		local average = trinketInfo.averageTime

		---@type breakdownspellblock
		local trinketBlock = spellBlockContainer:GetBlock(blockIndex)
		trinketBlock:Show()
		trinketBlock:SetValue(100)
		trinketBlock.sparkTexture:SetPoint("left", trinketBlock, "left", trinketBlock:GetWidth() + Details.breakdown_spell_tab.blockspell_spark_offset, 0)
		blockIndex = blockIndex + 1

		local blockLine1, blockLine2, blockLine3 = trinketBlock:GetLines()
		blockLine1.leftText:SetText("Trinket Info")

		blockLine1.rightText:SetText("PPM: " .. string.format("%.2f", average / 60))
		if (minTime == 9999999) then
			blockLine2.leftText:SetText("Min Time: " .. _G["UNKNOWN"])
		else
			blockLine2.leftText:SetText("Min Time: " .. math.floor(minTime))
		end
		blockLine2.rightText:SetText("Max Time: " .. math.floor(maxTime))
	end
end

function Details:BuildPlayerDetailsSpellChart()
	local playerDetailSmallChart = DetailsPlayerDetailSmallChart

	if (not playerDetailSmallChart) then

		playerDetailSmallChart = CreateFrame("frame", "DetailsPlayerDetailSmallChart", breakdownWindowFrame,"BackdropTemplate")
		DetailsFramework:ApplyStandardBackdrop(playerDetailSmallChart)
		playerDetailSmallChart.Lines = {}

		for i = 1, 200 do
			local texture = playerDetailSmallChart:CreateTexture(nil, "artwork")
			texture:SetColorTexture(1, 1, 1, 1)
			tinsert(playerDetailSmallChart.Lines, texture)
		end

		--Details.BreakdownWindowFrame.grupos_detalhes [index]
		function playerDetailSmallChart.ShowChart(parent, combatObject, cleuData, playerName, targetName, spellId, ...)
			local tokenIdList = {}
			local eventList = {}

			--build the list of tokens
			for i = 1, select("#", ... ) do
				local tokenId = select(i, ...)
				tokenIdList [tokenId] = true
			end

			--check which lines can be added
			local index = 1
			local peakValue = 0

			for i = 1, cleuData.n -1 do
				local event = cleuData [i]
				if (event [2]) then --index 2 = token
					local playerNameFilter = playerName and playerName == event [3]
					local targetNameFilter = targetName and targetName == event [4]
					local spellIdFilter = spellId and spellId == event [5]

					if (playerNameFilter or targetNameFilter or spellIdFilter) then
						eventList [index] = cleuData [i]
						if (peakValue < cleuData [i] [6]) then
							peakValue = cleuData [i] [6]
						end
						index = index + 1
					end
				end
			end

			--200 lines, adjust the mini chart
			playerDetailSmallChart:SetPoint("topleft", parent, "topleft")
			playerDetailSmallChart:SetPoint("bottomright", parent, "bottomright")

			--update lines
			local width = playerDetailSmallChart:GetWidth()
			local combatTime = combatObject:GetCombatTime()
			local secondsPerBar = combatTime / 200
			local barWidth = width / 200
			local barHeight = playerDetailSmallChart:GetHeight()

			local currentTime = eventList [1][1]
			local currentIndex = 1
			local eventAmount = #eventList

			for i = 1, #playerDetailSmallChart.Lines do
				playerDetailSmallChart.Lines [i]:SetWidth(width / 200)
				playerDetailSmallChart.Lines [i]:SetHeight(1)

				for o = currentIndex, eventAmount do
					if (eventList [o][1] <= currentTime + secondsPerBar or eventList [o][1] >= currentTime) then
						playerDetailSmallChart.Lines [i]:SetPoint("bottomleft", playerDetailSmallChart, "bottomleft", barWidth  *(i - 1), 0)
						playerDetailSmallChart.Lines [i]:SetWidth(barWidth)
						playerDetailSmallChart.Lines [i]:SetHeight(eventList [o][6] / peakValue * barHeight)
					else
						currentIndex = o
						break
					end
				end

				currentTime = currentTime + secondsPerBar
			end
		end
	end
end

function damageClass:MontaTooltipDamageTaken(thisLine, index)
	local aggressor = breakdownWindowFrame.instancia.showing [1]:PegarCombatente(_, thisLine.nome_inimigo)
	local container = aggressor.spells._ActorTable
	local habilidades = {}

	local total = 0

	for spellid, spell in pairs(container) do
		for target_name, amount in pairs(spell.targets) do
			if (target_name == self.nome) then
				total = total + amount
				habilidades [#habilidades+1] = {spellid, amount}
			end
		end
	end

	table.sort(habilidades, Details.Sort2)

	GameTooltip:AddLine(index..". "..thisLine.nome_inimigo)
	GameTooltip:AddLine(Loc ["STRING_DAMAGE_TAKEN_FROM2"]..":")
	GameTooltip:AddLine(" ")

	for index, tabela in ipairs(habilidades) do
		local nome, _, icone = _GetSpellInfo(tabela[1])
		if (index < 8) then
			GameTooltip:AddDoubleLine(index..". |T"..icone..":0|t "..nome, Details:comma_value(tabela[2]).."("..format("%.1f", tabela[2]/total*100).."%)", 1, 1, 1, 1, 1, 1)
		else
			GameTooltip:AddDoubleLine(index..". "..nome, Details:comma_value(tabela[2]).."("..format("%.1f", tabela[2]/total*100).."%)", .65, .65, .65, .65, .65, .65)
		end
	end

	return true
	--GameTooltip:AddDoubleLine(meus_danos[i][4][1]..": ", meus_danos[i][2].."(".._cstr("%.1f", meus_danos[i][3]).."%)", 1, 1, 1, 1, 1, 1)

end

function damageClass:MontaTooltipAlvos(thisLine, index, instancia) --~deprecated

	local inimigo = thisLine.nome_inimigo
	local habilidades = {}
	local total = self.total
	local i = 1

	Details:FormatCooltipForSpells()
	GameCooltip:SetOwner(thisLine, "bottom", "top", 4, -2)
	GameCooltip:SetOption("MinWidth", math.max(230, thisLine:GetWidth()*0.98))

	for spellid, spell in pairs(self.spells._ActorTable) do
		if (spell.isReflection) then
			for target_name, amount in pairs(spell.targets) do
				if (target_name == inimigo) then
					for reflectedSpellId, amount in pairs(spell.extra) do
						local spellName, _, spellIcon = _GetSpellInfo(reflectedSpellId)
						local t = habilidades [i]
						if (not t) then
							habilidades [i] = {}
							t = habilidades [i]
						end

						t[1], t[2], t[3] = spellName .. "(|cFFCCBBBBreflected|r)", amount, spellIcon
						i = i + 1
					end
				end
			end
		else
			for target_name, amount in pairs(spell.targets) do
				if (target_name == inimigo) then
					local nome, _, icone = _GetSpellInfo(spellid)

					local t = habilidades [i]
					if (not t) then
						habilidades [i] = {}
						t = habilidades [i]
					end

					t[1], t[2], t[3] = nome, amount, icone
					i = i + 1
				end
			end
		end
	end

	--add pets
	for _, PetName in ipairs(self.pets) do
		local PetActor = instancia.showing(class_type, PetName)
		if (PetActor) then
			local PetSkillsContainer = PetActor.spells._ActorTable
			for _spellid, _skill in pairs(PetSkillsContainer) do

				local alvos = _skill.targets
				for target_name, amount in pairs(alvos) do
					if (target_name == inimigo) then

						local t = habilidades [i]
						if (not t) then
							habilidades [i] = {}
							t = habilidades [i]
						end

						local nome, _, icone = _GetSpellInfo(_spellid)
						t[1], t[2], t[3] = nome .. "(" .. PetName:gsub((" <.*"), "") .. ")", amount, icone

						i = i + 1
					end
				end
			end
		end
	end

	table.sort(habilidades, Details.Sort2)

	--get time type
	local meu_tempo
	if (Details.time_type == 1 or not self.grupo) then
		meu_tempo = self:Tempo()
	elseif(Details.time_type == 2 or Details.use_realtimedps) then
		meu_tempo = breakdownWindowFrame.instancia.showing:GetCombatTime()
	end

	local is_dps = breakdownWindowFrame.instancia.sub_atributo == 2

	if (is_dps) then
		Details:AddTooltipSpellHeaderText(Loc ["STRING_DAMAGE_DPS_IN"] .. ":", {1, 0.9, 0.0, 1}, 1, Details.tooltip_spell_icon.file, unpack(Details.tooltip_spell_icon.coords))
		Details:AddTooltipHeaderStatusbar(1, 1, 1, 1)

	else
		Details:AddTooltipSpellHeaderText(Loc ["STRING_DAMAGE_FROM"] .. ":", {1, 0.9, 0.0, 1}, 1, Details.tooltip_spell_icon.file, unpack(Details.tooltip_spell_icon.coords))
		Details:AddTooltipHeaderStatusbar(1, 1, 1, 1)
	end

	local icon_size = Details.tooltip.icon_size
	local icon_border = Details.tooltip.icon_border_texcoord

	local topSpellDamage = habilidades[1] and habilidades[1][2]

	if (topSpellDamage) then
		for index, tabela in ipairs(habilidades) do
			if (tabela [2] < 1) then
				break
			end

			if (is_dps) then
				--GameCooltip:AddDoubleLine(index..". |T"..tabela[3]..":0|t "..tabela[1], Details:comma_value( math.floor(tabela[2] / meu_tempo) ).."(".._cstr("%.1f", tabela[2]/total*100).."%)", 1, 1, 1, 1, 1, 1)
				GameCooltip:AddLine(tabela[1], Details:comma_value( math.floor(tabela[2] / meu_tempo) ).."("..format("%.1f", tabela[2]/total*100).."%)")
			else
				--GameCooltip:AddDoubleLine(index..". |T"..tabela[3]..":0|t " .. tabela[1], SelectedToKFunction(_, tabela[2]) .. "(".._cstr("%.1f", tabela[2]/total*100).."%)", 1, 1, 1, 1, 1, 1)
				GameCooltip:AddLine(tabela[1], selectedToKFunction(_, tabela[2]) .. "("..format("%.1f", tabela[2]/total*100).."%)")
			end

			GameCooltip:AddIcon(tabela[3], nil, nil, icon_size.W + 4, icon_size.H + 4, icon_border.L, icon_border.R, icon_border.T, icon_border.B)
			Details:AddTooltipBackgroundStatusbar(false, tabela[2] / topSpellDamage * 100)
		end
	end

	GameCooltip:Show()

	return true
end

--controls the activity time of the actor
function damageClass:GetOrChangeActivityStatus(activityStatus)
	if (activityStatus == nil) then
		--if no value passed, return the current activity status
		return self.dps_started

	elseif(activityStatus) then
		self.dps_started = true
		Details222.TimeMachine.AddActor(self)

	else
		self.dps_started = false
		Details222.TimeMachine.RemoveActor(self)
	end
end Details.network_key = "Comm"

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--core functions

	--clear cache tables when resetting data
		function damageClass:ClearCacheTables()
			for i = #ntable, 1, -1 do
				ntable [i] = nil
			end

			for i = #vtable, 1, -1 do
				vtable [i] = nil
			end

			for i = #bs_table, 1, -1 do
				bs_table [i] = nil
			end

			if (bs_tooltip_table) then
				Details:Destroy(bs_tooltip_table)
			end

			if (frags_tooltip_table) then
				Details:Destroy(frags_tooltip_table)
			end

			Details:Destroy(bs_index_table)
			Details:Destroy(tooltip_temp_table)
			Details:Destroy(tooltip_void_zone_temp)
		end

	--atualize a funcao de abreviacao
		function damageClass:UpdateSelectedToKFunction()
			selectedToKFunction = ToKFunctions [Details.ps_abbreviation]
			formatTooltipNumber = ToKFunctions [Details.tooltip.abbreviation]
			tooltipMaximizedMethod = Details.tooltip.maximize_method
			headerColor = Details.tooltip.header_text_color
		end

	--diminui o total das tabelas do combate
		function damageClass:subtract_total(combat_table)
			combat_table.totals [class_type] = combat_table.totals [class_type] - self.total
			if (self.grupo) then
				combat_table.totals_grupo [class_type] = combat_table.totals_grupo [class_type] - self.total
			end
		end
		function damageClass:add_total(combat_table)
			combat_table.totals [class_type] = combat_table.totals [class_type] + self.total
			if (self.grupo) then
				combat_table.totals_grupo [class_type] = combat_table.totals_grupo [class_type] + self.total
			end
		end

	---sum the passed actor into a combat, if the combat isn't passed, it will use the overall combat
	---the function returns the actor that was created of found in the combat passed
	---@param actorObject actor
	---@param bRefreshActor boolean|nil
	---@param combatObject combat|nil
	---@return actor
	function damageClass:AddToCombat(actorObject, bRefreshActor, combatObject)
		--check if there's a custom combat, if not just use the overall container
		combatObject = combatObject or Details.tabela_overall --same as Details:GetCombat(DETAILS_SEGMENTID_OVERALL)

		--check if the combatObject has an actor with the same name, if not, just create one new
		local actorContainer = combatObject[DETAILS_ATTRIBUTE_DAMAGE] --same as combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		local overallActor = actorContainer._ActorTable[actorContainer._NameIndexTable[actorObject.nome]] --same as actorContainer:GetActor(actorObject:Name())

		if (not overallActor) then
			overallActor = actorContainer:GetOrCreateActor(actorObject.serial, actorObject.nome, actorObject.flag_original, true)
			overallActor.classe = actorObject.classe
			overallActor:SetSpecId(actorObject.spec)
			overallActor.isTank = actorObject.isTank
			overallActor.pvp = actorObject.pvp
			overallActor.boss = actorObject.boss
			overallActor.start_time = time() - 3
			overallActor.end_time = time()
		end

		overallActor.displayName = actorObject.displayName or actorObject.nome
		overallActor.boss_fight_component = actorObject.boss_fight_component or overallActor.boss_fight_component
		overallActor.fight_component = actorObject.fight_component or overallActor.fight_component
		overallActor.grupo = actorObject.grupo or overallActor.grupo

		--check if need to restore meta tables and indexes for this actor
		if (bRefreshActor) then
			--this call will reenable the metatable, __index and set the metatable on the .spells container
			Details.refresh:r_atributo_damage(actorObject)
		end

		--elapsed time
		local endTime = actorObject.end_time
		if (not actorObject.end_time) then
			endTime = time()
		end

		local tempo = endTime - actorObject.start_time
		overallActor.start_time = overallActor.start_time - tempo

		--pets(add unique pet names)
		for _, petName in ipairs(actorObject.pets) do --same as actorObject:GetPets()
			DetailsFramework.table.addunique(overallActor.pets, petName)
		end

		---@cast actorObject actordamage

		--sum total damage
		overallActor.total = overallActor.total + actorObject.total
		overallActor.total_extra = overallActor.total_extra + actorObject.total_extra
		overallActor.totalabsorbed = overallActor.totalabsorbed + actorObject.totalabsorbed

		--sum total damage without pet
		overallActor.total_without_pet = overallActor.total_without_pet + actorObject.total_without_pet

		--sum total damage taken
		overallActor.damage_taken = overallActor.damage_taken + actorObject.damage_taken

		--sum friendly fire
		overallActor.friendlyfire_total = overallActor.friendlyfire_total + actorObject.friendlyfire_total

		--sum total damage on the combatObject passed
		combatObject.totals[1] = combatObject.totals[1] + actorObject.total
		if (actorObject.grupo) then
			combatObject.totals_grupo[1] = combatObject.totals_grupo[1] + actorObject.total
		end

		--copy damage taken from
		for aggressorName, _ in pairs(actorObject.damage_from) do
			overallActor.damage_from[aggressorName] = true
		end

		--copy targets
		for targetName, amount in pairs(actorObject.targets) do
			overallActor.targets[targetName] =(overallActor.targets[targetName] or 0) + amount
		end

		--copy raid targets
		for flag, amount in pairs(actorObject.raid_targets) do
			overallActor.raid_targets = overallActor.raid_targets or {}
			overallActor.raid_targets[flag] =(overallActor.raid_targets[flag] or 0) + amount
		end

		---@type spellcontainer
		local overallSpellsContainer = overallActor.spells --same as overallActor:GetSpellContainer("spell")

		--copy spell table
		for spellId, spellTable in pairs(actorObject.spells._ActorTable) do --same as overallSpellsContainer:GetRawSpellTable()
			--var name has 'overall' but this function accepts any combat table
			local overallSpellTable = overallSpellsContainer:GetOrCreateSpell(spellId, true)

			--sum spell targets
			for targetName, amount in pairs(spellTable.targets) do
				overallSpellTable.targets[targetName] =(overallSpellTable.targets[targetName] or 0) + amount
			end

			--refresh and add extra values
			for extraSpellId, amount in pairs(spellTable.extra) do
				overallSpellTable.extra[extraSpellId] =(overallSpellTable.extra[extraSpellId] or 0) + amount
			end

			overallSpellTable.spellschool = spellTable.spellschool

			--sum all values of the spelltable which can be summed
			for key, value in pairs(spellTable) do
				if (type(value) == "number") then
					if (key ~= "id" and key ~= "spellschool") then
						if (not overallSpellTable [key]) then
							overallSpellTable [key] = 0
						end

						if (key == "n_min" or key == "c_min") then
							if (overallSpellTable [key] > value) then
								overallSpellTable [key] = value
							end
						elseif(key == "n_max" or key == "c_max") then
							if (overallSpellTable [key] < value) then
								overallSpellTable [key] = value
							end
						else
							overallSpellTable [key] = overallSpellTable [key] + value
						end
					end

				--empowered spells
				elseif(key == "e_dmg" or key == "e_lvl") then
					if (not overallSpellTable[key]) then
						overallSpellTable[key] = {}
					end
					for empowermentLevel, empowermentValue in pairs(spellTable[key]) do
						overallSpellTable[key][empowermentLevel] = empowermentValue
					end
				end
			end
		end

		if (actorObject.augmentedSpellsContainer) then
			local overallAugmentedSpellsContainer = overallActor.augmentedSpellsContainer or spellContainerClass:CreateSpellContainer(Details.container_type.CONTAINER_DAMAGE_CLASS)
			overallActor.augmentedSpellsContainer = overallAugmentedSpellsContainer

			for spellId, spellTable in pairs(actorObject.augmentedSpellsContainer._ActorTable) do --same as actorObject.augmentedSpellsContainer:GetRawSpellTable()
				local overallSpellTable = overallAugmentedSpellsContainer:GetOrCreateSpell(spellId, true)
				overallSpellTable.total = overallSpellTable.total + spellTable.total
				for targetName, amount in pairs(spellTable.targets) do
					overallSpellTable.targets[targetName] =(overallSpellTable.targets[targetName] or 0) + amount
				end
			end
		end

		--copy the friendly fire container
		for targetName, friendlyFireTable in pairs(actorObject.friendlyfire) do
			--get or create the friendly fire table in the overall data
			local friendlyFireOverall = overallActor.friendlyfire[targetName] or overallActor:CreateFFTable(targetName)
			--sum the total
			friendlyFireOverall.total = friendlyFireOverall.total + friendlyFireTable.total
			--sum spells
			for friendlyFireSpellId, amount in pairs(friendlyFireTable.spells) do
				friendlyFireOverall.spells[friendlyFireSpellId] =(friendlyFireOverall.spells[friendlyFireSpellId] or 0) + amount
			end
		end

		return overallActor
	end

--actor 1 is who will receive the sum from actor2
function Details.SumDamageActors(actor1, actor2, actorContainer) --not called anywhere, can be deprecated
	--general
	actor1.total = actor1.total + actor2.total
	actor1.damage_taken = actor1.damage_taken + actor2.damage_taken
	actor1.totalabsorbed = actor1.totalabsorbed + actor2.totalabsorbed
	actor1.total_without_pet = actor1.total_without_pet + actor2.total_without_pet
	actor1.friendlyfire_total = actor1.friendlyfire_total + actor2.friendlyfire_total

	--damage taken from
	for actorName in pairs(actor2.damage_from) do
		actor1.damage_from[actorName] = true

		--add the damage done to actor2 into the damage done to target1
		if (actorContainer) then
			--get the actor that caused the damage on actor2
			local actorObject = actorContainer:GetActor(actorName)
			if (actorObject) then
				local damageToActor2 =(actorObject.targets[actor2.nome]) or 0
				actorObject.targets[actor1.nome] =(actorObject.targets[actor1.nome] or 0) + damageToActor2
			end
		end
	end

	--targets
	for actorName, damageDone in pairs(actor2.targets) do
		actor1.targets[actorName] =(actor1.targets[actorName] or 0) + damageDone
	end

	--pets
	for i = 1, #actor2.pets do
		DetailsFramework.table.addunique(actor1.pets, actor2.pets[i])
	end

	--raid targets
	for raidTargetFlag, damageDone in pairs(actor2.raid_targets) do
		actor1.raid_targets[raidTargetFlag] =(actor1.raid_targets[raidTargetFlag] or 0) + damageDone
	end

	--friendly fire
	for actorName, ffTable in pairs(actor2.friendlyfire) do
		actor1.friendlyfire[actorName] = actor1.friendlyfire[actorName] or actor1:CreateFFTable(actorName)
		actor1.friendlyfire[actorName].total = actor1.friendlyfire[actorName].total + ffTable.total

		for spellId, damageDone in pairs(ffTable.spells) do
			actor1.friendlyfire[actorName].spells[spellId] =(actor1.friendlyfire[actorName].spells[spellId] or 0) + damageDone
		end
	end

	--spells
	local ignoredKeys = {
		id = true,
		spellschool =  true,
	}

	local actor1Spells = actor1.spells
	for spellId, spellTable in pairs(actor2.spells._ActorTable) do

		local actor1Spell = actor1Spells:GetOrCreateSpell(spellId, true, "DAMAGE_DONE")

		--genetal spell attributes
		for key, value in pairs(spellTable) do
			if (type(value) == "number") then
				if (not ignoredKeys[key]) then
					if (key == "n_min" or key == "c_min") then
						if (actor1Spell[key] > value) then
							actor1Spell[key] = value
						end
					elseif(key == "n_max" or key == "c_max") then
						if (actor1Spell[key] < value) then
							actor1Spell[key] = value
						end
					else
						actor1Spell[key] = actor1Spell[key] + value
					end
				end
			end
		end

		--spell targets
		for targetName, damageDone in pairs(spellTable) do
			actor1Spell.targets[targetName] =(actor1Spell.targets[targetName] or 0) + damageDone
		end
	end
end


damageClass.__add = function(tabela1, tabela2)

	--tempo decorrido
		local tempo =(tabela2.end_time or time()) - tabela2.start_time
		tabela1.start_time = tabela1.start_time - tempo

	--total de dano
		tabela1.total = tabela1.total + tabela2.total
		tabela1.totalabsorbed = tabela1.totalabsorbed + tabela2.totalabsorbed
	--total de dano sem o pet
		tabela1.total_without_pet = tabela1.total_without_pet + tabela2.total_without_pet
	--total de dano que o cara levou
		tabela1.damage_taken = tabela1.damage_taken + tabela2.damage_taken
	--total do friendly fire causado
		tabela1.friendlyfire_total = tabela1.friendlyfire_total + tabela2.friendlyfire_total

	--soma o damage_from
		for nome, _ in pairs(tabela2.damage_from) do
			tabela1.damage_from [nome] = true
		end

		--pets(add unique pet names)
		for _, petName in ipairs(tabela2.pets) do
			local hasPet = false
			for i = 1, #tabela1.pets do
				if (tabela1.pets[i] == petName) then
					hasPet = true
					break
				end
			end

			if (not hasPet) then
				tabela1.pets [#tabela1.pets+1] = petName
			end
		end

	--soma os containers de alvos
		for target_name, amount in pairs(tabela2.targets) do
			tabela1.targets [target_name] =(tabela1.targets [target_name] or 0) + amount
		end

	--soma o container de raid targets
		for flag, amount in pairs(tabela2.raid_targets) do
			tabela1.raid_targets [flag] =(tabela1.raid_targets [flag] or 0) + amount
		end

	--soma o container de habilidades
		for spellid, habilidade in pairs(tabela2.spells._ActorTable) do
			--pega a habilidade no primeiro ator
			local habilidade_tabela1 = tabela1.spells:PegaHabilidade(spellid, true, "SPELL_DAMAGE", false)

			--soma os alvos
			for target_name, amount in pairs(habilidade.targets) do
				habilidade_tabela1.targets[target_name] =(habilidade_tabela1.targets [target_name] or 0) + amount
			end

			--soma os extras
			for spellId, amount in pairs(habilidade.extra) do
				habilidade_tabela1.extra =(habilidade_tabela1.extra [spellId] or 0) + amount
			end

			--soma os valores da habilidade
			for key, value in pairs(habilidade) do
				if (type(value) == "number") then
					if (key ~= "id" and key ~= "spellschool") then
						if (not habilidade_tabela1 [key]) then
							habilidade_tabela1 [key] = 0
						end

						if (key == "n_min" or key == "c_min") then
							if (habilidade_tabela1 [key] > value) then
								habilidade_tabela1 [key] = value
							end
						elseif(key == "n_max" or key == "c_max") then
							if (habilidade_tabela1 [key] < value) then
								habilidade_tabela1 [key] = value
							end
						else
							habilidade_tabela1 [key] = habilidade_tabela1 [key] + value
						end

					end
				elseif(key == "e_dmg" or key == "e_lvl") then
					if (not habilidade_tabela1[key]) then
						habilidade_tabela1[key] = {}
					end
					for empowermentLevel, empowermentValue in pairs(habilidade[key]) do
						habilidade_tabela1[key][empowermentLevel] = habilidade_tabela1[key][empowermentValue] or 0 + empowermentValue
					end
				end
			end
		end

	--soma o container de friendly fire
		for target_name, ff_table in pairs(tabela2.friendlyfire) do
			--pega o ator ff no ator principal
			local friendlyFire_tabela1 = tabela1.friendlyfire [target_name] or tabela1:CreateFFTable(target_name)
			--soma o total
			friendlyFire_tabela1.total = friendlyFire_tabela1.total + ff_table.total

			--soma as habilidades
			for spellid, amount in pairs(ff_table.spells) do
				friendlyFire_tabela1.spells [spellid] =(friendlyFire_tabela1.spells [spellid] or 0) + amount
			end
		end

	return tabela1
end

damageClass.__sub = function(tabela1, tabela2)

	--tempo decorrido
		local tempo =(tabela2.end_time or time()) - tabela2.start_time
		tabela1.start_time = tabela1.start_time + tempo

	--total de dano
		tabela1.total = tabela1.total - tabela2.total
		tabela1.totalabsorbed = tabela1.totalabsorbed - tabela2.totalabsorbed

	--total de dano sem o pet
		tabela1.total_without_pet = tabela1.total_without_pet - tabela2.total_without_pet
	--total de dano que o cara levou
		tabela1.damage_taken = tabela1.damage_taken - tabela2.damage_taken
	--total do friendly fire causado
		tabela1.friendlyfire_total = tabela1.friendlyfire_total - tabela2.friendlyfire_total

	--reduz os containers de alvos
		for target_name, amount in pairs(tabela2.targets) do
			local alvo_tabela1 = tabela1.targets [target_name]
			if (alvo_tabela1) then
				tabela1.targets [target_name] = tabela1.targets [target_name] - amount
			end
		end

	--reduz o container de raid targets
		for flag, amount in pairs(tabela2.raid_targets) do
			if (tabela1.raid_targets [flag]) then
				tabela1.raid_targets [flag] = math.max(tabela1.raid_targets [flag] - amount, 0)
			end
		end

	--reduz o container de habilidades
		for spellid, habilidade in pairs(tabela2.spells._ActorTable) do
			--get the spell from the first actor
			local habilidade_tabela1 = tabela1.spells:PegaHabilidade(spellid, true, "SPELL_DAMAGE", false)

			--subtract targets
			for target_name, amount in pairs(habilidade.targets) do
				local alvo_tabela1 = habilidade_tabela1.targets [target_name]
				if (alvo_tabela1) then
					habilidade_tabela1.targets [target_name] = habilidade_tabela1.targets [target_name] - amount
				end
			end

			--subtract extra table
			for spellId, amount in pairs(habilidade.extra) do
				local extra_tabela1 = habilidade_tabela1.extra [spellId]
				if (extra_tabela1) then
					habilidade_tabela1.extra [spellId] = habilidade_tabela1.extra [spellId] - amount
				end
			end

			--subtrai os valores da habilidade
			for key, value in pairs(habilidade) do
				if (type(value) == "number") then
					if (key ~= "id" and key ~= "spellschool") then
						if (not habilidade_tabela1 [key]) then
							habilidade_tabela1 [key] = 0
						end
						if (key == "n_min" or key == "c_min") then
							if (habilidade_tabela1 [key] > value) then
								habilidade_tabela1 [key] = value
							end
						elseif(key == "n_max" or key == "c_max") then
							if (habilidade_tabela1 [key] < value) then
								habilidade_tabela1 [key] = value
							end
						else
							habilidade_tabela1 [key] = habilidade_tabela1 [key] - value
						end
					end
				end
			end
		end

	--reduz o container de friendly fire
		for target_name, ff_table in pairs(tabela2.friendlyfire) do
			--pega o ator ff no ator principal
			local friendlyFire_tabela1 = tabela1.friendlyfire [target_name]
			if (friendlyFire_tabela1) then
				friendlyFire_tabela1.total = friendlyFire_tabela1.total - ff_table.total
				for spellid, amount in pairs(ff_table.spells) do
					if (friendlyFire_tabela1.spells [spellid]) then
						friendlyFire_tabela1.spells [spellid] = friendlyFire_tabela1.spells [spellid] - amount
					end
				end
			end
		end

	return tabela1
end

function Details.refresh:r_atributo_damage(actorObject)
	detailsFramework:Mixin(actorObject, Details222.Mixins.ActorMixin)
	detailsFramework:Mixin(actorObject, damageClassMixin)

	setmetatable(actorObject, Details.atributo_damage)
	actorObject.__index = Details.atributo_damage

	--restore metatable for the spell container
	Details.refresh:r_container_habilidades(actorObject.spells)
	if (actorObject.augmentedSpellsContainer) then
		Details.refresh:r_container_habilidades(actorObject.augmentedSpellsContainer)
	end
end

function Details.clear:c_atributo_damage(este_jogador)
	este_jogador.__index = nil
	este_jogador.links = nil
	este_jogador.minha_barra = nil

	Details.clear:c_container_habilidades(este_jogador.spells)
end


--[[
	--enemy damage done
	i = 1
	local enemy = combat(1, enemy_name)
	if (enemy) then

		local damage_done = 0

		--get targets
		for target_name, amount in pairs(enemy.targets) do
			local player = combat(1, target_name)
			if (player and player.grupo) then
				local t = tooltip_temp_table [i]
				if (not t) then
					tooltip_temp_table [i] = {}
					t = tooltip_temp_table [i]
				end
				t [1] = player
				t [2] = amount
				damage_done = damage_done + amount
				i = i + 1
			end
		end

		--first clenup
		for o = i, #tooltip_temp_table do
			local t = tooltip_temp_table [o]
			t[2] = 0
			t[1] = 0
		end

		table.sort(tooltip_temp_table, Details.Sort2)

		--enemy damage taken
		Details:AddTooltipSpellHeaderText(Loc ["STRING_ATTRIBUTE_DAMAGE"], headerColor, i-1, true)
		GameCooltip:AddIcon([=[Interface\Buttons\UI-MicroStream-Green]=], 2, 1, 14, 14, 0.1875, 0.8125, 0.15625, 0.78125)
		GameCooltip:AddIcon([=[Interface\AddOns\Details\images\key_shift]=], 2, 2, Details.tooltip_key_size_width, Details.tooltip_key_size_height, 0, 1, 0, 0.640625, Details.tooltip_key_overlay2)
		GameCooltip:AddStatusBar(100, 2, 0.7, g, b, 1)

		--build the tooltip
		for o = 1, i-1 do

			local player = tooltip_temp_table [o][1]
			local total = tooltip_temp_table [o][2]
			local player_name = player:name()

			if (player_name:find(Details.playername)) then
				GameCooltip:AddLine(player_name .. ": ", FormatTooltipNumber(_, total) .. "(" .. _cstr("%.1f",(total / damage_done) * 100) .. "%)", 2, "yellow")
			else
				GameCooltip:AddLine(player_name .. ": ", FormatTooltipNumber(_, total) .."(" .. _cstr("%.1f",(total / damage_done) * 100) .. "%)", 2)
			end

			local classe = player:class()
			if (not classe) then
				classe = "UNKNOW"
			end
			if (classe == "UNKNOW") then
				GameCooltip:AddIcon("Interface\\LFGFRAME\\LFGROLE_BW", 2, nil, 14, 14, .25, .5, 0, 1)
			else
				GameCooltip:AddIcon(instancia.row_info.icon_file, 2, nil, 14, 14, _unpack(Details.class_coords [classe]))
			end
			Details:AddTooltipBackgroundStatusbar(2)

		end

	end

	--clean up
	for o = 1, #tooltip_temp_table do
		local t = tooltip_temp_table [o]
		t[2] = 0
		t[1] = 0
	end
--]]
