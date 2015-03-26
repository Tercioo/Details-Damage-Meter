-- damage object

	local _detalhes = 		_G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local gump = 			_detalhes.gump
	local _

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _cstr = string.format --lua local
	local _math_floor = math.floor --lua local
	local _table_sort = table.sort --lua local
	local _table_insert = table.insert --lua local
	local _table_size = table.getn --lua local
	local _setmetatable = setmetatable --lua local
	local _getmetatable = getmetatable --lua local
	local _ipairs = ipairs --lua local
	local _pairs = pairs --lua local
	local _rawget= rawget --lua local
	local _math_min = math.min --lua local
	local _math_max = math.max --lua local
	local _math_abs = math.abs --lua local
	local _bit_band = bit.band --lua local
	local _unpack = unpack --lua local
	local _type = type --lua local
	local GameTooltip = GameTooltip --api local
	local _IsInRaid = IsInRaid --api local
	local _IsInGroup = IsInGroup --api local
	
	local _GetSpellInfo = _detalhes.getspellinfo --details api
	local _string_replace = _detalhes.string.replace --details api

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local alvo_da_habilidade	= 	_detalhes.alvo_da_habilidade
	local container_habilidades	= 	_detalhes.container_habilidades
	local container_combatentes =	_detalhes.container_combatentes
	local atributo_damage	=	_detalhes.atributo_damage
	local atributo_misc		=	_detalhes.atributo_misc
	local habilidade_dano		=	_detalhes.habilidade_dano
	local container_damage_target =	_detalhes.container_type.CONTAINER_DAMAGETARGET_CLASS
	local container_damage	=	_detalhes.container_type.CONTAINER_DAMAGE_CLASS
	local container_friendlyfire	=	_detalhes.container_type.CONTAINER_FRIENDLYFIRE

	local modo_GROUP = _detalhes.modos.group
	local modo_ALL = _detalhes.modos.all

	local class_type = _detalhes.atributos.dano

	local ToKFunctions = _detalhes.ToKFunctions
	local SelectedToKFunction = ToKFunctions [1]
	
	local UsingCustomLeftText = false
	local UsingCustomRightText = false
	
	local FormatTooltipNumber = ToKFunctions [8]
	local TooltipMaximizedMethod = 1

	local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
	local is_player_class = _detalhes.player_class

	_detalhes.tooltip_key_overlay1 = {1, 1, 1, .2}
	_detalhes.tooltip_key_overlay2 = {1, 1, 1, .5}
	
	_detalhes.tooltip_key_size_width = 24
	_detalhes.tooltip_key_size_height = 10

	local headerColor = {1, 0.9, 0.0, 1}

	local info = _detalhes.janela_info
	local keyName

	local OBJECT_TYPE_PLAYER =	0x00000400
	
	local ntable = {} --temp
	local vtable = {} --temp

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> exported functions

--[[exported]]	function _detalhes:CreateActorLastEventTable()
				local t = { {}, {}, {}, {}, {}, {}, {}, {} }
				t.n = 1
				return t
			end
			
			function atributo_damage:CreateFFTable (target_name)
				local new_table = {total = 0, spells = {}}
				self.friendlyfire [target_name] = new_table
				return new_table
			end
			
--[[exported]]	function _detalhes:CreateActorAvoidanceTable (no_overall)
				if (no_overall) then
					local t = {["ALL"] = 0, ["DODGE"] = 0, ["PARRY"] = 0, ["HITS"] = 0, ["ABSORB"] = 0, --quantas vezes foi dodge, parry, quandos hits tomou, quantos absorbs teve
					["FULL_HIT"] = 0, ["FULL_ABSORBED"] = 0, ["PARTIAL_ABSORBED"] = 0, --full hit full absorbed and partial absortion
					["FULL_HIT_AMT"] = 0, ["PARTIAL_ABSORB_AMT"] = 0, ["ABSORB_AMT"] = 0, ["FULL_ABSORB_AMT"] = 0} --amounts
					return t
				else
					local t = {overall = {["ALL"] = 0, ["DODGE"] = 0, ["PARRY"] = 0, ["HITS"] = 0, ["ABSORB"] = 0, --quantas vezes foi dodge, parry, quandos hits tomou, quantos absorbs teve
					["FULL_HIT"] = 0, ["FULL_ABSORBED"] = 0, ["PARTIAL_ABSORBED"] = 0, --full hit full absorbed and partial absortion
					["FULL_HIT_AMT"] = 0, ["PARTIAL_ABSORB_AMT"] = 0, ["ABSORB_AMT"] = 0, ["FULL_ABSORB_AMT"] = 0}} --amounts
					return t
				end
			end

--[[exported]]	function _detalhes.SortGroup (container, keyName2)
				keyName = keyName2
				return _table_sort (container, _detalhes.SortKeyGroup)
			end

--[[exported]]	function _detalhes.SortKeyGroup (table1, table2)
				if (table1.grupo and table2.grupo) then
					return table1 [keyName] > table2 [keyName]
				elseif (table1.grupo and not table2.grupo) then
					return true
				elseif (not table1.grupo and table2.grupo) then
					return false
				else
					return table1 [keyName] > table2 [keyName]
				end
			end

--[[exported]] 	function _detalhes.SortKeySimple (table1, table2)
				return table1 [keyName] > table2 [keyName]
			end
			
--[[exported]] 	function _detalhes:ContainerSort (container, amount, keyName2)
				keyName = keyName2
				_table_sort (container,  _detalhes.SortKeySimple)
				
				if (amount) then 
					for i = amount, 1, -1 do --> de trás pra frente
						if (container[i][keyName] < 1) then
							amount = amount-1
						else
							break
						end
					end
					
					return amount
				end
			end

--[[ exported]]	function _detalhes:IsGroupPlayer()
				return self.grupo
			end
			
--[[ exported]] 	function _detalhes:IsPlayer()
				if (self.flag_original) then
					if (_bit_band (self.flag_original, OBJECT_TYPE_PLAYER) ~= 0) then
						return true
					end
				end
				return false
			end

			local ignored_enemy_npcs = {
				[31216] = true, --mirror image
				[53006] = true, --spirit link totem
				[63508] = true, --xuen
				[73967] = true, --xuen
			}
			
			-- Night-Twisted Brute - Creature-0-3024-1228-19402-85241-00001E2097
			
--[[ exported]]	function _detalhes:IsNeutralOrEnemy()
				if (self.flag_original) then
					if (_bit_band (self.flag_original, 0x00000060) ~= 0) then
						local npcid1 = _detalhes:GetNpcIdFromGuid (self.serial)
						if (ignored_enemy_npcs [npcid1]) then
							return false
						end
						return true
					end
				end
				return false
			end
			
--[[ exported]]	function _detalhes:IsEnemy()
				if (self.flag_original) then
					if (_bit_band (self.flag_original, 0x00000060) ~= 0) then
						local npcid1 = _detalhes:GetNpcIdFromGuid (self.serial)
						if (ignored_enemy_npcs [npcid1]) then
							return false
						end
						return true
					end
				end
				return false
			end
			
--[[ exported]]	function _detalhes:GetSpellList()
				return self.spells._ActorTable
			end

			-- enemies (sort function)
			local sortEnemies = function (t1, t2)
				local a = _bit_band (t1.flag_original, 0x00000060)
				local b = _bit_band (t2.flag_original, 0x00000060)
				
				if (a ~= 0 and b ~= 0) then
					local npcid1 = _detalhes:GetNpcIdFromGuid (t1.serial)
					local npcid2 = _detalhes:GetNpcIdFromGuid (t2.serial)
					
					if (not ignored_enemy_npcs [npcid1] and not ignored_enemy_npcs [npcid2]) then
						return t1.damage_taken > t2.damage_taken
					elseif (ignored_enemy_npcs [npcid1] and not ignored_enemy_npcs [npcid2]) then
						return false
					elseif (not ignored_enemy_npcs [npcid1] and ignored_enemy_npcs [npcid2]) then
						return true
					else
						return t1.damage_taken > t2.damage_taken
					end
					
				elseif (a ~= 0 and b == 0) then
					return true
				elseif (a == 0 and b ~= 0) then
					return false
				end
				
				return false
			end

--[[exported]] 	function _detalhes:ContainerSortEnemies (container, amount, keyName2)

				keyName = keyName2
				
				_table_sort (container, sortEnemies)
				
				local total = 0
				
				for index, player in _ipairs (container) do
					local npcid1 = _detalhes:GetNpcIdFromGuid (player.serial)
					--p rint (player.nome, npcid1, ignored_enemy_npcs [npcid1])
					if (_bit_band (player.flag_original, 0x00000060) ~= 0 and not ignored_enemy_npcs [npcid1]) then --> é um inimigo
						total = total + player [keyName]
					else
						amount = index-1
						break
					end
				end
				
				return amount, total
			end

--[[Exported]] 	function _detalhes:TooltipForCustom (barra)
				GameCooltip:AddLine (Loc ["STRING_LEFT_CLICK_SHARE"])
				return true
			end
			
--[[ Void Zone Sort]]
			local void_zone_sort = function (t1, t2)
				if (t1.damage == t2.damage) then
					return t1.nome <= t2.nome
				else
					return t1.damage > t2.damage
				end
			end


--[[exported]]	function _detalhes.Sort1 (table1, table2)
				return table1 [1] > table2 [1]
			end
			
--[[exported]]	function _detalhes.Sort2 (table1, table2)
				return table1 [2] > table2 [2]
			end
			
--[[exported]]	function _detalhes.Sort3 (table1, table2)
				return table1 [3] > table2 [3]
			end
			
--[[exported]]	function _detalhes.Sort4 (table1, table2)
				return table1 [4] > table2 [4]
			end
			
--[[exported]]	function _detalhes.Sort4Reverse (table1, table2)
				if (not table2) then
					return true
				end
				return table1 [4] < table2 [4]
			end
			
--[[exported]]	function _detalhes:GetBarColor (actor)
				actor = actor or self
				
				if (actor.monster) then
					return _unpack (_detalhes.class_colors.ENEMY)
					
				elseif (actor.owner) then
					return _unpack (_detalhes.class_colors [actor.owner.classe])

				elseif (actor.arena_enemy) then
					return _unpack (_detalhes.class_colors.ARENA_ENEMY)
				
				elseif (actor.arena_ally) then
					return _unpack (_detalhes.class_colors.ARENA_ALLY)
				
				else
					if (not is_player_class [actor.classe] and actor.flag_original and _bit_band (actor.flag_original, 0x00000020) ~= 0) then --> neutral
						return _unpack (_detalhes.class_colors.NEUTRAL)
					else
						return _unpack (_detalhes.class_colors [actor.classe])
					end
				end
			end
			
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> class constructor

	function atributo_damage:NovaTabela (serial, nome, link)

		local alphabetical = _detalhes:GetOrderNumber (nome)
	
		--> constructor
		local _new_damageActor = {
			
			tipo = class_type,
			
			total = alphabetical,
			total_without_pet = alphabetical,
			custom = 0,
			
			damage_taken = alphabetical,
			damage_from = {},
			
			dps_started = false,
			last_event = 0,
			on_hold = false,
			delay = 0,
			last_value = nil,
			last_dps = 0,

			end_time = nil,
			start_time = 0,
			
			pets = {},
			
			friendlyfire_total = 0,
			friendlyfire = {},

			targets = {},
			spells = container_habilidades:NovoContainer (container_damage)
		}
		
		_setmetatable (_new_damageActor, atributo_damage)
		
		return _new_damageActor
	end
	
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> special cases

	-- dps (calculate dps for actors)
	function atributo_damage:ContainerRefreshDps (container, combat_time)
	
		local total = 0
		
		if (_detalhes.time_type == 2 or not _detalhes:CaptureGet ("damage")) then
			for _, actor in _ipairs (container) do
				if (actor.grupo) then
					actor.last_dps = actor.total / combat_time
				else
					actor.last_dps = actor.total / actor:Tempo()
				end
				total = total + actor.last_dps
			end
		else
			for _, actor in _ipairs (container) do
				actor.last_dps = actor.total / actor:Tempo()
				total = total + actor.last_dps
			end
		end
		
		return total
	end	

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> frags
	
	function _detalhes:ToolTipFrags (instancia, frag, esta_barra, keydown)

		local name = frag [1]
		local GameCooltip = GameCooltip
		
		--> mantendo a função o mais low level possível
		local damage_container = instancia.showing [1]
		
		local frag_actor = damage_container._ActorTable [damage_container._NameIndexTable [ name ]]

		if (frag_actor) then
			
			local damage_taken_table = {}

			local took_damage_from = frag_actor.damage_from
			local total_damage_taken = frag_actor.damage_taken

			for aggressor, _ in _pairs (took_damage_from) do
			
				local damager_actor = damage_container._ActorTable [damage_container._NameIndexTable [ aggressor ]]
				
				if (damager_actor and not damager_actor.owner) then --> checagem por causa do total e do garbage collector que não limpa os names que deram dano
					local target_amount = damager_actor.targets [name]
					if (target_amount) then
						damage_taken_table [#damage_taken_table+1] = {aggressor, target_amount, damager_actor.classe}
					end
				end
			end

			if (#damage_taken_table > 0) then
				
				_table_sort (damage_taken_table, _detalhes.Sort2)
				
				GameCooltip:AddLine (Loc ["STRING_DAMAGE_FROM"], nil, nil, headerColor, nil, 12)
				GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0.126953125, 0.1796875, 0, 0.0546875)
			
				local min = 6
				local ismaximized = false
				if (keydown == "shift" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 3) then
					min = 99
					ismaximized = true
				end
				
				if (ismaximized) then
					--highlight shift key
					GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
					GameCooltip:AddStatusBar (100, 1, .1, .1, .1, 1)
				else
					GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
					GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .3)
				end
			
				for i = 1, math.min (min, #damage_taken_table) do 
				
					local t = damage_taken_table [i]
				
					GameCooltip:AddLine (t [1], FormatTooltipNumber (_, t [2]))
					local classe = t [3]
					if (not classe) then
						classe = "UNKNOW"
					end
					
					if (classe == "UNKNOW") then
						GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, 14, 14, .25, .5, 0, 1)
					else
						GameCooltip:AddIcon (instancia.row_info.icon_file, nil, nil, 14, 14, _unpack (_detalhes.class_coords [classe]))
					end
					_detalhes:AddTooltipBackgroundStatusbar()
				end
				
				GameCooltip:AddLine ("")
				GameCooltip:AddLine (Loc ["STRING_REPORT_LEFTCLICK"], nil, 1, _unpack (self.click_to_report_color))
				GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, 16, 0.015625, 0.13671875, 0.4375, 0.59765625)
				GameCooltip:ShowCooltip()
			
			else
				GameCooltip:AddLine (Loc ["STRING_NO_DATA"], nil, 1, "white")
				GameCooltip:AddIcon (instancia.row_info.icon_file, nil, nil, 14, 14, _unpack (_detalhes.class_coords ["UNKNOW"]))
				GameCooltip:ShowCooltip()
			end
			
		else
			GameCooltip:AddLine (Loc ["STRING_NO_DATA"], nil, 1, "white")
			GameCooltip:AddIcon (instancia.row_info.icon_file, nil, nil, 14, 14, _unpack (_detalhes.class_coords ["UNKNOW"]))
			GameCooltip:ShowCooltip()
		end
		
	end

	local function RefreshBarraFrags (tabela, barra, instancia)
		atributo_damage:AtualizarFrags (tabela, tabela.minha_barra, barra.colocacao, instancia)
	end

	function atributo_damage:ReportSingleFragsLine (frag, instancia)
		local barra = instancia.barras [frag.minha_barra]

		local reportar = {"Details!: " .. frag [1] .. " - " .. Loc ["STRING_ATTRIBUTE_DAMAGE_TAKEN"]}
		
		for i = 2, GameCooltip:GetNumLines()-2 do
			local texto_left, texto_right = GameCooltip:GetText (i)
			if (texto_left and texto_right) then 
				texto_left = texto_left:gsub (("|T(.*)|t "), "")
				reportar [#reportar+1] = "" .. texto_left .. " ....... " .. texto_right
			end
		end

		return _detalhes:Reportar (reportar, {_no_current = true, _no_inverse = true, _custom = true})
	end

	function atributo_damage:AtualizarFrags (tabela, qual_barra, colocacao, instancia)

		tabela ["frags"] = true --> marca que esta tabela é uma tabela de frags, usado no controla na hora de montar o tooltip
		local esta_barra = instancia.barras [qual_barra] --> pega a referência da barra na janela
		
		if (not esta_barra) then
			print ("DEBUG: problema com <instancia.esta_barra> "..qual_barra.." "..lugar)
			return
		end
		
		local tabela_anterior = esta_barra.minha_tabela
		
		esta_barra.minha_tabela = tabela
		
		tabela.nome = tabela [1] --> evita dar erro ao redimencionar a janela
		tabela.minha_barra = qual_barra
		esta_barra.colocacao = colocacao
		
		if (not _getmetatable (tabela)) then 
			_setmetatable (tabela, {__call = RefreshBarraFrags}) 
			tabela._custom = true
		end

		local total = instancia.showing.totals.frags_total
		local porcentagem
		
		if (instancia.row_info.percent_type == 1) then
			porcentagem = _cstr ("%.1f", tabela [2] / total * 100)
		elseif (instancia.row_info.percent_type == 2) then
			porcentagem = _cstr ("%.1f", tabela [2] / instancia.top * 100)
		end
		
		esta_barra.texto_esquerdo:SetText (colocacao .. ". " .. tabela [1])

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
		
		esta_barra.texto_direita:SetText (total_frags .. bars_brackets[1] .. porcentagem .. bars_brackets[2])
		
		esta_barra.texto_esquerdo:SetTextColor (1, 1, 1, 1)
		esta_barra.texto_direita:SetTextColor (1, 1, 1, 1)
		
		esta_barra.texto_esquerdo:SetSize (esta_barra:GetWidth() - esta_barra.texto_direita:GetStringWidth() - 20, 15)
		
		if (colocacao == 1) then
			esta_barra:SetValue (100)
		else
			esta_barra:SetValue (tabela [2] / instancia.top * 100)
		end
		
		if (esta_barra.hidden or esta_barra.fading_in or esta_barra.faded) then
			gump:Fade (esta_barra, "out")
		end

		if (instancia.row_info.texture_class_colors) then
			esta_barra.textura:SetVertexColor (_unpack (_detalhes.class_colors [tabela [3]]))
		end

		if (tabela [3] == "UNKNOW" or tabela [3] == "UNGROUPPLAYER" or tabela [3] == "ENEMY") then
			esta_barra.icone_classe:SetTexture ([[Interface\AddOns\Details\images\classes_plus]])
			esta_barra.icone_classe:SetTexCoord (0.50390625, 0.62890625, 0, 0.125)
			esta_barra.icone_classe:SetVertexColor (1, 1, 1)
		else
			esta_barra.icone_classe:SetTexture (instancia.row_info.icon_file)
			esta_barra.icone_classe:SetTexCoord (_unpack (_detalhes.class_coords [tabela [3]]))
			esta_barra.icone_classe:SetVertexColor (1, 1, 1)
		end

		if (esta_barra.mouse_over and not instancia.baseframe.isMoving) then --> precisa atualizar o tooltip
			--gump:UpdateTooltip (qual_barra, esta_barra, instancia)
		end

	end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> void zones

	function atributo_damage:ReportSingleVoidZoneLine (actor, instancia)
		local barra = instancia.barras [actor.minha_barra]

		local reportar = {"Details!: " .. actor.nome .. " - " .. Loc ["STRING_ATTRIBUTE_DAMAGE_DEBUFFS_REPORT"]}
		for i = 2, GameCooltip:GetNumLines()-2 do 
			local texto_left, texto_right = GameCooltip:GetText (i)
			if (texto_left and texto_right) then 
				texto_left = texto_left:gsub (("|T(.*)|t "), "")
				reportar [#reportar+1] = "" .. texto_left .. " ..... " .. texto_right
			end
		end

		return _detalhes:Reportar (reportar, {_no_current = true, _no_inverse = true, _custom = true})
	end

	local sort_tooltip_void_zones = function (tabela1, tabela2)
		if (tabela1 [2] > tabela2 [2]) then
			return true
		elseif (tabela1 [2] == tabela2 [2]) then
			if (tabela1[1] ~= "" and tabela2[1] ~= "") then
				return tabela1 [3].uptime > tabela2 [3].uptime
			elseif (tabela1[1] ~= "") then
				return true
			elseif (tabela2[1] ~= "") then
				return false
			end
		else
			return false
		end
	end
	
	local tooltip_void_zone_temp = {}
	
	function _detalhes:ToolTipVoidZones (instancia, actor, barra, keydown)
		
		local damage_actor = instancia.showing[1]:PegarCombatente (_, actor.damage_twin)
		local habilidade
		local alvos
		
		if (damage_actor) then
			habilidade = damage_actor.spells._ActorTable [actor.damage_spellid]
		end
		
		if (habilidade) then
			alvos = habilidade.targets
		end
		
		local container = actor.debuff_uptime_targets
		
		for target_name, debuff_table in _pairs (container) do
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
		for target_name, debuff_table in _pairs (container) do 
			local t = tooltip_void_zone_temp [i]			
			if (not t) then
				t = {}
				tinsert (tooltip_void_zone_temp, t)
			end
			
			t[1] = target_name
			t[2] = debuff_table.damage
			t[3] = debuff_table
			
			i = i + 1
		end
		
		--> sort no container:
		_table_sort (tooltip_void_zone_temp, sort_tooltip_void_zones)

		--> monta o cooltip
		local GameCooltip = GameCooltip
		
		GameCooltip:AddLine (Loc ["STRING_VOIDZONE_TOOLTIP"], nil, nil, headerColor, nil, 12)
		GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0.126953125, 0.1796875, 0, 0.0546875)
		
		--for target_name, debuff_table in _pairs (container) do 
		for index, t in _ipairs (tooltip_void_zone_temp) do
		
			if (t[3] == 0) then
				break
			end
		
			local debuff_table = t[3]

			local minutos, segundos = _math_floor (debuff_table.uptime / 60), _math_floor (debuff_table.uptime % 60)
			if (minutos > 0) then
				GameCooltip:AddLine (t[1], FormatTooltipNumber (_, debuff_table.damage) .. " (" .. minutos .. "m " .. segundos .. "s" .. ")")
			else
				GameCooltip:AddLine (t[1], FormatTooltipNumber (_, debuff_table.damage) .. " (" .. segundos .. "s" .. ")")
			end
			
			local classe = _detalhes:GetClass (t[1])
			if (classe) then	
				GameCooltip:AddIcon ([[Interface\AddOns\Details\images\classes_small]], nil, nil, 14, 14, unpack (_detalhes.class_coords [classe]))
			else
				GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, 14, 14, .25, .5, 0, 1)
			end
			
			_detalhes:AddTooltipBackgroundStatusbar()
		
		end
		
		GameCooltip:AddLine ("")
		GameCooltip:AddLine (Loc ["STRING_REPORT_LEFTCLICK"], nil, 1, _unpack (self.click_to_report_color))
		GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, 16, 0.015625, 0.13671875, 0.4375, 0.59765625)
		
		GameCooltip:ShowCooltip()
		
	end

	local function RefreshBarraVoidZone (tabela, barra, instancia)
		tabela:AtualizarVoidZone (tabela.minha_barra, barra.colocacao, instancia)
	end

	function atributo_misc:AtualizarVoidZone (qual_barra, colocacao, instancia)

		--> pega a referência da barra na janela
		local esta_barra = instancia.barras [qual_barra]
		
		if (not esta_barra) then
			print ("DEBUG: problema com <instancia.esta_barra> "..qual_barra.." "..lugar)
			return
		end
		
		self._refresh_window = RefreshBarraVoidZone
		
		local tabela_anterior = esta_barra.minha_tabela
		
		esta_barra.minha_tabela = self
		
		self.minha_barra = qual_barra
		esta_barra.colocacao = colocacao
		
		local total = instancia.showing.totals.voidzone_damage

		local combat_time = instancia.showing:GetCombatTime()
		local dps = _math_floor (self.damage / combat_time)
		
		local formated_damage = SelectedToKFunction (_, self.damage)
		local formated_dps = SelectedToKFunction (_, dps)
		
		local porcentagem
		
		if (instancia.row_info.percent_type == 1) then
			porcentagem = _cstr ("%.1f", self.damage / total * 100)
		elseif (instancia.row_info.percent_type == 2) then
			porcentagem = _cstr ("%.1f", self.damage / instancia.top * 100)
		end
		
		if (UsingCustomRightText) then
			esta_barra.texto_direita:SetText (_string_replace (instancia.row_info.textR_custom_text, formated_damage, formated_dps, porcentagem, self))
		else
		
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
			
			esta_barra.texto_direita:SetText (formated_damage .. bars_brackets[1] .. formated_dps .. bars_separator .. porcentagem .. bars_brackets[2])

		end

		esta_barra.texto_esquerdo:SetText (colocacao .. ". " .. self.nome)
		esta_barra.texto_esquerdo:SetSize (esta_barra:GetWidth() - esta_barra.texto_direita:GetStringWidth() - 20, 15)
		
		esta_barra.texto_esquerdo:SetTextColor (1, 1, 1, 1)
		esta_barra.texto_direita:SetTextColor (1, 1, 1, 1)
		
		esta_barra:SetValue (100)
		
		if (esta_barra.hidden or esta_barra.fading_in or esta_barra.faded) then
			gump:Fade (esta_barra, "out")
		end
		
		local _, _, icon = GetSpellInfo (self.damage_spellid)
		local school_color = _detalhes.school_colors [self.spellschool]
		if (not school_color) then
			school_color = _detalhes.school_colors ["unknown"]
		end
		
		if (instancia.row_info.texture_class_colors) then
			esta_barra.textura:SetVertexColor (_unpack (school_color))
		end
		esta_barra.icone_classe:SetTexture (icon)
		esta_barra.icone_classe:SetTexCoord (0, 1, 0, 1)
		esta_barra.icone_classe:SetVertexColor (1, 1, 1)

		if (esta_barra.mouse_over and not instancia.baseframe.isMoving) then
			--need call a refresh function
		end

	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> main refresh function


function atributo_damage:RefreshWindow (instancia, tabela_do_combate, forcar, exportar, refresh_needed)
	
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable

	--> não há barras para mostrar -- not have something to show
	if (#showing._ActorTable < 1) then 
		--> colocado isso recentemente para fazer as barras de dano sumirem na troca de atributo
		return _detalhes:EsconderBarrasNaoUsadas (instancia, showing) 
	end
	
	--> total
	local total = 0
	--> top actor #1
	instancia.top = 0
	
	local using_cache = false
	
	local sub_atributo = instancia.sub_atributo --> o que esta sendo mostrado nesta instância
	local conteudo = showing._ActorTable --> pega a lista de jogadores -- get actors table from container
	local amount = #conteudo
	local modo = instancia.modo
	
	--> pega qual a sub key que será usada --sub keys
	if (exportar) then
	
		if (_type (exportar) == "boolean") then 		
			if (sub_atributo == 1) then --> DAMAGE DONE
				keyName = "total"
			elseif (sub_atributo == 2) then --> DPS
				keyName = "last_dps"
			elseif (sub_atributo == 3) then --> TAMAGE TAKEN
				keyName = "damage_taken"
			if (_detalhes.damage_taken_everything) then
				modo = modo_ALL
			end
			elseif (sub_atributo == 4) then --> FRIENDLY FIRE
				keyName = "friendlyfire_total"
			elseif (sub_atributo == 5) then --> FRAGS
				keyName = "frags"
			elseif (sub_atributo == 6) then --> ENEMIES
				keyName = "enemies"
			elseif (sub_atributo == 7) then --> AURAS VOIDZONES
				keyName = "voidzones"
			end
		else
			keyName = exportar.key
			modo = exportar.modo		
		end
	elseif (instancia.atributo == 5) then --> custom
		keyName = "custom"
		total = tabela_do_combate.totals [instancia.customName]
	else
		if (sub_atributo == 1) then --> DAMAGE DONE
			keyName = "total"
		elseif (sub_atributo == 2) then --> DPS
			keyName = "last_dps"
		elseif (sub_atributo == 3) then --> TAMAGE TAKEN
			keyName = "damage_taken"
			if (_detalhes.damage_taken_everything) then
				modo = modo_ALL
			end
		elseif (sub_atributo == 4) then --> FRIENDLY FIRE
			keyName = "friendlyfire_total"
		elseif (sub_atributo == 5) then --> FRAGS
			keyName = "frags"
		elseif (sub_atributo == 6) then --> ENEMIES
			keyName = "enemies"
		elseif (sub_atributo == 7) then --> AURAS VOIDZONES
			keyName = "voidzones"
		end
	end
	
	if (keyName == "frags") then 
	
		local frags = instancia.showing.frags
		local frags_total_kills = 0
		local index = 0
		
		for fragName, fragAmount in _pairs (frags) do 
		
			index = index + 1
		
			local fragged_actor = showing._NameIndexTable [fragName] --> get index
			local actor_classe
			if (fragged_actor) then
				fragged_actor = showing._ActorTable [fragged_actor] --> get object
				actor_classe = fragged_actor.classe
			end
			
			if (fragged_actor and fragged_actor.monster) then
				actor_classe = "ENEMY"
			elseif (not actor_classe) then
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
		
		local tsize = #ntable
		if (index < tsize) then
			for i = index+1, tsize do
				ntable [i][2] = 0
			end
		end
		
		instancia.top = 0
		if (tsize > 0) then
			_table_sort (ntable, _detalhes.Sort2)
			instancia.top = ntable [1][2]
		end
	
		total = index
		
		if (exportar) then 
			local export = {}
			for i = 1, index do 
				export [i] = {ntable[i][1], ntable[i][2], ntable[i][3]}
			end
			return export
		end
		
		if (total < 1) then
			instancia:EsconderScrollBar()
			return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
		end
		
		tabela_do_combate.totals.frags_total = frags_total_kills
		
		instancia:AtualizarScrollBar (total)
		
		local qual_barra = 1
		local barras_container = instancia.barras

		
		for i = instancia.barraS[1], instancia.barraS[2], 1 do --> vai atualizar só o range que esta sendo mostrado
			atributo_damage:AtualizarFrags (ntable[i], qual_barra, i, instancia)
			qual_barra = qual_barra+1
		end
		
		return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
	
	elseif (keyName == "voidzones") then 
		
		local index = 0
		local misc_container = tabela_do_combate [4]
		local voidzone_damage_total = 0
		
		for _, actor in _ipairs (misc_container._ActorTable) do
			if (actor.boss_debuff) then
				index = index + 1
			
				--pega no container de dano o actor responsável por aplicar o debuff
				local twin_damage_actor = showing._NameIndexTable [actor.damage_twin] or showing._NameIndexTable ["[*] " .. actor.damage_twin]
				
				if (twin_damage_actor) then
					local index = twin_damage_actor
					twin_damage_actor = showing._ActorTable [twin_damage_actor]

					local spell = twin_damage_actor.spells._ActorTable [actor.damage_spellid]
					
					if (spell) then
					
						--> fix spell, sometimes there is two spells with the same name, one is the cast and other is the debuff
						if (spell.total == 0 and not actor.damage_spellid_fixed) then
							local curname = _GetSpellInfo (actor.damage_spellid)
							for spellid, spelltable in _pairs (twin_damage_actor.spells._ActorTable) do
								if (spelltable.total > spell.total) then
									local name = _GetSpellInfo (spellid)
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
						
					elseif (not actor.damage_spellid_fixed) then --not
						--> fix spell, if the spellid passed for debuff uptime is actully the spell id of a ability and not if the aura it self
						actor.damage_spellid_fixed = true
						local found = false
						for spellid, spelltable in _pairs (twin_damage_actor.spells._ActorTable) do
							local name = _GetSpellInfo (spellid)
							if (actor.damage_twin:find (name)) then
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
			_table_sort (vtable, void_zone_sort)
			instancia.top = vtable [1].damage
		end
		total = index 
		
		if (exportar) then 
			return voidzone_damage_total, "damage", instancia.top, total, vtable
		end
		
		if (total < 1) then
			instancia:EsconderScrollBar()
			return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
		end
		
		tabela_do_combate.totals.voidzone_damage = voidzone_damage_total
		
		instancia:AtualizarScrollBar (total)
		
		local qual_barra = 1
		local barras_container = instancia.barras

		for i = instancia.barraS[1], instancia.barraS[2], 1 do --> vai atualizar só o range que esta sendo mostrado
			vtable[i]:AtualizarVoidZone (qual_barra, i, instancia)
			qual_barra = qual_barra+1
		end
		
		return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
		
	else
	
		if (keyName == "enemies") then 
		
			--amount, total = _detalhes:ContainerSortEnemies (conteudo, amount, "total")
			amount, total = _detalhes:ContainerSortEnemies (conteudo, amount, "damage_taken")
			--keyName = "enemies"
			--> grava o total
			instancia.top = conteudo[1][keyName]
			
		elseif (modo == modo_ALL) then --> mostrando ALL
		
			--> faz o sort da categoria e retorna o amount corrigido
			--print (keyName)
			if (sub_atributo == 2) then
				local combat_time = instancia.showing:GetCombatTime()
				total = atributo_damage:ContainerRefreshDps (conteudo, combat_time)
			else
				--> pega o total ja aplicado na tabela do combate
				total = tabela_do_combate.totals [class_type]
			end
			
			amount = _detalhes:ContainerSort (conteudo, amount, keyName)
			
			--> grava o total
			instancia.top = conteudo[1][keyName]
		
		elseif (modo == modo_GROUP) then --> mostrando GROUP
		
			--> organiza as tabelas
			
			if (_detalhes.in_combat and instancia.segmento == 0 and not exportar) then
				using_cache = true
			end
			
			if (using_cache) then
			
				conteudo = _detalhes.cache_damage_group
				
				if (sub_atributo == 2) then --> dps
					local combat_time = instancia.showing:GetCombatTime()
					atributo_damage:ContainerRefreshDps (conteudo, combat_time)
				end
			
				if (#conteudo < 1) then
					return _detalhes:EsconderBarrasNaoUsadas (instancia, showing)
				end
			
				_table_sort (conteudo, _detalhes.SortKeySimple)
			
				if (conteudo[1][keyName] < 1) then
					amount = 0
				else
					instancia.top = conteudo[1][keyName]
					amount = #conteudo
				end
			
				for i = 1, amount do 
					total = total + conteudo[i][keyName]
				end
			else
				if (sub_atributo == 2) then --> dps
					local combat_time = instancia.showing:GetCombatTime()
					atributo_damage:ContainerRefreshDps (conteudo, combat_time)
				end

				_table_sort (conteudo, _detalhes.SortKeyGroup)
			end
			--
			if (not using_cache) then
				for index, player in _ipairs (conteudo) do
					if (player.grupo) then --> é um player e esta em grupo
						if (player[keyName] < 1) then --> dano menor que 1, interromper o loop
							amount = index - 1
							break
						end
						
						total = total + player[keyName]
					else
						amount = index-1
						break
					end
				end
				
				instancia.top = conteudo[1] and conteudo[1][keyName]
			end

		end
	end
	
	--> refaz o mapa do container
	if (not using_cache) then
		showing:remapear()
	end
	
	if (exportar) then 
		return total, keyName, instancia.top, amount
	end

	if (amount < 1) then --> não há barras para mostrar
		if (forcar) then
			if (instancia.modo == 2) then --> group
				for i = 1, instancia.rows_fit_in_window  do
					gump:Fade (instancia.barras [i], "in", 0.3)
				end
			end
		end
		instancia:EsconderScrollBar() --> precisaria esconder a scroll bar
		return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
	end

	instancia:AtualizarScrollBar (amount)

	local qual_barra = 1
	local barras_container = instancia.barras
	local percentage_type = instancia.row_info.percent_type
	local bars_show_data = instancia.row_info.textR_show_data
	local bars_brackets = instancia:GetBarBracket()
	local bars_separator = instancia:GetBarSeparator()
	local baseframe = instancia.baseframe
	local use_animations = _detalhes.is_using_row_animations and (not baseframe.isStretching and not forcar and not baseframe.isResizing)
 	
	if (total == 0) then
		total = 0.00000001
	end
	
	local myPos
	local following = instancia.following.enabled and sub_atributo ~= 6
	
	if (following) then
		if (using_cache) then
			local pname = _detalhes.playername
			for i, actor in _ipairs (conteudo) do
				if (actor.nome == pname) then
					myPos = i
					break
				end
			end
		else
			myPos = showing._NameIndexTable [_detalhes.playername]
		end
	end

	local combat_time = instancia.showing:GetCombatTime()
	
	UsingCustomLeftText = instancia.row_info.textL_enable_custom_text
	UsingCustomRightText = instancia.row_info.textR_enable_custom_text
	
	local use_total_bar = false
	if (instancia.total_bar.enabled) then
	
		use_total_bar = true
		
		if (instancia.total_bar.only_in_group and (not _IsInGroup() and not _IsInRaid())) then
			use_total_bar = false
		end
		
		if (sub_atributo > 4) then --enemies, frags, void zones
			use_total_bar = false
		end
		
	end
	
	if (sub_atributo == 2) then --> dps
		instancia.player_top_dps = conteudo [1].last_dps
		instancia.player_top_dps_threshold = instancia.player_top_dps - (instancia.player_top_dps * 0.65)
	end
	
	if (instancia.bars_sort_direction == 1) then --top to bottom
		
		if (use_total_bar and instancia.barraS[1] == 1) then
		
			qual_barra = 2
			local iter_last = instancia.barraS[2]
			if (iter_last == instancia.rows_fit_in_window) then
				iter_last = iter_last - 1
			end
			
			local row1 = barras_container [1]
			row1.minha_tabela = nil
			row1.texto_esquerdo:SetText (Loc ["STRING_TOTAL"])
			row1.texto_direita:SetText (_detalhes:ToK2 (total) .. " (" .. _detalhes:ToK (total / combat_time) .. ")")
			
			row1:SetValue (100)
			local r, b, g = unpack (instancia.total_bar.color)
			row1.textura:SetVertexColor (r, b, g)
			
			row1.icone_classe:SetTexture (instancia.total_bar.icon)
			row1.icone_classe:SetTexCoord (0.0625, 0.9375, 0.0625, 0.9375)
			
			gump:Fade (row1, "out")
			
			if (following and myPos and myPos > instancia.rows_fit_in_window and instancia.barraS[2] < myPos) then
				for i = instancia.barraS[1], iter_last-1, 1 do --> vai atualizar só o range que esta sendo mostrado
					conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator) 
					qual_barra = qual_barra+1
				end
				
				conteudo[myPos]:AtualizaBarra (instancia, barras_container, qual_barra, myPos, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator) 
				qual_barra = qual_barra+1
			else
				for i = instancia.barraS[1], iter_last, 1 do --> vai atualizar só o range que esta sendo mostrado
					conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator) 
					qual_barra = qual_barra+1
				end
			end

		else
			if (following and myPos and myPos > instancia.rows_fit_in_window and instancia.barraS[2] < myPos) then
				for i = instancia.barraS[1], instancia.barraS[2]-1, 1 do --> vai atualizar só o range que esta sendo mostrado
					conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator) 
					qual_barra = qual_barra+1
				end
				
				conteudo[myPos]:AtualizaBarra (instancia, barras_container, qual_barra, myPos, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator) 
				qual_barra = qual_barra+1
			else
				for i = instancia.barraS[1], instancia.barraS[2], 1 do --> vai atualizar só o range que esta sendo mostrado
					if (not conteudo[i]) then
						print ("error on update", amount, conteudo[i], #conteudo, instancia.barraS[1], instancia.barraS[2])
					else
--[[ index nil value]]			conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator) 
						qual_barra = qual_barra+1
					end
				end
			end
		end
		
	elseif (instancia.bars_sort_direction == 2) then --bottom to top
	
		if (use_total_bar and instancia.barraS[1] == 1) then
		
			qual_barra = 2
			local iter_last = instancia.barraS[2]
			if (iter_last == instancia.rows_fit_in_window) then
				iter_last = iter_last - 1
			end
			
			local row1 = barras_container [1]
			row1.minha_tabela = nil
			row1.texto_esquerdo:SetText (Loc ["STRING_TOTAL"])
			row1.texto_direita:SetText (_detalhes:ToK2 (total) .. " (" .. _detalhes:ToK (total / combat_time) .. ")")
			
			row1:SetValue (100)
			local r, b, g = unpack (instancia.total_bar.color)
			row1.textura:SetVertexColor (r, b, g)
			
			row1.icone_classe:SetTexture (instancia.total_bar.icon)
			row1.icone_classe:SetTexCoord (0.0625, 0.9375, 0.0625, 0.9375)
			
			gump:Fade (row1, "out")
			
			if (following and myPos and myPos > instancia.rows_fit_in_window and instancia.barraS[2] < myPos) then
				for i = iter_last-1, instancia.barraS[1], -1 do --> vai atualizar só o range que esta sendo mostrado
					conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator) 
					qual_barra = qual_barra+1
				end
				
				conteudo[myPos]:AtualizaBarra (instancia, barras_container, qual_barra, myPos, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator) 
				qual_barra = qual_barra+1
			else
				for i = iter_last, instancia.barraS[1], -1 do --> vai atualizar só o range que esta sendo mostrado
					conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator) 
					qual_barra = qual_barra+1
				end
			end
		else
			if (following and myPos and myPos > instancia.rows_fit_in_window and instancia.barraS[2] < myPos) then
				for i = instancia.barraS[2]-1, instancia.barraS[1], -1 do --> vai atualizar só o range que esta sendo mostrado
					conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator) 
					qual_barra = qual_barra+1
				end
				
				conteudo[myPos]:AtualizaBarra (instancia, barras_container, qual_barra, myPos, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator) 
				qual_barra = qual_barra+1
			else
				-- /run print (_detalhes:GetInstance(1).barraS[2]) -- vai do 5 ao 1 -- qual barra começa no 1 -- i = 5 até 1 -- player 5 atualiza na barra 1 / player 1 atualiza na barra 5
				for i = instancia.barraS[2], instancia.barraS[1], -1 do --> vai atualizar só o range que esta sendo mostrado
					conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator) 
					qual_barra = qual_barra+1
				end
			end
		end
	
	end
	
	if (use_animations) then
		instancia:fazer_animacoes (qual_barra - 1)
	end
	
	--> beta, hidar barras não usadas durante um refresh forçado
	if (forcar) then
		if (instancia.modo == 2) then --> group
			for i = qual_barra, instancia.rows_fit_in_window  do
				gump:Fade (instancia.barras [i], "in", 0.3)
			end
		end
	end
	
	return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
	
end

function _detalhes:FastRefreshWindow (instancia)
	if (instancia.atributo == 1) then --> damage
		
	end
end

local actor_class_color_r, actor_class_color_g, actor_class_color_b

-- ~atualizar ~barra
function atributo_damage:AtualizaBarra (instancia, barras_container, qual_barra, lugar, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
							-- instância, container das barras, qual barra, colocação, total?, sub atributo, forçar refresh, key
	
	local esta_barra = barras_container [qual_barra] --> pega a referência da barra na janela
	
	if (not esta_barra) then
		print ("DEBUG: problema com <instancia.esta_barra> "..qual_barra.." "..lugar)
		return
	end
	
	local tabela_anterior = esta_barra.minha_tabela
	
	esta_barra.minha_tabela = self --> grava uma referência desse objeto na barra
	self.minha_barra = esta_barra --> grava uma referência da barra no objeto
	
	esta_barra.colocacao = lugar --> salva na barra qual a colocação mostrada.
	self.colocacao = lugar --> salva no objeto qual a colocação mostrada
	
	local damage_total = self.total --> total de dano que este jogador deu
	local dps
	
	local porcentagem
	local esta_porcentagem
	
	if (percentage_type == 1) then
		porcentagem = _cstr ("%.1f", self [keyName] / total * 100)
	elseif (percentage_type == 2) then
		porcentagem = _cstr ("%.1f", self [keyName] / instancia.top * 100)
	end

	--> tempo da shadow não é calculado pela timemachine
	if ( (_detalhes.time_type == 2 and self.grupo) or not _detalhes:CaptureGet ("damage") or instancia.segmento == -1) then
		if (instancia.segmento == -1 and combat_time == 0) then
			local p = _detalhes.tabela_vigente (1, self.nome)
			if (p) then
				local t = p:Tempo()
				dps = damage_total / t
				self.last_dps = dps
			else
				dps = damage_total / combat_time
				self.last_dps = dps
			end
		else
			--print ("calculando dps")
			dps = damage_total / combat_time
			self.last_dps = dps
		end
	else
		if (not self.on_hold) then
			dps = damage_total/self:Tempo() --calcula o dps deste objeto
			self.last_dps = dps --salva o dps dele
		else
			if (self.last_dps == 0) then --> não calculou o dps dele ainda mas entrou em standby
				dps = damage_total/self:Tempo()
				self.last_dps = dps
			else
				dps = self.last_dps
			end
		end
	end
	
	-- >>>>>>>>>>>>>>> texto da direita

	if (sub_atributo == 1) then --> mostrando damage done
	
		dps = _math_floor (dps)
		local formated_damage = SelectedToKFunction (_, damage_total)
		local formated_dps = SelectedToKFunction (_, dps)
		esta_barra.ps_text = formated_dps

		if (UsingCustomRightText) then
			esta_barra.texto_direita:SetText (_string_replace (instancia.row_info.textR_custom_text, formated_damage, formated_dps, porcentagem, self, instancia.showing))
		else
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
			esta_barra.texto_direita:SetText (formated_damage .. bars_brackets[1] .. formated_dps .. bars_separator .. porcentagem .. bars_brackets[2])
		end
		
		esta_porcentagem = _math_floor ((damage_total/instancia.top) * 100)

	elseif (sub_atributo == 2) then --> mostrando dps
	
		local raw_dps = dps
		dps = _math_floor (dps)
		
		local formated_damage = SelectedToKFunction (_, damage_total)
		local formated_dps = SelectedToKFunction (_, dps)
		esta_barra.ps_text = formated_dps
	
		local diff_from_topdps
	
		if (lugar > 1) then
			diff_from_topdps = instancia.player_top_dps - raw_dps
		end
	
		if (UsingCustomRightText) then
			esta_barra.texto_direita:SetText (_string_replace (instancia.row_info.textR_custom_text, formated_dps, formated_damage, porcentagem, self, instancia.showing))
		else
			
			if (diff_from_topdps) then
				local threshold = diff_from_topdps / instancia.player_top_dps_threshold * 100
				if (threshold < 100) then
					threshold = _math_abs (threshold - 100)
				else
					threshold = 5
				end
				
				local rr, gg, bb = _detalhes:percent_color ( threshold )
				
				rr, gg, bb = _detalhes:hex (_math_floor (rr*255)), _detalhes:hex (_math_floor (gg*255)), "28"
				local color_percent = "" .. rr .. gg .. bb .. ""
				
				if (not bars_show_data [1]) then
					formated_dps = ""
				end
				if (not bars_show_data [2]) then
					color_percent = ""
				else
					color_percent = bars_brackets[1] .. "|cFFFF4444-|r|cFF" .. color_percent .. SelectedToKFunction (_, _math_floor (diff_from_topdps)) .. "|r" .. bars_brackets[2]
				end
				
				esta_barra.texto_direita:SetText (formated_dps .. color_percent)
			else
				
				local icon = "  |TInterface\\GROUPFRAME\\UI-Group-LeaderIcon:14:14:0:0:16:16:0:16:0:16|t "
				if (not bars_show_data [1]) then
					formated_dps = ""
				end
				if (not bars_show_data [2]) then
					icon = ""
				end
				
				esta_barra.texto_direita:SetText (formated_dps .. icon)
			end
		end
		esta_porcentagem = _math_floor ((dps/instancia.top) * 100)
		
	elseif (sub_atributo == 3) then --> mostrando damage taken

		local dtps = self.damage_taken / combat_time
	
		local formated_damage_taken = SelectedToKFunction (_, self.damage_taken)
		local formated_dtps = SelectedToKFunction (_, dtps)
		esta_barra.ps_text = formated_dtps

		if (UsingCustomRightText) then
			esta_barra.texto_direita:SetText (_string_replace (instancia.row_info.textR_custom_text, formated_damage_taken, formated_dtps, porcentagem, self, instancia.showing))
		else
			if (not bars_show_data [1]) then
				formated_damage_taken = ""
			end
			if (not bars_show_data [2]) then
				formated_dtps = ""
			end
			if (not bars_show_data [3]) then
				porcentagem = ""
			else
				porcentagem = porcentagem .. "%"
			end
			esta_barra.texto_direita:SetText (formated_damage_taken .. bars_brackets[1] .. formated_dtps .. bars_separator .. porcentagem .. bars_brackets[2])
		end
		
		esta_porcentagem = _math_floor ((self.damage_taken/instancia.top) * 100)
		
	elseif (sub_atributo == 4) then --> mostrando friendly fire
	
		local formated_friendly_fire = SelectedToKFunction (_, self.friendlyfire_total)

		if (UsingCustomRightText) then
			esta_barra.texto_direita:SetText (_string_replace (instancia.row_info.textR_custom_text, formated_friendly_fire, "", porcentagem, self, instancia.showing))
		else
		
			if (not bars_show_data [1]) then
				formated_friendly_fire = ""
			end
			if (not bars_show_data [3]) then
				porcentagem = ""
			else
				porcentagem = porcentagem .. "%"
			end
		
			esta_barra.texto_direita:SetText (formated_friendly_fire .. bars_brackets[1] .. porcentagem ..  bars_brackets[2])
		end
		esta_porcentagem = _math_floor ((self.friendlyfire_total/instancia.top) * 100)
	
	elseif (sub_atributo == 6) then --> mostrando enemies
	
		local dtps = self.damage_taken / combat_time
	
		local formated_damage_taken = SelectedToKFunction (_, self.damage_taken)
		local formated_dtps = SelectedToKFunction (_, dtps)
		esta_barra.ps_text = formated_dtps

		if (UsingCustomRightText) then
			esta_barra.texto_direita:SetText (_string_replace (instancia.row_info.textR_custom_text, formated_damage_taken, formated_dtps, porcentagem, self, instancia.showing))
		else
			if (not bars_show_data [1]) then
				formated_damage_taken = ""
			end
			if (not bars_show_data [2]) then
				formated_dtps = ""
			end
			if (not bars_show_data [3]) then
				porcentagem = ""
			else
				porcentagem = porcentagem .. "%"
			end
			esta_barra.texto_direita:SetText (formated_damage_taken .. bars_brackets[1] .. formated_dtps .. bars_separator .. porcentagem .. bars_brackets[2])
		end
		
		esta_porcentagem = _math_floor ((self.damage_taken/instancia.top) * 100)
	
		--[[
		dps = _math_floor (dps)
		local formated_damage = SelectedToKFunction (_, damage_total)
		local formated_dps = SelectedToKFunction (_, dps)
		esta_barra.ps_text = formated_dps
	
		if (UsingCustomRightText) then
			esta_barra.texto_direita:SetText (_string_replace (instancia.row_info.textR_custom_text, formated_damage, formated_dps, porcentagem, self, instancia.showing))
		else
		
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
			esta_barra.texto_direita:SetText (formated_damage .. bars_brackets[1] .. formated_dps .. bars_separator .. porcentagem .. bars_brackets[2])

		end
		esta_porcentagem = _math_floor ((damage_total/instancia.top) * 100)
		--]]
	end

	if (esta_barra.mouse_over and not instancia.baseframe.isMoving) then --> precisa atualizar o tooltip
		gump:UpdateTooltip (qual_barra, esta_barra, instancia)
	end

	if (self.need_refresh) then
		self.need_refresh = false
		forcar = true
	end
	
	actor_class_color_r, actor_class_color_g, actor_class_color_b = self:GetBarColor()
	
	return self:RefreshBarra2 (esta_barra, instancia, tabela_anterior, forcar, esta_porcentagem, qual_barra, barras_container, use_animations)

end

--[[ exported]] function _detalhes:RefreshBarra2 (esta_barra, instancia, tabela_anterior, forcar, esta_porcentagem, qual_barra, barras_container, use_animations)
	
	--> primeiro colocado
	if (esta_barra.colocacao == 1) then
		--aqui
		esta_barra.animacao_ignorar = true
		
		if (not tabela_anterior or tabela_anterior ~= esta_barra.minha_tabela or forcar) then
			esta_barra:SetValue (100)
			
			if (esta_barra.hidden or esta_barra.fading_in or esta_barra.faded) then
				gump:Fade (esta_barra, "out")
			end
			
			return self:RefreshBarra (esta_barra, instancia)
		else
			return
		end
	else

		if (esta_barra.hidden or esta_barra.fading_in or esta_barra.faded) then
			
			if (use_animations) then
				esta_barra.animacao_fim = esta_porcentagem
			else
				esta_barra:SetValue (esta_porcentagem)
				esta_barra.animacao_ignorar = true
			end
			
			gump:Fade (esta_barra, "out")
			
			if (instancia.row_info.texture_class_colors) then
				esta_barra.textura:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
			end
			if (instancia.row_info.texture_background_class_color) then
				esta_barra.background:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
			end
			
			return self:RefreshBarra (esta_barra, instancia)
			
		else
			--> agora esta comparando se a tabela da barra é diferente da tabela na atualização anterior
			if (not tabela_anterior or tabela_anterior ~= esta_barra.minha_tabela or forcar) then --> aqui diz se a barra do jogador mudou de posição ou se ela apenas será atualizada
			
				if (use_animations) then
					esta_barra.animacao_fim = esta_porcentagem
				else
					esta_barra:SetValue (esta_porcentagem)
					esta_barra.animacao_ignorar = true
				end
			
				esta_barra.last_value = esta_porcentagem --> reseta o ultimo valor da barra
				
				return self:RefreshBarra (esta_barra, instancia)
				
			elseif (esta_porcentagem ~= esta_barra.last_value) then --> continua mostrando a mesma tabela então compara a porcentagem
				--> apenas atualizar
				if (use_animations) then
					esta_barra.animacao_fim = esta_porcentagem
				else
					esta_barra:SetValue (esta_porcentagem)
				end
				esta_barra.last_value = esta_porcentagem
				
				return self:RefreshBarra (esta_barra, instancia)
			end
		end

	end
	
end

--[[ exported]] function _detalhes:RefreshBarra (esta_barra, instancia, from_resize)
	
	if (from_resize) then
		actor_class_color_r, actor_class_color_g, actor_class_color_b = self:GetBarColor()
	end
	
	if (instancia.row_info.texture_class_colors) then
		esta_barra.textura:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
	end
	if (instancia.row_info.texture_background_class_color) then
		esta_barra.background:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
	end	
	
	--icon
	if (self.spellicon) then
		esta_barra.icone_classe:SetTexture (self.spellicon)
		esta_barra.icone_classe:SetTexCoord (0.078125, 0.921875, 0.078125, 0.921875)
		esta_barra.icone_classe:SetVertexColor (1, 1, 1)
		
	elseif (self.classe == "UNKNOW") then
		esta_barra.icone_classe:SetTexture ([[Interface\AddOns\Details\images\classes_plus]])
		esta_barra.icone_classe:SetTexCoord (0.50390625, 0.62890625, 0, 0.125)
		
		esta_barra.icone_classe:SetVertexColor (1, 1, 1)
	
	elseif (self.classe == "UNGROUPPLAYER") then
		if (self.enemy) then
			if (_detalhes.faction_against == "Horde") then
				esta_barra.icone_classe:SetTexture ("Interface\\ICONS\\Achievement_Character_Orc_Male")
				esta_barra.icone_classe:SetTexCoord (0, 1, 0, 1)
			else
				esta_barra.icone_classe:SetTexture ("Interface\\ICONS\\Achievement_Character_Human_Male")
				esta_barra.icone_classe:SetTexCoord (0, 1, 0, 1)
			end
		else
			if (_detalhes.faction_against == "Horde") then
				esta_barra.icone_classe:SetTexture ("Interface\\ICONS\\Achievement_Character_Human_Male")
				esta_barra.icone_classe:SetTexCoord (0, 1, 0, 1)
			else
				esta_barra.icone_classe:SetTexture ("Interface\\ICONS\\Achievement_Character_Orc_Male")
				esta_barra.icone_classe:SetTexCoord (0, 1, 0, 1)
			end
		end
		esta_barra.icone_classe:SetVertexColor (1, 1, 1)
	
	elseif (self.classe == "PET") then
		esta_barra.icone_classe:SetTexture (instancia.row_info.icon_file)
		esta_barra.icone_classe:SetTexCoord (0.25, 0.49609375, 0.75, 1)
		esta_barra.icone_classe:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)

	else
		if (instancia.row_info.use_spec_icons and self.spec) then
			esta_barra.icone_classe:SetTexture (instancia.row_info.spec_file)
			esta_barra.icone_classe:SetTexCoord (_unpack (_detalhes.class_specs_coords [self.spec]))
			esta_barra.icone_classe:SetVertexColor (1, 1, 1)
		else
			esta_barra.icone_classe:SetTexture (instancia.row_info.icon_file)
			esta_barra.icone_classe:SetTexCoord (_unpack (CLASS_ICON_TCOORDS [self.classe]))
			esta_barra.icone_classe:SetVertexColor (1, 1, 1)
		end
	end

	--texture and text
	local bar_number = ""
	if (instancia.row_info.textL_show_number) then
		bar_number = esta_barra.colocacao .. ". "
	end

	if (self.enemy) then
		if (self.arena_enemy) then
			if (UsingCustomLeftText) then
				esta_barra.texto_esquerdo:SetText (_string_replace (instancia.row_info.textL_custom_text, esta_barra.colocacao, self.displayName, "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" .. instancia.row_info.height .. ":" .. instancia.row_info.height .. ":0:0:256:256:" .. _detalhes.role_texcoord [self.role or "NONE"] .. "|t"))
			else
				esta_barra.texto_esquerdo:SetText (bar_number .. "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" .. instancia.row_info.height .. ":" .. instancia.row_info.height .. ":0:0:256:256:" .. _detalhes.role_texcoord [self.role or "NONE"] .. "|t" .. self.displayName)
			end
			esta_barra.textura:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
		else
			if (_detalhes.faction_against == "Horde") then
				if (UsingCustomLeftText) then
					esta_barra.texto_esquerdo:SetText (_string_replace (instancia.row_info.textL_custom_text, esta_barra.colocacao, self.displayName, "|TInterface\\AddOns\\Details\\images\\icones_barra:"..instancia.row_info.height..":"..instancia.row_info.height..":0:0:256:32:0:32:0:32|t"))
				else
					esta_barra.texto_esquerdo:SetText (bar_number .. "|TInterface\\AddOns\\Details\\images\\icones_barra:"..instancia.row_info.height..":"..instancia.row_info.height..":0:0:256:32:0:32:0:32|t"..self.displayName) --seta o texto da esqueda -- HORDA
				end
			else
				if (UsingCustomLeftText) then
					esta_barra.texto_esquerdo:SetText (_string_replace (instancia.row_info.textL_custom_text, esta_barra.colocacao, self.displayName, "|TInterface\\AddOns\\Details\\images\\icones_barra:"..instancia.row_info.height..":"..instancia.row_info.height..":0:0:256:32:32:64:0:32|t"))
				else
					esta_barra.texto_esquerdo:SetText (bar_number .. "|TInterface\\AddOns\\Details\\images\\icones_barra:"..instancia.row_info.height..":"..instancia.row_info.height..":0:0:256:32:32:64:0:32|t"..self.displayName) --seta o texto da esqueda -- ALLY
				end
			end
			
			if (instancia.row_info.texture_class_colors) then
				esta_barra.textura:SetVertexColor (0.94117, 0, 0.01960, 1)
			end
		end
	else
		if (self.arena_ally) then
			if (UsingCustomLeftText) then
				esta_barra.texto_esquerdo:SetText (_string_replace (instancia.row_info.textL_custom_text, esta_barra.colocacao, self.displayName, "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" .. instancia.row_info.height .. ":" .. instancia.row_info.height .. ":0:0:256:256:" .. _detalhes.role_texcoord [self.role or "NONE"] .. "|t"))
			else
				esta_barra.texto_esquerdo:SetText (bar_number .. "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" .. instancia.row_info.height .. ":" .. instancia.row_info.height .. ":0:0:256:256:" .. _detalhes.role_texcoord [self.role or "NONE"] .. "|t" .. self.displayName)
			end
		else
			if (UsingCustomLeftText) then
				esta_barra.texto_esquerdo:SetText (_string_replace (instancia.row_info.textL_custom_text, esta_barra.colocacao, self.displayName, ""))
			else
				esta_barra.texto_esquerdo:SetText (bar_number .. self.displayName) --seta o texto da esqueda
			end
		end
	end
	
	if (instancia.row_info.textL_class_colors) then
		esta_barra.texto_esquerdo:SetTextColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
	end
	if (instancia.row_info.textR_class_colors) then
		esta_barra.texto_direita:SetTextColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
	end
	
	esta_barra.texto_esquerdo:SetSize (esta_barra:GetWidth() - esta_barra.texto_direita:GetStringWidth() - 20, 15)
	
end


--------------------------------------------- // TOOLTIPS // ---------------------------------------------



---------> TOOLTIPS BIFURCAÇÃO
-- ~tooltip
function atributo_damage:ToolTip (instancia, numero, barra, keydown)
	--> seria possivel aqui colocar o icone da classe dele?

	if (instancia.atributo == 5) then --> custom
		return self:TooltipForCustom (barra)
	else
		if (instancia.sub_atributo == 1 or instancia.sub_atributo == 2) then --> damage done or Dps or enemy
			return self:ToolTip_DamageDone (instancia, numero, barra, keydown)
		elseif (instancia.sub_atributo == 3 or instancia.sub_atributo == 6) then --> damage taken
			return self:ToolTip_DamageTaken (instancia, numero, barra, keydown)
		elseif (instancia.sub_atributo == 4) then --> friendly fire
			return self:ToolTip_FriendlyFire (instancia, numero, barra, keydown)
		end
	end
end
--> tooltip locals
local r, g, b
local barAlha = .6



---------> DAMAGE DONE & DPS


function atributo_damage:ToolTip_DamageDone (instancia, numero, barra, keydown)
	
	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end

	do
		--> TOP HABILIDADES
		
			--get variables
			local ActorDamage = self.total_without_pet
			local ActorDamageWithPet = self.total
			if (ActorDamage == 0) then
				ActorDamage = 0.00000001
			end
			local ActorSkillsContainer = self.spells._ActorTable
			local ActorSkillsSortTable = {}
			
			--get time type
			local meu_tempo
			if (_detalhes.time_type == 1 or not self.grupo) then
				meu_tempo = self:Tempo()
			elseif (_detalhes.time_type == 2) then
				meu_tempo = instancia.showing:GetCombatTime()
			end
			
			--print ("time:", meu_tempo)
			
			--add and sort
			for _spellid, _skill in _pairs (ActorSkillsContainer) do
				ActorSkillsSortTable [#ActorSkillsSortTable+1] = {_spellid, _skill.total, _skill.total/meu_tempo}
			end
			_table_sort (ActorSkillsSortTable, _detalhes.Sort2)
		
		--> TOP INIMIGOS
			--get variables
			local ActorTargetsSortTable = {}
			
			--add and sort
			for target_name, amount in _pairs (self.targets) do
				ActorTargetsSortTable [#ActorTargetsSortTable+1] = {target_name, amount}
			end
			_table_sort (ActorTargetsSortTable, _detalhes.Sort2)

			--tooltip stuff
			local tooltip_max_abilities = _detalhes.tooltip.tooltip_max_abilities
			if (instancia.sub_atributo == 2) then
				tooltip_max_abilities = 6
			end
			
			local is_maximized = false
			if (keydown == "shift" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 3) then
				tooltip_max_abilities = 99
				is_maximized = true
			end
			
		--> MOSTRA HABILIDADES
			_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_SPELLS"], headerColor, r, g, b, #ActorSkillsSortTable)
			
			--GameCooltip:AddIcon ([[Interface\ICONS\Spell_Shaman_BlessingOfTheEternals]], 1, 1, 14, 14, 0.90625, 0.109375, 0.15625, 0.875)
			GameCooltip:AddIcon (_detalhes.tooltip_spell_icon.file, 1, 1, 14, 14, unpack (_detalhes.tooltip_spell_icon.coords))
			
			if (is_maximized) then
				--highlight shift key
				GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
				GameCooltip:AddStatusBar (100, 1, r, g, b, 1)
			else
				GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
				GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
			end
			
			--habilidades
			if (#ActorSkillsSortTable > 0) then
				for i = 1, _math_min (tooltip_max_abilities, #ActorSkillsSortTable) do
					local SkillTable = ActorSkillsSortTable [i]
					local nome_magia, _, icone_magia = _GetSpellInfo (SkillTable [1])
					if (instancia.sub_atributo == 1 or instancia.sub_atributo == 6) then
						GameCooltip:AddLine (nome_magia..": ", FormatTooltipNumber (_, SkillTable [2]) .." (".._cstr("%.1f", SkillTable [2]/ActorDamage*100).."%)")
					else
						GameCooltip:AddLine (nome_magia..": ", FormatTooltipNumber (_, _math_floor (SkillTable [3])) .." (".._cstr("%.1f", SkillTable [2]/ActorDamage*100).."%)")
					end
					GameCooltip:AddIcon (icone_magia, nil, nil, 14, 14)
					_detalhes:AddTooltipBackgroundStatusbar()
				end
			else
				GameCooltip:AddLine (Loc ["STRING_NO_SPELL"])
			end
			
		--> MOSTRA INIMIGOS
			if (instancia.sub_atributo == 1 or instancia.sub_atributo == 6) then
				
				_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_TARGETS"], headerColor, r, g, b, #ActorTargetsSortTable)

				local max_targets = _detalhes.tooltip.tooltip_max_targets
				local is_maximized = false
				if (keydown == "ctrl" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 4) then
					max_targets = 99
					is_maximized = true
				end
				
				GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0, 0.03125, 0.126953125, 0.15625)
				
				if (is_maximized) then
					--highlight
					GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
					GameCooltip:AddStatusBar (100, 1, r, g, b, 1)
				else
					GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
					GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
				end

				for i = 1, _math_min (max_targets, #ActorTargetsSortTable) do
					local este_inimigo = ActorTargetsSortTable [i]
					GameCooltip:AddLine (este_inimigo[1]..": ", FormatTooltipNumber (_, este_inimigo[2]) .." (".._cstr("%.1f", este_inimigo[2]/ActorDamageWithPet*100).."%)")
					--GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\espadas", nil, nil, 14, 14)
					--GameCooltip:AddIcon ([[Interface\CHARACTERFRAME\UI-StateIcon]], nil, nil, 14, 14, 33/64, 61/64, 31/64, 60/64)
					--GameCooltip:AddIcon ([[Interface\FriendsFrame\StatusIcon-Offline]], nil, nil, 14, 14, 0, 1, 0, 15/16)
					GameCooltip:AddIcon ([[Interface\PetBattles\PetBattle-StatIcons]], nil, nil, 12, 12, 0, 0.5, 0, 0.5, {.7, .7, .7, 1}, nil, true)
					_detalhes:AddTooltipBackgroundStatusbar()
				end
			end
	end
	
	--> PETS
	local meus_pets = self.pets
	if (#meus_pets > 0) then --> teve ajudantes
		
		local quantidade = {} --> armazena a quantidade de pets iguais
		local danos = {} --> armazena as habilidades
		local alvos = {} --> armazena os alvos
		local totais = {} --> armazena o dano total de cada objeto
		
		for index, nome in _ipairs (meus_pets) do
			if (not quantidade [nome]) then
				quantidade [nome] = 1
				
				local my_self = instancia.showing[class_type]:PegarCombatente (nil, nome)
				if (my_self) then
					local meu_total = my_self.total_without_pet
					local tabela = my_self.spells._ActorTable
					local meus_danos = {}
					
					--totais [nome] = my_self.total_without_pet
					local meu_tempo
					if (_detalhes.time_type == 1 or not self.grupo) then
						meu_tempo = my_self:Tempo()
					elseif (_detalhes.time_type == 2) then
						meu_tempo = my_self:GetCombatTime()
					end
					totais [#totais+1] = {nome, my_self.total_without_pet, my_self.total_without_pet/meu_tempo}
					
					for spellid, tabela in _pairs (tabela) do
						local nome, rank, icone = _GetSpellInfo (spellid)
						_table_insert (meus_danos, {spellid, tabela.total, tabela.total/meu_total*100, {nome, rank, icone}})
					end
					_table_sort (meus_danos, _detalhes.Sort2)
					danos [nome] = meus_danos
					
					local meus_inimigos = {}
					tabela = my_self.targets
					for target_name, amount in _pairs (tabela) do
						_table_insert (meus_inimigos, {target_name, amount, amount/meu_total*100})
					end
					_table_sort (meus_inimigos,_detalhes.Sort2)
					alvos [nome] = meus_inimigos
				end
				
			else
				quantidade [nome] = quantidade [nome]+1
			end
		end
		
		--GameTooltip:AddLine (" ")
		--GameCooltip:AddLine (" ")
		
		local _quantidade = 0
		local added_logo = false
		
		_table_sort (totais, _detalhes.Sort2)
		
		local ismaximized = false
		if (keydown == "alt" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 5) then
			ismaximized = true
		end
		
		for index, _table in _ipairs (totais) do
			
			if (_table [2] > 0 and (index <= _detalhes.tooltip.tooltip_max_pets or ismaximized)) then
			
				if (not added_logo) then
					added_logo = true
					
					_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_PETS"], headerColor, r, g, b, #totais)
					
					GameCooltip:AddIcon ([[Interface\COMMON\friendship-heart]], 1, 1, 14, 14, 0.21875, 0.78125, 0.09375, 0.6875)
					
					if (ismaximized) then
						GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_alt]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
						GameCooltip:AddStatusBar (100, 1, r, g, b, 1)
					else
						GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_alt]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
						GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
					end

				end
			
				local n = _table [1]:gsub (("%s%<.*"), "")
				if (instancia.sub_atributo == 1) then
					GameCooltip:AddLine (n, FormatTooltipNumber (_, _table [2]) .. " (" .. _math_floor (_table [2]/self.total*100) .. "%)")
				else
					GameCooltip:AddLine (n, FormatTooltipNumber (_,  _math_floor (_table [3])) .. " (" .. _math_floor (_table [2]/self.total*100) .. "%)")
				end
				_detalhes:AddTooltipBackgroundStatusbar()
				GameCooltip:AddIcon ([[Interface\AddOns\Details\images\classes_small]], 1, 1, 14, 14, 0.25, 0.49609375, 0.75, 1)
			end
		end
			
	end
	
	--> enemies
	if (instancia.sub_atributo == 6) then
		GameCooltip:AddLine (" ")
		GameCooltip:AddLine (Loc ["STRING_LEFTCLICK_DAMAGETAKEN"])
		--GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, 16, 8/512, 70/512, 224/512, 306/512)
		GameCooltip:AddLine (Loc ["STRING_MIDDLECLICK_DAMAGETAKEN"])
		--GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, 16, 14/512, 64/512, 127/512, 204/512)
	end
	
	return true
end

---------> DAMAGE TAKEN
function atributo_damage:ToolTip_DamageTaken (instancia, numero, barra, keydown)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end

	local agressores = self.damage_from
	local damage_taken = self.damage_taken
	
	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable
	
	local meus_agressores = {}

	for nome, _ in _pairs (agressores) do --> lista de nomes
		local este_agressor = showing._ActorTable [showing._NameIndexTable [nome]]
		if (este_agressor) then --> checagem por causa do total e do garbage collector que não limpa os nomes que deram dano
			local name = nome
			local damage_amount = este_agressor.targets [self.nome]
			
			if (damage_amount) then
				if (este_agressor:IsPlayer() or este_agressor:IsNeutralOrEnemy()) then
					meus_agressores [#meus_agressores+1] = {name, damage_amount, este_agressor.classe, este_agressor}
				end
			end
		end
	end

	_table_sort (meus_agressores, _detalhes.Sort2)
	
	local max = #meus_agressores
	if (max > 10) then
		max = 10
	end
	
	local ismaximized = false
	if (keydown == "shift" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 3 or instancia.sub_atributo == 6 or _detalhes.damage_taken_everything) then
		max = #meus_agressores
		ismaximized = true
	end

	if (instancia.sub_atributo == 6) then
		_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_DAMAGE_TAKEN_FROM"], headerColor, r, g, b, #meus_agressores)
		GameCooltip:AddIcon ([[Interface\Buttons\UI-MicroStream-Red]], 1, 1, 14, 14, 0.1875, 0.8125, 0.15625, 0.78125)
	else
		_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_FROM"], headerColor, r, g, b, #meus_agressores)
		GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0.126953125, 0.1796875, 0, 0.0546875)
	end

	if (ismaximized) then
		--highlight
		GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
		if (instancia.sub_atributo == 6) then
			GameCooltip:AddStatusBar (100, 1, 0.7, g, b, 1)
		else
			GameCooltip:AddStatusBar (100, 1, r, g, b, 1)
		end
	else
		GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
		if (instancia.sub_atributo == 6) then
			GameCooltip:AddStatusBar (100, 1, 0.7, 0, 0, barAlha)
		else
			GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
		end
	end	
	
	for i = 1, max do
	
		local aggressor = meus_agressores[i][4]
		if (aggressor:IsNeutralOrEnemy()) then
		
			local all_spells = {}
		
			for spellid, spell in _pairs (aggressor.spells._ActorTable) do
				local on_target = spell.targets [self.nome]
				if (on_target) then
					tinsert (all_spells, {spellid, on_target, aggressor.nome})
				end
			end
			
			for _, spell in _ipairs (all_spells) do
				local spellname, _, spellicon = _GetSpellInfo (spell [1])
				GameCooltip:AddLine (spellname .. " (|cFFFFFF00" .. spell [3] .. "|r): ", FormatTooltipNumber (_, spell [2]).." (" .. _cstr ("%.1f", (spell [2] / damage_taken) * 100).."%)")
				GameCooltip:AddIcon (spellicon, 1, 1, 14, 14)
				_detalhes:AddTooltipBackgroundStatusbar()
			end
			
		else
			if (ismaximized and meus_agressores[i][1]:find (_detalhes.playername)) then
				GameCooltip:AddLine (meus_agressores[i][1]..": ", FormatTooltipNumber (_, meus_agressores[i][2]).." (".._cstr("%.1f", (meus_agressores[i][2]/damage_taken) * 100).."%)", nil, "yellow")
			else
				GameCooltip:AddLine (meus_agressores[i][1]..": ", FormatTooltipNumber (_, meus_agressores[i][2]).." (".._cstr("%.1f", (meus_agressores[i][2]/damage_taken) * 100).."%)")
			end
			local classe = meus_agressores[i][3]
			
			if (not classe) then
				classe = "UNKNOW"
			end
			
			if (classe == "UNKNOW") then
				GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, 14, 14, .25, .5, 0, 1)
			else
				GameCooltip:AddIcon (instancia.row_info.icon_file, nil, nil, 14, 14, _unpack (_detalhes.class_coords [classe]))
			end
			_detalhes:AddTooltipBackgroundStatusbar()
		end
	end

	if (instancia.sub_atributo == 6) then
	
		GameCooltip:AddLine (" ")
		GameCooltip:AddLine (Loc ["STRING_ATTRIBUTE_DAMAGE_DONE"], FormatTooltipNumber (_, _math_floor (self.total)))
		local half = 0.00048828125
		GameCooltip:AddIcon (instancia:GetSkinTexture(), 1, 1, 14, 14, 0.005859375 + half, 0.025390625 - half, 0.3623046875, 0.3818359375)
		_detalhes:AddTooltipBackgroundStatusbar()
		
		local heal_actor = instancia.showing (2, self.nome)
		if (heal_actor) then
			GameCooltip:AddLine (Loc ["STRING_ATTRIBUTE_HEAL_DONE"], FormatTooltipNumber (_, _math_floor (heal_actor.heal_enemy_amt)))
		else
			GameCooltip:AddLine (Loc ["STRING_ATTRIBUTE_HEAL_DONE"], 0)
		end
		GameCooltip:AddIcon (instancia:GetSkinTexture(), 1, 1, 14, 14, 0.037109375 + half, 0.056640625 - half, 0.3623046875, 0.3818359375)
		_detalhes:AddTooltipBackgroundStatusbar()
		
	end
	
	--> enemies
	if (instancia.sub_atributo == 6) then
		GameCooltip:AddLine (" ")
		GameCooltip:AddLine (Loc ["STRING_LEFTCLICK_DAMAGETAKEN"])
		GameCooltip:AddStatusBar (100, 1, 0, 0, 0, 0.7)
		GameCooltip:AddLine (Loc ["STRING_MIDDLECLICK_DAMAGETAKEN"])
		GameCooltip:AddStatusBar (100, 1, 0, 0, 0, 0.7)
	end
	
	return true
end

---------> FRIENDLY FIRE
function atributo_damage:ToolTip_FriendlyFire (instancia, numero, barra, keydown)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end

	local FriendlyFire = self.friendlyfire
	local FriendlyFireTotal = self.friendlyfire_total
	local combat = instancia:GetShowingCombat()

	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type]
	
	local DamagedPlayers = {}
	local Skills = {}

	for target_name, ff_table in _pairs (FriendlyFire) do
		local actor = combat (1, target_name)
		if (actor) then
			DamagedPlayers [#DamagedPlayers+1] = {target_name, ff_table.total, actor.classe}
			for spellid, amount in _pairs (ff_table.spells) do
				Skills [#Skills+1] = {spellid, amount}
			end
		end
	end
	
	_table_sort (DamagedPlayers, _detalhes.Sort2)
	_table_sort (Skills, _detalhes.Sort2)

	_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_TARGETS"], headerColor, r, g, b, #DamagedPlayers)
	
	GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0.126953125, 0.224609375, 0.056640625, 0.140625)
	
	local ismaximized = false
	if (keydown == "shift" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 3) then
		GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
		GameCooltip:AddStatusBar (100, 1, r, g, b, 1)
		ismaximized = true
	else
		GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
		GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
	end
	
	local max_abilities = _detalhes.tooltip.tooltip_max_abilities
	if (ismaximized) then
		max_abilities = 99
	end
	
	for i = 1, _math_min (max_abilities, #DamagedPlayers) do
		local classe = DamagedPlayers[i][3]
		if (not classe) then
			classe = "UNKNOW"
		end

		GameCooltip:AddLine (DamagedPlayers[i][1]..": ", FormatTooltipNumber (_, DamagedPlayers[i][2]).." (".._cstr("%.1f", DamagedPlayers[i][2]/FriendlyFireTotal*100).."%)")
		GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\espadas", nil, nil, 14, 14)
		_detalhes:AddTooltipBackgroundStatusbar()
		
		if (classe == "UNKNOW") then
			GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack (_detalhes.class_coords ["UNKNOW"]))
		else
			GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack (_detalhes.class_coords [classe]))
		end
		
	end
	
	GameCooltip:AddLine (Loc ["STRING_SPELLS"].."", nil, nil, headerColor, nil, 12)

	GameCooltip:AddIcon ([[Interface\PVPFrame\bg-down-on]], 1, 1, 14, 14, 0, 1, 0, 1)
	
	local ismaximized = false
	if (keydown == "ctrl" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 4) then
		GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
		GameCooltip:AddStatusBar (100, 1, r, g, b, 1)
		ismaximized = true
	else
		GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
		GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
	end
	
	local max_abilities2 = _detalhes.tooltip.tooltip_max_abilities
	if (ismaximized) then
		max_abilities2 = 99
	end
	
	for i = 1, _math_min (max_abilities2, #Skills) do
		local nome, _, icone = _GetSpellInfo (Skills[i][1])
		GameCooltip:AddLine (nome .. ": ", FormatTooltipNumber (_, Skills[i][2]).." (".._cstr("%.1f", Skills[i][2]/FriendlyFireTotal*100).."%)")
		GameCooltip:AddIcon (icone, nil, nil, 14, 14)
		_detalhes:AddTooltipBackgroundStatusbar()
	end	
	
	return true
end


--------------------------------------------- // JANELA DETALHES // ---------------------------------------------


---------> DETALHES BIFURCAÇÃO
function atributo_damage:MontaInfo()
	if (info.sub_atributo == 1 or info.sub_atributo == 2 or info.sub_atributo == 6) then --> damage done & dps
		return self:MontaInfoDamageDone()
	elseif (info.sub_atributo == 3) then --> damage taken
		return self:MontaInfoDamageTaken()
	elseif (info.sub_atributo == 4) then --> friendly fire
		return self:MontaInfoFriendlyFire()
	end
end

---------> DETALHES bloco da direita BIFURCAÇÃO
function atributo_damage:MontaDetalhes (spellid, barra)
	if (info.sub_atributo == 1 or info.sub_atributo == 2) then
		return self:MontaDetalhesDamageDone (spellid, barra)
	elseif (info.sub_atributo == 3) then
		return self:MontaDetalhesDamageTaken (spellid, barra)
	elseif (info.sub_atributo == 4) then
		return self:MontaDetalhesFriendlyFire (spellid, barra)
	elseif (info.sub_atributo == 6) then
		if (_bit_band (self.flag_original, 0x00000400) ~= 0) then --é um jogador
			return self:MontaDetalhesDamageDone (spellid, barra)
		end
		return self:MontaDetalhesEnemy (spellid, barra)
		--return self:MontaDetalhesDamageDone (spellid, barra)
	end
end


------ Friendly Fire
function atributo_damage:MontaInfoFriendlyFire()

	local instancia = info.instancia
	local combat = instancia:GetShowingCombat()
	local barras = info.barras1
	local barras2 = info.barras2
	local barras3 = info.barras3
	
	local FriendlyFireTotal = self.friendlyfire_total
	
	local DamagedPlayers = {}
	local Skills = {}
	
	for target_name, ff_table in _pairs (self.friendlyfire) do
	
		local actor = combat (1, target_name)
		if (actor) then
			_table_insert (DamagedPlayers, {target_name, ff_table.total, ff_table.total / FriendlyFireTotal * 100, actor.classe})
			
			for spellid, amount in _pairs (ff_table.spells) do
				Skills [spellid] = (Skills [spellid] or 0) + amount
			end
		end
	end

	_table_sort (DamagedPlayers, _detalhes.Sort2)
	
	local amt = #DamagedPlayers
	gump:JI_AtualizaContainerBarras (amt)
	
	local FirstPlaceDamage = DamagedPlayers [1] and DamagedPlayers [1][2] or 0
	
	for index, tabela in _ipairs (DamagedPlayers) do
		local barra = barras [index]

		if (not barra) then
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1)
			barra.on_focus = false
		end
		
		if (not info.mostrando_mouse_over) then
			if (tabela[1] == self.detalhes) then --> tabela [1] = NOME = NOME que esta na caixa da direita
				if (not barra.on_focus) then --> se a barra não tiver no foco
					barra.textura:SetStatusBarColor (129/255, 125/255, 69/255, 1)
					barra.on_focus = true
					if (not info.mostrando) then
						info.mostrando = barra
					end
				end
			else
				if (barra.on_focus) then
					barra.textura:SetStatusBarColor (1, 1, 1, 1) --> volta a cor antiga
					barra:SetAlpha (.9) --> volta a alfa antiga
					barra.on_focus = false
				end
			end
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/FirstPlaceDamage*100)
		end
		
		barra.texto_esquerdo:SetText (index .. instancia.divisores.colocacao .. _detalhes:GetOnlyName (tabela[1])) --seta o texto da esqueda
		barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .. " (" .. _cstr ("%.1f", tabela[3]) .."%)") --seta o texto da direita
		
		local classe = tabela[4]
		if (not classe) then
			classe = "MONSTER"
		end
		
		barra.icone:SetTexture (info.instancia.row_info.icon_file)
		
		if (CLASS_ICON_TCOORDS [classe]) then
			barra.icone:SetTexCoord (_unpack (CLASS_ICON_TCOORDS [classe]))
		else
			barra.icone:SetTexture (nil)
		end

		local color = _detalhes.class_colors [classe]
		if (color) then
			barra.textura:SetStatusBarColor (_unpack (color))
		else
			barra.textura:SetStatusBarColor (1, 1, 1)
		end

		barra.minha_tabela = self
		barra.show = tabela[1]
		barra:Show()

		if (self.detalhes and self.detalhes == barra.show) then
			self:MontaDetalhes (self.detalhes, barra)
		end
	end

	local SkillTable = {}
	for spellid, amt in _pairs (Skills) do
		local nome, _, icone = _GetSpellInfo (spellid)
		SkillTable [#SkillTable+1] = {nome, amt, amt/FriendlyFireTotal*100, icone}
	end

	_table_sort (SkillTable, _detalhes.Sort2)	
	
	amt = #SkillTable
	if (amt < 1) then
		return
	end

	gump:JI_AtualizaContainerAlvos (amt)
	
	FirstPlaceDamage = SkillTable [1] and SkillTable [1][2] or 0
	
	for index, tabela in _ipairs (SkillTable) do
		local barra = barras2 [index]
		
		if (not barra) then
			barra = gump:CriaNovaBarraInfo2 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1)
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/FirstPlaceDamage*100)
		end
		
		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
		barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .." (" .._cstr("%.1f", tabela[3]) .. ")") --seta o texto da direita
		barra.icone:SetTexture (tabela[4])
		
		barra.minha_tabela = nil --> desativa o tooltip
	
		barra:Show()
	end
	
end

------ Damage Taken
function atributo_damage:MontaInfoDamageTaken()

	local damage_taken = self.damage_taken
	local agressores = self.damage_from
	local instancia = info.instancia
	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable
	local barras = info.barras1	
	local meus_agressores = {}
	
	local este_agressor	
	for nome, _ in _pairs (agressores) do
		este_agressor = showing._ActorTable[showing._NameIndexTable[nome]]
		if (este_agressor) then
			local alvos = este_agressor.targets
			local este_alvo = alvos [self.nome]
			if (este_alvo) then
				meus_agressores [#meus_agressores+1] = {nome, este_alvo, este_alvo/damage_taken*100, este_agressor.classe}
			end
		end
	end

	local amt = #meus_agressores
	
	if (amt < 1) then --> caso houve apenas friendly fire
		return true
	end
	
	--_table_sort (meus_agressores, function (a, b) return a[2] > b[2] end)
	_table_sort (meus_agressores, _detalhes.Sort2)
	
	gump:JI_AtualizaContainerBarras (amt)

	local max_ = meus_agressores [1] and meus_agressores [1][2] or 0

	local barra
	for index, tabela in _ipairs (meus_agressores) do
		barra = barras [index]
		if (not barra) then
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
		end

		self:FocusLock (barra, tabela[1])
		
		local texCoords = CLASS_ICON_TCOORDS [tabela[4]]
		if (not texCoords) then
			texCoords = _detalhes.class_coords ["UNKNOW"]
		end
		
		self:UpdadeInfoBar (barra, index, tabela[1], tabela[1], tabela[2], _detalhes:comma_value (tabela[2]), max_, tabela[3], "Interface\\AddOns\\Details\\images\\classes_small_alpha", true, texCoords, nil, tabela[4])
	end
	
end

--[[exported]] function _detalhes:UpdadeInfoBar (row, index, spellid, name, value, value_formated, max, percent, icon, detalhes, texCoords, spellschool, class)
	--> seta o tamanho da barra
	if (index == 1) then
		row.textura:SetValue (100)
	else
		row.textura:SetValue (value/max*100)
	end
	
	row.texto_esquerdo:SetText (index .. ". " .. name)
	row.texto_esquerdo.text = row.texto_esquerdo:GetText()
	
	row.texto_direita:SetText (value_formated .. " (" .. _cstr ("%.1f", percent) .."%)")
	
	row.texto_esquerdo:SetSize (row:GetWidth() - row.texto_direita:GetStringWidth() - 40, 15)

	--> seta o icone
	if (icon) then 
		row.icone:SetTexture (icon)
		if (icon == "Interface\\AddOns\\Details\\images\\classes_small") then
			row.icone:SetTexCoord (0.25, 0.49609375, 0.75, 1)
		else
			row.icone:SetTexCoord (0, 1, 0, 1)
		end
	else
		row.icone:SetTexture ("")
	end
	
	if (texCoords) then
		row.icone:SetTexCoord (unpack (texCoords))
	end
	
	row.minha_tabela = self
	row.show = spellid
	row:Show() --> mostra a barra
	
	if (spellschool) then
		local t = _detalhes.spells_school [spellschool]
		if (t and t.decimals) then
			row.textura:SetStatusBarColor (t.decimals[1], t.decimals[2], t.decimals[3])
		else
			row.textura:SetStatusBarColor (1, 1, 1)
		end
		
	elseif (class) then
		local color = _detalhes.class_colors [class]
		if (color) then
			row.textura:SetStatusBarColor (_unpack (color))
		else
			row.textura:SetStatusBarColor (1, 1, 1)
		end
	else
		if (spellid == 98021) then
			row.textura:SetStatusBarColor (1, 0.4, 0.4)
		else
			row.textura:SetStatusBarColor (1, 1, 1)
		end
	end
	
	if (detalhes and self.detalhes and self.detalhes == spellid and info.showing == index) then
		--self:MontaDetalhes (spellid, row) --> poderia deixar isso pro final e montar uma tail call??
		self:MontaDetalhes (row.show, row, info.instancia) --> poderia deixar isso pro final e montar uma tail call??
	end
end

--[[exported]] function _detalhes:FocusLock (row, spellid)
	if (not info.mostrando_mouse_over) then
		if (spellid == self.detalhes) then --> tabela [1] = spellid = spellid que esta na caixa da direita
			if (not row.on_focus) then --> se a barra não tiver no foco
				row.textura:SetStatusBarColor (129/255, 125/255, 69/255, 1)
				row.on_focus = true
				if (not info.mostrando) then
					info.mostrando = row
				end
			end
		else
			if (row.on_focus) then
				row.textura:SetStatusBarColor (1, 1, 1, 1) --> volta a cor antiga
				row:SetAlpha (.9) --> volta a alfa antiga
				row.on_focus = false
			end
		end
	end
end

------ Damage Done & Dps
function atributo_damage:MontaInfoDamageDone()

	local barras = info.barras1
	local instancia = info.instancia
	local total = self.total_without_pet --> total de dano aplicado por este jogador 
	
	local ActorTotalDamage = self.total
	local ActorSkillsSortTable = {}
	local ActorSkillsContainer = self.spells._ActorTable
	
	--get time type
	local meu_tempo
	if (_detalhes.time_type == 1 or not self.grupo) then
		meu_tempo = self:Tempo()
	elseif (_detalhes.time_type == 2) then
		meu_tempo = info.instancia.showing:GetCombatTime()
	end
	
	for _spellid, _skill in _pairs (ActorSkillsContainer) do --> da foreach em cada spellid do container
		local nome, _, icone = _GetSpellInfo (_spellid)
		_table_insert (ActorSkillsSortTable, {_spellid, _skill.total, _skill.total/ActorTotalDamage*100, nome, icone, nil, _skill.spellschool})
	end

	--> add pets
	local ActorPets = self.pets
	--local class_color = RAID_CLASS_COLORS [self.classe] and RAID_CLASS_COLORS [self.classe].colorStr
	local class_color = "FFDDDDDD"
	local class_color = "FFDDDD44"
	for _, PetName in _ipairs (ActorPets) do
		local PetActor = instancia.showing (class_type, PetName)
		if (PetActor) then 
			local PetSkillsContainer = PetActor.spells._ActorTable
			for _spellid, _skill in _pairs (PetSkillsContainer) do --> da foreach em cada spellid do container
				local nome, _, icone = _GetSpellInfo (_spellid)
				_table_insert (ActorSkillsSortTable, {_spellid, _skill.total, _skill.total/ActorTotalDamage*100, nome .. " |TInterface\\AddOns\\Details\\images\\classes_small_alpha:12:12:0:0:128:128:33:64:96:128|t|c" .. class_color .. PetName:gsub ((" <.*"), "") .. "|r", icone, PetActor, _skill.spellschool})
			end
		end
	end
	
	_table_sort (ActorSkillsSortTable, _detalhes.Sort2)

	gump:JI_AtualizaContainerBarras (#ActorSkillsSortTable)

	local max_ = ActorSkillsSortTable[1] and ActorSkillsSortTable[1][2] or 0 --> dano que a primeiro magia vez

	local barra
	for index, tabela in _ipairs (ActorSkillsSortTable) do
		barra = barras [index]
		if (not barra) then
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
		end

		barra.other_actor = tabela [6]

		local name = tabela[4]
		
		if (info.sub_atributo == 2) then
			self:UpdadeInfoBar (barra, index, tabela[1], name, tabela[2], _detalhes:comma_value (_math_floor (tabela[2]/meu_tempo)), max_, tabela[3], tabela[5], true, nil, tabela [7])
		else
			self:UpdadeInfoBar (barra, index, tabela[1], name, tabela[2], _detalhes:comma_value (tabela[2]), max_, tabela[3], tabela[5], true, nil, tabela [7])
		end
		
		self:FocusLock (barra, tabela[1])

	end
	
	--> TOP INIMIGOS
	if (instancia.sub_atributo == 6) then
	
		local damage_taken = self.damage_taken
		local agressores = self.damage_from
		local tabela_do_combate = instancia.showing
		local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable
		local barras = info.barras2
		local meus_agressores = {}
		
		local este_agressor	
		for nome, _ in _pairs (agressores) do
			este_agressor = showing._ActorTable[showing._NameIndexTable[nome]]
			if (este_agressor) then
				local este_alvo = este_agressor.targets [self.nome]
				if (este_alvo) then
					meus_agressores [#meus_agressores+1] = {nome, este_alvo, este_alvo/damage_taken*100, este_agressor.classe}
				end
			end
		end

		local amt = #meus_agressores
		
		if (amt < 1) then --> caso houve apenas friendly fire
			return true
		end
		
		gump:JI_AtualizaContainerAlvos (amt)
		
		--_table_sort (meus_agressores, function (a, b) return a[2] > b[2] end)
		_table_sort (meus_agressores, _detalhes.Sort2)
		
		local max_ = meus_agressores[1] and meus_agressores[1][2] or 0 --> dano que a primeiro magia vez
		
		local barra
		for index, tabela in _ipairs (meus_agressores) do
			barra = barras [index]

			if (not barra) then --> se a barra não existir, criar ela então
				barra = gump:CriaNovaBarraInfo2 (instancia, index)
				barra.textura:SetStatusBarColor (1, 1, 1, 1) --> isso aqui é a parte da seleção e desceleção
			end
			
			if (index == 1) then
				barra.textura:SetValue (100)
			else
				barra.textura:SetValue (tabela[2]/max_*100)
			end

			barra.texto_esquerdo:SetText (index .. ". " .. _detalhes:GetOnlyName (tabela[1])) --seta o texto da esqueda
			barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .. " (" .. _cstr ("%.1f", tabela[3]) .. "%)") --seta o texto da direita
			
			barra.icone:SetTexture ([[Interface\AddOns\Details\images\classes_small_alpha]]) --CLASSE
			
			local texCoords = _detalhes.class_coords [tabela[4]]
			if (not texCoords) then
				texCoords = _detalhes.class_coords ["UNKNOW"]
			end
			barra.icone:SetTexCoord (_unpack (texCoords))
			
			local color = _detalhes.class_colors [tabela[4]]
			if (color) then
				barra.textura:SetStatusBarColor (_unpack (color))
			else
				barra.textura:SetStatusBarColor (1, 1, 1)
			end
			
			_detalhes:name_space_info (barra)
			
			if (barra.mouse_over) then --> atualizar o tooltip
				if (barra.isAlvo) then
					GameTooltip:Hide() 
					GameTooltip:SetOwner (barra, "ANCHOR_TOPRIGHT")
					if (not barra.minha_tabela:MontaTooltipDamageTaken (barra, index)) then
						return
					end
					GameTooltip:Show()
				end
			end
			
			barra.minha_tabela = self --> grava o jogador na tabela
			barra.nome_inimigo = tabela [1] --> salva o nome do inimigo na barra --> isso é necessário?
			
			-- no lugar do spell id colocar o que?
			barra.spellid = "enemies"

			barra:Show() --> mostra a barra
		end
	else
		local meus_inimigos = {}
		
		--> my target container
		conteudo = self.targets
		for target_name, amount in _pairs (conteudo) do
			_table_insert (meus_inimigos, {target_name, amount, amount/total*100})
		end
		
		--> sort
		_table_sort (meus_inimigos, _detalhes.Sort2)
		
		local amt_alvos = #meus_inimigos
		if (amt_alvos < 1) then
			return
		end
		
		gump:JI_AtualizaContainerAlvos (amt_alvos)
		
		local max_inimigos = meus_inimigos[1] and meus_inimigos[1][2] or 0
		
		local barra
		for index, tabela in _ipairs (meus_inimigos) do
		
			barra = info.barras2 [index]
			
			if (not barra) then
				barra = gump:CriaNovaBarraInfo2 (instancia, index)
				barra.textura:SetStatusBarColor (1, 1, 1, 1)
			end
			
			if (index == 1) then
				barra.textura:SetValue (100)
			else
				barra.textura:SetValue (tabela[2]/max_inimigos*100)
			end
			
			barra.textura:SetStatusBarColor (1, 0.8, 0.8)
			
			barra.icone:SetTexture ([[Interface\AddOns\Details\images\classes_small_alpha]]) --CLASSE
			
			local texCoords = _detalhes.class_coords ["ENEMY"]
			barra.icone:SetTexCoord (_unpack (texCoords))
			
			barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
			if (info.sub_atributo == 2) then
				barra.texto_direita:SetText (_detalhes:comma_value ( _math_floor (tabela[2]/meu_tempo)) .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[3]) .. instancia.divisores.fecha) --seta o texto da direita
			else
				barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[3]) .. instancia.divisores.fecha) --seta o texto da direita
			end
			
			if (barra.mouse_over) then --> atualizar o tooltip
				if (barra.isAlvo) then
					GameTooltip:Hide() 
					GameTooltip:SetOwner (barra, "ANCHOR_TOPRIGHT")
					if (not barra.minha_tabela:MontaTooltipAlvos (barra, index, instancia)) then
						return
					end
					GameTooltip:Show()
				end
			end
			
			barra.minha_tabela = self --> grava o jogador na tabela
			barra.nome_inimigo = tabela [1] --> salva o nome do inimigo na barra --> isso é necessário?
			
			-- no lugar do spell id colocar o que?
			barra.spellid = tabela[5]
			barra:Show()
		end
	end
end


------ Detalhe Info Friendly Fire
function atributo_damage:MontaDetalhesFriendlyFire (nome, barra)

	for _, barra in _ipairs (info.barras3) do 
		barra:Hide()
	end

	local barras = info.barras3
	local instancia = info.instancia
	
	local tabela_do_combate = info.instancia.showing
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable

	local friendlyfire = self.friendlyfire

	local ff_table = self.friendlyfire [nome] --> assumindo que nome é o nome do Alvo que tomou dano // bastaria pegar a tabela de habilidades dele
	if (not ff_table) then
		return
	end
	local total = ff_table.total
	
	local minhas_magias = {}

	for spellid, amount in _pairs (ff_table.spells) do --> da foreach em cada spellid do container
		local nome, _, icone = _GetSpellInfo (spellid)
		_table_insert (minhas_magias, {spellid, amount, amount / total * 100, nome, icone})
	end

	_table_sort (minhas_magias, _detalhes.Sort2)

	local max_ = minhas_magias[1] and minhas_magias[1][2] or 0 --> dano que a primeiro magia vez
	
	local barra
	for index, tabela in _ipairs (minhas_magias) do
		barra = barras [index]

		if (not barra) then --> se a barra não existir, criar ela então
			barra = gump:CriaNovaBarraInfo3 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1) --> isso aqui é a parte da seleção e desceleção
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/max_*100) --> muito mais rapido...
		end

		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[4]) --seta o texto da esqueda
		barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .. " " .. instancia.divisores.abre .. _cstr ("%.1f", tabela[3]) .. "%" .. instancia.divisores.fecha) --seta o texto da direita
		
		barra.icone:SetTexture (tabela[5])
		barra.icone:SetTexCoord (0, 1, 0, 1)
		
		barra:Show() --> mostra a barra
		
		if (index == 15) then 
			break
		end
	end
	
end

-- detalhes info enemies
function atributo_damage:MontaDetalhesEnemy (spellid, barra)
	
	for _, barra in _ipairs (info.barras3) do 
		barra:Hide()
	end

	local container = info.instancia.showing[1]
	local barras = info.barras3
	local instancia = info.instancia
	
	local other_actor = barra.other_actor
	if (other_actor) then
		self = other_actor
	end
	
	if (barra.texto_esquerdo:IsTruncated()) then
		_detalhes:CooltipPreset (2)
		GameCooltip:SetOption ("FixedWidth", nil)
		GameCooltip:AddLine (barra.texto_esquerdo.text)
		GameCooltip:SetOwner (barra, "bottomleft", "topleft", 5, -10)
		GameCooltip:ShowCooltip()
	end
	
	local spell = self.spells:PegaHabilidade (spellid)
	
	local targets = spell.targets
	local target_pool = {}
	
	for target_name, amount in _pairs (targets) do	
		local classe
		local this_actor = info.instancia.showing (1, target_name)
		if (this_actor) then
			classe = this_actor.classe or "UNKNOW"
		else
			classe = "UNKNOW"
		end

		target_pool [#target_pool+1] = {target_name, amount, classe}
	end
	
	_table_sort (target_pool, _detalhes.Sort2)
	
	local max_ = target_pool [1] and target_pool [1][2] or 0
	
	local barra
	for index, tabela in _ipairs (target_pool) do
		barra = barras [index]

		if (not barra) then --> se a barra não existir, criar ela então
			barra = gump:CriaNovaBarraInfo3 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1) --> isso aqui é a parte da seleção e desceleção
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/max_*100) --> muito mais rapido...
		end

		barra.texto_esquerdo:SetText (index .. ". " .. _detalhes:GetOnlyName (tabela [1])) --seta o texto da esqueda
		_detalhes:name_space_info (barra)
		
		if (spell.total > 0) then
			barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .." (".. _cstr("%.1f", tabela[2] / spell.total * 100) .."%)") --seta o texto da direita
		else
			barra.texto_direita:SetText (tabela[2] .." (0%)") --seta o texto da direita
		end
		
		local texCoords = _detalhes.class_coords [tabela[3]]
		if (not texCoords) then
			texCoords = _detalhes.class_coords ["UNKNOW"]
		end
		
		local color = _detalhes.class_colors [tabela[3]]
		if (color) then
			barra.textura:SetStatusBarColor (_unpack (color))
		else
			barra.textura:SetStatusBarColor (1, 1, 1, 1)
		end
		
		barra.icone:SetTexture ("Interface\\AddOns\\Details\\images\\classes_small_alpha")
		barra.icone:SetTexCoord (unpack (texCoords))

		barra:Show() --> mostra a barra
		
		if (index == 15) then 
			break
		end
	end
	
end

------ Detalhe Info Damage Taken
function atributo_damage:MontaDetalhesDamageTaken (nome, barra)

	for _, barra in _ipairs (info.barras3) do 
		barra:Hide()
	end

	local barras = info.barras3
	local instancia = info.instancia
	
	local tabela_do_combate = info.instancia.showing
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable

	local este_agressor = showing._ActorTable[showing._NameIndexTable[nome]]
	
	if (not este_agressor ) then 
		return
	end
	
	local conteudo = este_agressor.spells._ActorTable --> _pairs[] com os IDs das magias
	
	local actor = info.jogador.nome
	
	local total = este_agressor.targets [actor] or 0

	local minhas_magias = {}

	for spellid, tabela in _pairs (conteudo) do --> da foreach em cada spellid do container
		local este_alvo = tabela.targets [actor]
		if (este_alvo) then --> esta magia deu dano no actor
			local spell_nome, rank, icone = _GetSpellInfo (spellid)
			_table_insert (minhas_magias, {spellid, este_alvo, este_alvo/total*100, spell_nome, icone})
		end
	end

	_table_sort (minhas_magias, _detalhes.Sort2)

	--local amt = #minhas_magias
	--gump:JI_AtualizaContainerBarras (amt)

	local max_ = minhas_magias[1] and minhas_magias[1][2] or 0 --> dano que a primeiro magia vez
	
	local barra
	for index, tabela in _ipairs (minhas_magias) do
		barra = barras [index]

		if (not barra) then --> se a barra não existir, criar ela então
			barra = gump:CriaNovaBarraInfo3 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1) --> isso aqui é a parte da seleção e desceleção
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/max_*100)
		end

		barra.texto_esquerdo:SetText (index .. "." .. tabela[4]) --seta o texto da esqueda
		_detalhes:name_space_info (barra)
		
		barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[3]) .."%".. instancia.divisores.fecha) --seta o texto da direita
		
		barra.icone:SetTexture (tabela[5])
		barra.icone:SetTexCoord (0, 1, 0, 1)

		barra:Show() --> mostra a barra
		
		if (index == 15) then 
			break
		end
	end
	
end

------ Detalhe Info Damage Done e Dps
--local defenses_table = {c = {117/255, 58/255, 0/255}, p = 0}
--local normal_table = {c = {255/255, 180/255, 0/255, 0.5}, p = 0}
--local multistrike_table = {c = {223/255, 249/255, 45/255, 0.5}, p = 0}
--local critical_table = {c = {249/255, 74/255, 45/255, 0.5}, p = 0}

local defenses_table = {c = {1, 1, 1, 0.5}, p = 0}
local normal_table = {c = {1, 1, 1, 0.5}, p = 0}
local multistrike_table = {c = {1, 1, 1, 0.5}, p = 0}
local critical_table = {c = {1, 1, 1, 0.5}, p = 0}

local data_table = {}
local t1, t2, t3, t4 = {}, {}, {}, {}

function atributo_damage:MontaDetalhesDamageDone (spellid, barra, instancia)

	local esta_magia
	if (barra.other_actor) then
		esta_magia = barra.other_actor.spells._ActorTable [spellid]
	else
		esta_magia = self.spells._ActorTable [spellid]
	end

	if (not esta_magia) then
		return
	end
	
	--> icone direito superior
	local _, _, icone = _GetSpellInfo (spellid)

	_detalhes.janela_info.spell_icone:SetTexture (icone)

	local total = self.total
	
	local meu_tempo
	if (_detalhes.time_type == 1 or not self.grupo) then
		meu_tempo = self:Tempo()
	elseif (_detalhes.time_type == 2) then
		meu_tempo = info.instancia.showing:GetCombatTime()
	end
	
	local total_hits = esta_magia.counter
	local index = 1
	local data = data_table

	table.wipe (t1)
	table.wipe (t2)
	table.wipe (t3)
	table.wipe (t4)
	table.wipe (data)

	--> GERAL
		local media = esta_magia.total/total_hits
		
		local this_dps = nil
		if (esta_magia.counter > esta_magia.c_amt) then
			this_dps = Loc ["STRING_DPS"] .. ": " .. _detalhes:comma_value (esta_magia.total/meu_tempo)
		else
			this_dps = Loc ["STRING_DPS"] .. ": " .. Loc ["STRING_SEE_BELOW"]
		end

		local spellschool, schooltext = esta_magia.spellschool, ""
		if (spellschool) then
			local t = _detalhes.spells_school [spellschool]
			if (t and t.name) then
				schooltext = t.formated
			end
		end
		
		gump:SetaDetalheInfoTexto ( index, 100,
			Loc ["STRING_GERAL"],
			Loc ["STRING_DAMAGE"]..": ".._detalhes:ToK (esta_magia.total), 
			--Loc ["STRING_MULTISTRIKE"] .. ": " .. _cstr ("%.1f", esta_magia.counter/esta_magia.m_amt*100) .. "%", 
			schooltext, --offhand,
			Loc ["STRING_AVERAGE"] .. ": " .. _detalhes:comma_value (media), 
			this_dps,
			Loc ["STRING_HITS"]..": " .. total_hits)
	
	--> NORMAL
		local normal_hits = esta_magia.n_amt
		if (normal_hits > 0) then
			local normal_dmg = esta_magia.n_dmg
			local media_normal = normal_dmg/normal_hits
			local T = (meu_tempo*normal_dmg)/esta_magia.total
			local P = media/media_normal*100
			T = P*T/100

			normal_table.p = normal_hits/total_hits*100

			data[#data+1] = t1
			
			t1[1] = esta_magia.n_amt
			t1[2] = normal_table
			t1[3] = Loc ["STRING_NORMAL_HITS"]
			t1[4] = Loc ["STRING_MINIMUM_SHORT"] .. ": " .. _detalhes:comma_value (esta_magia.n_min)
			t1[5] = Loc ["STRING_MAXIMUM_SHORT"] .. ": " .. _detalhes:comma_value (esta_magia.n_max)
			t1[6] = Loc ["STRING_AVERAGE"] .. ": " .. _detalhes:comma_value (media_normal)
			t1[7] = Loc ["STRING_DPS"] .. ": " .. _detalhes:comma_value (normal_dmg/T)
			t1[8] = normal_hits .. " / " .. _cstr ("%.1f", normal_hits/total_hits*100) .. "%"
			
		end

	--> CRITICO
		if (esta_magia.c_amt > 0) then	
			local media_critico = esta_magia.c_dmg/esta_magia.c_amt
			local T = (meu_tempo*esta_magia.c_dmg)/esta_magia.total
			local P = media/media_critico*100
			T = P*T/100
			local crit_dps = esta_magia.c_dmg/T
			if (not crit_dps) then
				crit_dps = 0
			end
			
			critical_table.p = esta_magia.c_amt/total_hits*100

			data[#data+1] = t2
			
			t2[1] = esta_magia.c_amt
			t2[2] = critical_table
			t2[3] = Loc ["STRING_CRITICAL_HITS"]
			t2[4] = Loc ["STRING_MINIMUM_SHORT"] .. ": " .. _detalhes:comma_value (esta_magia.c_min)
			t2[5] = Loc ["STRING_MAXIMUM_SHORT"] .. ": " .. _detalhes:comma_value (esta_magia.c_max)
			t2[6] = Loc ["STRING_AVERAGE"] .. ": " .. _detalhes:comma_value (media_critico)
			t2[7] = Loc ["STRING_DPS"] .. ": " .. _detalhes:comma_value (crit_dps)
			t2[8] = esta_magia.c_amt .. " / " .. _cstr ("%.1f", esta_magia.c_amt/total_hits*100) .. "%"

		end
		
	--> Outros erros: GLACING, resisted, blocked, absorbed
		local outros_desvios = esta_magia.g_amt + esta_magia.b_amt
		local parry = esta_magia ["PARRY"] or 0
		local dodge = esta_magia ["DODGE"] or 0
		local erros = parry + dodge

		if (outros_desvios > 0 or erros > 0) then
		
			local porcentagem_defesas = (outros_desvios+erros) / total_hits * 100

			data[#data+1] = t3
			defenses_table.p = porcentagem_defesas
			
			t3[1] = outros_desvios+erros
			t3[2] = defenses_table
			t3[3] = Loc ["STRING_DEFENSES"]
			t3[4] = Loc ["STRING_GLANCING"] .. ": " .. _math_floor (esta_magia.g_amt/esta_magia.counter*100) .. "%"
			t3[5] = Loc ["STRING_PARRY"] .. ": " .. parry
			t3[6] = Loc ["STRING_DODGE"] .. ": " .. dodge
			t3[7] = Loc ["STRING_BLOCKED"] .. ": " .. _math_floor (esta_magia.b_amt/esta_magia.counter*100)
			t3[8] = (outros_desvios+erros) .. " / " .. _cstr ("%.1f", porcentagem_defesas) .. "%"

		end
	
	--> multistrike
		if (esta_magia.m_amt > 0) then
		
			local normal_hits = esta_magia.m_amt
			local normal_dmg = esta_magia.m_dmg
			
			local media_normal = normal_dmg/normal_hits
			local T = (meu_tempo*normal_dmg)/esta_magia.total
			local P = media/media_normal*100
			T = P*T/100
			
			data[#data+1] = t4
			multistrike_table.p = esta_magia.m_amt/total_hits*100

			t4[1] = esta_magia.m_amt
			t4[2] = multistrike_table
			t4[3] = Loc ["STRING_MULTISTRIKE_HITS"]
			t4[4] = "On Critical: " .. esta_magia.m_crit
			t4[5] = "On Normals: " .. (esta_magia.m_amt - esta_magia.m_crit)
			t4[6] = Loc ["STRING_AVERAGE"] .. ": " .. _detalhes:comma_value (esta_magia.m_dmg/esta_magia.m_amt)
			t4[7] = Loc ["STRING_DPS"] .. ": " .. _detalhes:comma_value (esta_magia.m_dmg/T)
			t4[8] = esta_magia.m_amt .. " / " .. _cstr ("%.1f", esta_magia.m_amt/total_hits*100) .. "%"

		end
	
	_table_sort (data, _detalhes.Sort1)
	
	for index, tabela in _ipairs (data) do
		gump:SetaDetalheInfoTexto (index+1, tabela[2], tabela[3], tabela[4], tabela[5], tabela[6], tabela[7], tabela[8])
	end
	
	for i = #data+2, 5 do
		gump:HidaDetalheInfo (i)
	end
	
end

function atributo_damage:MontaTooltipDamageTaken (esta_barra, index)
	
	local aggressor = info.instancia.showing [1]:PegarCombatente (_, esta_barra.nome_inimigo)
	local container = aggressor.spells._ActorTable
	local habilidades = {}

	local total = 0
	
	for spellid, spell in _pairs (container) do 
		for target_name, amount in _pairs (spell.targets) do 
			if (target_name == self.nome) then
				total = total + amount
				habilidades [#habilidades+1] = {spellid, amount}
			end
		end
	end

	_table_sort (habilidades, _detalhes.Sort2)
	
	GameTooltip:AddLine (index..". "..esta_barra.nome_inimigo)
	GameTooltip:AddLine (Loc ["STRING_DAMAGE_TAKEN_FROM2"]..":")
	GameTooltip:AddLine (" ")
	
	for index, tabela in _ipairs (habilidades) do
		local nome, _, icone = _GetSpellInfo (tabela[1])
		if (index < 8) then
			GameTooltip:AddDoubleLine (index..". |T"..icone..":0|t "..nome, _detalhes:comma_value (tabela[2]).." (".._cstr("%.1f", tabela[2]/total*100).."%)", 1, 1, 1, 1, 1, 1)
			--GameTooltip:AddTexture (icone)
		else
			GameTooltip:AddDoubleLine (index..". "..nome, _detalhes:comma_value (tabela[2]).." (".._cstr("%.1f", tabela[2]/total*100).."%)", .65, .65, .65, .65, .65, .65)
		end
	end
	
	return true
	--GameTooltip:AddDoubleLine (meus_danos[i][4][1]..": ", meus_danos[i][2].." (".._cstr("%.1f", meus_danos[i][3]).."%)", 1, 1, 1, 1, 1, 1)
	
end

local targets_tooltips_table = {}

function atributo_damage:MontaTooltipAlvos (esta_barra, index, instancia)
	
	local inimigo = esta_barra.nome_inimigo
	local habilidades = targets_tooltips_table
	
	for i = 1, #habilidades do
		local t = habilidades [i]
		t[1], t[2], t[3] = "", 0, "" --name, total, icon
	end
	
	local total = self.total
	
	local i = 1
	
	for spellid, spell in _pairs (self.spells._ActorTable) do
		for target_name, amount in _pairs (spell.targets) do
			if (target_name == inimigo) then
				local nome, _, icone = _GetSpellInfo (spellid)
				
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

	--> add pets
	for _, PetName in _ipairs (self.pets) do
		local PetActor = instancia.showing (class_type, PetName)
		if (PetActor) then 
			local PetSkillsContainer = PetActor.spells._ActorTable
			for _spellid, _skill in _pairs (PetSkillsContainer) do
			
				local alvos = _skill.targets
				for target_name, amount in _pairs (alvos) do
					if (target_name == inimigo) then
					
						local t = habilidades [i]
						if (not t) then
							habilidades [i] = {}
							t = habilidades [i]
						end
						
						local nome, _, icone = _GetSpellInfo (_spellid)
						t[1], t[2], t[3] = nome .. " (" .. PetName:gsub ((" <.*"), "") .. ")", amount, icone
						
						i = i + 1
					end
				end
			end
		end
	end	

	_table_sort (habilidades, _detalhes.Sort2)

	--get time type
	local meu_tempo
	if (_detalhes.time_type == 1 or not self.grupo) then
		meu_tempo = self:Tempo()
	elseif (_detalhes.time_type == 2) then
		meu_tempo = info.instancia.showing:GetCombatTime()
	end
	
	local is_dps = info.instancia.sub_atributo == 2
	
	if (is_dps) then
		GameTooltip:AddLine (index..". "..inimigo)
		GameTooltip:AddLine (Loc ["STRING_DAMAGE_DPS_IN"] .. ":")
		GameTooltip:AddLine (" ")
	else
		GameTooltip:AddLine (index..". "..inimigo)
		GameTooltip:AddLine (Loc ["STRING_DAMAGE_FROM"] .. ":")
		GameTooltip:AddLine (" ")
	end
	
	for index, tabela in _ipairs (habilidades) do
		
		if (tabela [2] < 1) then
			break
		end
		
		if (index < 8) then
			if (is_dps) then
				GameTooltip:AddDoubleLine (index..". |T"..tabela[3]..":0|t "..tabela[1], _detalhes:comma_value ( _math_floor (tabela[2] / meu_tempo) ).." (".._cstr("%.1f", tabela[2]/total*100).."%)", 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine (index..". |T"..tabela[3]..":0|t "..tabela[1], _detalhes:comma_value (tabela[2]).." (".._cstr("%.1f", tabela[2]/total*100).."%)", 1, 1, 1, 1, 1, 1)
			end
		else
			if (is_dps) then
				GameTooltip:AddDoubleLine (index..". "..tabela[1], _detalhes:comma_value ( _math_floor (tabela[2] / meu_tempo) ).." (".._cstr("%.1f", tabela[2]/total*100).."%)", .65, .65, .65, .65, .65, .65)
			else
				GameTooltip:AddDoubleLine (index..". "..tabela[1], _detalhes:comma_value (tabela[2]).." (".._cstr("%.1f", tabela[2]/total*100).."%)", .65, .65, .65, .65, .65, .65)
			end
		end
	end
	
	return true
	
end

--> controla se o dps do jogador esta travado ou destravado
function atributo_damage:Iniciar (iniciar)
	if (iniciar == nil) then 
		return self.dps_started --> retorna se o dps esta aberto ou fechado para este jogador
	elseif (iniciar) then
		self.dps_started = true
		self:RegistrarNaTimeMachine() --coloca ele da timeMachine
	else
		self.dps_started = false
		self:DesregistrarNaTimeMachine() --retira ele da timeMachine
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core functions

	--> limpa as tabelas temporárias ao resetar
		function atributo_damage:ClearTempTables()
			for i = #ntable, 1, -1 do
				ntable [i] = nil
			end
			for i = #vtable, 1, -1 do
				vtable [i] = nil
			end
		end

	--> atualize a funcao de abreviacao
		function atributo_damage:UpdateSelectedToKFunction()
			SelectedToKFunction = ToKFunctions [_detalhes.ps_abbreviation]
			FormatTooltipNumber = ToKFunctions [_detalhes.tooltip.abbreviation]
			TooltipMaximizedMethod = _detalhes.tooltip.maximize_method
			headerColor = _detalhes.tooltip.header_text_color
		end

	--> diminui o total das tabelas do combate
		function atributo_damage:subtract_total (combat_table)
			combat_table.totals [class_type] = combat_table.totals [class_type] - self.total
			if (self.grupo) then
				combat_table.totals_grupo [class_type] = combat_table.totals_grupo [class_type] - self.total
			end
		end
		function atributo_damage:add_total (combat_table)
			combat_table.totals [class_type] = combat_table.totals [class_type] + self.total
			if (self.grupo) then
				combat_table.totals_grupo [class_type] = combat_table.totals_grupo [class_type] + self.total
			end
		end
		
	--> restaura a tabela de last event
		function atributo_damage:r_last_events_table (actor)
			if (not actor) then
				actor = self
			end
			--actor.last_events_table = _detalhes:CreateActorLastEventTable()
		end
		
	--> restaura e liga o ator com a sua shadow durante a inicialização (startup function)
		function atributo_damage:r_onlyrefresh_shadow (actor)
			--> criar uma shadow desse ator se ainda não tiver uma
				local overall_dano = _detalhes.tabela_overall [1]
				local shadow = overall_dano._ActorTable [overall_dano._NameIndexTable [actor.nome]]
				
				if (not shadow) then 
					shadow = overall_dano:PegarCombatente (actor.serial, actor.nome, actor.flag_original, true)
					
					shadow.classe = actor.classe
					shadow.spec = actor.spec
					shadow.grupo = actor.grupo
					shadow.isTank = actor.isTank
					shadow.boss = actor.boss
					shadow.boss_fight_component = actor.boss_fight_component
					shadow.fight_component = actor.fight_component
					
					shadow.start_time = time() - 3
					shadow.end_time = time()
				end

			--> restaura a meta e indexes ao ator
			_detalhes.refresh:r_atributo_damage (actor, shadow)
			
			--> copia o container de alvos (captura de dados)
				for target_name, amount in _pairs (actor.targets) do 
					--> cria e soma o valor do total
					if (not shadow.targets [target_name]) then
						shadow.targets [target_name] = 0
					end
				end
				
			--> copia o container de habilidades (captura de dados)
				for spellid, habilidade in _pairs (actor.spells._ActorTable) do 
					--> cria e soma o valor
					local habilidade_shadow = shadow.spells:PegaHabilidade (spellid, true, nil, true)
					--> refresh e soma os valores dos alvos
					for target_name, amount in _pairs (habilidade.targets) do 
						--> cria e soma o valor do total
						if (not habilidade_shadow.targets [target_name]) then
							habilidade_shadow.targets [target_name] = 0
						end
					end

				end
				
			--> copia o container de friendly fire (captura de dados)
				for target_name, ff_table in _pairs (actor.friendlyfire) do 
					--> cria ou pega a shadow
					local friendlyFire_shadow = shadow.friendlyfire [target_name] or shadow:CreateFFTable (target_name)
					--> some as spells
					for spellid, amount in _pairs (ff_table.spells) do
						friendlyFire_shadow.spells [spellid] = 0
					end
				end
				
			return shadow
		end
		
		function atributo_damage:r_connect_shadow (actor, no_refresh)
	
			--> criar uma shadow desse ator se ainda não tiver uma
				local overall_dano = _detalhes.tabela_overall [1]
				local shadow = overall_dano._ActorTable [overall_dano._NameIndexTable [actor.nome]]
				
				if (not shadow) then 
					shadow = overall_dano:PegarCombatente (actor.serial, actor.nome, actor.flag_original, true)
					
					shadow.classe = actor.classe
					shadow.spec = actor.spec
					shadow.isTank = actor.isTank
					shadow.grupo = actor.grupo
					shadow.boss = actor.boss
					shadow.boss_fight_component = actor.boss_fight_component
					shadow.fight_component = actor.fight_component
					
					shadow.start_time = time() - 3
					shadow.end_time = time()
				end

			--> restaura a meta e indexes ao ator
			if (not no_refresh) then
				_detalhes.refresh:r_atributo_damage (actor, shadow)
			end
			
			--> tempo decorrido (captura de dados)
				local end_time = actor.end_time
				if (not actor.end_time) then
					end_time = time()
				end
				
				local tempo = end_time - actor.start_time
				shadow.start_time = shadow.start_time - tempo
				
			--> total de dano (captura de dados)
				shadow.total = shadow.total + actor.total				
			--> total de dano sem o pet (captura de dados)
				shadow.total_without_pet = shadow.total_without_pet + actor.total_without_pet
			--> total de dano que o ator sofreu (captura de dados)
				shadow.damage_taken = shadow.damage_taken + actor.damage_taken
			--> total do friendly fire causado
				shadow.friendlyfire_total = shadow.friendlyfire_total + actor.friendlyfire_total

			--> total no combate overall (captura de dados)
				_detalhes.tabela_overall.totals[1] = _detalhes.tabela_overall.totals[1] + actor.total
				if (actor.grupo) then
					_detalhes.tabela_overall.totals_grupo[1] = _detalhes.tabela_overall.totals_grupo[1] + actor.total
				end
				
			--> copia o damage_from (captura de dados)
				for nome, _ in _pairs (actor.damage_from) do 
					shadow.damage_from [nome] = true
				end
			
			--> copia o container de alvos (captura de dados)
				for target_name, amount in _pairs (actor.targets) do 
					shadow.targets [target_name] = (shadow.targets [target_name] or 0) + amount
				end
				
			--> copia o container de habilidades (captura de dados)
				for spellid, habilidade in _pairs (actor.spells._ActorTable) do 
					--> cria e soma o valor
					local habilidade_shadow = shadow.spells:PegaHabilidade (spellid, true, nil, true)
					--> refresh e soma os valores dos alvos
					for target_name, amount in _pairs (habilidade.targets) do 
						habilidade_shadow.targets [target_name] = (habilidade_shadow.targets [target_name] or 0) + amount
					end
					--> soma todos os demais valores
					for key, value in _pairs (habilidade) do 
						if (_type (value) == "number") then
							if (key ~= "id" and key ~= "spellschool") then
								if (not habilidade_shadow [key]) then 
									habilidade_shadow [key] = 0
								end
								
								if (key == "n_min" or key == "c_min") then
									if (habilidade_shadow [key] > value) then
										habilidade_shadow [key] = value
									end
								elseif (key == "n_max" or key == "c_max") then
									if (habilidade_shadow [key] < value) then
										habilidade_shadow [key] = value
									end
								else
									habilidade_shadow [key] = habilidade_shadow [key] + value
								end

							end
						end
					end
				end
				
			--> copia o container de friendly fire (captura de dados)
				for target_name, ff_table in _pairs (actor.friendlyfire) do 
					--> cria ou pega a shadow
					local friendlyFire_shadow = shadow.friendlyfire [target_name] or shadow:CreateFFTable (target_name)
					--> soma o total
					friendlyFire_shadow.total = friendlyFire_shadow.total + ff_table.total
					--> some as spells
					for spellid, amount in _pairs (ff_table.spells) do
						friendlyFire_shadow.spells [spellid] = (friendlyFire_shadow.spells [spellid] or 0) + amount
					end
				end
			
			return shadow
		end

function atributo_damage:ColetarLixo (lastevent)
	return _detalhes:ColetarLixo (class_type, lastevent)
end

atributo_damage.__add = function (tabela1, tabela2)

	--> tempo decorrido
		local tempo = (tabela2.end_time or time()) - tabela2.start_time
		tabela1.start_time = tabela1.start_time - tempo
	
	--> total de dano
		tabela1.total = tabela1.total + tabela2.total
	--> total de dano sem o pet
		tabela1.total_without_pet = tabela1.total_without_pet + tabela2.total_without_pet
	--> total de dano que o cara levou
		tabela1.damage_taken = tabela1.damage_taken + tabela2.damage_taken
	--> total do friendly fire causado
		tabela1.friendlyfire_total = tabela1.friendlyfire_total + tabela2.friendlyfire_total

	--> soma o damage_from
		for nome, _ in _pairs (tabela2.damage_from) do 
			tabela1.damage_from [nome] = true
		end
	
	--> soma os containers de alvos
		for target_name, amount in _pairs (tabela2.targets) do 
			tabela1.targets [target_name] = (tabela1.targets [target_name] or 0) + amount
		end
		
	--> soma o container de habilidades
		for spellid, habilidade in _pairs (tabela2.spells._ActorTable) do 
			--> pega a habilidade no primeiro ator
			local habilidade_tabela1 = tabela1.spells:PegaHabilidade (spellid, true, "SPELL_DAMAGE", false)
			--> soma os alvos
			for target_name, amount in _pairs (habilidade.targets) do 	
				habilidade_tabela1.targets = (habilidade_tabela1.targets [target_name] or 0) + amount
			end
			--> soma os valores da habilidade
			for key, value in _pairs (habilidade) do 
				if (_type (value) == "number") then
					if (key ~= "id" and key ~= "spellschool") then
						if (not habilidade_tabela1 [key]) then 
							habilidade_tabela1 [key] = 0
						end
						
						if (key == "n_min" or key == "c_min") then
							if (habilidade_tabela1 [key] > value) then
								habilidade_tabela1 [key] = value
							end
						elseif (key == "n_max" or key == "c_max") then
							if (habilidade_tabela1 [key] < value) then
								habilidade_tabela1 [key] = value
							end
						else
							habilidade_tabela1 [key] = habilidade_tabela1 [key] + value
						end
						
					end
				end
			end
		end
	
	--> soma o container de friendly fire
		for target_name, ff_table in _pairs (tabela2.friendlyfire) do 
			--> pega o ator ff no ator principal
			local friendlyFire_tabela1 = tabela1.friendlyfire [target_name] or tabela1:CreateFFTable (target_name)
			--> soma o total
			friendlyFire_tabela1.total = friendlyFire_tabela1.total + ff_table.total
			
			--> soma as habilidades
			for spellid, amount in _pairs (ff_table.spells) do
				friendlyFire_tabela1.spells [spellid] = (friendlyFire_tabela1.spells [spellid] or 0) + amount
			end
		end

	return tabela1
end

atributo_damage.__sub = function (tabela1, tabela2)

	--> tempo decorrido
		local tempo = (tabela2.end_time or time()) - tabela2.start_time
		tabela1.start_time = tabela1.start_time + tempo
	
	--> total de dano
		tabela1.total = tabela1.total - tabela2.total
	--> total de dano sem o pet
		tabela1.total_without_pet = tabela1.total_without_pet - tabela2.total_without_pet
	--> total de dano que o cara levou
		tabela1.damage_taken = tabela1.damage_taken - tabela2.damage_taken
	--> total do friendly fire causado
		tabela1.friendlyfire_total = tabela1.friendlyfire_total - tabela2.friendlyfire_total
		
	--> reduz os containers de alvos
		for target_name, amount in _pairs (tabela2.targets) do 
			local alvo_tabela1 = tabela1.targets [target_name]
			if (alvo_tabela1) then
				tabela1.targets [target_name] = tabela1.targets [target_name] - amount
			end
		end
		
	--> reduz o container de habilidades
		for spellid, habilidade in _pairs (tabela2.spells._ActorTable) do 
			--> pega a habilidade no primeiro ator
			local habilidade_tabela1 = tabela1.spells:PegaHabilidade (spellid, true, "SPELL_DAMAGE", false)
			--> soma os alvos
			for target_name, amount in _pairs (habilidade.targets._ActorTable) do 
				local alvo_tabela1 = habilidade_tabela1.targets [target_name]
				if (alvo_tabela1) then
					habilidade_tabela1.targets [target_name] = habilidade_tabela1.targets [target_name] - amount
				end
			end
			--> subtrai os valores da habilidade
			for key, value in _pairs (habilidade) do 
				if (_type (value) == "number") then
					if (key ~= "id" and key ~= "spellschool") then
						if (not habilidade_tabela1 [key]) then 
							habilidade_tabela1 [key] = 0
						end
						if (key == "n_min" or key == "c_min") then
							if (habilidade_tabela1 [key] > value) then
								habilidade_tabela1 [key] = value
							end
						elseif (key == "n_max" or key == "c_max") then
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
		
	--> reduz o container de friendly fire
		for target_name, ff_table in _pairs (tabela2.friendlyfire) do
			--> pega o ator ff no ator principal
			local friendlyFire_tabela1 = tabela1.friendlyfire [target_name]
			if (friendlyFire_tabela1) then
				friendlyFire_tabela1.total = friendlyFire_tabela1.total - ff_table.total
				for spellid, amount in _pairs (ff_table.spells) do
					if (friendlyFire_tabela1.spells [spellid]) then
						friendlyFire_tabela1.spells [spellid] = friendlyFire_tabela1.spells [spellid] - amount
					end
				end
			end
		end
	
	return tabela1
end

function _detalhes.refresh:r_atributo_damage (este_jogador, shadow)
	--> restaura metas do ator
		_setmetatable (este_jogador, _detalhes.atributo_damage)
		este_jogador.__index = _detalhes.atributo_damage
	--> restaura as metas dos containers
		_detalhes.refresh:r_container_habilidades (este_jogador.spells, shadow and shadow.spells)
end

function _detalhes.clear:c_atributo_damage (este_jogador)
	este_jogador.__index = nil
	este_jogador.shadow = nil
	este_jogador.links = nil
	este_jogador.minha_barra = nil

	_detalhes.clear:c_container_habilidades (este_jogador.spells)
end
