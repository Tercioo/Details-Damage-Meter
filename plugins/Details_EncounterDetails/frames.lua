do
	local _detalhes = _G._detalhes
	local DetailsFrameWork = _detalhes.gump
	local AceLocale = LibStub ("AceLocale-3.0")
	local Loc = AceLocale:GetLocale ("Details_EncounterDetails")
	local Graphics = LibStub:GetLibrary("LibGraph-2.0")
	local _ipairs = ipairs
	local _math_floor = math.floor
	local _cstr = string.format
	local _GetSpellInfo = _detalhes.getspellinfo
	
	_detalhes.EncounterDetailsTempWindow = function (EncounterDetails)
	
	--> options panel
	
	function EncounterDetails:AutoShowIcon()
		local found_boss = false
		for _, combat in ipairs (EncounterDetails:GetCombatSegments()) do 
			if (combat.is_boss) then
				EncounterDetails:ShowIcon()
				found_boss = true
			end
		end
		if (EncounterDetails:GetCurrentCombat().is_boss) then
			EncounterDetails:ShowIcon()
			found_boss = true
		end
		if (not found_boss) then
			EncounterDetails:HideIcon()
		end
	end
	
	local build_options_panel = function()
	
		local options_frame = EncounterDetails:CreatePluginOptionsFrame ("EncounterDetailsOptionsWindow", "Encounter Details Options", 2)
		
		-- 1 = only when inside a raid map
		-- 2 = only when in raid group
		-- 3 = only after a boss encounter
		-- 4 = always show
		-- 5 = automatic show when have at least 1 encounter with boss
		
		local set = function (_, _, value) 
			EncounterDetails.db.show_icon = value 
			if (value == 1) then
				if (EncounterDetails:GetZoneType() == "raid") then
					EncounterDetails:ShowIcon()
				else
					EncounterDetails:HideIcon()
				end
			elseif (value == 2) then
				if (EncounterDetails:InGroup()) then
					EncounterDetails:ShowIcon()
				else
					EncounterDetails:HideIcon()
				end
			elseif (value == 3) then
				if (EncounterDetails:GetCurrentCombat().is_boss) then
					EncounterDetails:ShowIcon()
				else
					EncounterDetails:HideIcon()
				end
			elseif (value == 4) then
				EncounterDetails:ShowIcon()
			elseif (value == 5) then
				EncounterDetails:AutoShowIcon()
			end
		end
		local on_show_menu = {
			{value = 1, label = "Inside Raid", onclick = set, desc = "Only show the icon while inside a raid."},
			{value = 2, label = "In Group", onclick = set, desc = "Only show the icon while in group."},
			{value = 3, label = "After Encounter", onclick = set, desc = "Show the icon after a raid boss encounter."},
			{value = 4, label = "Always", onclick = set, desc = "Always show the icon."},
			{value = 5, label = "Auto", onclick = set, desc = "The plugin decides when the icon needs to be shown."},
		}
		
--		/dump DETAILS_PLUGIN_ENCOUNTER_DETAILS.db.show_icon
		
		local menu = {
			{
				type = "select",
				get = function() return EncounterDetails.db.show_icon end,
				values = function() return on_show_menu end,
				desc = "When the icon is shown in the Details! tooltip.",
				name = "Show Icon"
			},
			{
				type = "toggle",
				get = function() return EncounterDetails.db.hide_on_combat end,
				set = function (self, fixedparam, value) EncounterDetails.db.hide_on_combat = value end,
				desc = "Encounter Details window automatically close when you enter in combat.",
				name = "Hide on Combat"
			},
			{
				type = "range",
				get = function() return EncounterDetails.db.max_emote_segments end,
				set = function (self, fixedparam, value) EncounterDetails.db.max_emote_segments = value end,
				min = 1,
				max = 10,
				step = 1,
				desc = "Keep how many segments emotes.",
				name = "Emote Segments Amount",
				usedecimals = true,
			},
			{
				type = "range",
				get = function() return EncounterDetails.db.window_scale end,
				set = function (self, fixedparam, value) EncounterDetails.db.window_scale = value; EncounterDetails:RefreshScale() end,
				min = 0.65,
				max = 1.50,
				step = 0.1,
				desc = "Set the window size",
				name = "Window Scale",
				usedecimals = true,
			},
			
		}
		
		DetailsFrameWork:BuildMenu (options_frame, menu, 15, -75, 260)
		
	end
	
	EncounterDetails.OpenOptionsPanel = function()
		if (not EncounterDetailsOptionsWindow) then
			build_options_panel()
		end
		EncounterDetailsOptionsWindow:Show()
	end
	
	function EncounterDetails:RefreshScale()
		local scale = EncounterDetails.db.window_scale
		if (EncounterDetails.Frame) then
			EncounterDetails.Frame:SetScale (scale)
		end
	end	
	
	function EncounterDetails:CreateRowTexture (row)
		row.textura = CreateFrame ("StatusBar", nil, row)
		row.textura:SetAllPoints (row)
		local t = row.textura:CreateTexture (nil, "overlay")
		t:SetTexture ("Interface\\AddOns\\Details\\images\\bar_serenity")
		--t:SetTexture ("Interface\\AddOns\\Details\\images\\bar_skyline")
		row.t = t
		row.textura:SetStatusBarTexture (t)
		row.textura:SetStatusBarColor(.5, .5, .5, 0)
		row.textura:SetMinMaxValues(0,100)
		
		row.texto_esquerdo = row.textura:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
		row.texto_esquerdo:SetPoint ("LEFT", row.textura, "LEFT", 22, -1)
		row.texto_esquerdo:SetJustifyH ("LEFT")
		row.texto_esquerdo:SetTextColor (1,1,1,1)

		row.texto_direita = row.textura:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
		row.texto_direita:SetPoint ("RIGHT", row.textura, "RIGHT", -2, 0)
		row.texto_direita:SetJustifyH ("RIGHT")
		row.texto_direita:SetTextColor (1,1,1,1)
		
		row.textura:Show()
	end
	
	function EncounterDetails:CreateRow (index, container, x_mod, y_mod, width_mod)

		local barra = CreateFrame ("Button", "Details_"..container:GetName().."_barra_"..index, container)
		
		x_mod = x_mod or 0
		width_mod = width_mod or 0
		
		barra:SetWidth (200+width_mod) --> tamanho da barra de acordo com o tamanho da janela
		barra:SetHeight (16) --> altura determinada pela instância

		local y = (index-1)*15 --> 17 é a altura da barra
		y_mod = y_mod or 0
		y = y + y_mod
		y = y*-1 --> baixo
		
		barra:SetPoint ("LEFT", container, "LEFT", x_mod, 0)
		barra:SetPoint ("RIGHT", container, "RIGHT", width_mod, 0)
		barra:SetPoint ("TOP", container, "TOP", 0, y)
		barra:SetFrameLevel (container:GetFrameLevel() + 1)

		barra:EnableMouse (true)
		barra:RegisterForClicks ("LeftButtonDown","RightButtonUp")	

		EncounterDetails:CreateRowTexture (barra)

		--> icone
		barra.icone = barra.textura:CreateTexture (nil, "OVERLAY")
		barra.icone:SetWidth (14)
		barra.icone:SetHeight (14)
		barra.icone:SetPoint ("RIGHT", barra.textura, "LEFT", 0+20, 0)
		
		barra:SetAlpha(0.9)
		barra.icone:SetAlpha (0.8)
		
		EncounterDetails:SetRowScripts (barra, index, container)
		
		container.barras [index] = barra

		return barra
	end	
	
	function EncounterDetails:JB_AtualizaContainer (container, amt, barras_total)
		barras_total = barras_total or 6
		if (amt >= barras_total and container.ultimo ~= amt) then
			local tamanho = 17*amt
			container:SetHeight (tamanho)
			container.window.slider:Update()
			container.window.ultimo = amt
		elseif (amt <= barras_total-1 and container.slider.ativo) then
			container.window.slider:Update (true)
			container:SetHeight (140)
			container.window.scroll_ativo = false
			container.window.ultimo = 0
		end
	end
	
	local grafico_cores = {{1, 1, 1, 1}, {1, 0.5, 0.3, 1}, {0.75, 0.7, 0.1, 1}, {0.2, 0.9, 0.2, 1}, {0.2, 0.5, 0.9, 1}}
	
	local lastBoss = nil
	EncounterDetails.CombatsAlreadyDrew = {}
	
	function EncounterDetails:BuildDpsGraphic()
		
		local segment = EncounterDetails._segment

		local g
		
		if (not _G.DetailsRaidDpsGraph) then
			EncounterDetails:CreateGraphPanel()
			g = _G.DetailsRaidDpsGraph
		else
			g = _G.DetailsRaidDpsGraph

			--if (not combat.is_boss or not lastBoss or combat.is_boss.index ~= lastBoss) then
			--	g.max_damage = 0
			--end
		end
		g:ResetData()
		
		local combat = EncounterDetails:GetCombat (segment)
		local graphicData = combat:GetTimeData ("Raid Damage Done")
		
		if (not graphicData or not combat.start_time or not combat.end_time) then
			EncounterDetails:Msg ("This segment doesn't have chart data.")
			return
		--elseif (EncounterDetails.CombatsAlreadyDrew [combat:GetCombatNumber()]) then
			--return
		end
		
		if (graphicData.max_value == 0) then
			return
		end
		
		--> battle time
		if (combat.end_time - combat.start_time < 12) then
			return
		end

		--EncounterDetails.Frame.linhas = EncounterDetails.Frame.linhas or 0
		EncounterDetails.Frame.linhas = 1
		
		if (EncounterDetails.Frame.linhas > 5) then
			EncounterDetails.Frame.linhas = 1
		end
		

		
		g.max_damage = 0

		for _, line in ipairs (g.VerticalLines) do
			line:Hide()
		end

		lastBoss = combat.is_boss and combat.is_boss.index
		
		--
		for i = segment + 4, segment+1, -1 do
			local combat = EncounterDetails:GetCombat (i)
			if (combat) then --the combat exists
				local elapsed_time = combat:GetCombatTime()
				
				if (EncounterDetails.debugmode and not combat.is_boss) then
					combat.is_boss = {
						index = 1, 
						name = _detalhes:GetBossName (1098, 1),
						zone = "Throne of Thunder", 
						mapid = 1098, 
						encounter = "Jin'Rohk the Breaker"
					}
				end
				
				if (elapsed_time > 12 and combat.is_boss and combat.is_boss.index == lastBoss) then --is the same boss
				
					local chart_data = combat:GetTimeData ("Raid Damage Done")
					if (chart_data and chart_data.max_value and chart_data.max_value > 0) then --have a chart data
						--if (not EncounterDetails.CombatsAlreadyDrew [combat:GetCombatNumber()]) then --isn't drew yet
							EncounterDetails:DrawSegmentGraphic (g, chart_data, combat)
							--EncounterDetails.CombatsAlreadyDrew [combat:GetCombatNumber()] = true
						--end
					end
				end
			end
		end
		
		g:ClearPhaseTexture()
		local phase_data = combat.PhaseData
		local scale = 610 / combat:GetCombatTime()
		
		for i = 1, #phase_data do
			local phase = phase_data[i][1]
			local start_at = phase_data[i][2]
			local texture = g:GetPhaseTexture (i, phase)
			
			texture:SetPoint ("bottomleft", g, "bottomleft", (start_at * scale)+58, 0)
			texture.phase = phase
			texture.start_at = start_at
			
			local next_phase = phase_data[i+1]
			if (next_phase) then
				local duration = next_phase [2] - start_at
				texture:SetWidth (scale * duration)
				texture.elapsed = duration
			else
				local duration = combat:GetCombatTime() - start_at
				texture:SetWidth (scale * duration)
				texture.elapsed = duration
			end
		end
		
		g.combat = combat
		
		--
		
		EncounterDetails:DrawSegmentGraphic (g, graphicData, combat, combat)
		EncounterDetails.CombatsAlreadyDrew [combat:GetCombatNumber()] = true
		
		g:Show()
		
	end	
	
	function EncounterDetails:DrawSegmentGraphic (g, graphicData, combat, drawDeathsCombat)
	
		local _data = {}
		local dps_max = graphicData.max_value
		local amount = #graphicData
		
		local scaleW = 1/670

		local content = graphicData
		tinsert (content, 1, 0)
		tinsert (content, 1, 0)
		tinsert (content, #content+1, 0)
		tinsert (content, #content+1, 0)
		
		local _i = 3
		
		local graphMaxDps = math.max (g.max_damage, dps_max)
		while (_i <= #content-2) do 
			local v = (content[_i-2]+content[_i-1]+content[_i]+content[_i+1]+content[_i+2])/5 --> normalize
			_data [#_data+1] = {scaleW*(_i-2), v/graphMaxDps} --> x and y coords
			_i = _i + 1
		end
		
		tremove (content, 1)
		tremove (content, 1)
		tremove (content, #graphicData)
		tremove (content, #graphicData)

		local tempo = combat.end_time - combat.start_time
		if (g.max_time < tempo) then 
			g.max_time = tempo

			local tempo_divisao = g.max_time / 8
			
			for i = 1, 8, 1 do
				local t = tempo_divisao*i
				local minutos, segundos = _math_floor (t/60), _math_floor (t%60)
				if (segundos < 10) then
					segundos = "0"..segundos
				end
				if (minutos < 10) then
					minutos = "0"..minutos
				end
				EncounterDetails.Frame["timeamt"..i]:SetText (minutos..":"..segundos)
			end
		end
		
		if (dps_max > g.max_damage) then 
		
			--> normalize previous data
			if (g.max_damage > 0) then
				local normalizePercent = g.max_damage / dps_max
				for dataIndex, Data in ipairs (g.Data) do 
					local Points = Data.Points
					for i = 1, #Points do 
						Points[i][2] = Points[i][2]*normalizePercent
					end
				end
			end
		
			g.max_damage = dps_max
			
			local dano_divisao = g.max_damage/8
			
			local o = 1
			for i = 8, 1, -1 do
				local d = _detalhes:ToK (dano_divisao*i)
				EncounterDetails.Frame["dpsamt"..o]:SetText (d)
				o = o + 1
			end
			
		end
		
		if (#g.Data == 5) then
			table.remove (g.Data, 5)
		end
		
		g:AddDataSeriesOnFirstIndex (_data, grafico_cores [1])
		
		for i = 2, #g.Data do 
			g:ChangeColorOnDataSeries (i, grafico_cores [i])
		end

		if (drawDeathsCombat) then
			local mortes = drawDeathsCombat.last_events_tables
			--local scaleG = 650/_detalhes.tabela_vigente:GetCombatTime()
			local scaleG = 610/drawDeathsCombat:GetCombatTime()
			
			for _, row in _ipairs (g.VerticalLines) do 
				row:Hide()
			end
			
			for i = 1, math.min (3, #mortes) do 
			
				local vRowFrame = g.VerticalLines [i]
				
				if (not vRowFrame) then
				
					vRowFrame = CreateFrame ("frame", "DetailsEncountersVerticalLine"..i, g)
					vRowFrame:SetWidth (20)
					vRowFrame:SetHeight (43)
					vRowFrame:SetFrameLevel (g:GetFrameLevel()+2)
					
					vRowFrame:SetScript ("OnEnter", function (frame) 
						
						if (vRowFrame.dead[1] and vRowFrame.dead[1][3] and vRowFrame.dead[1][3][2]) then
						
							GameCooltip:Reset()
							
							--time of death and player name
							GameCooltip:AddLine (vRowFrame.dead[6].." "..vRowFrame.dead[3])
							local class, l, r, t, b = _detalhes:GetClass (vRowFrame.dead[3])
							if (class) then
								GameCooltip:AddIcon ([[Interface\AddOns\Details\images\classes_small]], 1, 1, 12, 12, l, r, t, b)
							end
							GameCooltip:AddLine ("")
							
							--last hits:
							local death = vRowFrame.dead
							local amt = 0
							for i = #death[1], 1, -1 do
								local this_hit = death[1][i]
								if (type (this_hit[1]) == "boolean" and this_hit[1]) then
									local spellname, _, spellicon = _GetSpellInfo (this_hit[2])
									local t = death [2] - this_hit [4]
									GameCooltip:AddLine ("-" .. _cstr ("%.1f", t) .. " " .. spellname .. " (" .. this_hit[6] .. ")", EncounterDetails:comma_value (this_hit [3]))
									GameCooltip:AddIcon (spellicon, 1, 1, 12, 12, 0.1, 0.9, 0.1, 0.9)
									amt = amt + 1
									if (amt == 3) then
										break
									end
								end
							end
							
							GameCooltip:SetOption ("TextSize", 9.5)
							GameCooltip:SetOption ("HeightAnchorMod", -15)
							
							GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
							GameCooltip:ShowCooltip (frame, "tooltip")
						end
					end)
					
					vRowFrame:SetScript ("OnLeave", function (frame) 
						_detalhes.popup:ShowMe (false)
					end)

					vRowFrame.texture = vRowFrame:CreateTexture (nil, "overlay")
					vRowFrame.texture:SetTexture ("Interface\\AddOns\\Details\\images\\verticalline")
					vRowFrame.texture:SetWidth (3)
					vRowFrame.texture:SetHeight (20)
					vRowFrame.texture:SetPoint ("center", "DetailsEncountersVerticalLine"..i, "center")
					vRowFrame.texture:SetPoint ("bottom", "DetailsEncountersVerticalLine"..i, "bottom", 0, 0)
					vRowFrame.texture:SetVertexColor (1, 1, 1, .5)

					vRowFrame.icon = vRowFrame:CreateTexture (nil, "overlay")
					vRowFrame.icon:SetTexture ("Interface\\WorldStateFrame\\SkullBones")
					vRowFrame.icon:SetTexCoord (0.046875, 0.453125, 0.046875, 0.46875)
					vRowFrame.icon:SetWidth (16)
					vRowFrame.icon:SetHeight (16)
					vRowFrame.icon:SetPoint ("center", "DetailsEncountersVerticalLine"..i, "center")
					vRowFrame.icon:SetPoint ("bottom", "DetailsEncountersVerticalLine"..i, "bottom", 0, 20)

					g.VerticalLines [i] = vRowFrame
				end
				
				local deadTime = mortes [i].dead_at
				--print (deadTime, mortes [i][3])
				vRowFrame:SetPoint ("topleft", EncounterDetails.Frame, "topleft", (deadTime*scaleG)+70, -268)
				vRowFrame.dead = mortes [i]
				vRowFrame:Show()
				
			end
		end
	end
	
	function EncounterDetails:CreateGraphPanel()
		local g = Graphics:CreateGraphLine ("DetailsRaidDpsGraph", EncounterDetails.Frame, "topleft","topleft",20,-76,670,238)
		g:SetXAxis (-1,1)
		g:SetYAxis (-1,1)
		g:SetGridSpacing (false, false)
		g:SetGridColor ({0.5,0.5,0.5,0.3})
		g:SetAxisDrawing (false,false)
		g:SetAxisColor({1.0,1.0,1.0,1.0})
		g:SetAutoScale (true)
		g:SetLineTexture ("smallline")
		g:SetBorderSize ("right", 0.001)
		g.VerticalLines = {}
		g.TryIndicator = {}
		g.PhaseTextures = {}
		
		local phase_alpha = 0.5
		local phase_colors = {{0.2, 1, 0.2, phase_alpha}, {1, 1, 0.2, phase_alpha}, {1, 0.2, 0.2, phase_alpha}, {0.2, 1, 1, phase_alpha}, {0.2, 0.2, 1, phase_alpha},
			[1.5] = {0.25, 0.95, 0.25, phase_alpha}, [2.5] = {0.95, 0.95, 0.25, phase_alpha}, [3.5] = {0.95, 0.25, 0.25, phase_alpha}
		}
		
		local phase_panel = CreateFrame ("frame", "EncounterDetailsPhasePanel", g)
		phase_panel:SetFrameStrata ("TOOLTIP")
		phase_panel:SetWidth (451)
		phase_panel:SetBackdrop ({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
			edgeFile = [[Interface\AddOns\Details\images\border_2]], edgeSize = 32,
			insets = {left = 1, right = 1, top = 1, bottom = 1}})
		phase_panel:SetBackdropColor (0, 0, 0, .4)
		
		local damage_icon = DetailsFrameWork:CreateImage (phase_panel, [[Interface\AddOns\Details\images\skins\classic_skin_v1]], 16, 16, "overlay", {11/1024, 24/1024, 376/1024, 390/1024})
		local damage_label = DetailsFrameWork:CreateLabel (phase_panel, "Damage Done:")
		damage_icon:SetPoint ("topleft", phase_panel, "topleft", 10, -10)
		damage_label:SetPoint ("left", damage_icon, "right", 4, 0)
		
		local heal_icon = DetailsFrameWork:CreateImage (phase_panel, [[Interface\AddOns\Details\images\skins\classic_skin_v1]], 16, 16, "overlay", {43/1024, 57/1024, 376/1024, 390/1024})
		local heal_label = DetailsFrameWork:CreateLabel (phase_panel, "Healing Done:")
		heal_icon:SetPoint ("topleft", phase_panel, "topleft", 250, -10)
		heal_label:SetPoint ("left", heal_icon, "right", 4, 0)
		
		phase_panel.damage_labels = {}
		phase_panel.heal_labels = {}
		
		function phase_panel:ClearLabels()
			for i, label in ipairs (phase_panel.damage_labels) do
				label.lefttext:Hide()
				label.righttext:Hide()
				label.icon:Hide()
				label.bg:Hide()
			end
			for i, label in ipairs (phase_panel.heal_labels) do
				label.lefttext:Hide()
				label.righttext:Hide()
				label.icon:Hide()
				label.bg:Hide()
			end
		end
		
		function phase_panel:GetDamageLabel (index)
			local label = phase_panel.damage_labels [index]
			if (not label) then
				local player_name = DetailsFrameWork:CreateLabel (phase_panel, "")
				local amount = DetailsFrameWork:CreateLabel (phase_panel, "")
				amount:SetJustifyH ("right")
				local icon = DetailsFrameWork:CreateImage (phase_panel, "", 16, 16)
				local bg = DetailsFrameWork:CreateImage (phase_panel, [[Interface\AddOns\Details\images\BantoBar]], nil, nil, "artwork")
				bg:SetPoint ("left", icon, "left"); bg.height = 16; bg:SetPoint ("right", amount, "right"); bg:SetVertexColor (.2, .2, .2, 0.8)
				
				icon:SetPoint ("topleft", phase_panel, "topleft", 10, ((index * 16) * -1) - 16)
				player_name:SetPoint ("left", icon, "right", 2, 0)
				amount:SetPoint ("topright", phase_panel, "topleft", 200, ((index * 16) * -1) - 16)
				
				label = {lefttext = player_name, righttext = amount, icon = icon, bg = bg}
				phase_panel.damage_labels [index] = label
			end
			return label
		end
		
		function phase_panel:GetHealLabel (index)
			local label = phase_panel.heal_labels [index]
			if (not label) then
				local player_name = DetailsFrameWork:CreateLabel (phase_panel, "")
				local amount = DetailsFrameWork:CreateLabel (phase_panel, "")
				amount:SetJustifyH ("right")
				local icon = DetailsFrameWork:CreateImage (phase_panel, "", 16, 16)
				local bg = DetailsFrameWork:CreateImage (phase_panel, [[Interface\AddOns\Details\images\BantoBar]], nil, nil, "artwork")
				bg:SetPoint ("left", icon, "left"); bg.height = 16; bg:SetPoint ("right", amount, "right"); bg:SetVertexColor (.2, .2, .2, 0.8)
				
				icon:SetPoint ("topleft", phase_panel, "topleft", 250, ((index * 16) * -1) - 16)
				player_name:SetPoint ("left", icon, "right", 2, 0)
				amount:SetPoint ("topright", phase_panel, "topleft", 440, ((index * 16) * -1) - 16)
				
				label = {lefttext = player_name, righttext = amount, icon = icon, bg = bg}
				phase_panel.heal_labels [index] = label
			end
			return label
		end
		
		phase_panel.phase_label = DetailsFrameWork:CreateLabel (phase_panel, "")
		phase_panel.time_label = DetailsFrameWork:CreateLabel (phase_panel, "")
		phase_panel.report_label = DetailsFrameWork:CreateLabel (phase_panel, "|cFFffb400Left Click|r: Report Damage |cFFffb400Right Click|r: Report Heal")
		
		phase_panel.phase_label:SetPoint ("bottomleft", phase_panel, "bottomleft", 10, 5)
		phase_panel.time_label:SetPoint ("left", phase_panel.phase_label, "right", 5, 0)
		phase_panel.report_label:SetPoint ("bottomright", phase_panel, "bottomright", -10, 5)
		
		local bg = DetailsFrameWork:CreateImage (phase_panel, [[Interface\Tooltips\UI-Tooltip-Background]], nil, nil, "artwork")
		bg:SetPoint ("left", phase_panel.phase_label, "left"); bg.height = 16; bg:SetPoint ("right", phase_panel.report_label, "right"); bg:SetVertexColor (0, 0, 0, 1)
		
		local spark_container = {}
		local create_spark = function()
			local t = phase_panel:CreateTexture (nil, "overlay")
			t:SetTexture ([[Interface\CastingBar\UI-CastingBar-Spark]])
			t:SetBlendMode ("ADD")
			t:Hide()
			tinsert (spark_container, t)
		end
		local get_spark = function (index)
			local spark = spark_container [index]
			if (not spark) then
				create_spark()
				spark = spark_container [index]
			end
			spark:ClearAllPoints()
			return spark
		end
		local hide_sparks = function()
			for _, spark in ipairs (spark_container) do
				spark:Hide()
			end
		end
		
		local phase_on_enter = function (self)

			local spark1 = get_spark (1)
			local spark2 = get_spark (2)
			self.texture:SetBlendMode ("ADD")
			spark1:SetPoint ("left", self.texture, "left", -16, 0)
			spark2:SetPoint ("right", self.texture, "right", 16, 0)
			spark1:Show()
			spark2:Show()
			
			local phase = self.phase
			local spark_index = 3
			
			self.texture:SetVertexColor (1, 1, 1)
			
			for _, f in ipairs (g.PhaseTextures) do
				if (f ~= self and f.phase == phase) then
					local spark1 = get_spark (spark_index)
					local spark2 = get_spark (spark_index+1)
					f.texture:SetBlendMode ("ADD")
					f.texture:SetVertexColor (1, 1, 1)
					spark1:SetPoint ("left", f.texture, "left", -16, 0)
					spark2:SetPoint ("right", f.texture, "right", 16, 0)
					spark1:Show()
					spark2:Show()
					spark_index = spark_index + 2
				end
			end
			
			local combat = DetailsRaidDpsGraph.combat
			if (combat) then
			
				phase_panel:ClearLabels()
			
				--damage
				local players = {}
				for player_name, damage in pairs (combat.PhaseData.damage [self.phase]) do
					tinsert (players, {player_name, damage})
				end
				table.sort (players, _detalhes.Sort2)
				
				for i, player in ipairs (players) do
					local dlabel = phase_panel:GetDamageLabel (i)
					dlabel.lefttext.text = EncounterDetails:GetOnlyName (player [1])
					dlabel.righttext.text = _detalhes:ToK (_math_floor (player [2]))
					
					local class = EncounterDetails:GetClass (player [1])
					local spec = EncounterDetails:GetSpec (player [1])
					
					if (spec) then
						dlabel.icon.texture = [[Interface\AddOns\Details\images\spec_icons_normal]]
						dlabel.icon.texcoord = EncounterDetails.class_specs_coords [spec]
					
					elseif (class) then
						dlabel.icon.texture = [[Interface\AddOns\Details\images\classes_small_alpha]]
						dlabel.icon.texcoord = _detalhes.class_coords [class]
						
					else
						dlabel.icon.texture = [[Interface\LFGFRAME\LFGROLE_BW]]
						dlabel.icon:SetTexCoord (.25, .5, 0, 1)
					end
					
					dlabel.lefttext:Show()
					dlabel.righttext:Show()
					dlabel.icon:Show()
					dlabel.bg:Show()
				end
				
				local damage_players = #players
				self.damage_actors = players
				
				--heal
				local players = {}
				for player_name, heal in pairs (combat.PhaseData.heal [self.phase]) do
					tinsert (players, {player_name, heal})
				end
				table.sort (players, _detalhes.Sort2)
				
				for i, player in ipairs (players) do
					local hlabel = phase_panel:GetHealLabel (i)
					hlabel.lefttext.text = EncounterDetails:GetOnlyName (player [1])
					hlabel.righttext.text = _detalhes:ToK (_math_floor (player [2]))
					
					local classe = _detalhes:GetClass (player [1])
					if (classe) then	
						hlabel.icon:SetTexture ([[Interface\AddOns\Details\images\classes_small_alpha]])
						hlabel.icon:SetTexCoord (unpack (_detalhes.class_coords [classe]))
					else
						hlabel.icon:SetTexture ([[Interface\LFGFRAME\LFGROLE_BW]])
						hlabel.icon:SetTexCoord (.25, .5, 0, 1)
					end
					
					hlabel.lefttext:Show()
					hlabel.righttext:Show()
					hlabel.icon:Show()
					hlabel.bg:Show()
				end

				local heal_players = #players
				self.heal_actors = players
				
				--show the panel
				phase_panel:SetHeight ((math.max (damage_players, heal_players) * 16) + 60)
				phase_panel:SetPoint ("bottom", self, "top", 0, 10)
				phase_panel:Show()
				
				phase_panel.phase_label.text = "|cFFffb400Phase|r: " .. self.phase

				local m, s = _math_floor (self.elapsed / 60), _math_floor (self.elapsed % 60)
				phase_panel.time_label.text = "|cFFffb400Elapsed|r: " .. m .. "m " .. s .. "s"

			end
			
		end
		local phase_on_leave = function (self)
			table.wipe (self.damage_actors)
			table.wipe (self.heal_actors)
			
			for _, f in ipairs (g.PhaseTextures) do
				f.texture:SetBlendMode ("BLEND")
				f.texture:SetVertexColor (unpack (f.texture.original_color))
			end
			
			hide_sparks()
			phase_panel:Hide()
		end
		
		local phase_on_click = function (self, button)
			if (button == "LeftButton") then
			
				local result = {}
				local reportFunc = function (IsCurrent, IsReverse, AmtLines)
					AmtLines = AmtLines + 1
					if (#result > AmtLines) then
						for i = #result, AmtLines+1, -1 do
							tremove (result, i)
						end
					end
					EncounterDetails:SendReportLines (result)
				end
				
				--need to build here because the mouse will leave the block to click in the send button
				tinsert (result, "Details!: Damage for Phase " .. self.phase .. " of " .. (g.combat and g.combat.is_boss and g.combat.is_boss.name or "Unknown") .. ":")
				for i = 1, #self.damage_actors do
					tinsert (result, EncounterDetails:GetOnlyName (self.damage_actors[i][1]) .. ": " .. _detalhes:ToK (_math_floor (self.damage_actors [i][2])))
				end
				EncounterDetails:SendReportWindow (reportFunc, nil, nil, true)
				
			elseif (button == "RightButton") then
				
				local result = {}
				local reportFunc = function (IsCurrent, IsReverse, AmtLines)
					AmtLines = AmtLines + 1
					if (#result > AmtLines) then
						for i = #result, AmtLines+1, -1 do
							tremove (result, i)
						end
					end
					EncounterDetails:SendReportLines (result)
				end
				
				tinsert (result, "Details!: Healing for Phase " .. self.phase .. " of " .. (g.combat and g.combat.is_boss and g.combat.is_boss.name or "Unknown") .. ":")
				for i = 1, #self.heal_actors do
					tinsert (result, EncounterDetails:GetOnlyName (self.heal_actors[i][1]) .. ": " .. _detalhes:ToK (_math_floor (self.heal_actors [i][2])))
				end
				EncounterDetails:SendReportWindow (reportFunc, nil, nil, true)
				
			end
		end
		
		function g:GetPhaseTexture (index, phase)
		
			local texture = g.PhaseTextures [index]
			
			if (not texture) then
				local f = CreateFrame ("frame", "EncounterDetailsPhaseTexture" .. index, g)
				f:SetHeight (16)
				
				local t = f:CreateTexture (nil, "artwork")
				t:SetAllPoints()
				t:SetColorTexture (1, 1, 1, phase_alpha)
				t.original_color = {1, 1, 1}
				f.texture = t

				f:SetScript ("OnEnter", phase_on_enter)
				f:SetScript ("OnLeave", phase_on_leave)
				f:SetScript ("OnMouseUp", phase_on_click)
				
				texture = f
				tinsert (g.PhaseTextures, f)
			end
			
			texture:ClearAllPoints()
			
			phase = math.min (phase, 5)
			if (not phase_colors [phase]) then
				_detalhes:Msg ("Phase out of range:", phase)
				phase = math.max (phase, 1)
			end

			texture.texture:SetVertexColor (unpack (phase_colors [phase]))
			local oc = texture.texture.original_color
			oc[1], oc[2], oc[3] = unpack (phase_colors [phase])
			
			texture:Show()
			
			return texture
		end
		
		function g:ClearPhaseTexture()
			for i, texture in pairs (g.PhaseTextures) do
				texture:Hide()
			end
		end
		
		function g:ChangeColorOnDataSeries (index, color)
			self.Data [index].Color = color
			self.NeedsUpdate=true
		end
		
		function g:AddDataSeriesOnFirstIndex (points, color, n2)
			local data
			--Make sure there is data points
			if not points then
				return
			end

			data=points
			if n2==nil then
				n2=false
			end
			if n2 or (table.getn(points)==2 and table.getn(points[1])~=2) then
				data={}
				for k,v in ipairs(points[1]) do
					tinsert(data,{v,points[2][k]})
				end
			end
			
			table.insert (self.Data, 1, {Points=data;Color=color})
			
			self.NeedsUpdate=true
		end

		DetailsFrameWork:NewLabel (EncounterDetails.Frame, EncounterDetails.Frame, nil, "timeamt0", "00:00", "GameFontHighlightSmall")
		EncounterDetails.Frame["timeamt0"]:SetPoint ("TOPLEFT", EncounterDetails.Frame, "TOPLEFT", 85, -300)
		
		for i = 1, 8, 1 do
		
			local line = g:CreateTexture (nil, "overlay")
			line:SetColorTexture (.5, .5, .5, .7)
			line:SetWidth (670)
			line:SetHeight (1)
			line:SetVertexColor (.4, .4, .4, .8)
		
			DetailsFrameWork:NewLabel (EncounterDetails.Frame, EncounterDetails.Frame, nil, "dpsamt"..i, "", "GameFontHighlightSmall")
			EncounterDetails.Frame["dpsamt"..i]:SetPoint ("TOPLEFT", EncounterDetails.Frame, "TOPLEFT", 27, -61 + (-(24.6*i)))
			line:SetPoint ("topleft", EncounterDetails.Frame["dpsamt"..i].widget, "bottom", -27, 0)

			DetailsFrameWork:NewLabel (EncounterDetails.Frame, EncounterDetails.Frame, nil, "timeamt"..i, "", "GameFontHighlightSmall")
			EncounterDetails.Frame["timeamt"..i].widget:SetPoint ("TOPLEFT", EncounterDetails.Frame, "TOPLEFT", 75+(73*i), -300)
		end
		
		g.max_time = 0
		g.max_damage = 0
		
		EncounterDetails.MaxGraphics = EncounterDetails.MaxGraphics or 5
		
		for i = 1, EncounterDetails.MaxGraphics do 
			local texture = g:CreateTexture (nil, "overlay")
			texture:SetWidth (9)
			texture:SetHeight (9)
			texture:SetPoint ("TOPLEFT", EncounterDetails.Frame, "TOPLEFT", (i*65) + 299, -81)
			texture:SetColorTexture (unpack (grafico_cores[i]))
			local text = g:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
			text:SetPoint ("LEFT", texture, "right", 2, 0)
			text:SetJustifyH ("LEFT")
			if (i == 1) then
				text:SetText (Loc ["STRING_CURRENT"])
			else
				text:SetText (Loc ["STRING_TRY"] .. " #" .. i)
			end
			--texture:Hide()
			g.TryIndicator [#g.TryIndicator+1] = {texture = texture, text = text}
		end
		
		local v = g:CreateTexture (nil, "overlay")
		v:SetWidth (1)
		v:SetHeight (238)
		v:SetPoint ("top", g, "top", 0, 1)
		v:SetPoint ("left", g, "left", 55, 0)
		v:SetColorTexture (1, 1, 1, 1)
		
		local h = g:CreateTexture (nil, "overlay")
		h:SetWidth (668)
		h:SetHeight (2)
		h:SetPoint ("top", g, "top", 0, -217)
		h:SetPoint ("left", g, "left")
		h:SetColorTexture (1, 1, 1, 1)
	end
	
	local BossFrame = EncounterDetails.Frame
	
	local DetailsFrameWork = _detalhes.gump

	BossFrame:SetFrameStrata ("HIGH")
	BossFrame:SetToplevel (true)
	
	-- ~size
	BossFrame:SetWidth (698)
	BossFrame:SetHeight (354)
	
	
	BossFrame:EnableMouse (true)
	BossFrame:SetResizable (false)
	BossFrame:SetMovable (true)
	
	BossFrame:SetScript ("OnMouseDown", 
					function (self, botao)
						if (botao == "LeftButton") then
							self:StartMoving()
							self.isMoving = true
						elseif (botao == "RightButton" and not self.isMoving) then
							EncounterDetails:CloseWindow()
						end
					end)
					
	BossFrame:SetScript ("OnMouseUp", 
					function (self)
						if (self.isMoving) then
							self:StopMovingOrSizing()
							self.isMoving = false
						end
					end)
	
	BossFrame:SetPoint ("CENTER", UIParent)
	
	--> icone da classe no canto esquerdo superior
	BossFrame.boss_icone = BossFrame:CreateTexture (nil, "BACKGROUND")
	BossFrame.boss_icone:SetPoint ("TOPLEFT", BossFrame, "TOPLEFT", 4, 0)
	BossFrame.boss_icone:SetWidth (64)
	BossFrame.boss_icone:SetHeight (64)
	
	--> imagem de fundo
	BossFrame.raidbackground = BossFrame:CreateTexture (nil, "BORDER")
	BossFrame.raidbackground:SetPoint ("TOPLEFT", BossFrame, "TOPLEFT", 244, -74)
	BossFrame.raidbackground:SetDrawLayer ("BORDER", 2)
	BossFrame.raidbackground:SetWidth (445)
	BossFrame.raidbackground:SetHeight (240)
	BossFrame.raidbackground:SetAlpha (0.4)
	
	--> background completo
	BossFrame.bg = BossFrame:CreateTexture (nil, "BORDER")
	BossFrame.bg:SetPoint ("TOPLEFT", BossFrame, "TOPLEFT", 0, 0)
	BossFrame.bg:SetWidth (1024)
	BossFrame.bg:SetHeight (512)
	BossFrame.bg:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_bg_graphic") 
	BossFrame.bg:SetDrawLayer ("BORDER", 1)
	
	BossFrame.bg_filler = BossFrame:CreateTexture (nil, "BORDER")
	BossFrame.bg_filler:SetPoint ("TOPLEFT", BossFrame, "TOPLEFT", 20, -74)
	BossFrame.bg_filler:SetSize (670, 239)
	BossFrame.bg_filler:SetDrawLayer ("BORDER", 0)
	BossFrame.bg_filler:SetTexture ([[Interface\FrameGeneral\UI-Background-Marble]], true)
	BossFrame.bg_filler:SetVertTile (true)
	BossFrame.bg_filler:SetHorizTile (true)

	BossFrame.bg_main = BossFrame:CreateTexture (nil, "BORDER")
	BossFrame.bg_main:SetPoint ("TOPLEFT", BossFrame, "TOPLEFT", 0, 0)
	BossFrame.bg_main:SetWidth (700)
	BossFrame.bg_main:SetHeight (512)
	BossFrame.bg_main:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_bg")
	BossFrame.bg_main:SetTexCoord (0, 700/1024, 0, 1)
	BossFrame.bg_main:SetDrawLayer ("BORDER", 3)
	BossFrame.bg_main:Show()
	
	BossFrame.Widgets = {}
	
	BossFrame.ShowType = "main"

	--> revisar
	BossFrame.Reset = function()
		BossFrame.switch (nil, nil, "main")
		if (_G.DetailsRaidDpsGraph) then 
			_G.DetailsRaidDpsGraph:ResetData()
		end
		if (BossFrame.aberta) then
			_detalhes:FecharEncounterWindows()
		end
		BossFrame.linhas = nil
	end
	
	local selected
	local u
	local mode_label
	local scrollframe
	local emote_segment = 1
	local searching
	
	BossFrame.switch = function (to, _, to2)
		if (type (to) == "string") then
			to = to
		elseif (type (to2) == "string") then
			to = to2
		end
		
		BossFrame.DBMBars:Hide()
		BossFrame.BigWigsBars:Hide()
		BossFrame.label_dbm_bars:Hide()
		BossFrame.label_bw_bars:Hide()

		if (to == "main") then 
		
			local bg_texture = BossFrame.bg_main
			BossFrame.bg_main:Show()
			
			BossFrame.raidbackground:Show()

			for _, frame in _ipairs (BossFrame.Widgets) do 
				frame:Show()
			end
			
			selected:SetPoint ("center", BossFrame.buttonSwitchNormal, "center", 0, 1)
			u:SetAllPoints (BossFrame.buttonSwitchNormal)
			
			if (_G.DetailsRaidDpsGraph) then 
				_G.DetailsRaidDpsGraph:Hide()
				for i = 1, 8, 1 do
					BossFrame["dpsamt"..i]:Hide()
					BossFrame["timeamt"..i]:Hide()
					
				end
				BossFrame["timeamt0"]:Hide()
			end
			
			--hide emote frames
			for _, widget in pairs (BossFrame.EmoteWidgets) do
				widget:Hide()
			end
			
			--hide spells frames
			for _, widget in pairs (BossFrame.EnemySpellsWidgets) do
				widget:Hide()
			end
			
			BossFrame.ShowType = "main"
			mode_label.text = "Summary"
			BossFrame.segmentosDropdown:Enable()
		
		elseif (to == "spellsauras") then 
		
			--hide boss frames
			for _, frame in _ipairs (BossFrame.Widgets) do 
				frame:Hide()
			end
			
			BossFrame.bg_main:Hide()
			BossFrame.raidbackground:Show()
			
			--hide graph
			if (_G.DetailsRaidDpsGraph) then 
				_G.DetailsRaidDpsGraph:Hide()
				for i = 1, 8, 1 do
					BossFrame["dpsamt"..i]:Hide()
					BossFrame["timeamt"..i]:Hide()
					
				end
				BossFrame["timeamt0"]:Hide()
			end
			
			--hide emote frames
			for _, widget in pairs (BossFrame.EmoteWidgets) do
				widget:Hide()
			end
			
			--show spells frames
			for _, widget in pairs (BossFrame.EnemySpellsWidgets) do
				widget:Show()
			end
			
			selected:SetPoint ("center", BossFrame.buttonSwitchSpellsAuras.widget, "center", 0, 1)
			u:SetAllPoints (BossFrame.buttonSwitchSpellsAuras.widget)
			
			BossFrame.ShowType = "spellsauras"
			mode_label.text = "Spells and Auras"
			
			-- show spells box
			local actor = EncounterDetails.build_actor_menu() [1]
			actor = actor and actor.value
			if (actor) then
				_G [BossFrame:GetName() .. "EnemyActorSpellsDropdown"].MyObject:Select (actor)
				EncounterDetails.update_enemy_spells (actor)
			end
			
			BossFrame.segmentosDropdown:Enable()
			
			BossFrame.DBMBars:Show()
			BossFrame.BigWigsBars:Show()
			BossFrame.label_dbm_bars:Show()
			BossFrame.label_bw_bars:Show()
			
			BossFrame.DBMBars:Refresh()
			BossFrame.BigWigsBars:Refresh()
		
		elseif (to == "emotes") then 

			--hide boss frames
			for _, frame in _ipairs (BossFrame.Widgets) do 
				frame:Hide()
			end
			
			BossFrame.bg_main:Hide()
			BossFrame.raidbackground:Show()
			
			--hide graph
			if (_G.DetailsRaidDpsGraph) then 
				_G.DetailsRaidDpsGraph:Hide()
				for i = 1, 8, 1 do
					BossFrame["dpsamt"..i]:Hide()
					BossFrame["timeamt"..i]:Hide()
					
				end
				BossFrame["timeamt0"]:Hide()
			end
			--show emote frames
			for _, widget in pairs (BossFrame.EmoteWidgets) do
				widget:Show()
			end
			
			--hide spells frames
			for _, widget in pairs (BossFrame.EnemySpellsWidgets) do
				widget:Hide()
			end			
		
			selected:SetPoint ("center", BossFrame.buttonSwitchBossEmotes.widget, "center", 0, 1)
			u:SetAllPoints (BossFrame.buttonSwitchBossEmotes.widget)
		
			BossFrame.ShowType = "emotes"
			mode_label.text = "Boss Emotes"
			
			scrollframe:Update()
			BossFrame.EmotesSegment:Refresh()
			BossFrame.EmotesSegment:Select (emote_segment)
			
			BossFrame.segmentosDropdown:Disable()
		
		elseif (to == "graph") then 
			
			EncounterDetails:BuildDpsGraphic()
			if (not _G.DetailsRaidDpsGraph) then
				return
			end
			
			BossFrame.bg_main:Hide()
			BossFrame.raidbackground:Hide()
 
			for _, frame in _ipairs (BossFrame.Widgets) do 
				frame:Hide()
			end
			
			selected:SetPoint ("center", BossFrame.buttonSwitchGraphic, "center", 0, 1)
			u:SetAllPoints (BossFrame.buttonSwitchGraphic)
			
			_G.DetailsRaidDpsGraph:Show()
			
			for i = 1, 8, 1 do
				BossFrame["dpsamt"..i].widget:Show()
				BossFrame["timeamt"..i].widget:Show()
			end
			BossFrame["timeamt0"].widget:Show()
			
			BossFrame.ShowType = "graph"
			mode_label.text = "Damage Graphic"
			
			--hide emote frames
			for _, widget in pairs (BossFrame.EmoteWidgets) do
				widget:Hide()
			end
			
			--hide spells frames
			for _, widget in pairs (BossFrame.EnemySpellsWidgets) do
				widget:Hide()
			end			
			
			BossFrame.segmentosDropdown:Enable()
		end
	end

	-- ~button
	--summary
	BossFrame.buttonSwitchNormal = DetailsFrameWork:NewDetailsButton (BossFrame, BossFrame, _, BossFrame.switch, "main", nil, 26, 33)
	BossFrame.buttonSwitchNormal:SetPoint ("bottomright", BossFrame, "bottomright", -270, 5)
	local t = BossFrame.buttonSwitchNormal:CreateTexture (nil, "artwork")
	t:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons")
	t:SetTexCoord (0, 0.1015625, 0, 0.515625)
	t:SetWidth (26)
	t:SetHeight (33)
	t:SetAllPoints (BossFrame.buttonSwitchNormal)
	--chart
	BossFrame.buttonSwitchGraphic = DetailsFrameWork:NewDetailsButton (BossFrame, BossFrame, _, BossFrame.switch, "graph", nil, 26, 33)
	BossFrame.buttonSwitchGraphic:SetPoint ("left", BossFrame.buttonSwitchNormal, "right", 0, 0)
	local g = BossFrame.buttonSwitchGraphic:CreateTexture (nil, "artwork")
	g:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons")
	g:SetTexCoord (0.1171875, 0.21875, 0, 0.515625)	
	g:SetWidth (26)
	g:SetHeight (33)
	g:SetAllPoints (BossFrame.buttonSwitchGraphic)
	--emotes
	BossFrame.buttonSwitchBossEmotes = DetailsFrameWork:NewButton (BossFrame, nil, "EncounterDetailsBossEmoteButton", nil, 26, 33, BossFrame.switch, "emotes")
	BossFrame.buttonSwitchBossEmotes:SetPoint ("left", BossFrame.buttonSwitchGraphic, "right", 0, 0)
	local e = BossFrame.buttonSwitchBossEmotes:CreateTexture (nil, "artwork")
	e:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons")
	e:SetTexCoord (90/256, 116/256, 0, 0.515625)
	e:SetWidth (26)
	e:SetHeight (33)
	e:SetAllPoints (BossFrame.buttonSwitchBossEmotes.widget)
	--spells e auras
	BossFrame.buttonSwitchSpellsAuras = DetailsFrameWork:NewButton (BossFrame, nil, "EncounterDetailsBossSpellAuraButton", nil, 26, 33, BossFrame.switch, "spellsauras")
	BossFrame.buttonSwitchSpellsAuras:SetPoint ("left", BossFrame.buttonSwitchBossEmotes, "right", 0, 0)
	local aa = BossFrame.buttonSwitchSpellsAuras:CreateTexture (nil, "artwork")
	aa:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons")
	aa:SetTexCoord (120/256, 146/256, 0, 0.515625)
	aa:SetWidth (26)
	aa:SetHeight (33)
	aa:SetAllPoints()
	
	--> tutorial frame
	function EncounterDetails:ButtonsTutorial()
	
		local tutorial_frame = CreateFrame ("frame", nil, BossFrame)
		tutorial_frame:SetFrameStrata ("FULLSCREEN")
		tutorial_frame:SetPoint ("topleft", t, "topleft")
		tutorial_frame:SetPoint ("bottomright", aa, "bottomright")
	
		local plugin_icon_alert = CreateFrame ("frame", "EncounterDetailsPopUp2", tutorial_frame, "DetailsHelpBoxTemplate")
		plugin_icon_alert.ArrowUP:Show()
		plugin_icon_alert.ArrowGlowUP:Show()
		plugin_icon_alert.Text:SetText ("Select here, the module you want to see:")
		plugin_icon_alert:SetPoint ("bottom", tutorial_frame, "top", 0, 30)
		plugin_icon_alert:Show()

	end
	
	u = BossFrame.buttonSwitchGraphic:CreateTexture (nil, "overlay")
	u:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons")
	u:SetTexCoord (0.8984375, 1, 0, 0.515625)
	u:SetWidth (26)
	u:SetHeight (33)
	u:SetAllPoints (BossFrame.buttonSwitchNormal)
	
	selected = BossFrame.buttonSwitchGraphic:CreateTexture (nil, "overlay")
	selected:SetColorTexture (1, 1, 1, .1)
	selected:SetWidth (22)
	selected:SetHeight (28)
	selected:SetPoint ("center", BossFrame.buttonSwitchNormal, "center", 0, 0)
	
	--mode label
	local support_frame = CreateFrame ("frame", nil, BossFrame)
	support_frame:SetPoint ("topleft", BossFrame.buttonSwitchSpellsAuras.widget, "topright", 0, -1)
	support_frame:SetPoint ("bottomright", BossFrame, "bottomright", -9, 6)
	support_frame:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})	
	support_frame:SetBackdropColor (1, 1, 1, 0.3)
	
	mode_label = DetailsFrameWork:CreateLabel (support_frame, "Summary", 13, color, "GameFontNormal")
	mode_label:SetPoint ("center", support_frame, "center")
	
	local left = support_frame:CreateTexture (nil, "overlay")
	left:SetTexture ([[Interface\TALENTFRAME\talent-main]])
	left:SetTexCoord (0.13671875, 0.25, 0.486328125, 0.576171875)
	left:SetPoint ("left", support_frame, 0, 0)
	left:SetWidth (10)
	left:SetHeight (support_frame:GetHeight())
	
	local right = support_frame:CreateTexture (nil, "overlay")
	right:SetTexture ([[Interface\TALENTFRAME\talent-main]])
	right:SetTexCoord (0.01953125, 0.13671875, 0.486328125, 0.576171875)
	right:SetPoint ("right", support_frame, 0, 0)	
	right:SetWidth (10)
	right:SetHeight (support_frame:GetHeight())
	
	--tooltips
	BossFrame.buttonSwitchNormal.MouseOnEnterHook = function()  
		GameCooltip:Reset()
		GameCooltip:AddLine (Loc ["STRING_FIGHT_SUMMARY"], nil, nil, "orange", nil, 12)
		GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
		GameCooltip:ShowCooltip (BossFrame.buttonSwitchNormal, "tooltip")
		t:SetBlendMode ("ADD")
	end
	BossFrame.buttonSwitchNormal.MouseOnLeaveHook = function() _detalhes.popup:ShowMe (false); t:SetBlendMode ("BLEND") end
	--
	BossFrame.buttonSwitchGraphic.MouseOnEnterHook = function() 
		GameCooltip:Reset()
		GameCooltip:AddLine (Loc ["STRING_FIGHT_GRAPHIC"], nil, nil, "orange", nil, 12)
		GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
		GameCooltip:ShowCooltip (BossFrame.buttonSwitchGraphic, "tooltip")
		g:SetBlendMode ("ADD")
	end
	BossFrame.buttonSwitchGraphic.MouseOnLeaveHook = function() _detalhes.popup:ShowMe (false); g:SetBlendMode ("BLEND") end	
	--
	BossFrame.buttonSwitchBossEmotes:SetHook ("OnEnter", function() 
		GameCooltip:Reset()
		GameCooltip:AddLine (Loc ["STRING_FIGHT_EMOTES"], nil, nil, "orange", nil, 12)
		GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
		GameCooltip:ShowCooltip (BossFrame.buttonSwitchBossEmotes, "tooltip")
		e:SetBlendMode ("ADD")
	end)
	BossFrame.buttonSwitchBossEmotes:SetHook ("OnLeave", function() 
		_detalhes.popup:ShowMe (false);
		e:SetBlendMode ("BLEND") 
	end)
	--
	BossFrame.buttonSwitchSpellsAuras:SetHook ("OnEnter", function() 
		GameCooltip:Reset()
		GameCooltip:AddLine (Loc ["STRING_FIGHT_SPELLS"], nil, nil, "orange", nil, 12)
		GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
		GameCooltip:ShowCooltip (BossFrame.buttonSwitchSpellsAuras, "tooltip")
		aa:SetBlendMode ("ADD")
	end)
	BossFrame.buttonSwitchSpellsAuras:SetHook ("OnLeave", function() 
		_detalhes.popup:ShowMe (false);
		aa:SetBlendMode ("BLEND") 
	end)
	
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> ~emotes
	
	local emote_lines = {}
	local emote_search_table = {}
	
	local refresh_emotes = function (self)
		--update emote scroll
		
		local offset = FauxScrollFrame_GetOffset (self)
		
		--print (EncounterDetails.charsaved, EncounterDetails.charsaved.emotes, EncounterDetails.charsaved.emotes [1], #EncounterDetails.charsaved.emotes)
		local emote_pool = EncounterDetails.charsaved.emotes [emote_segment]
		
		if (searching) then
			local i = 0
			local lower = string.lower
			for index, data in ipairs (emote_pool) do
				if (lower (data [2]):find (lower(searching))) then
					i = i + 1
					emote_search_table [i] = data
				end
				for o = #emote_search_table, i+1, -1 do
					emote_search_table [o] = nil
				end
				emote_pool = emote_search_table
			end
			BossFrame.SearchResults:Show()
			BossFrame.SearchResults:SetText ("Found " .. i .. " matches")
			
			if (i > 0) then
				BossFrame.ReportEmoteButton:Enable()
			elseif (i == 0) then
				BossFrame.ReportEmoteButton:Disable()
			end
		else
			BossFrame.SearchResults:Hide()
		end
		
		if (emote_pool) then
			for bar_index = 1, 16 do 
				local data = emote_pool [bar_index + offset]
				local bar = emote_lines [bar_index]
				
				if (data) then
					bar:Show()
					local min, sec = _math_floor (data[1] / 60), _math_floor (data[1] % 60)
					bar.lefttext:SetText (min .. "m" .. sec .. "s:")
					
					if (data [2] == "") then
						bar.righttext:SetText ("--x--x--")
					else
						bar.righttext:SetText (_cstr (data [2], data [3]))
					end
					
					local color_string = EncounterDetails.BossWhispColors [data [4]]
					local color_table = ChatTypeInfo [color_string]	
					
					bar.righttext:SetTextColor (color_table.r, color_table.g, color_table.b)
					bar.icon:SetTexture ([[Interface\CHARACTERFRAME\UI-StateIcon]])
					bar.icon:SetTexCoord (0, 0.5, 0.5, 1)
				else
					bar:Hide()
				end
			end
			
			FauxScrollFrame_Update (self, #emote_pool, 16, 15)
		else
			for bar_index = 1, 16 do 
				local bar = emote_lines [bar_index]
				bar:Hide()
			end
		end
	end
	
	BossFrame.EmoteWidgets = {}
	
	local bar_div_emotes = DetailsFrameWork:CreateImage (BossFrame, "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_bg", 4, 240, "artwork", {724/1024, 728/1024, 0, 245/512})
	bar_div_emotes:SetPoint ("TOPLEFT", BossFrame, "TOPLEFT", 244, -74)
	bar_div_emotes:Hide()
	tinsert (BossFrame.EmoteWidgets, bar_div_emotes)
	
	scrollframe = CreateFrame ("ScrollFrame", "EncounterDetails_EmoteScroll", BossFrame, "FauxScrollFrameTemplate")
	scrollframe:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (self, offset, 14, refresh_emotes) end)
	scrollframe:SetPoint ("topleft", BossFrame, "topleft", 249, -75)
	scrollframe:SetPoint ("bottomright", BossFrame, "bottomright", -33, 42)
	scrollframe.Update = refresh_emotes
	scrollframe:Hide()
	--
	tinsert (BossFrame.EmoteWidgets, scrollframe)

	local row_on_enter = function (self)
		self:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})
		self:SetBackdropColor (1, 1, 1, .6)
		if (self.righttext:IsTruncated()) then
			GameCooltip:Reset()
			GameCooltip:AddLine (self.righttext:GetText())
			GameCooltip:SetOwner (self, "bottomleft", "topleft", 42, -9)
			GameCooltip:Show()
		end
	end
	local row_on_leave = function (self)
		self:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})	
		self:SetBackdropColor (1, 1, 1, .3)
		GameCooltip:Hide()
	end
	
	local row_on_mouse_up = function (self)
		--report
		local text = self.righttext:GetText()
		local time = self.lefttext:GetText()
		
		local reportFunc = function()
			-- remove textures
			text = text:gsub ("(|T).*(|t)", "")
			-- remove colors
			text = text:gsub ("|c%x?%x?%x?%x?%x?%x?%x?%x?", "")
			text = text:gsub ("|r", "")
			-- replace links
			for _, spellid in text:gmatch ("(|Hspell:)(.-)(|h)") do
				local spell = tonumber (spellid)
				local link = GetSpellLink (spell)
				text = text:gsub ("(|Hspell).*(|h)", link)
			end
			-- remove unit links
			text = text:gsub ("(|Hunit).-(|h)", "")
			-- remove the left space
			text = text:gsub ("^%s$", "")

			EncounterDetails:SendReportLines ({"Details! Encounter Emote at " .. time, "\"" .. text .. "\""})
		end
		
		EncounterDetails:SendReportWindow (reportFunc)
	end
	
	for i = 1, 16 do
		local line = CreateFrame ("frame", nil, BossFrame)
		local y = (i-1) * 15 * -1
		line:SetPoint ("topleft", scrollframe, "topleft", 0, y)
		line:SetPoint ("topright", scrollframe, "topright", 0, y)
		line:SetHeight (14)
		line:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})	
		line:SetBackdropColor (1, 1, 1, .3)
		
		line.icon = line:CreateTexture (nil, "overlay")
		line.icon:SetPoint ("left", line, "left", 2, 0)
		line.icon:SetSize (14, 14)
		
		line.lefttext = line:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		line.lefttext:SetPoint ("left", line.icon, "right", 2, 0)
		line.lefttext:SetWidth (line:GetWidth() - 22)
		line.lefttext:SetHeight (14)
		line.lefttext:SetJustifyH ("left")
		
		line.righttext = line:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		line.righttext:SetPoint ("left", line.icon, "right", 42, 0)
		line.righttext:SetWidth (line:GetWidth() - 60)
		line.righttext:SetHeight (14)
		line.righttext:SetJustifyH ("left")
		
		line:SetFrameLevel (scrollframe:GetFrameLevel()+1)
		
		line:SetScript ("OnEnter", row_on_enter)
		line:SetScript ("OnLeave", row_on_leave)
		line:SetScript ("OnMouseUp", row_on_mouse_up)
		tinsert (emote_lines, line)
		tinsert (BossFrame.EmoteWidgets, line)
		line:Hide()
	end
	
	--select emote segment
	local emotes_segment_label = DetailsFrameWork:CreateLabel (BossFrame, "Emote Segment:", 11, nil, "GameFontHighlightSmall")
	emotes_segment_label:SetPoint ("topleft", BossFrame, "topleft", 25, -85)
	
	local on_emote_Segment_select = function (_, _, segment)
		FauxScrollFrame_SetOffset (scrollframe, 0)
		emote_segment = segment
		scrollframe:Update()
	end
	
	function EncounterDetails:SetEmoteSegment (segment)
		emote_segment = segment
	end
	
	local segment_icon = [[Interface\AddOns\Details\images\icons]]
	local segment_icon_coord = {0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625}
	local segment_icon_color = {1, 1, 1, 0.5}
	
	local build_emote_segments = function()
		local t = {}
		if (not EncounterDetails.charsaved) then
			return t
		end
		for index, segment in ipairs (EncounterDetails.charsaved.emotes) do
			tinsert (t, {label = "#" .. index .. " "  .. (segment.boss or "unknown"), value = index, icon = segment_icon, texcoord = segment_icon_coord, onclick = on_emote_Segment_select, iconcolor = segment_icon_color})
		end
		return t
	end
	local dropdown = DetailsFrameWork:NewDropDown (BossFrame, _, "$parentEmotesSegmentDropdown", "EmotesSegment", 160, 20, build_emote_segments, 1)
	dropdown:SetPoint ("topleft", emotes_segment_label, "bottomleft", -1, -2)
	
	tinsert (BossFrame.EmoteWidgets, dropdown)
	tinsert (BossFrame.EmoteWidgets, emotes_segment_label)
	
	--search box
	local emotes_search_label = DetailsFrameWork:CreateLabel (BossFrame, "Search:", 11, nil, "GameFontHighlightSmall")
	emotes_search_label:SetPoint ("topleft", BossFrame, "topleft", 25, -130)
	
	local emotes_search_results_label = DetailsFrameWork:CreateLabel (BossFrame, "", 11, nil, "GameFontNormal", "SearchResults")
	emotes_search_results_label:SetPoint ("topleft", BossFrame, "topleft", 25, -180)
	--
	local search = DetailsFrameWork:NewTextEntry (BossFrame, nil, "$parentEmoteSearchBox", nil, 160, 20)
	search:SetPoint ("topleft",emotes_search_label, "bottomleft", -1, -2)
	search:SetJustifyH ("left")
	
	search:SetHook ("OnTextChanged", function() 
		searching = search:GetText()
		if (searching == "") then
			searching = nil
			FauxScrollFrame_SetOffset (scrollframe, 0)
			BossFrame.ReportEmoteButton:Disable()
			scrollframe:Update()
		else
			FauxScrollFrame_SetOffset (scrollframe, 0)
			BossFrame.ReportEmoteButton:Enable()
			scrollframe:Update()
		end
	end)

	local reset = DetailsFrameWork:NewButton (BossFrame, nil, "$parentResetSearchBoxtButton", "ResetSearchBox", 16, 16, function()
		search:SetText ("")
	end)
	
	reset:SetPoint ("left", search, "right", -1, 0)
	reset:SetNormalTexture ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]] or [[Interface\Buttons\UI-GroupLoot-Pass-Down]])
	reset:SetHighlightTexture ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]] or [[Interface\Buttons\UI-GROUPLOOT-PASS-HIGHLIGHT]])
	reset:SetPushedTexture ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]] or [[Interface\Buttons\UI-GroupLoot-Pass-Up]])
	reset:GetNormalTexture():SetDesaturated (true)
	reset.tooltip = "Reset Search"
	
	tinsert (BossFrame.EmoteWidgets, search)
	tinsert (BossFrame.EmoteWidgets, reset)
	tinsert (BossFrame.EmoteWidgets, emotes_search_label)
	
	-- report button
	local report_emote_button = DetailsFrameWork:NewButton (BossFrame, nil, "$parentReportEmoteButton", "ReportEmoteButton", 120, 20, function()
		local reportFunc = function (IsCurrent, IsReverse, AmtLines)
			local segment = EncounterDetails.charsaved.emotes and EncounterDetails.charsaved.emotes [emote_segment]

			if (segment) then
				EncounterDetails.report_lines = {"Details!: Emotes for " .. segment.boss}
				local added = 0

				for index = 1, 16 do
					local bar = emote_lines [index]
					if (bar:IsShown() and added < AmtLines) then
						local time = bar.lefttext:GetText()
						local text = bar.righttext:GetText()

						--"|Hunit:77182:Oregorger|hOregorger prepares to cast |cFFFF0000|Hspell:156879|h[Blackrock Barrage]|h|r."
						
						-- remove textures
						text = text:gsub ("(|T).*(|t)", "")
						-- remove colors
						text = text:gsub ("|c%x?%x?%x?%x?%x?%x?%x?%x?", "")
						text = text:gsub ("|r", "")
						-- replace links
						for _, spellid in text:gmatch ("(|Hspell:)(.-)(|h)") do
							local spell = tonumber (spellid)
							local link = GetSpellLink (spell)
							text = text:gsub ("(|Hspell).*(|h)", link)
						end
						-- remove unit links
						text = text:gsub ("(|Hunit).-(|h)", "")
						-- remove the left space
						text = text:gsub ("^%s$", "")

						tinsert (EncounterDetails.report_lines, time .. " " .. text)
						added = added + 1
						
						if (added == AmtLines) then
							break
						end
					end
				end
				
				EncounterDetails:SendReportLines (EncounterDetails.report_lines)
			else
				EncounterDetails:Msg ("There is nothing to report.")
			end
		end

		local use_slider = true
		EncounterDetails:SendReportWindow (reportFunc, nil, nil, use_slider)
	end, nil, nil, nil, "Report Lines")

	report_emote_button:SetIcon ([[Interface\AddOns\Details\images\report_button]], 8, 16, nil, {0, 1, 0, 1}, nil, nil, 2)
	
	report_emote_button:SetPoint ("topleft", BossFrame.SearchResults, "bottomleft", 0, -2)
	report_emote_button:InstallCustomTexture()
	report_emote_button:Disable()
	
	tinsert (BossFrame.EmoteWidgets, report_emote_button)
	
	--
	
	for _, widget in pairs (BossFrame.EmoteWidgets) do
		widget:Hide()
	end
	
	local emote_report_label = DetailsFrameWork:NewLabel (search.widget, search.widget, nil, "report_click", "|cFFffb400Left Click|r: Report Line")
	emote_report_label:SetPoint ("topleft", search.widget, "bottomleft", 1, -141)
	
	--window title
	DetailsFrameWork:NewLabel (BossFrame, BossFrame, nil, "titulo", Loc ["STRING_WINDOW_TITLE"], "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
	BossFrame.titulo:SetPoint ("center", BossFrame, "center")
	BossFrame.titulo:SetPoint ("top", BossFrame, "top", 0, -18)
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	BossFrame.EnemySpellsWidgets = {}

	--> spells and auras ~auras ~spell

	-- actor dropdown
	
	local EnemyActorSpells_label = DetailsFrameWork:CreateLabel (BossFrame, "Enemy Actor:", 11, nil, "GameFontHighlightSmall")
	EnemyActorSpells_label:SetPoint ("topleft", BossFrame, "topleft", 25, -85)

	local spell_blocks = {}
	
	local on_focus_gain = function (self)
		self:HighlightText()
	end
	
	local on_focus_lost = function (self)
		self:HighlightText (0, 0)
	end
	
	local on_enter_spell = function (self)

		GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
		GameTooltip:SetSpellByID (self.MyObject._spellid)
		GameTooltip:Show()
		
	end
	
	local on_leave_spell = function (self, capsule)
		GameTooltip:Hide()
	end
	
	local create_aura_func = function (self, button, spellid, encounter_id)
		local name, _, icon = EncounterDetails.getspellinfo (spellid)
		EncounterDetails:OpenAuraPanel (spellid, name, self and self.MyObject._icon.texture, encounter_id)
	end
	
	local info_onenter = function (self)
		local spellid = self._spellid
		
		local info = EncounterDetails.EnemySpellPool [spellid]
		if (info) then
			_detalhes:CooltipPreset (2)
			GameCooltip:SetOption ("FixedWidth", false)
			
			for token, _ in pairs (info.token) do
				GameCooltip:AddLine ("event:", token, 1, nil, "white")
			end
			
			GameCooltip:AddLine ("source:", info.source, 1, nil, "white")
			GameCooltip:AddLine ("school:", EncounterDetails:GetSpellSchoolFormatedName (info.school), 1, nil, "white")
			
			if (info.type) then
				GameCooltip:AddLine ("aura type:", info.type, 1, nil, "white")
			end
			GameCooltip:ShowCooltip (self, "tooltip")
		end
		
		self:SetBackdropColor (0.6, 0.6, 0.6, 0.5)
	end
	local info_onleave = function (self)
		GameCooltip:Hide()
		self:SetBackdropColor (0, 0, 0, 0.5)
	end
	
	for i = 1, 10 do
		local anchor_frame = CreateFrame ("frame", "BossFrameSpellAnchor" .. i, BossFrame)
	
		local icon_button_func = function (texture)
			anchor_frame.icon.texture = texture
		end
	
		local spellicon_button = DetailsFrameWork:NewButton (anchor_frame, nil, "$parentIconButton", "IconButton", 20, 20, function() DetailsFrameWork:IconPick (icon_button_func, true) end)
		local spellicon = DetailsFrameWork:NewImage (spellicon_button, [[Interface\ICONS\TEMP]], 19, 19, "background", nil, "icon", "$parentIcon")
		spellicon_button:InstallCustomTexture()
		
		local spellid = DetailsFrameWork:CreateTextEntry (anchor_frame, EncounterDetails.empty_function, 60, 20)
		spellid:SetHook ("OnEditFocusGained", on_focus_gain)
		spellid:SetHook ("OnEditFocusLost", on_focus_lost)
		spellid:SetHook ("OnEnter", on_enter_spell)
		spellid:SetHook ("OnLeave", on_leave_spell)
		
		local spellname = DetailsFrameWork:CreateTextEntry (anchor_frame, EncounterDetails.empty_function, 140, 20)
		spellname:SetHook ("OnEditFocusGained", on_focus_gain)
		spellname:SetHook ("OnEditFocusLost", on_focus_lost)
		spellname:SetHook ("OnEnter", on_enter_spell)
		spellname:SetHook ("OnLeave", on_leave_spell)
		
		spellicon_button:SetPoint ("topleft", BossFrame, "topleft", 255, -65 + (i * 21 * -1))
		spellicon:SetAllPoints()
		spellid:SetPoint ("left", spellicon_button, "right", 4, 0)
		spellname:SetPoint ("left", spellid, "right", 4, 0)
		
		local spellinfo = CreateFrame ("frame", nil, anchor_frame)
		spellinfo:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, edgeFile = [[Interface\AddOns\Details\images\border_2]], edgeSize = 12, insets = {left = 1, right = 1, top = 1, bottom = 1}})
		spellinfo:SetBackdropColor (0, 0, 0, 0.5)
		spellinfo:SetSize (60, 20)
		spellinfo:SetScript ("OnEnter", info_onenter)
		spellinfo:SetScript ("OnLeave", info_onleave)
		
		local spellinfotext = spellinfo:CreateFontString (nil, "overlay", "GameFontNormal")
		spellinfotext:SetPoint ("center", spellinfo, "center")
		spellinfotext:SetText ("info")
		spellinfo:SetPoint ("left", spellname.widget, "right", 4, 0)
		
		local create_aura = DetailsFrameWork:NewButton (anchor_frame, nil, "$parentCreateAuraButton", "AuraButton", 105, 18, create_aura_func, nil, nil, nil, "Create Aura")
		create_aura:SetPoint ("left", spellinfo, "right", 4, 0)
		create_aura:InstallCustomTexture()
		
		anchor_frame.icon = spellicon
		anchor_frame.spellid = spellid
		anchor_frame.spellname = spellname
		anchor_frame.aurabutton = create_aura
		anchor_frame.aurabutton._icon = spellicon
		anchor_frame.info = spellinfo
		
		tinsert (spell_blocks, anchor_frame)
		tinsert (BossFrame.EnemySpellsWidgets, anchor_frame)
		
		anchor_frame:Hide()
	end
	
	local last_npc_name
	
	local update_enemy_spells = function (npc_name)
		npc_name = npc_name or last_npc_name
		last_npc_name = npc_name
	
		local combat = EncounterDetails:GetCombat (EncounterDetails._segment)
		
		if (combat and npc_name) then
		
			local spell_list = {}
			
			--damage
			local npc = combat (1, npc_name)
			if (npc) then
				for spellid, spell in pairs (npc.spells._ActorTable) do
					if (spellid > 10) then
						local name, _, icon = EncounterDetails.getspellinfo (spellid)
						tinsert (spell_list, {spellid, name, icon, nil, npc.serial})
					end
				end
				
				BossFrame.aura_npc_id2.text = EncounterDetails:GetNpcIdFromGuid (npc.serial)
			end
			
			--heal
			local npc = combat (2, npc_name)
			if (npc) then
				for spellid, spell in pairs (npc.spells._ActorTable) do
					if (spellid > 10) then
						local name, _, icon = EncounterDetails.getspellinfo (spellid)
						tinsert (spell_list, {spellid, name, icon, true, npc.serial})
					end
				end
				
				BossFrame.aura_npc_id2.text = EncounterDetails:GetNpcIdFromGuid (npc.serial)
			end
			
			EncounterDetails_SpellAurasScroll.spell_pool = spell_list
			EncounterDetails_SpellAurasScroll.encounter_id = combat.is_boss and combat.is_boss.id
			EncounterDetails_SpellAurasScroll:Update()
		end
	end
	
	local refresh_spellauras = function (self)
		
		local pool = EncounterDetails_SpellAurasScroll.spell_pool
		local encounter_id = EncounterDetails_SpellAurasScroll.encounter_id
		local offset = FauxScrollFrame_GetOffset (self)
		
		for bar_index = 1, 10 do 
			local data = pool [bar_index + offset]
			local bar = spell_blocks [bar_index]
			
			if (data) then
				bar:Show()
				
				bar.icon.texture = data [3]
				bar.spellid.text = data [1]
				bar.spellname.text = data [2]
				
				bar.spellid._spellid = data [1]
				bar.spellname._spellid = data [1]
				bar.info._spellid = data [1]
				
				local is_heal = data [4]
				if (is_heal) then
					bar.spellid:SetBackdropBorderColor (0, 1, 0)
					bar.spellname:SetBackdropBorderColor (0, 1, 0)
				else
					bar.spellid:SetBackdropBorderColor (1, 1, 1)
					bar.spellname:SetBackdropBorderColor (1, 1, 1)
				end
				
				bar.aurabutton:SetClickFunction (create_aura_func, data [1], encounter_id)

			else
				bar:Hide()
			end
		end
		
		FauxScrollFrame_Update (self, #pool, 10, 20)
		
	end
	
	local spell_scrollframe = CreateFrame ("ScrollFrame", "EncounterDetails_SpellAurasScroll", BossFrame, "FauxScrollFrameTemplate")
	spell_scrollframe:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (self, offset, 14, refresh_spellauras) end)
	spell_scrollframe:SetPoint ("topleft", BossFrame, "topleft", 200, -75)
	spell_scrollframe:SetPoint ("bottomright", BossFrame, "bottomright", -33, 42)
	spell_scrollframe.Update = refresh_spellauras
	spell_scrollframe:Hide()
	
	tinsert (BossFrame.EnemySpellsWidgets, spell_scrollframe)
	
	EncounterDetails.update_enemy_spells = update_enemy_spells
	
	local on_select_actor_spell = function (self, fixedparam, option)
		last_npc_name = option
		update_enemy_spells (option)
	end
	
	local build_actor_menu = function()
		local t = {}
		local combat = EncounterDetails:GetCombat (EncounterDetails._segment)
		
		if (combat) then
			local AllDamageCharacters = combat:GetActorList (DETAILS_ATTRIBUTE_DAMAGE)
			for index, character in ipairs (AllDamageCharacters) do
				if (character:IsEnemy()) then
					tinsert (t, {label = character:name(), value = character:name(), icon = "Interface\\AddOns\\Details_EncounterDetails\\images\\icon", onclick = on_select_actor_spell, iconcolor = "silver"})
				end
			end
			return t
		else
			return t
		end
	end
	EncounterDetails.build_actor_menu = build_actor_menu

	local EnemyActorSpells = DetailsFrameWork:NewDropDown (BossFrame, _, "$parentEnemyActorSpellsDropdown", "EnemyActorSpells", 160, 20, build_actor_menu, 1)
	EnemyActorSpells:SetPoint ("topleft", EnemyActorSpells_label, "bottomleft", -1, -2)
	
	EnemyActorSpells:Hide()
	EnemyActorSpells_label:Hide()

	local bar_div = DetailsFrameWork:CreateImage (BossFrame, "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_bg", 4, 240, "artwork", {724/1024, 728/1024, 0, 245/512})
	bar_div:SetPoint ("TOPLEFT", BossFrame, "TOPLEFT", 244, -74)
	bar_div:Hide()
	
	local npc_id = DetailsFrameWork:CreateLabel (BossFrame, "NpcID:", 11, nil, "GameFontHighlightSmall")
	BossFrame.aura_npc_id = npc_id
	npc_id:SetPoint ("topleft", BossFrame, "topleft", 25, -130)
	npc_id:Hide()
	local npc_id2 = DetailsFrameWork:CreateLabel (BossFrame, "", 11, nil, "GameFontHighlightSmall")
	BossFrame.aura_npc_id2 = npc_id2
	npc_id2:SetPoint ("left", npc_id, "right", 2, 0)
	npc_id2:Hide()
	
	--
	local label_dbm_bars = DetailsFrameWork:CreateLabel (BossFrame, "DBM Bars:", 11, nil, "GameFontHighlightSmall")
	label_dbm_bars:SetPoint ("topleft", BossFrame, "topleft", 25, -160)
	local label_bw_bars = DetailsFrameWork:CreateLabel (BossFrame, "Big Wigs Bars:", 11, nil, "GameFontHighlightSmall")
	label_bw_bars:SetPoint ("topleft", BossFrame, "topleft", 25, -205)
	
	BossFrame.label_dbm_bars = label_dbm_bars
	BossFrame.label_bw_bars = label_bw_bars
	
	local on_select_dbm_bar = function (_, _, value)
		local timer_id, spellname, spellicon, encounterid, spellid = unpack (value)
		EncounterDetails:OpenAuraPanel (timer_id, spellname, spellicon, encounterid, DETAILS_WA_TRIGGER_DBM_TIMER, DETAILS_WA_AURATYPE_TEXT, {dbm_timer_id = timer_id, spellid = spellid, text = "Next " .. spellname .. " In", text_size = 72, icon = spellicon})
	end
	
	local on_select_bw_bar = function (_, _, value)
		local timer_id, spellname, spellicon, encounterid = unpack (value)
		EncounterDetails:OpenAuraPanel (timer_id, spellname, spellicon, encounterid, DETAILS_WA_TRIGGER_BW_TIMER, DETAILS_WA_AURATYPE_TEXT, {bw_timer_id = timer_id, text = "Next " .. spellname .. " In", text_size = 72, icon = spellicon})
	end
	
	local already_added = {}
	local build_dbm_bars = function()
		local t = {}
		local db = _detalhes.global_plugin_database ["DETAILS_PLUGIN_ENCOUNTER_DETAILS"]
		if (db) then
			wipe (already_added)
			local encounter_id = EncounterDetails_SpellAurasScroll.encounter_id
			
			for timer_id, timer_table in pairs (db.encounter_timers_dbm) do
				if (timer_table.id == encounter_id) then
					local spellId = timer_table [7]
					local spellIcon = timer_table [5]
					local spellName
				
					local spell = timer_id
					spell = spell:gsub ("ej", "")
					spell = tonumber (spell)
					
					if (spell and not already_added [spell]) then
						if (spell > 30000) then
							local spellname, _, spellicon = _GetSpellInfo (spell)
							tinsert (t, {label = spellname, value = {timer_table [2], spellname, spellIcon or spellicon, timer_table.id, timer_table [7]}, icon = spellIcon or spellicon, onclick = on_select_dbm_bar})
						else
							local title, description, depth, abilityIcon, displayInfo, siblingID, nextSectionID, filteredByDifficulty, link, startsOpen, flag1, flag2, flag3, flag4 = EJ_GetSectionInfo (spell)
							tinsert (t, {label = title, value = {timer_table [2], title, spellIcon or abilityIcon, timer_table.id, timer_table [7]}, icon = spellIcon or abilityIcon, onclick = on_select_dbm_bar})
						end
						already_added [spell] = true
					end
				end
			end
		end
		return t
	end
	
	local build_bigwigs_bars = function()
		local t = {}
		local db = _detalhes.global_plugin_database ["DETAILS_PLUGIN_ENCOUNTER_DETAILS"]
		if (db) then
			wipe (already_added)
			local encounter_id = EncounterDetails_SpellAurasScroll.encounter_id
			
			for timer_id, timer_table in pairs (db.encounter_timers_bw) do
				if (timer_table.id == encounter_id) then
					local spell = timer_id
					if (spell and not already_added [spell]) then	
						local int_spell = tonumber (spell)
						if (not int_spell) then
							local spellname = timer_table [2]:gsub (" %(.%)", "")
							tinsert (t, {label = spellname, value = {timer_table [2], spellname, timer_table [5], timer_table.id}, icon = timer_table [5], onclick = on_select_bw_bar})
						elseif (int_spell < 0) then
							local title, description, depth, abilityIcon, displayInfo, siblingID, nextSectionID, filteredByDifficulty, link, startsOpen, flag1, flag2, flag3, flag4 = EJ_GetSectionInfo (abs (int_spell))
							tinsert (t, {label = title, value = {timer_table [2], title, timer_table [5] or abilityIcon, timer_table.id}, icon = timer_table [5] or abilityIcon, onclick = on_select_bw_bar})
						else
							local spellname, _, spellicon = _GetSpellInfo (int_spell)
							tinsert (t, {label = spellname, value = {timer_table [2], spellname, timer_table [5] or spellicon, timer_table.id}, icon = timer_table [5] or spellicon, onclick = on_select_bw_bar})
						end
						
						already_added [spell] = true
					end
				end
			end
		end
		return t
	end

	local dropdown_dbm_bars = DetailsFrameWork:NewDropDown (BossFrame, _, "$parentDBMBarsDropdown", "DBMBars", 160, 20, build_dbm_bars, 1)
	dropdown_dbm_bars:SetPoint ("topleft", label_dbm_bars, "bottomleft", -1, -2)
	
	local dropdown_bw_bars = DetailsFrameWork:NewDropDown (BossFrame, _, "$parentBigWigsBarsDropdown", "BigWigsBars", 160, 20, build_bigwigs_bars, 1)
	dropdown_bw_bars:SetPoint ("topleft", label_bw_bars, "bottomleft", -1, -2)
	
	dropdown_dbm_bars:Hide()
	dropdown_bw_bars:Hide()
	label_dbm_bars:Hide()
	label_bw_bars:Hide()
	
	--
	
	tinsert (BossFrame.EnemySpellsWidgets, EnemyActorSpells_label)
	tinsert (BossFrame.EnemySpellsWidgets, EnemyActorSpells)
	tinsert (BossFrame.EnemySpellsWidgets, bar_div)
	tinsert (BossFrame.EnemySpellsWidgets, npc_id)
	tinsert (BossFrame.EnemySpellsWidgets, npc_id2)
	

	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	local frame = BossFrame
	
	local mouse_down = function()
					frame:StartMoving()
					frame.isMoving = true
				end
				
	local mouse_up = function()
					if (frame.isMoving) then
						frame:StopMovingOrSizing()
						frame.isMoving = false
					end
				end
	
	
	
	local backdrop = {edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, edgeSize = 1, insets = {left = 1, right = 1, top = 0, bottom = 1}}
	
	--> Nome do Encontro
		DetailsFrameWork:NewLabel (frame, frame, nil, "boss_name", "Unknown Encounter", "QuestFont_Large")
		frame.boss_name:SetPoint ("TOPLEFT", frame, "TOPLEFT", 100, -51)

	--> Nome da Raid
		DetailsFrameWork:NewLabel (frame, frame, nil, "raid_name", "Unknown Raid", "GameFontHighlightSmall")
		frame.raid_name:SetPoint ("CENTER", frame.boss_name, "CENTER", 0, 14)

	--> Selecionar o segmento
	
		local buildSegmentosMenu = function (self)
			local historico = _detalhes.tabela_historico.tabelas
			local return_table = {}
			
			for index, combate in ipairs (historico) do 
				if (combate.is_boss and combate.is_boss.index) then
					local l, r, t, b, icon = _detalhes:GetBossIcon (combate.is_boss.mapid, combate.is_boss.index)
					return_table [#return_table+1] = {value = index, label = "#" .. index .. " " .. combate.is_boss.name, icon = icon, texcoord = {l, r, t, b}, onclick = EncounterDetails.OpenAndRefresh}
				end
			end
			
			return return_table
		end
		
		local segmentos_string = DetailsFrameWork:NewLabel (frame, nil, nil, "segmentosString", "Segment:", "GameFontNormal", 12)
		segmentos_string:SetPoint ("bottomleft", frame, "bottomleft", 20, 16)
		
		local segmentos = DetailsFrameWork:NewDropDown (frame, _, "$parentSegmentsDropdown", "segmentosDropdown", 160, 18, buildSegmentosMenu, nil)	
		segmentos:SetPoint ("left", segmentos_string, "right", 2, 0)
		
	
		local options = DetailsFrameWork:NewButton (frame, nil, "$parentOptionsButton", "OptionsButton", 86, 16, EncounterDetails.OpenOptionsPanel, nil, nil, nil, "Options")
		options:SetPoint ("left", segmentos, "right", 7, -1)
		options:SetTextColor (1, 0.93, 0.74)
		options:SetIcon ([[Interface\Buttons\UI-OptionsButton]], 14, 14, nil, {0, 1, 0, 1}, nil, 3)
	
	--> Caixa do Dano total tomado pela Raid
	
		local container_damagetaken_window = CreateFrame ("ScrollFrame", "Details_Boss_ContainerDamageTaken", frame)
		local container_damagetaken_frame = CreateFrame ("Frame", "Details_Boss_FrameDamageTaken", container_damagetaken_window)
		
		frame.Widgets [#frame.Widgets+1] = container_damagetaken_window
		
		container_damagetaken_frame:SetScript ("OnMouseDown", mouse_down)
		container_damagetaken_frame:SetScript ("OnMouseUp", mouse_up)
		
		container_damagetaken_frame.barras = {}

		--label titulo & background		
		local dano_recebido_bg = CreateFrame ("Frame", nil, frame)
		dano_recebido_bg:SetWidth (200)
		dano_recebido_bg:SetHeight (16)
		dano_recebido_bg:EnableMouse (true)
		dano_recebido_bg:SetResizable (false)
		dano_recebido_bg:SetPoint ("topleft", frame, "topleft", 20, -76)
		
		frame.Widgets [#frame.Widgets+1] = dano_recebido_bg
		
		dano_recebido_bg.textura = dano_recebido_bg:CreateTexture (nil, "overlay")
		dano_recebido_bg.textura:SetPoint ("topleft", dano_recebido_bg, "topleft", 0, 2)
		dano_recebido_bg.textura:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_bg")
		dano_recebido_bg.textura:SetTexCoord (19/1024, 217/1024, 74/512, 90/512)
		dano_recebido_bg.textura:SetSize (198, 16)
		dano_recebido_bg.textura:SetBlendMode ("ADD")
		dano_recebido_bg.textura:Hide()
		
		dano_recebido_bg:SetScript ("OnEnter", function(self) self.textura:Show() end)
		dano_recebido_bg:SetScript ("OnLeave", function(self) self.textura:Hide() end)
		
		DetailsFrameWork:NewLabel (dano_recebido_bg, dano_recebido_bg, nil, "damagetaken_title", Loc ["STRING_DAMAGE_AT"], "GameFontHighlightSmall")
		dano_recebido_bg.damagetaken_title:SetPoint ("BOTTOMLEFT", container_damagetaken_window, "TOPLEFT", 5, 3)
		
		--container_damagetaken_window:SetBackdrop({edgeFile = "Interface\\DialogFrame\\UI-DialogBox-gold-Border", tile = true, tileSize = 16, edgeSize = 5, insets = {left = 1, right = 1, top = 0, bottom = 1},})		
		--container_damagetaken_window:SetBackdropBorderColor (0,0,0,0)
		
		container_damagetaken_frame:SetBackdrop (backdrop)
		container_damagetaken_frame:SetBackdropBorderColor (0,0,0,0)
		container_damagetaken_frame:SetBackdropColor (0, 0, 0, 0.6)
		
		container_damagetaken_frame:SetAllPoints (container_damagetaken_window)
		container_damagetaken_frame:SetWidth (200)
		container_damagetaken_frame:SetHeight (100)
		container_damagetaken_frame:EnableMouse (true)
		container_damagetaken_frame:SetResizable (false)
		container_damagetaken_frame:SetMovable (true)
		
		container_damagetaken_window:SetWidth (200)
		container_damagetaken_window:SetHeight (100)
		container_damagetaken_window:SetScrollChild (container_damagetaken_frame)
		container_damagetaken_window:SetPoint ("TOPLEFT", frame, "TOPLEFT", 20, -90)

		DetailsFrameWork:NewScrollBar (container_damagetaken_window, container_damagetaken_frame, 4, -2)
		container_damagetaken_window.slider:Altura (89)
		container_damagetaken_window.slider:cimaPoint (0, 1)
		container_damagetaken_window.slider:baixoPoint (0, -1)
		container_damagetaken_frame.slider = container_damagetaken_window.slider
		
		container_damagetaken_window.gump = container_damagetaken_frame
		container_damagetaken_frame.window = container_damagetaken_window
		container_damagetaken_window.ultimo = 0
		frame.overall_damagetaken = container_damagetaken_window
		
	--> Caixa das Habilidades do boss
	
		local container_habilidades_window = CreateFrame ("ScrollFrame", "Details_Boss_ContainerHabilidades", frame)
		local container_habilidades_frame = CreateFrame ("Frame", "Details_Boss_FrameHabilidades", container_habilidades_window)
		
		container_habilidades_frame:SetScript ("OnMouseDown",  mouse_down)
		container_habilidades_frame:SetScript ("OnMouseUp", mouse_up)
		
		container_habilidades_frame.barras = {}

		--label titulo % background
		
		local habilidades_inimigas_bg = CreateFrame ("Frame", nil, frame)
		habilidades_inimigas_bg:SetWidth (200)
		habilidades_inimigas_bg:SetHeight (16)
		habilidades_inimigas_bg:EnableMouse (true)
		habilidades_inimigas_bg:SetResizable (false)
		habilidades_inimigas_bg:SetPoint ("topleft", frame, "topleft", 20, -196)
		
		frame.Widgets [#frame.Widgets+1] = habilidades_inimigas_bg
		frame.Widgets [#frame.Widgets+1] = container_habilidades_window
		frame.Widgets [#frame.Widgets+1] = container_habilidades_frame
		
		habilidades_inimigas_bg.textura = habilidades_inimigas_bg:CreateTexture (nil, "overlay")
		habilidades_inimigas_bg.textura:SetPoint ("topleft", habilidades_inimigas_bg, "topleft")
		habilidades_inimigas_bg.textura:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_bg")
		
		habilidades_inimigas_bg.textura:SetTexCoord (19/1024, 217/1024, 195/512, 211/512)
		habilidades_inimigas_bg.textura:SetSize (199, 16)
		habilidades_inimigas_bg.textura:SetBlendMode ("ADD")
		
		habilidades_inimigas_bg.textura:Hide()
		
		habilidades_inimigas_bg:SetScript ("OnEnter", function(self) self.textura:Show() end)
		habilidades_inimigas_bg:SetScript ("OnLeave", function(self) self.textura:Hide() end)		
		
		DetailsFrameWork:NewLabel (habilidades_inimigas_bg, habilidades_inimigas_bg, nil, "habilidades_title", Loc ["STRING_INFLICTED_BY"], "GameFontHighlightSmall")
		habilidades_inimigas_bg.habilidades_title:SetPoint ("BOTTOMLEFT", container_habilidades_window, "TOPLEFT", 5, 3)
		
		--> container background
		--container_habilidades_window:SetBackdrop({edgeFile = "Interface\\DialogFrame\\UI-DialogBox-gold-Border", tile = true, tileSize = 16, edgeSize = 5, insets = {left = 1, right = 1, top = 0, bottom = 1},})		
		--container_habilidades_window:SetBackdropBorderColor (0,0,0,0)
		
		container_habilidades_frame:SetBackdrop (backdrop)
		container_habilidades_frame:SetBackdropBorderColor (0,0,0,0)
		container_habilidades_frame:SetBackdropColor (0, 0, 0, 0.6)
		
		container_habilidades_frame:SetAllPoints (container_habilidades_window)
		container_habilidades_frame:SetWidth (200)
		container_habilidades_frame:SetHeight (100)
		container_habilidades_frame:EnableMouse (true)
		container_habilidades_frame:SetResizable (false)
		container_habilidades_frame:SetMovable (true)
		
		container_habilidades_window:SetWidth (200)
		container_habilidades_window:SetHeight (100)
		container_habilidades_window:SetScrollChild (container_habilidades_frame)
		container_habilidades_window:SetPoint ("TOPLEFT", frame, "TOPLEFT", 20, -211)

		DetailsFrameWork:NewScrollBar (container_habilidades_window, container_habilidades_frame, 4, -2)
		container_habilidades_window.slider:Altura (89)
		container_habilidades_window.slider:cimaPoint (0, 1)
		container_habilidades_window.slider:baixoPoint (0, -1)
		container_habilidades_frame.slider = container_habilidades_window.slider
		
		container_habilidades_window.gump = container_habilidades_frame
		container_habilidades_frame.window = container_habilidades_window
		container_habilidades_window.ultimo = 0
		frame.overall_habilidades = container_habilidades_window
		
		
	--> Caixa dos Adds
	
		local container_adds_window = CreateFrame ("ScrollFrame", "Details_Boss_ContainerAdds", frame)
		local container_adds_frame = CreateFrame ("Frame", "Details_Boss_FrameAdds", container_adds_window)
		local mouseOver_adds_frame = CreateFrame ("Frame", "MouseOverDetails_Boss_FrameAdds", frame)
		
		frame.Widgets [#frame.Widgets+1] = mouseOver_adds_frame 
		frame.Widgets [#frame.Widgets+1] = container_adds_frame 
		frame.Widgets [#frame.Widgets+1] = container_adds_window
		
		mouseOver_adds_frame:SetPoint ("bottom", container_adds_window, "top")
		mouseOver_adds_frame:SetPoint ("bottomleft", container_adds_window, "topleft", 0, 5)
		mouseOver_adds_frame:SetPoint ("bottomright", container_adds_window, "topright", 20, 5)
		mouseOver_adds_frame:SetHeight (50)
		
		mouseOver_adds_frame.imagem = mouseOver_adds_frame:CreateTexture (nil, "overlay")
		mouseOver_adds_frame.imagem:SetPoint ("topright", mouseOver_adds_frame, "topright", -7, -9)
		
		mouseOver_adds_frame.imagem:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_icons")
		mouseOver_adds_frame.imagem:SetTexCoord (0.52734375, 0.7421875, 0.03125, 0.3671875)
		mouseOver_adds_frame.imagem:SetWidth (57)
		mouseOver_adds_frame.imagem:SetHeight (44)

		mouseOver_adds_frame:SetScript ("OnEnter", 
			function() 
				if (EncounterDetails.db.opened < 30) then
					_G.DetailsBubble:SetOwner (mouseOver_adds_frame.imagem, nil, nil, -45, -22)
					_G.DetailsBubble:FlipHorizontal()
					_G.DetailsBubble:SetBubbleText (Loc ["STRING_ADDS_HELP"])
					_G.DetailsBubble:ShowBubble()
				end
				mouseOver_adds_frame.imagem:SetTexCoord (0.7734375, 0.99609375, 0.03125, 0.3671875)
			end)
		mouseOver_adds_frame:SetScript ("OnLeave", 
			function() 
				_G.DetailsBubble:HideBubble()
				mouseOver_adds_frame.imagem:SetTexCoord (0.52734375, 0.7421875, 0.03125, 0.3671875)
			end)
		
		mouseOver_adds_frame:SetScript ("OnMouseDown",  mouse_down)
		mouseOver_adds_frame:SetScript ("OnMouseUp", mouse_up)
		container_adds_frame:SetScript ("OnMouseDown",  mouse_down)
		container_adds_frame:SetScript ("OnMouseUp", mouse_up)
		
		container_adds_frame.barras = {}
		
		container_adds_frame:SetAllPoints (container_adds_window)
		container_adds_frame:SetWidth (175)
		container_adds_frame:SetHeight (90)
		container_adds_frame:EnableMouse (true)
		container_adds_frame:SetResizable (false)
		container_adds_frame:SetMovable (true)
		
		container_adds_window:SetWidth (175)
		container_adds_window:SetHeight (88)
		container_adds_window:SetScrollChild (container_adds_frame)
		container_adds_window:SetPoint ("TOPLEFT", frame, "TOPLEFT", 255, -113)

		DetailsFrameWork:NewLabel (container_adds_window, container_adds_window, nil, "titulo", Loc ["STRING_ADDS"], "QuestFont_Large", 16, {1, 1, 1})
		container_adds_window.titulo:SetPoint ("bottomleft", container_adds_window, "topleft", 0, 0)
		
		DetailsFrameWork:NewScrollBar (container_adds_window, container_adds_frame, 4, -13)
		container_adds_window.slider:Altura (65)
		container_adds_window.slider:cimaPoint (0, 1)
		container_adds_window.slider:baixoPoint (0, -1)
		container_adds_frame.slider = container_adds_window.slider
		
		container_adds_window.gump = container_adds_frame
		container_adds_frame.window = container_adds_window
		container_adds_window.ultimo = 0
		frame.overall_adds = container_adds_window
		
	--> Caixa dos interrupts (kicks)
	
		local container_interrupt_window = CreateFrame ("ScrollFrame", "Details_Boss_Containerinterrupt", frame)
		local container_interrupt_frame = CreateFrame ("Frame", "Details_Boss_Frameinterrupt", container_interrupt_window)
		local mouseOver_interrupt_frame = CreateFrame ("Frame", "MouseOverDetails_Boss_FrameInterrupt", frame)
		
		frame.Widgets [#frame.Widgets+1] = container_interrupt_window
		frame.Widgets [#frame.Widgets+1] = container_interrupt_frame
		frame.Widgets [#frame.Widgets+1] = mouseOver_interrupt_frame
		
		mouseOver_interrupt_frame:SetPoint ("bottom", container_interrupt_window, "top")
		mouseOver_interrupt_frame:SetPoint ("bottomleft", container_interrupt_window, "topleft", 0, 5)
		mouseOver_interrupt_frame:SetPoint ("bottomright", container_interrupt_window, "topright", 20, 5)
		mouseOver_interrupt_frame:SetHeight (50)
		
		mouseOver_interrupt_frame.imagem = mouseOver_interrupt_frame:CreateTexture (nil, "overlay")
		mouseOver_interrupt_frame.imagem:SetPoint ("topright", mouseOver_interrupt_frame, "topright", 1, -25)
		
		mouseOver_interrupt_frame.imagem:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_icons")
		mouseOver_interrupt_frame.imagem:SetTexCoord (0.6015625, 1, 0.734375, 0.9765625)
		mouseOver_interrupt_frame.imagem:SetWidth (103*0.7)
		mouseOver_interrupt_frame.imagem:SetHeight (34*0.7)
		
		mouseOver_interrupt_frame:SetScript ("OnEnter", 
			function()
				if (EncounterDetails.db.opened < 30) then
					_G.DetailsBubble:SetOwner (mouseOver_interrupt_frame.imagem, nil, nil, 40, -18)
					_G.DetailsBubble:SetBubbleText (Loc ["STRING_INTERRIPT_HELP"])
					_G.DetailsBubble:ShowBubble()
				end
				mouseOver_interrupt_frame.imagem:SetTexCoord (0.6015625, 1, 0.4296875, 0.6953125)
			end)
		mouseOver_interrupt_frame:SetScript ("OnLeave", 
			function()
				_G.DetailsBubble:HideBubble()
				mouseOver_interrupt_frame.imagem:SetTexCoord (0.6015625, 1, 0.734375, 0.9765625)
			end)

		container_interrupt_frame:SetScript ("OnMouseDown",  mouse_down)
		container_interrupt_frame:SetScript ("OnMouseUp", mouse_up)
		mouseOver_interrupt_frame:SetScript ("OnMouseDown",  mouse_down)
		mouseOver_interrupt_frame:SetScript ("OnMouseUp", mouse_up)			
		
		container_interrupt_frame.barras = {}
		
		container_interrupt_frame:SetAllPoints (container_interrupt_window)
		container_interrupt_frame:SetWidth (185)
		container_interrupt_frame:SetHeight (67)
		container_interrupt_frame:EnableMouse (true)
		container_interrupt_frame:SetResizable (false)
		container_interrupt_frame:SetMovable (true)
		
		container_interrupt_window:SetWidth (185)
		container_interrupt_window:SetHeight (65)
		container_interrupt_window:SetScrollChild (container_interrupt_frame)
		container_interrupt_window:SetPoint ("TOPLEFT", frame, "TOPLEFT", 470, -234)

		DetailsFrameWork:NewLabel (container_interrupt_window, container_interrupt_window, nil, "titulo", Loc ["STRING_INTERRUPTS"], "QuestFont_Large", 16, {1, 1, 1})
		container_interrupt_window.titulo:SetPoint ("bottomleft", container_interrupt_window, "topleft", 0, 3)
		
		DetailsFrameWork:NewScrollBar (container_interrupt_window, container_interrupt_frame, -1, -8)
		container_interrupt_window.slider:Altura (45)
		container_interrupt_window.slider:cimaPoint (0, 0)
		container_interrupt_window.slider:baixoPoint (0, -2)
		container_interrupt_frame.slider = container_interrupt_window.slider
		
		container_interrupt_window.gump = container_interrupt_frame
		container_interrupt_frame.window = container_interrupt_window
		container_interrupt_window.ultimo = 0
		frame.overall_interrupt = container_interrupt_window
		
	--> Caixa dos Dispells
	
		local container_dispell_window = CreateFrame ("ScrollFrame", "Details_Boss_Containerdispell", frame)
		local container_dispell_frame = CreateFrame ("Frame", "Details_Boss_Framedispell", container_dispell_window)
		local mouseOver_dispell_frame = CreateFrame ("Frame", "MouseOverDetails_Boss_FrameDispell", frame)
		
		frame.Widgets [#frame.Widgets+1] = container_dispell_window
		frame.Widgets [#frame.Widgets+1] = container_dispell_frame
		frame.Widgets [#frame.Widgets+1] = mouseOver_dispell_frame	
		
		mouseOver_dispell_frame:SetPoint ("bottom", container_dispell_window, "top")
		mouseOver_dispell_frame:SetPoint ("bottomleft", container_dispell_window, "topleft", 0, 5)
		mouseOver_dispell_frame:SetPoint ("bottomright", container_dispell_window, "topright", 20, 5)
		mouseOver_dispell_frame:SetHeight (30)
		
		mouseOver_dispell_frame.imagem = mouseOver_dispell_frame:CreateTexture (nil, "overlay")
		mouseOver_dispell_frame.imagem:SetPoint ("topright", mouseOver_dispell_frame, "topright", -10, -10)
		
		mouseOver_dispell_frame.imagem:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_icons")
		mouseOver_dispell_frame.imagem:SetTexCoord (0, 0.15625, 0.4140625, 0.71875)
		mouseOver_dispell_frame.imagem:SetWidth (30)
		mouseOver_dispell_frame.imagem:SetHeight (29)
		
		mouseOver_dispell_frame:SetScript ("OnEnter", 
			function()
				if (EncounterDetails.db.opened < 30) then
					_G.DetailsBubble:SetOwner (mouseOver_dispell_frame.imagem, nil, nil, -45, -22)
					_G.DetailsBubble:FlipHorizontal()
					_G.DetailsBubble:SetBubbleText (Loc ["STRING_DISPELL_HELP"])
					_G.DetailsBubble:ShowBubble()
				end
				mouseOver_dispell_frame.imagem:SetTexCoord (0.1796875, 0.3359375, 0.4140625, 0.71875)
			end)
		mouseOver_dispell_frame:SetScript ("OnLeave", 
			function()
				_G.DetailsBubble:HideBubble()
				mouseOver_dispell_frame.imagem:SetTexCoord (0, 0.15625, 0.4140625, 0.71875)
			end)	
	
		container_dispell_frame:SetScript ("OnMouseDown",  mouse_down)
		container_dispell_frame:SetScript ("OnMouseUp", mouse_up)
		mouseOver_dispell_frame:SetScript ("OnMouseDown",  mouse_down)
		mouseOver_dispell_frame:SetScript ("OnMouseUp", mouse_up)
		
		container_dispell_frame.barras = {}
		
		container_dispell_frame:SetAllPoints (container_dispell_window)
		container_dispell_frame:SetWidth (190)
		container_dispell_frame:SetHeight (62)
		container_dispell_frame:EnableMouse (true)
		container_dispell_frame:SetResizable (false)
		container_dispell_frame:SetMovable (true)
		
		container_dispell_window:SetWidth (190)
		container_dispell_window:SetHeight (68)
		container_dispell_window:SetScrollChild (container_dispell_frame)
		container_dispell_window:SetPoint ("TOPLEFT", frame, "TOPLEFT", 245, -231)

		DetailsFrameWork:NewLabel (container_dispell_window, container_dispell_window, nil, "titulo", Loc ["STRING_DISPELLS"], "QuestFont_Large", 16, {1, 1, 1})
		container_dispell_window.titulo:SetPoint ("bottomleft", container_dispell_window, "topleft", 8, 0)
		
		DetailsFrameWork:NewScrollBar (container_dispell_window, container_dispell_frame, -1, -13)
		container_dispell_window.slider:Altura (45)
		container_dispell_window.slider:cimaPoint (0, 1)
		container_dispell_window.slider:baixoPoint (0, -1)
		container_dispell_frame.slider = container_dispell_window.slider
		
		container_dispell_window.gump = container_dispell_frame
		container_dispell_frame.window = container_dispell_window
		container_dispell_window.ultimo = 0
		frame.overall_dispell = container_dispell_window		

	--> Caixa das mortes
	
		local container_dead_window = CreateFrame ("ScrollFrame", "Details_Boss_ContainerDead", frame)
		local container_dead_frame = CreateFrame ("Frame", "Details_Boss_FrameDead", container_dead_window)
		local mouseOver_dead_frame = CreateFrame ("Frame", "MouseOverDetails_Boss_FrameDead", frame)
		
		frame.Widgets [#frame.Widgets+1] = container_dead_window
		frame.Widgets [#frame.Widgets+1] =  container_dead_frame
		frame.Widgets [#frame.Widgets+1] = mouseOver_dead_frame	
		
		mouseOver_dead_frame:SetPoint ("bottom", container_dead_window, "top")
		mouseOver_dead_frame:SetPoint ("bottomleft", container_dead_window, "topleft", 0, 5)
		mouseOver_dead_frame:SetPoint ("bottomright", container_dead_window, "topright", 20, 5)
		mouseOver_dead_frame:SetHeight (50)
		
		mouseOver_dead_frame.imagem = mouseOver_dead_frame:CreateTexture (nil, "overlay")
		mouseOver_dead_frame.imagem:SetPoint ("topright", mouseOver_dead_frame, "topright", -14, -14)
		
		mouseOver_dead_frame.imagem:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_icons")
		mouseOver_dead_frame.imagem:SetTexCoord (0, 0.1640625, 0.03125, 0.34375)
		mouseOver_dead_frame.imagem:SetWidth (42)
		mouseOver_dead_frame.imagem:SetHeight (41)
		
		mouseOver_dead_frame:SetScript ("OnEnter", 
			function()
				if (EncounterDetails.db.opened < 30) then
					_G.DetailsBubble:SetOwner (mouseOver_dead_frame.imagem, nil, nil, 40, -18)
					_G.DetailsBubble:SetBubbleText (Loc ["STRING_DEATHS_HELP"])
					_G.DetailsBubble:ShowBubble()
				end
				mouseOver_dead_frame.imagem:SetTexCoord (0.171875, 0.3359375, 0.03125, 0.34375)
			end)
		mouseOver_dead_frame:SetScript ("OnLeave", 
			function()
				_G.DetailsBubble:HideBubble()
				mouseOver_dead_frame.imagem:SetTexCoord (0, 0.1640625, 0.03125, 0.34375)
			end)
		
		container_dead_frame:SetScript ("OnMouseDown",  mouse_down)
		container_dead_frame:SetScript ("OnMouseUp", mouse_up)
		mouseOver_dead_frame:SetScript ("OnMouseDown",  mouse_down)
		mouseOver_dead_frame:SetScript ("OnMouseUp", mouse_up)
		
		container_dead_frame.barras = {}

		container_dead_frame:SetPoint ("left", container_dead_window, "left")
		container_dead_frame:SetPoint ("right", container_dead_window, "right")
		container_dead_frame:SetPoint ("top", container_dead_window, "top")
		container_dead_frame:SetPoint ("bottom", container_dead_window, "bottom", 0, 10)

		container_dead_frame:SetWidth (178)
		container_dead_frame:SetHeight (89)
		
		container_dead_frame:EnableMouse (true)
		container_dead_frame:SetResizable (false)
		container_dead_frame:SetMovable (true)
		
		container_dead_window:SetWidth (178)
		container_dead_window:SetHeight (88)
		container_dead_window:SetScrollChild (container_dead_frame)
		container_dead_window:SetPoint ("TOPLEFT", frame, "TOPLEFT", 470, -113)

		DetailsFrameWork:NewLabel (container_dead_window, container_dead_window, nil, "titulo", Loc ["STRING_DEATH_LOG"], "QuestFont_Large", 16, {1, 1, 1})
		container_dead_window.titulo:SetPoint ("bottomleft", container_dead_window, "topleft", 0, 1)
		
		DetailsFrameWork:NewScrollBar (container_dead_window, container_dead_frame, 6, -12)
		container_dead_window.slider:Altura (65)
		container_dead_window.slider:cimaPoint (0, 1)
		container_dead_window.slider:baixoPoint (0, -1)
		container_dead_frame.slider = container_dead_window.slider
		
		container_dead_window.gump = container_dead_frame
		container_dead_frame.window = container_dead_window
		container_dead_window.ultimo = 0
		frame.overall_dead = container_dead_window
	
	--> botão fechar
		frame.fechar = CreateFrame ("Button", nil, frame, "UIPanelCloseButton")
		frame.fechar:SetWidth (32)
		frame.fechar:SetHeight (32)
		frame.fechar:SetPoint ("TOPRIGHT", frame, "TOPRIGHT", 5, -8)
		frame.fechar:SetText ("X")
		frame.fechar:SetScript ("OnClick", function(self) 
						EncounterDetails:CloseWindow()
					end)
		frame.fechar:SetFrameLevel (frame:GetFrameLevel()+2)
	
	--emotes frame
	local emote_frame = CreateFrame ("frame", "DetailsEncountersEmoteFrame", UIParent)
	emote_frame:RegisterEvent ("CHAT_MSG_RAID_BOSS_EMOTE")
	emote_frame:RegisterEvent ("CHAT_MSG_RAID_BOSS_WHISPER")
	emote_frame:RegisterEvent ("CHAT_MSG_MONSTER_EMOTE")
	emote_frame:RegisterEvent ("CHAT_MSG_MONSTER_SAY")
	emote_frame:RegisterEvent ("CHAT_MSG_MONSTER_WHISPER")
	emote_frame:RegisterEvent ("CHAT_MSG_MONSTER_PARTY")
	emote_frame:RegisterEvent ("CHAT_MSG_MONSTER_YELL")
	
	local emote_table = {
		["CHAT_MSG_RAID_BOSS_EMOTE"] = 1,
		["CHAT_MSG_RAID_BOSS_WHISPER"] = 2,
		["CHAT_MSG_MONSTER_EMOTE"] = 3,
		["CHAT_MSG_MONSTER_SAY"] = 4,
		["CHAT_MSG_MONSTER_WHISPER"] = 5,
		["CHAT_MSG_MONSTER_PARTY"] = 6,
		["CHAT_MSG_MONSTER_YELL"] = 7,
	}
	
	emote_frame:SetScript ("OnEvent", function (...)
	
		if (not EncounterDetails.current_whisper_table) then
			return
		end
	
		local combat = EncounterDetails:GetCombat ("current")
		--local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 = ...
		--print ("2 =", arg2, "3 =", arg3, "4 =",  arg4, "5 =",  arg5, "6 =",  arg6, "7 =",  arg7, "8 =",  arg8, "9 =",  arg9)
		if (combat and EncounterDetails:IsInCombat() and EncounterDetails:GetZoneType() == "raid") then
			local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 = ...
			tinsert (EncounterDetails.current_whisper_table, {combat:GetCombatTime(), arg3, arg4, emote_table [arg2]})
		end
	end)
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




end
end
--endd