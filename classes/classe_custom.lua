--> customized display script

	local _detalhes = 		_G._detalhes
	local gump = 			_detalhes.gump
	local _
	
	_detalhes.custom_function_cache = {}
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _cstr = string.format --lua local
	local _math_floor = math.floor --lua local
	local _table_sort = table.sort --lua local
	local _table_insert = table.insert --lua local
	local _table_size = table.getn --lua local
	local _setmetatable = setmetatable --lua local
	local _ipairs = ipairs --lua local
	local _pairs = pairs --lua local
	local _rawget= rawget --lua local
	local _math_min = math.min --lua local
	local _math_max = math.max --lua local
	local _bit_band = bit.band --lua local
	local _unpack = unpack --lua local
	local _type = type --lua local
	
	local _GetSpellInfo = _detalhes.getspellinfo -- api local
	local _IsInRaid = IsInRaid -- api local
	local _IsInGroup = IsInGroup -- api local
	local _GetNumGroupMembers = GetNumGroupMembers -- api local
	local _GetNumPartyMembers = GetNumPartyMembers or GetNumSubgroupMembers -- api local
	local _GetNumRaidMembers = GetNumRaidMembers or GetNumGroupMembers -- api local
	local _GetUnitName = GetUnitName -- api local

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local atributo_custom = _detalhes.atributo_custom
	atributo_custom.mt = {__index = atributo_custom}
	
	local combat_containers = {
		["damagedone"] = 1,
		["healdone"] = 2,
	}
	
	--> hold the mini custom objects
	atributo_custom._InstanceActorContainer = {}
	atributo_custom._InstanceLastCustomShown = {}
	atributo_custom._InstanceLastCombatShown = {}
	atributo_custom._TargetActorsProcessed = {}
	
	local ToKFunctions = _detalhes.ToKFunctions
	local SelectedToKFunction = ToKFunctions [1]
	local FormatTooltipNumber = ToKFunctions [8]
	local TooltipMaximizedMethod = 1
	local UsingCustomRightText = false
	local UsingCustomLeftText = false
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	function atributo_custom:GetCombatContainerIndex (attribute)
		return combat_containers [attribute]
	end

	function atributo_custom:RefreshWindow (instance, combat, force, export)

		--> get the custom object
		local custom_object = instance:GetCustomObject()

		if (not custom_object) then
			return instance:ResetAttribute()
		end

		--> save the custom name in the instance
		instance.customName = custom_object:GetName()
		
		--> get the container holding the custom actor objects for this instance
		local instance_container = atributo_custom:GetInstanceCustomActorContainer (instance)
		
		local last_shown = atributo_custom._InstanceLastCustomShown [instance:GetId()]
		if (last_shown and last_shown ~= custom_object:GetName()) then
			instance_container:WipeCustomActorContainer()
		end
		atributo_custom._InstanceLastCustomShown [instance:GetId()] = custom_object:GetName()
		
		local last_combat_shown = atributo_custom._InstanceLastCombatShown [instance:GetId()]
		if (last_combat_shown and last_combat_shown ~= combat) then
			instance_container:WipeCustomActorContainer()
		end
		atributo_custom._InstanceLastCombatShown [instance:GetId()] = combat
		
		--> declare the main locals
		local total = 0
		local top = 0
		local amount = 0
		
		--> check if is a custom script
		if (custom_object:IsScripted()) then

			--> be save reseting the values on every refresh
			instance_container:ResetCustomActorContainer()
		
			local func
			
			if (_detalhes.custom_function_cache [instance.customName]) then
				func = _detalhes.custom_function_cache [instance.customName]
			else
				func = loadstring (custom_object.script)
				if (func) then
					_detalhes.custom_function_cache [instance.customName] = func
				end

				local tooltip_script  = custom_object.tooltip and loadstring (custom_object.tooltip)
				if (tooltip_script) then
					_detalhes.custom_function_cache [instance.customName .. "Tooltip"] = tooltip_script
				end
				local total_script = custom_object.total_script and loadstring (custom_object.total_script)
				if (total_script) then
					_detalhes.custom_function_cache [instance.customName .. "Total"] = total_script
				end
				local percent_script = custom_object.percent_script and loadstring (custom_object.percent_script)
				if (percent_script) then
					_detalhes.custom_function_cache [instance.customName .. "Percent"] = percent_script
				end
			end
			
			if (not func) then
				_detalhes:Msg (Loc ["STRING_CUSTOM_FUNC_INVALID"], func)
				_detalhes:EndRefresh (instance, 0, combat, combat [1])
			end
			
			--> call the loop function
			total, top, amount = func (combat, instance_container, instance)
		else
			--> get the attribute
			local attribute = custom_object:GetAttribute()
			
			--> get the custom function (actor, source, target, spellid)
			local func = atributo_custom [attribute]
			
			--> get the combat container
			local container_index = self:GetCombatContainerIndex (attribute)
			local combat_container = combat [container_index]._ActorTable

			--> build container
			total, top, amount = atributo_custom:BuildActorList (func, custom_object.source, custom_object.target, custom_object.spellid, combat, combat_container, container_index, instance_container, instance, custom_object)

		end

		if (custom_object:IsSpellTarget()) then
			amount = atributo_custom._TargetActorsProcessedAmt
			total = atributo_custom._TargetActorsProcessedTotal
			top = atributo_custom._TargetActorsProcessedTop
		end

		if (amount == 0) then
			if (force) then
				if (instance:IsGroupMode()) then
					for i = 1, instance.rows_fit_in_window  do
						gump:Fade (instance.barras [i], "in", 0.3)
					end
				end
			end
			instance:EsconderScrollBar()
			return _detalhes:EndRefresh (instance, total, combat, combat [container_index])
		end
		
		combat.totals [custom_object:GetName()] = total
		
		instance_container:Sort()
		instance_container:Remap()
		
		if (export) then
			return total, instance_container._ActorTable, top, amount
		end
		
		instance:AtualizarScrollBar (amount)

		atributo_custom:Refresh (instance, instance_container, combat, force, total, top, custom_object)
		
		return _detalhes:EndRefresh (instance, total, combat, combat [container_index])

	end

	function atributo_custom:BuildActorList (func, source, target, spellid, combat, combat_container, container_index, instance_container, instance, custom_object)

		--> do the loop
		
		local total = 0
		local top = 0
		local amount = 0
		
		--> check if is a spell target custom
		if (custom_object:IsSpellTarget()) then
			table.wipe (atributo_custom._TargetActorsProcessed)
			atributo_custom._TargetActorsProcessedAmt = 0
			atributo_custom._TargetActorsProcessedTotal = 0
			atributo_custom._TargetActorsProcessedTop = 0
			instance_container:ResetCustomActorContainer()
		end
		
		if (source == "[all]") then
			
			for _, actor in _ipairs (combat_container) do 
				local actortotal = func (_, actor, source, target, spellid, combat, instance_container)
				if (actortotal > 0) then
					total = total + actortotal
					amount = amount + 1
					
					if (actortotal > top) then
						top = actortotal
					end
					
					instance_container:SetValue (actor, actortotal)
				end
			end
			
		elseif (source == "[raid]") then
		
			if (_detalhes.in_combat and instance.segmento == 0 and not export) then
				if (container_index == 1) then
					combat_container = _detalhes.cache_damage_group
				elseif (container_index == 2) then
					combat_container = _detalhes.cache_healing_group
				end
			end

			for _, actor in _ipairs (combat_container) do 
				if (actor.grupo) then
					local actortotal = func (_, actor, source, target, spellid, combat, instance_container)

					if (actortotal > 0) then
						total = total + actortotal
						amount = amount + 1
						
						if (actortotal > top) then
							top = actortotal
						end
						
						instance_container:SetValue (actor, actortotal)
					end
					
				end
			end
			
		elseif (source == "[player]") then
			local pindex = combat [container_index]._NameIndexTable [_detalhes.playername]
			if (pindex) then
				local actor = combat [container_index]._ActorTable [pindex]
				local actortotal = func (_, actor, source, target, spellid, combat, instance_container)
				
				if (actortotal > 0) then
					total = total + actortotal
					amount = amount + 1
					
					if (actortotal > top) then
						top = actortotal
					end
					
					instance_container:SetValue (actor, actortotal)
				end
			end
		else

			local pindex = combat [container_index]._NameIndexTable [source]
			if (pindex) then
				local actor = combat [container_index]._ActorTable [pindex]
				local actortotal = func (_, actor, source, target, spellid, combat, instance_container)
				
				if (actortotal > 0) then
					total = total + actortotal
					amount = amount + 1
					
					if (actortotal > top) then
						top = actortotal
					end
					
					instance_container:SetValue (actor, actortotal)
				end
			end
		end
		
		return total, top, amount
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> refresh functions

	function atributo_custom:Refresh (instance, instance_container, combat, force, total, top, custom_object)
		local qual_barra = 1
		local barras_container = instance.barras
		local percentage_type = instance.row_info.percent_type
		
		local combat_time = combat:GetCombatTime()
		UsingCustomLeftText = instance.row_info.textL_enable_custom_text
		UsingCustomRightText = instance.row_info.textR_enable_custom_text
		
		--> total bar
		local use_total_bar = false
		if (instance.total_bar.enabled) then
			use_total_bar = true
			if (instance.total_bar.only_in_group and (not _IsInGroup() and not _IsInRaid())) then
				use_total_bar = false
			end
		end

		local percent_script = _detalhes.custom_function_cache [instance.customName .. "Percent"]
		local total_script = _detalhes.custom_function_cache [instance.customName .. "Total"]

		if (instance.bars_sort_direction == 1) then --top to bottom
			
			if (use_total_bar and instance.barraS[1] == 1) then
			
				qual_barra = 2
				local iter_last = instance.barraS[2]
				if (iter_last == instance.rows_fit_in_window) then
					iter_last = iter_last - 1
				end
				
				local row1 = barras_container [1]
				row1.minha_tabela = nil
				row1.texto_esquerdo:SetText (Loc ["STRING_TOTAL"])
				row1.texto_direita:SetText (_detalhes:ToK2 (total) .. " (" .. _detalhes:ToK (total / combat_time) .. ")")
				
				row1.statusbar:SetValue (100)
				local r, b, g = unpack (instance.total_bar.color)
				row1.textura:SetVertexColor (r, b, g)
				
				row1.icone_classe:SetTexture (instance.total_bar.icon)
				row1.icone_classe:SetTexCoord (0.0625, 0.9375, 0.0625, 0.9375)
				
				gump:Fade (row1, "out")
				
				for i = instance.barraS[1], iter_last, 1 do
					instance_container._ActorTable[i]:UpdateBar (barras_container, qual_barra, percentage_type, i, total, top, instance, force, percent_script, total_script, combat)
					qual_barra = qual_barra+1
				end
			
			else
				for i = instance.barraS[1], instance.barraS[2], 1 do
					instance_container._ActorTable[i]:UpdateBar (barras_container, qual_barra, percentage_type, i, total, top, instance, force, percent_script, total_script, combat)
					qual_barra = qual_barra+1
				end
			end
			
		elseif (instance.bars_sort_direction == 2) then --bottom to top
		
			if (use_total_bar and instance.barraS[1] == 1) then
			
				qual_barra = 2
				local iter_last = instance.barraS[2]
				if (iter_last == instance.rows_fit_in_window) then
					iter_last = iter_last - 1
				end
				
				local row1 = barras_container [1]
				row1.minha_tabela = nil
				row1.texto_esquerdo:SetText (Loc ["STRING_TOTAL"])
				row1.texto_direita:SetText (_detalhes:ToK2 (total) .. " (" .. _detalhes:ToK (total / combat_time) .. ")")
				
				row1.statusbar:SetValue (100)
				local r, b, g = unpack (instance.total_bar.color)
				row1.textura:SetVertexColor (r, b, g)
				
				row1.icone_classe:SetTexture (instance.total_bar.icon)
				row1.icone_classe:SetTexCoord (0.0625, 0.9375, 0.0625, 0.9375)
				
				gump:Fade (row1, "out")
				
				for i = iter_last, instance.barraS[1], -1 do --> vai atualizar só o range que esta sendo mostrado
					instance_container._ActorTable[i]:UpdateBar (barras_container, qual_barra, percentage_type, i, total, top, instance, force, percent_script, total_script, combat)
					qual_barra = qual_barra+1
				end
			
			else
				for i = instance.barraS[2], instance.barraS[1], -1 do --> vai atualizar só o range que esta sendo mostrado
					instance_container._ActorTable[i]:UpdateBar (barras_container, qual_barra, percentage_type, i, total, top, instance, force, percent_script, total_script, combat)
					qual_barra = qual_barra+1
				end
			end
			
		end	
		
		if (force) then
			if (instance:IsGroupMode()) then
				for i = qual_barra, instance.rows_fit_in_window  do
					gump:Fade (instance.barras [i], "in", 0.3)
				end
			end
		end
		
	end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> custom object functions

	local actor_class_color_r, actor_class_color_g, actor_class_color_b
	
	function atributo_custom:UpdateBar (row_container, index, percentage_type, rank, total, top, instance, is_forced, percent_script, total_script, combat)
	
		local row = row_container [index]
		
		local previous_table = row.minha_tabela
		row.colocacao = rank
		row.minha_tabela = self
		self.minha_barra = row
		
		local percent

		if (percent_script) then
			--local value, top, total, combat, instance = ...
			percent = percent_script (self.value, top, total, combat, instance)
		else
			if (percentage_type == 1) then
				percent = _cstr ("%.1f", self.value / total * 100)
			elseif (percentage_type == 2) then
				percent = _cstr ("%.1f", self.value / top * 100)
			end
		end
		
		if (total_script) then
			local value = total_script (self.value, top, total, combat, instance)
			if (type (value) == "number") then
				row.texto_direita:SetText (SelectedToKFunction (_, value) .. " (" .. percent .. "%)")
			else
				row.texto_direita:SetText (value .. " (" .. percent .. "%)")
			end
		else
			local formated_value = SelectedToKFunction (_, self.value)
			if (UsingCustomRightText) then
				row.texto_direita:SetText (instance.row_info.textR_custom_text:ReplaceData (formated_value, "", percent, self))
			else
				row.texto_direita:SetText (formated_value .. " (" .. percent .. "%)")
			end
		end
		
		local row_value = _math_floor ((self.value / top) * 100)

		-- update tooltip function--

		actor_class_color_r, actor_class_color_g, actor_class_color_b = self:GetBarColor()
		
		self:RefreshBarra2 (row, instance, previous_table, is_forced, row_value, index, row_container)
		
	end
	
	function atributo_custom:RefreshBarra2 (esta_barra, instancia, tabela_anterior, forcar, esta_porcentagem, qual_barra, barras_container)
		
		--> primeiro colocado
		if (esta_barra.colocacao == 1) then
			if (not tabela_anterior or tabela_anterior ~= esta_barra.minha_tabela or forcar) then
				esta_barra.statusbar:SetValue (100)
				
				if (esta_barra.hidden or esta_barra.fading_in or esta_barra.faded) then
					gump:Fade (esta_barra, "out")
				end
				
				return self:RefreshBarra (esta_barra, instancia)
			else
				return
			end
		else

			if (esta_barra.hidden or esta_barra.fading_in or esta_barra.faded) then
			
				esta_barra.statusbar:SetValue (esta_porcentagem)
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
				
					esta_barra.statusbar:SetValue (esta_porcentagem)
				
					esta_barra.last_value = esta_porcentagem --> reseta o ultimo valor da barra
					
					if (_detalhes.is_using_row_animations and forcar) then
						esta_barra.tem_animacao = 0
						esta_barra:SetScript ("OnUpdate", nil)
					end
					
					return self:RefreshBarra (esta_barra, instancia)
					
				elseif (esta_porcentagem ~= esta_barra.last_value) then --> continua mostrando a mesma tabela então compara a porcentagem
					--> apenas atualizar
					if (_detalhes.is_using_row_animations) then
						
						local upRow = barras_container [qual_barra-1]
						if (upRow) then
							if (upRow.statusbar:GetValue() < esta_barra.statusbar:GetValue()) then
								esta_barra.statusbar:SetValue (esta_porcentagem)
							else
								instancia:AnimarBarra (esta_barra, esta_porcentagem)
							end
						else
							instancia:AnimarBarra (esta_barra, esta_porcentagem)
						end
					else
						esta_barra.statusbar:SetValue (esta_porcentagem)
					end
					esta_barra.last_value = esta_porcentagem
				end
			end

		end
		
	end

	function atributo_custom:RefreshBarra (esta_barra, instancia, from_resize)
		
		if (from_resize) then
			actor_class_color_r, actor_class_color_g, actor_class_color_b = self:GetBarColor()
		end
		
		if (instancia.row_info.texture_class_colors) then
			esta_barra.textura:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
		end
		if (instancia.row_info.texture_background_class_color) then
			esta_barra.background:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
		end	
		
		if (self.classe == "UNKNOW") then
			esta_barra.icone_classe:SetTexture ("Interface\\LFGFRAME\\LFGROLE_BW")
			esta_barra.icone_classe:SetTexCoord (.25, .5, 0, 1)
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
			esta_barra.icone_classe:SetTexture (instancia.row_info.icon_file)
			esta_barra.icone_classe:SetTexCoord (_unpack (CLASS_ICON_TCOORDS [self.classe])) --very slow method
			esta_barra.icone_classe:SetVertexColor (1, 1, 1)
		end

		--texture and text
		
		local bar_number = ""
		if (instancia.row_info.textL_show_number) then
			bar_number = esta_barra.colocacao .. ". "
		end
		
		if (self.enemy) then
			if (self.arena_enemy) then
				if (UsingCustomLeftText) then
					esta_barra.texto_esquerdo:SetText (instancia.row_info.textL_custom_text:ReplaceData (esta_barra.colocacao, self.displayName, "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" .. instancia.row_info.height .. ":" .. instancia.row_info.height .. ":0:0:256:256:" .. _detalhes.role_texcoord [self.role or "NONE"] .. "|t"))
				else
					esta_barra.texto_esquerdo:SetText (bar_number .. "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" .. instancia.row_info.height .. ":" .. instancia.row_info.height .. ":0:0:256:256:" .. _detalhes.role_texcoord [self.role or "NONE"] .. "|t" .. self.displayName)
				end
				esta_barra.textura:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
			else
				if (_detalhes.faction_against == "Horde") then
					if (UsingCustomLeftText) then
						esta_barra.texto_esquerdo:SetText (instancia.row_info.textL_custom_text:ReplaceData (esta_barra.colocacao, self.displayName, "|TInterface\\AddOns\\Details\\images\\icones_barra:"..instancia.row_info.height..":"..instancia.row_info.height..":0:0:256:32:0:32:0:32|t"))
					else
						esta_barra.texto_esquerdo:SetText (bar_number .. "|TInterface\\AddOns\\Details\\images\\icones_barra:"..instancia.row_info.height..":"..instancia.row_info.height..":0:0:256:32:0:32:0:32|t"..self.displayName) --seta o texto da esqueda -- HORDA
					end
				else
					if (UsingCustomLeftText) then
						esta_barra.texto_esquerdo:SetText (instancia.row_info.textL_custom_text:ReplaceData (esta_barra.colocacao, self.displayName, "|TInterface\\AddOns\\Details\\images\\icones_barra:"..instancia.row_info.height..":"..instancia.row_info.height..":0:0:256:32:32:64:0:32|t"))
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
					esta_barra.texto_esquerdo:SetText (instancia.row_info.textL_custom_text:ReplaceData (esta_barra.colocacao, self.displayName, "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" .. instancia.row_info.height .. ":" .. instancia.row_info.height .. ":0:0:256:256:" .. _detalhes.role_texcoord [self.role or "NONE"] .. "|t"))
				else
					esta_barra.texto_esquerdo:SetText (bar_number .. "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" .. instancia.row_info.height .. ":" .. instancia.row_info.height .. ":0:0:256:256:" .. _detalhes.role_texcoord [self.role or "NONE"] .. "|t" .. self.displayName)
				end
			else
				if (UsingCustomLeftText) then
					esta_barra.texto_esquerdo:SetText (instancia.row_info.textL_custom_text:ReplaceData (esta_barra.colocacao, self.displayName, ""))
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

	function atributo_custom:CreateCustomActorContainer()
		return _setmetatable ({
			_NameIndexTable = {},
			_ActorTable = {}
		}, {__index = atributo_custom})
	end
	
	function atributo_custom:ResetCustomActorContainer()
		for _, actor in _ipairs (self._ActorTable) do
			actor.value = actor.value - _math_floor (actor.value)
			--actor.value = _detalhes:GetOrderNumber (actor.nome)
		end
	end
	
	function atributo_custom:WipeCustomActorContainer()
		table.wipe (self._ActorTable)
		table.wipe (self._NameIndexTable)
	end

	function atributo_custom:AddValue (actor, actortotal, checktop)
		local actor_table = self:GetActorTable (actor)
		actor_table.my_actor = actor
		actor_table.value = actor_table.value + actortotal
		
		if (checktop) then
			if (actor_table.value > atributo_custom._TargetActorsProcessedTop) then
				atributo_custom._TargetActorsProcessedTop = actor_table.value
			end
		end
	end
	
	function atributo_custom:SetValue (actor, actortotal)
		local actor_table = self:GetActorTable (actor)
		actor_table.my_actor = actor
		actor_table.value = actortotal
	end

	function atributo_custom:UpdateClass (actors)
		actors.new_actor.classe = actors.actor.classe
	end
	
	function atributo_custom:GetActorTable (actor)
		local index = self._NameIndexTable [actor.nome]
		if (index) then
			return self._ActorTable [index]
		else
			local new_actor = _setmetatable ({
			nome = actor.nome,
			classe = actor.classe,
			value = _detalhes:GetOrderNumber (actor.nome),
			}, atributo_custom.mt)
			
			new_actor.displayName = new_actor.nome
			
			if (not new_actor.classe) then
				new_actor.classe = _detalhes:GetClass (actor.nome) or "UNKNOW"
			end
			if (new_actor.classe == "UNGROUPPLAYER") then
				atributo_custom:ScheduleTimer ("UpdateClass", 5, {new_actor = new_actor, actor = actor})
			end

			index = #self._ActorTable+1
			
			self._ActorTable [index] = new_actor
			self._NameIndexTable [actor.nome] = index
			return new_actor
		end
	end
	
	function atributo_custom:GetInstanceCustomActorContainer (instance)
		if (not atributo_custom._InstanceActorContainer [instance:GetId()]) then
			atributo_custom._InstanceActorContainer [instance:GetId()] = self:CreateCustomActorContainer()
		end
		return atributo_custom._InstanceActorContainer [instance:GetId()]
	end

	function atributo_custom:CreateCustomDisplayObject()
		return _setmetatable ({
			name = "new custom",
			icon = [[Interface\ICONS\TEMP]],
			author = "unknown",
			attribute = "damagedone",
			source = "[all]",
			target = "[all]",
			spellid = false,
			script = false,
		}, {__index = atributo_custom})
	end

	local custom_sort = function (t1, t2)
		return t1.value > t2.value
	end
	function atributo_custom:Sort (container)
		container = container or self
		_table_sort (container._ActorTable, custom_sort)
	end
	
	function atributo_custom:Remap()
		local map = self._NameIndexTable
		local actors = self._ActorTable
		for i = 1, #actors do
			map [actors[i].nome] = i
		end
	end

	function atributo_custom:ToolTip (instance, bar_number, row_object, keydown)
	
		--> get the custom object
		local custom_object = instance:GetCustomObject()
		
		--> get the actor
		local actor = self.my_actor
		
		local r, g, b = actor:GetClassColor()
		
		_detalhes:AddTooltipSpellHeaderText (custom_object:GetName(), "yellow", 1, 0, 0, 0)
		GameCooltip:AddIcon (custom_object:GetIcon(), 1, 1, 14, 14, 0.90625, 0.109375, 0.15625, 0.875)
		GameCooltip:AddStatusBar (100, 1, r, g, b, 1)
		
		if (custom_object:IsScripted()) then
			if (custom_object.tooltip) then
				local func = loadstring (custom_object.tooltip)
				func (actor, instance.showing, instance)
			end
		else
			--> get the attribute
			local attribute = custom_object:GetAttribute()
			local container_index = atributo_custom:GetCombatContainerIndex (attribute)
			
			--> get the tooltip function
			local func = atributo_custom [attribute .. "Tooltip"]
			
			--> build the tooltip
			func (_, actor, custom_object.target, custom_object.spellid, instance.showing, instance)
		end
		
		return true
	end
	
	function atributo_custom:GetName()
		return self.name
	end
	function atributo_custom:GetIcon()
		return self.icon
	end
	function atributo_custom:GetAuthor()
		return self.author
	end
	function atributo_custom:GetDesc()
		return self.desc
	end
	function atributo_custom:GetAttribute()
		return self.attribute
	end
	function atributo_custom:GetSource()
		return self.source
	end
	function atributo_custom:GetTarget()
		return self.target
	end
	function atributo_custom:GetSpellId()
		return self.spellid
	end
	function atributo_custom:GetScript()
		return self.script
	end
	function atributo_custom:GetScriptToolip()
		return self.tooltip
	end

	function atributo_custom:SetName (name)
		self.name = name
	end
	function atributo_custom:SetIcon (path)
		self.icon = path
	end
	function atributo_custom:SetAuthor (author)
		self.author = author
	end
	function atributo_custom:SetDesc (desc)
		self.desc = desc
	end
	function atributo_custom:SetAttribute (newattribute)
		self.attribute = newattribute
	end
	function atributo_custom:SetSource (source)
		self.source = source
	end
	function atributo_custom:SetTarget (target)
		self.target = target
	end
	function atributo_custom:SetSpellId (spellid)
		self.spellid = spellid
	end
	function atributo_custom:SetScript (code)
		self.script = code
	end
	function atributo_custom:SetScriptToolip (code)
		self.tooltip = code
	end

	function atributo_custom:IsScripted()
		return self.script and true or false
	end
	
	function atributo_custom:IsSpellTarget()
		return self.spellid and self.target and true
	end
	
	function atributo_custom:RemoveCustom (index)
	
		if (not _detalhes.tabela_instancias) then
			--> do not remove customs while the addon is loading.
			return
		end
	
		table.remove (_detalhes.custom, index)
		
		for _, instance in _ipairs (_detalhes.tabela_instancias) do 
			if (instance.atributo == 5 and instance.sub_atributo == index) then 
				instance:ResetAttribute()
			elseif (instance.atributo == 5 and instance.sub_atributo > index) then
				instance.sub_atributo = instance.sub_atributo - 1
				instance.sub_atributo_last [5] = 1
			else
				instance.sub_atributo_last [5] = 1
			end
		end
		
		_detalhes.switch:OnRemoveCustom (index)
	end
	
	function _detalhes:ResetCustomFunctionsCache()
		table.wipe (_detalhes.custom_function_cache)
	end
	
	function _detalhes.refresh:r_atributo_custom()
		--> check for non used temp displays
		if (_detalhes.tabela_instancias) then

			for i = #_detalhes.custom, 1, -1 do
				local custom_object = _detalhes.custom [i]
				if (custom_object.temp) then
					--> check if there is a instance showing this custom
					local showing = false
					
					for index, instance in _ipairs (_detalhes.tabela_instancias) do
						if (instance.atributo == 5 and instance.sub_atributo == i) then 
							showing = true
						end
					end
					
					if (not showing) then
						atributo_custom:RemoveCustom (i)
					end
				end
			end
		end
	
		--> restore metatable and indexes
		for index, custom_object in _ipairs (_detalhes.custom) do
			_setmetatable (custom_object, atributo_custom)
			custom_object.__index = atributo_custom
		end
	end

	function _detalhes.clear:c_atributo_custom()
		for _, custom_object in _ipairs (_detalhes.custom) do
			custom_object.__index = nil
		end
	end

	function atributo_custom:UpdateSelectedToKFunction()
		SelectedToKFunction = ToKFunctions [_detalhes.ps_abbreviation]
		FormatTooltipNumber = ToKFunctions [_detalhes.tooltip.abbreviation]
		TooltipMaximizedMethod = _detalhes.tooltip.maximize_method
		atributo_custom:UpdateDamageDoneBracket()
		atributo_custom:UpdateHealingDoneBracket()
		atributo_custom:UpdateDamageTakenBracket()
	end

	function _detalhes:AddDefaultCustomDisplays()
	
		local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
		
		local PotionUsed = {
			name = Loc ["STRING_CUSTOM_POT_DEFAULT"],
			icon = [[Interface\ICONS\Trade_Alchemy_PotionD4]],
			attribute = false,
			spellid = false,
			author = "Details!",
			desc = Loc ["STRING_CUSTOM_POT_DEFAULT_DESC"],
			source = false,
			target = false,
			script = [[
				--init:
				local combat, instance_container, instance = ...
				local total, top, amount = 0, 0, 0

				--get the misc actor container
				local misc_container = combat:GetActorList ( DETAILS_ATTRIBUTE_MISC )

				--do the loop:
				for _, player in ipairs ( misc_container ) do 
				    
				    --only player in group
				    if (player:IsGroupPlayer()) then
					
					local found_potion = false
					
					--get the spell debuff uptime container
					local debuff_uptime_container = player.debuff_uptime and player.debuff_uptime_spell_tables and player.debuff_uptime_spell_tables._ActorTable
					if (debuff_uptime_container) then
					    --potion of focus (can't use as pre-potion, so, its amount is always 1
					    local focus_potion = debuff_uptime_container [105701]
					    if (focus_potion) then
						total = total + 1
						found_potion = true
						if (top < 1) then
						    top = 1
						end
						--add amount to the player 
						instance_container:AddValue (player, 1)
					    end
					end
					
					--get the spell buff uptime container
					local buff_uptime_container = player.buff_uptime and player.buff_uptime_spell_tables and player.buff_uptime_spell_tables._ActorTable
					if (buff_uptime_container) then
					    
					    --potion of the jade serpent
					    local jade_serpent_potion = buff_uptime_container [105702]
					    if (jade_serpent_potion) then
						local used = jade_serpent_potion.activedamt
						if (used > 0) then
						    total = total + used
						    found_potion = true
						    if (used > top) then
							top = used
						    end
						    --add amount to the player 
						    instance_container:AddValue (player, used)
						end
					    end
					    
					    --potion of mogu power
					    local mogu_power_potion = buff_uptime_container [105706]
					    if (mogu_power_potion) then
						local used = mogu_power_potion.activedamt
						if (used > 0) then
						    total = total + used
						    found_potion = true
						    if (used > top) then
							top = used
						    end
						    --add amount to the player 
						    instance_container:AddValue (player, used)
						end
					    end
					    
					    --virmen's bite
					    local virmens_bite_potion = buff_uptime_container [105697]
					    if (virmens_bite_potion) then
						local used = virmens_bite_potion.activedamt
						if (used > 0) then
						    total = total + used
						    found_potion = true
						    if (used > top) then
							top = used
						    end
						    --add amount to the player 
						    instance_container:AddValue (player, used)
						end
					    end
					    
					    --potion of the mountains
					    local mountains_potion = buff_uptime_container [105698]
					    if (mountains_potion) then
						local used = mountains_potion.activedamt
						if (used > 0) then
						    total = total + used
						    found_potion = true
						    if (used > top) then
							top = used
						    end
						    --add amount to the player 
						    instance_container:AddValue (player, used)
						end
					    end
					end
					
					if (found_potion) then
					    amount = amount + 1
					end    
				    end
				end

				--return:
				return total, top, amount
				]],
			tooltip = [[
			--init:
			local player, combat, instance = ...

			--get the debuff container for potion of focus
			local debuff_uptime_container = player.debuff_uptime and player.debuff_uptime_spell_tables and player.debuff_uptime_spell_tables._ActorTable
			if (debuff_uptime_container) then
			    local focus_potion = debuff_uptime_container [105701]
			    if (focus_potion) then
				local name, _, icon = GetSpellInfo (105701)
				GameCooltip:AddLine (name, 1) --> can use only 1 focus potion (can't be pre-potion)
				_detalhes:AddTooltipBackgroundStatusbar()
				GameCooltip:AddIcon (icon, 1, 1, 14, 14)
			    end
			end

			--get the buff container for all the others potions
			local buff_uptime_container = player.buff_uptime and player.buff_uptime_spell_tables and player.buff_uptime_spell_tables._ActorTable
			if (buff_uptime_container) then
			    --potion of the jade serpent
			    local jade_serpent_potion = buff_uptime_container [105702]
			    if (jade_serpent_potion) then
				local name, _, icon = GetSpellInfo (105702)
				GameCooltip:AddLine (name, jade_serpent_potion.activedamt)
				_detalhes:AddTooltipBackgroundStatusbar()
				GameCooltip:AddIcon (icon, 1, 1, 14, 14)
			    end
			    
			    --potion of mogu power
			    local mogu_power_potion = buff_uptime_container [105706]
			    if (mogu_power_potion) then
				local name, _, icon = GetSpellInfo (105706)
				GameCooltip:AddLine (name, mogu_power_potion.activedamt)
				_detalhes:AddTooltipBackgroundStatusbar()
				GameCooltip:AddIcon (icon, 1, 1, 14, 14)
			    end
			    
			    --virmen's bite
			    local virmens_bite_potion = buff_uptime_container [105697]
			    if (virmens_bite_potion) then
				local name, _, icon = GetSpellInfo (105697)
				GameCooltip:AddLine (name, virmens_bite_potion.activedamt)
				_detalhes:AddTooltipBackgroundStatusbar()
				GameCooltip:AddIcon (icon, 1, 1, 14, 14)
			    end
			    
			    --potion of the mountains
			    local mountains_potion = buff_uptime_container [105698]
			    if (mountains_potion) then
				local name, _, icon = GetSpellInfo (105698)
				GameCooltip:AddLine (name, mountains_potion.activedamt)
				_detalhes:AddTooltipBackgroundStatusbar()
				GameCooltip:AddIcon (icon, 1, 1, 14, 14)
			    end
			end
		]]
		}
		
		local have = false
		for _, custom in ipairs (self.custom) do
			if (custom.name == Loc ["STRING_CUSTOM_POT_DEFAULT"]) then
				have = true
				break
			end
		end
		if (not have) then
			setmetatable (PotionUsed, _detalhes.atributo_custom)
			PotionUsed.__index = _detalhes.atributo_custom
			self.custom [#self.custom+1] = PotionUsed
		end
		
		local Healthstone = {
			name = Loc ["STRING_CUSTOM_HEALTHSTONE_DEFAULT"],
			icon = [[Interface\ICONS\warlock_ healthstone]],
			attribute = "healdone",
			spellid = 6262, 
			author = "Details!",
			desc = Loc ["STRING_CUSTOM_HEALTHSTONE_DEFAULT_DESC"],
			source = "[raid]",
			target = "[raid]",
			script = false,
			tooltip = false
		}

		local have = false
		for _, custom in ipairs (self.custom) do
			if (custom.name == Loc ["STRING_CUSTOM_HEALTHSTONE_DEFAULT"]) then
				have = true
				break
			end
		end
		if (not have) then
			setmetatable (Healthstone, _detalhes.atributo_custom)
			Healthstone.__index = _detalhes.atributo_custom
			self.custom [#self.custom+1] = Healthstone
		end
		
		local DamageActivityTime = {
			name = Loc ["STRING_CUSTOM_ACTIVITY_DPS"],
			icon = [[Interface\ICONS\Achievement_PVP_H_06]],
			attribute = false,
			spellid = false,
			author = "Details!",
			desc = Loc ["STRING_CUSTOM_ACTIVITY_DPS_DESC"],
			source = false,
			target = false,
			total_script = [[
				local value, top, total, combat, instance = ...
				local minutos, segundos = math.floor (value/60), math.floor (value%60)
				return minutos .. "m " .. segundos .. "s"
			]],
			percent_script = [[
				local value, top, total, combat, instance = ...
				return string.format ("%.1f", value/top*100)
			]],
			script = [[
				--init:
				local combat, instance_container, instance = ...
				local total, amount = 0, 0

				--get the misc actor container
				local damage_container = combat:GetActorList ( DETAILS_ATTRIBUTE_DAMAGE )
				
				--do the loop:
				for _, player in ipairs ( damage_container ) do 
					if (player.grupo) then
						local activity = player:Tempo()
						total = total + activity
						amount = amount + 1
						--add amount to the player 
						instance_container:AddValue (player, activity)
					end
				end
				
				--return:
				return total, combat:GetCombatTime(), amount
			]],
			tooltip = [[
				
			]],
		}
		
		local have = false
		for _, custom in ipairs (self.custom) do
			if (custom.name == Loc ["STRING_CUSTOM_ACTIVITY_DPS"]) then
				have = true
				break
			end
		end
		if (not have) then
			setmetatable (DamageActivityTime, _detalhes.atributo_custom)
			DamageActivityTime.__index = _detalhes.atributo_custom		
			self.custom [#self.custom+1] = DamageActivityTime
		end

		local HealActivityTime = {
			name = Loc ["STRING_CUSTOM_ACTIVITY_HPS"],
			icon = [[Interface\ICONS\Achievement_PVP_G_06]],
			attribute = false,
			spellid = false,
			author = "Details!",
			desc = Loc ["STRING_CUSTOM_ACTIVITY_HPS_DESC"],
			source = false,
			target = false,
			total_script = [[
				local value, top, total, combat, instance = ...
				local minutos, segundos = math.floor (value/60), math.floor (value%60)
				return minutos .. "m " .. segundos .. "s"
			]],
			percent_script = [[
				local value, top, total, combat, instance = ...
				return string.format ("%.1f", value/top*100)
			]],
			script = [[
				--init:
				local combat, instance_container, instance = ...
				local total, top, amount = 0, 0, 0

				--get the misc actor container
				local damage_container = combat:GetActorList ( DETAILS_ATTRIBUTE_HEAL )
				
				--do the loop:
				for _, player in ipairs ( damage_container ) do 
					if (player.grupo) then
						local activity = player:Tempo()
						total = total + activity
						amount = amount + 1
						--add amount to the player 
						instance_container:AddValue (player, activity)
					end
				end
				
				--return:
				return total, combat:GetCombatTime(), amount
			]],
			tooltip = [[
				
			]],
		}
		
		local have = false
		for _, custom in ipairs (self.custom) do
			if (custom.name == Loc ["STRING_CUSTOM_ACTIVITY_HPS"]) then
				have = true
				break
			end
		end
		if (not have) then
			setmetatable (HealActivityTime, _detalhes.atributo_custom)
			HealActivityTime.__index = _detalhes.atributo_custom
			self.custom [#self.custom+1] = HealActivityTime
		end
		
	end



