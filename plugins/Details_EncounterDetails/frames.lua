do
	local _detalhes = _G._detalhes
	local DetailsFrameWork = _detalhes.gump
	local AceLocale = LibStub ("AceLocale-3.0")
	local Loc = AceLocale:GetLocale ("Details_EncounterDetails")
	local Graphics = LibStub:GetLibrary("LibGraph-2.0")
	local _ipairs = ipairs
	local _math_floor = math.floor
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
		local options_frame = CreateFrame ("frame", "EncounterDetailsOptionsWindow", UIParent, "ButtonFrameTemplate")
		tinsert (UISpecialFrames, "EncounterDetailsOptionsWindow")
		options_frame:SetSize (500, 200)
		options_frame:SetFrameStrata ("HIGH")
		options_frame:SetScript ("OnMouseDown", function(self) self:StartMoving()end)
		options_frame:SetScript ("OnMouseUp", function(self) self:StopMovingOrSizing()end)
		options_frame:SetMovable (true)
		options_frame:EnableMouse (true)
		options_frame:Hide()
		options_frame:SetPoint ("center", UIParent, "center")
		options_frame.TitleText:SetText ("Encounter Details Options")
		options_frame.portrait:SetTexture ([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-BLOODELF]])
		
-- 1 = only when inside a raid map
-- 2 = only when in raid group
-- 3 = only after a boss encounter
-- 4 = always show
		
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
			--show when dropdown
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
		}
		
		DetailsFrameWork:BuildMenu (options_frame, menu, 15, -75, 260)
		
	end
	
	EncounterDetails.OpenOptionsPanel = function()
		if (not EncounterDetailsOptionsWindow) then
			build_options_panel()
		end
		EncounterDetailsOptionsWindow:Show()
	end
	
	function EncounterDetails:CreateRowTexture (row)
		row.textura = CreateFrame ("StatusBar", nil, row)
		row.textura:SetAllPoints (row)
		local t = row.textura:CreateTexture (nil, "overlay")
		t:SetTexture ("Interface\\AddOns\\Details\\images\\bar_serenity")
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

		local y = (index-1)*17 --> 17 é a altura da barra
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
	
	local grafico_cores = {{1, 1, 1, 1}, {1, 0.5, 0.3, 1}, {0.75, 0.7, 0.1, 1}, {0.2, 0.9, 0.2, 1}, {0.2, 0.5, 0.9, 1}} --, {0.9, 0.2, 0.35, 1}, {0.85, 0.55, 0.45, 1}, {0.4, 0.98, 0.29, 1}
	
	local lastBoss = nil
	function EncounterDetails:BuildDpsGraphic()

		EncounterDetails.LastGraphicDrew = EncounterDetails.LastGraphicDrew or {}
		local graphicData = _detalhes.tabela_vigente:GetTimeData ("Raid Damage Done")
		
		if (not graphicData or not _detalhes.tabela_vigente.start_time or not _detalhes.tabela_vigente.end_time) then
			return
		elseif (graphicData == EncounterDetails.LastGraphicDrew) then
			return
		else
			EncounterDetails.LastGraphicDrew = graphicData
		end
		
		if (graphicData.max_value == 0) then
			return
		end
		
		--> battle time
		if (_detalhes.tabela_vigente.end_time - _detalhes.tabela_vigente.start_time < 12) then
			return
		end

		local g

		EncounterDetails.Frame.linhas = EncounterDetails.Frame.linhas or 0
		EncounterDetails.Frame.linhas = EncounterDetails.Frame.linhas + 1
		
		if (EncounterDetails.Frame.linhas > 5) then
			EncounterDetails.Frame.linhas = 1
		end
		
		if (not _G.DetailsRaidDpsGraph) then
			g = Graphics:CreateGraphLine ("DetailsRaidDpsGraph", EncounterDetails.Frame, "topleft","topleft",20,-76,670,238)
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
				line:SetTexture (.5, .5, .5, .7)
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
				texture:SetTexture (unpack (grafico_cores[i]))
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
			v:SetTexture (1, 1, 1, 1)
			
			local h = g:CreateTexture (nil, "overlay")
			h:SetWidth (668)
			h:SetHeight (2)
			h:SetPoint ("top", g, "top", 0, -217)
			h:SetPoint ("left", g, "left")
			h:SetTexture (1, 1, 1, 1)
			
		else
			g = _G.DetailsRaidDpsGraph

			if (not _detalhes.tabela_vigente.is_boss or not lastBoss or _detalhes.tabela_vigente.is_boss.index ~= lastBoss) then
				g:ResetData()
				g.max_damage = 0
			end
		end
		
		lastBoss = _detalhes.tabela_vigente.is_boss and _detalhes.tabela_vigente.is_boss.index
		
		local _data = {}
		local dps_max = graphicData.max_value
		local amount = #graphicData
		
		local scaleW = 1/670

		local content = graphicData
		table.insert (content, 1, 0)
		table.insert (content, 1, 0)
		table.insert (content, #content+1, 0)
		table.insert (content, #content+1, 0)
		local _i = 3
		
		local graphMaxDps = math.max (g.max_damage, dps_max)
		while (_i <= #content-2) do 
			local v = (content[_i-2]+content[_i-1]+content[_i]+content[_i+1]+content[_i+2])/5 --> normalize
			_data [#_data+1] = {scaleW*(_i-2), v/graphMaxDps} --> x and y coords
			_i = _i + 1
		end

--[[ precisa de uma proteção contra troca de tabela, no inicio dos trash		
Message: ..\AddOns\Details_EncounterDetails\frames.lua line 156:
   attempt to perform arithmetic on field 'end_time' (a nil value)--]]

		local tempo = _detalhes.tabela_vigente.end_time - _detalhes.tabela_vigente.start_time
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
		
		--print ("DPSMAX: " .. dps_max .. " > " .. g.max_damage)
		
		if (dps_max > g.max_damage) then 
		
			--> normalize previous data
			
			--table.insert (self.Data, 1, {Points=data;Color=color})
			
			if (g.max_damage > 0) then
				local normalizePercent = g.max_damage / dps_max
				for dataIndex, Data in ipairs (g.Data) do 
					local Points = Data.Points
					for i = 1, #Points do 
						--print (Points[i][1], Points[i][2])
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
		
		local mortes = _detalhes.tabela_vigente.last_events_tables
		local scaleG = 650/_detalhes.tabela_vigente:GetCombatTime()
		
		for _, row in _ipairs (g.VerticalLines) do 
			row:Hide()
		end
		
		for i = 1, math.min (3, #mortes) do 
		
			local vRowFrame = g.VerticalLines [i]
			local deadTime = mortes [i][2] - _detalhes.tabela_vigente.start_time
			
			if (not vRowFrame) then
			
				vRowFrame = CreateFrame ("frame", "DetailsEncountersVerticalLine"..i, g)
				vRowFrame:SetWidth (20)
				vRowFrame:SetHeight (43)
				vRowFrame:SetFrameLevel (g:GetFrameLevel()+2)
				
				vRowFrame:SetScript ("OnEnter", function (frame) 
					
					if (vRowFrame.dead[1] and vRowFrame.dead[1][3] and vRowFrame.dead[1][3][2]) then
						local nome_magia3, _, icone_magia3 = _GetSpellInfo (vRowFrame.dead[1][3][2])
						if (type (vRowFrame.dead[1][3][3]) == "number") then
							nome_magia3 = _detalhes:comma_value (vRowFrame.dead[1][3][3]).." "..nome_magia3
						end
						
						local nome_magia2, _, icone_magia2 = _GetSpellInfo (vRowFrame.dead[1][2][2])
						if (type (vRowFrame.dead[1][2][3]) == "number") then
							nome_magia2 = _detalhes:comma_value (vRowFrame.dead[1][2][3]).." "..nome_magia2
						end
						
						local nome_magia1, _, icone_magia1 = _GetSpellInfo (vRowFrame.dead[1][1][2])
						if (type (vRowFrame.dead[1][1][3]) == "number") then
							nome_magia1 = _detalhes:comma_value (vRowFrame.dead[1][1][3]).." "..nome_magia1
						else --bress
							local decorrido = vRowFrame.dead[1][1][4] - _detalhes.tabela_vigente.start_time
							local minutos, segundos = _math_floor (decorrido/60), _math_floor (decorrido%60)
							nome_magia1 = minutos..":"..segundos.." "..nome_magia1
						end

						GameCooltip:Reset()
						
						GameCooltip:AddLine (vRowFrame.dead[6].." "..vRowFrame.dead[3])
						GameCooltip:AddIcon ("Interface\\AddOns\\Details_EncounterDetails\\images\\small_icons", _,_,_,_, .75, 1, 0, 1)
						
						GameCooltip:AddLine (nome_magia3)
						GameCooltip:AddIcon (icone_magia3)
						
						GameCooltip:AddLine (nome_magia2)
						GameCooltip:AddIcon (icone_magia1)
						
						GameCooltip:AddLine (nome_magia1)
						GameCooltip:AddIcon (icone_magia1)

						GameCooltip:SetOption ("TextSize", 9.5)
						GameCooltip:SetOption ("IconSize", 12)
						GameCooltip:SetOption ("HeightAnchorMod", -15)
						
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
			
			vRowFrame:SetPoint ("topleft", EncounterDetails.Frame, "topleft", (deadTime*scaleG), -268)
			vRowFrame.dead = mortes [i]
			vRowFrame:Show()
			
		end
		
		_G.DetailsRaidDpsGraph:Show()
		
	end	
	
	local BossFrame = EncounterDetails.Frame
	
	local DetailsFrameWork = _detalhes.gump

	BossFrame:SetFrameStrata ("MEDIUM")
	if (_detalhes.janela_info) then
		BossFrame:SetFrameLevel (_detalhes.janela_info:GetFrameLevel()+3)
	end
	
	BossFrame:SetWidth (698)
	BossFrame:SetHeight (354)
	BossFrame:EnableMouse (true)
	BossFrame:SetResizable (false)
	BossFrame:SetMovable (true)
	
	function BossFrame:ToFront()
		if (_detalhes.janela_info) then
			if (BossFrame:GetFrameLevel() < _detalhes.janela_info:GetFrameLevel()) then 
				BossFrame:SetFrameLevel (BossFrame:GetFrameLevel()+3)
				_detalhes.janela_info:SetFrameLevel (_detalhes.janela_info:GetFrameLevel()-3)
			end
		end
	end
	
	BossFrame.grab = DetailsFrameWork:NewDetailsButton (BossFrame, BossFrame, _, BossFrame.ToFront, nil, nil, 698, 73, "", "", "", "", {OnGrab = "PassClick"})
	BossFrame.grab:SetPoint ("topleft", BossFrame, "topleft")
	BossFrame.grab:SetFrameLevel (BossFrame:GetFrameLevel()+1)
	
	BossFrame:SetScript ("OnMouseDown", 
					function (self, botao)
						if (botao == "LeftButton") then
							self:StartMoving()
							self.isMoving = true
						end
					end)
					
	BossFrame:SetScript ("OnMouseUp", 
					function (self)
						if (self.isMoving) then
							self:StopMovingOrSizing()
							self.isMoving = false
						end
					end)
	
	--> fix para dar fadein ao apertar esc
	--[[
	BossFrame:SetScript ("OnHide", function (self)
		if (not BossFrame.hidden) then --> significa que foi fechado com ESC
			BossFrame:Show()
			DetailsFrameWork:Fade (BossFrame, "in")
		end
	end)
	--]]
	
	--BossFrame:SetBackdrop (gump_fundo_backdrop)
	--BossFrame:SetBackdropColor (0, 0, 0, 0.3)

	BossFrame:SetPoint ("CENTER", UIParent)
	--EncounterDetails.Frame = BossFrame
	
	--> icone da classe no canto esquerdo superior
	BossFrame.boss_icone = BossFrame:CreateTexture (nil, "BACKGROUND")
	BossFrame.boss_icone:SetPoint ("TOPLEFT", BossFrame, "TOPLEFT", 4, 0)
	BossFrame.boss_icone:SetWidth (64)
	BossFrame.boss_icone:SetHeight (64)
	
	--> imagem de fundo
	BossFrame.raidbackground = BossFrame:CreateTexture (nil, "BACKGROUND")
	BossFrame.raidbackground:SetPoint ("TOPLEFT", BossFrame, "TOPLEFT", 244, -74)
	
	BossFrame.raidbackground:SetWidth (450)
	BossFrame.raidbackground:SetHeight (256)
	
	--> background completo
	BossFrame.bg = BossFrame:CreateTexture (nil, "BORDER")
	BossFrame.bg:SetPoint ("TOPLEFT", BossFrame, "TOPLEFT", 0, 0)
	BossFrame.bg:SetWidth (1024)
	BossFrame.bg:SetHeight (512)
	BossFrame.bg:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_bg") 

	BossFrame.Widgets = {}
	
	BossFrame.ShowType = "main"

	--> revisar
	BossFrame.Reset = function()
		BossFrame.switch ("main")
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
	
	BossFrame.switch = function (to)
		if (to == "main") then 
			BossFrame.bg:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_bg") 
			for _, frame in _ipairs (BossFrame.Widgets) do 
				frame:Show()
			end
			
			--BossFrame.buttonSwitchNormal:Disable()
			--BossFrame.buttonSwitchGraphic:Enable()
			
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

			--BossFrame.StatusBar_damageicon:Show()
			--BossFrame.StatusBar_healicon:Show()
			--BossFrame.StatusBar_totaldamage:Show()
			--BossFrame.StatusBar_totalheal:Show()
			
			BossFrame.ShowType = "main"
			
		elseif (to == "graph") then 

			EncounterDetails:BuildDpsGraphic()
			if (not _G.DetailsRaidDpsGraph) then
				return
			end
			
			BossFrame.bg:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_bg_graphic") 
			for _, frame in _ipairs (BossFrame.Widgets) do 
				frame:Hide()
			end
			
			selected:SetPoint ("center", BossFrame.buttonSwitchGraphic, "center", 0, 1)
			u:SetAllPoints (BossFrame.buttonSwitchGraphic)
			
			--BossFrame.buttonSwitchNormal:Enable()
			--BossFrame.buttonSwitchGraphic:Disable()
			
			_G.DetailsRaidDpsGraph:Show()
			
			BossFrame.StatusBar_damageicon:Hide()
			BossFrame.StatusBar_healicon:Hide()
			BossFrame.StatusBar_totaldamage:Hide()
			BossFrame.StatusBar_totalheal:Hide()
			
			for i = 1, 8, 1 do
				BossFrame["dpsamt"..i].widget:Show()
				BossFrame["timeamt"..i].widget:Show()
			end
			BossFrame["timeamt0"].widget:Show()
			
			BossFrame.ShowType = "graph"
		end
	end

	BossFrame.buttonSwitchNormal = DetailsFrameWork:NewDetailsButton (BossFrame, BossFrame, _, BossFrame.switch, "main", nil, 26, 33)
	BossFrame.buttonSwitchNormal:SetPoint ("bottomright", BossFrame, "bottomright", -10, 5)
	local t = BossFrame.buttonSwitchNormal:CreateTexture (nil, "artwork")
	t:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons")
	t:SetTexCoord (0, 0.1015625, 0, 0.515625)
	t:SetWidth (26)
	t:SetHeight (33)
	t:SetAllPoints (BossFrame.buttonSwitchNormal)

	BossFrame.buttonSwitchGraphic = DetailsFrameWork:NewDetailsButton (BossFrame, BossFrame, _, BossFrame.switch, "graph", nil, 26, 33)
	BossFrame.buttonSwitchGraphic:SetPoint ("right", BossFrame.buttonSwitchNormal, "left", 0, 0)
	local g = BossFrame.buttonSwitchGraphic:CreateTexture (nil, "artwork")
	g:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons")
	g:SetTexCoord (0.1171875, 0.21875, 0, 0.515625)	
	g:SetWidth (26)
	g:SetHeight (33)
	g:SetAllPoints (BossFrame.buttonSwitchGraphic)
	
	u = BossFrame.buttonSwitchGraphic:CreateTexture (nil, "overlay")
	u:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons")
	u:SetTexCoord (0.8984375, 1, 0, 0.515625)
	u:SetWidth (26)
	u:SetHeight (33)
	u:SetAllPoints (BossFrame.buttonSwitchNormal)
	
	selected = BossFrame.buttonSwitchGraphic:CreateTexture (nil, "overlay")
	selected:SetTexture (1, 1, 1, .1)
	selected:SetWidth (22)
	selected:SetHeight (28)
	selected:SetPoint ("center", BossFrame.buttonSwitchNormal, "center", 0, 0)
	
	BossFrame.buttonSwitchNormal.MouseOnEnterHook = function()  
		GameCooltip:Reset()
		GameCooltip:AddLine (Loc ["STRING_FIGHT_SUMMARY"])
		GameCooltip:ShowCooltip (BossFrame.buttonSwitchNormal, "tooltip")
	end
	BossFrame.buttonSwitchNormal.MouseOnLeaveHook = function() _detalhes.popup:ShowMe (false) end
	
	BossFrame.buttonSwitchGraphic.MouseOnEnterHook = function() 
		GameCooltip:Reset()
		GameCooltip:AddLine (Loc ["STRING_FIGHT_GRAPHIC"])
		GameCooltip:ShowCooltip (BossFrame.buttonSwitchGraphic, "tooltip")
	end
	BossFrame.buttonSwitchGraphic.MouseOnLeaveHook = function() _detalhes.popup:ShowMe (false) end	

	DetailsFrameWork:NewLabel (BossFrame, BossFrame, nil, "titulo", Loc ["STRING_WINDOW_TITLE"], "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
	BossFrame.titulo:SetPoint ("center", BossFrame, "center")
	BossFrame.titulo:SetPoint ("top", BossFrame, "top", 0, -18)
	
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

	--> Barra de Status:

		frame.StatusBar_damageicon = frame:CreateTexture (nil, "overlay")
		frame.StatusBar_damageicon:SetPoint ("bottomleft", frame, "bottomleft", 20, 21)
		frame.StatusBar_damageicon:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_icones")
		frame.StatusBar_damageicon:SetWidth (16)
		frame.StatusBar_damageicon:SetHeight (16)
		frame.StatusBar_damageicon:SetTexCoord (0, 0.0625, 0, 1) -- 256x16
		
		DetailsFrameWork:NewLabel (frame, frame, nil, "StatusBar_totaldamage", Loc ["STRING_TOTAL_DAMAGE"], "GameFontHighlightSmall")
		frame.StatusBar_totaldamage:SetPoint ("left", frame.StatusBar_damageicon, "right", 2, 0)
		
		frame.StatusBar_healicon = frame:CreateTexture (nil, "overlay")
		frame.StatusBar_healicon:SetPoint ("bottomleft", frame, "bottomleft", 20, 5)
		frame.StatusBar_healicon:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_icones")
		frame.StatusBar_healicon:SetWidth (16)
		frame.StatusBar_healicon:SetHeight (16)
		frame.StatusBar_healicon:SetTexCoord (0.0625, 0.125, 0, 1) -- 256x16 
		
		DetailsFrameWork:NewLabel (frame, frame, nil, "StatusBar_totalheal", Loc ["STRING_TOTAL_HEAL"], "GameFontHighlightSmall")
		frame.StatusBar_totalheal:SetPoint ("left", frame.StatusBar_healicon, "right", 2, 0)
		
		frame.StatusBar_damageicon:Hide()
		frame.StatusBar_totaldamage:Hide()
		frame.StatusBar_healicon:Hide()
		frame.StatusBar_totalheal:Hide()
		
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
		segmentos_string:SetPoint ("bottomleft", frame, "bottomleft", 20, 17)
		_detalhes:SetFontColor (segmentos_string, "white")
		_detalhes:SetFontSize (segmentos_string, 10)
		
		local segmentos = DetailsFrameWork:NewDropDown (frame, _, "$parentSegmentsDropdown", "segmentosDropdown", 160, 18, buildSegmentosMenu, nil)	
		segmentos:SetPoint ("left", segmentos_string, "right", 2, 0)
		
		local options_button = DetailsFrameWork:NewButton (frame, _, "$parentOptionsButton", nil, 100, 18, EncounterDetails.OpenOptionsPanel, nil, nil, nil, "Options")
		options_button:SetPoint ("left", segmentos, "right", 14, 0)
		options_button.textalign = "<"
	
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
		dano_recebido_bg.textura:SetPoint ("topleft", dano_recebido_bg, "topleft")
		dano_recebido_bg.textura:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\dano_recebido_bg")
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
		--habilidades_inimigas_bg.textura:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\habilidades_inimigas_bg")
		habilidades_inimigas_bg.textura:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\habilidades_inimigas_bg")
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
				_G.DetailsBubble:SetOwner (mouseOver_adds_frame.imagem, nil, nil, -45, -22)
				_G.DetailsBubble:FlipHorizontal()
				_G.DetailsBubble:SetBubbleText (Loc ["STRING_ADDS_HELP"])
				_G.DetailsBubble:ShowBubble()
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
		
		--container_adds_window:SetBackdrop({edgeFile = "Interface\\DialogFrame\\UI-DialogBox-gold-Border", tile = true, tileSize = 16, edgeSize = 5, insets = {left = 1, right = 1, top = 0, bottom = 1},})		
		--container_adds_window:SetBackdropBorderColor (0,0,0,0)
		
		--container_adds_window:SetBackdrop (gump_fundo_backdrop)
		--container_adds_window:SetBackdropBorderColor (1, 1, 1, 1)
		--container_adds_window:SetBackdropColor (0, 0, 0, 0.1)
		
		container_adds_frame:SetAllPoints (container_adds_window)
		container_adds_frame:SetWidth (170)
		container_adds_frame:SetHeight (67)
		container_adds_frame:EnableMouse (true)
		container_adds_frame:SetResizable (false)
		container_adds_frame:SetMovable (true)
		
		container_adds_window:SetWidth (170)
		container_adds_window:SetHeight (65)
		container_adds_window:SetScrollChild (container_adds_frame)
		container_adds_window:SetPoint ("TOPLEFT", frame, "TOPLEFT", 260, -113)

		DetailsFrameWork:NewLabel (container_adds_window, container_adds_window, nil, "titulo", Loc ["STRING_ADDS"], "QuestFont_Large", 16, {1, 1, 1})
		container_adds_window.titulo:SetPoint ("bottomleft", container_adds_window, "topleft", 0, 4)
		
		DetailsFrameWork:NewScrollBar (container_adds_window, container_adds_frame, 4, -13)
		container_adds_window.slider:Altura (45)
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
		mouseOver_interrupt_frame.imagem:SetPoint ("topright", mouseOver_interrupt_frame, "topright", 12, -16)
		
		mouseOver_interrupt_frame.imagem:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_icons")
		mouseOver_interrupt_frame.imagem:SetTexCoord (0.6015625, 1, 0.734375, 0.9765625)
		mouseOver_interrupt_frame.imagem:SetWidth (103)
		mouseOver_interrupt_frame.imagem:SetHeight (34)
		
		mouseOver_interrupt_frame:SetScript ("OnEnter", 
			function()
				_G.DetailsBubble:SetOwner (mouseOver_interrupt_frame.imagem, nil, nil, 40, -18)
				--_G.DetailsBubble:FlipHorizontal()
				_G.DetailsBubble:SetBubbleText (Loc ["STRING_INTERRIPT_HELP"])
				_G.DetailsBubble:ShowBubble()
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
		
		--container_interrupt_window:SetBackdrop({edgeFile = "Interface\\DialogFrame\\UI-DialogBox-gold-Border", tile = true, tileSize = 16, edgeSize = 5, insets = {left = 1, right = 1, top = 0, bottom = 1},})		
		--container_interrupt_window:SetBackdropBorderColor (0,0,0,0)
		
		--container_interrupt_window:SetBackdrop (gump_fundo_backdrop)
		--container_interrupt_window:SetBackdropBorderColor (1, 1, 1, 1)
		--container_interrupt_window:SetBackdropColor (0, 0, 0, 0.1)
		
		container_interrupt_frame:SetAllPoints (container_interrupt_window)
		container_interrupt_frame:SetWidth (170)
		container_interrupt_frame:SetHeight (67)
		container_interrupt_frame:EnableMouse (true)
		container_interrupt_frame:SetResizable (false)
		container_interrupt_frame:SetMovable (true)
		
		container_interrupt_window:SetWidth (170)
		container_interrupt_window:SetHeight (65)
		container_interrupt_window:SetScrollChild (container_interrupt_frame)
		container_interrupt_window:SetPoint ("TOPLEFT", frame, "TOPLEFT", 480, -113)

		DetailsFrameWork:NewLabel (container_interrupt_window, container_interrupt_window, nil, "titulo", Loc ["STRING_INTERRUPTS"], "QuestFont_Large", 16, {1, 1, 1})
		container_interrupt_window.titulo:SetPoint ("bottomleft", container_interrupt_window, "topleft", 0, 4)
		
		DetailsFrameWork:NewScrollBar (container_interrupt_window, container_interrupt_frame, 4, -13)
		container_interrupt_window.slider:Altura (45)
		container_interrupt_window.slider:cimaPoint (0, 1)
		container_interrupt_window.slider:baixoPoint (0, -1)
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
		mouseOver_dispell_frame:SetHeight (50)
		
		mouseOver_dispell_frame.imagem = mouseOver_dispell_frame:CreateTexture (nil, "overlay")
		mouseOver_dispell_frame.imagem:SetPoint ("topright", mouseOver_dispell_frame, "topright", -8, -17)
		
		mouseOver_dispell_frame.imagem:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_icons")
		mouseOver_dispell_frame.imagem:SetTexCoord (0, 0.15625, 0.4140625, 0.71875)
		mouseOver_dispell_frame.imagem:SetWidth (40)
		mouseOver_dispell_frame.imagem:SetHeight (39)
		
		mouseOver_dispell_frame:SetScript ("OnEnter", 
			function()
				_G.DetailsBubble:SetOwner (mouseOver_dispell_frame.imagem, nil, nil, -45, -22)
				_G.DetailsBubble:FlipHorizontal()
				_G.DetailsBubble:SetBubbleText (Loc ["STRING_DISPELL_HELP"])
				_G.DetailsBubble:ShowBubble()
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
		
		--container_dispell_window:SetBackdrop (backdrop)
		--container_dispell_window:SetBackdropBorderColor (0,0,0,0)
		
		--container_dispell_window:SetBackdrop (gump_fundo_backdrop)
		--container_dispell_window:SetBackdropBorderColor (1, 1, 1, 1)
		--container_dispell_window:SetBackdropColor (0, 0, 0, 0.1)
		
		container_dispell_frame:SetAllPoints (container_dispell_window)
		container_dispell_frame:SetWidth (170)
		container_dispell_frame:SetHeight (62)
		container_dispell_frame:EnableMouse (true)
		container_dispell_frame:SetResizable (false)
		container_dispell_frame:SetMovable (true)
		
		container_dispell_window:SetWidth (170)
		container_dispell_window:SetHeight (68)
		container_dispell_window:SetScrollChild (container_dispell_frame)
		container_dispell_window:SetPoint ("TOPLEFT", frame, "TOPLEFT", 260, -231)

		DetailsFrameWork:NewLabel (container_dispell_window, container_dispell_window, nil, "titulo", Loc ["STRING_DISPELLS"], "QuestFont_Large", 16, {1, 1, 1})
		container_dispell_window.titulo:SetPoint ("bottomleft", container_dispell_window, "topleft", 0, 4)
		
		DetailsFrameWork:NewScrollBar (container_dispell_window, container_dispell_frame, 4, -13)
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
		mouseOver_dead_frame.imagem:SetPoint ("topright", mouseOver_dead_frame, "topright", -14, -10)
		
		mouseOver_dead_frame.imagem:SetTexture ("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_icons")
		mouseOver_dead_frame.imagem:SetTexCoord (0, 0.1640625, 0.03125, 0.34375)
		mouseOver_dead_frame.imagem:SetWidth (42)
		mouseOver_dead_frame.imagem:SetHeight (41)
		
		mouseOver_dead_frame:SetScript ("OnEnter", 
			function()
				_G.DetailsBubble:SetOwner (mouseOver_dead_frame.imagem, nil, nil, 40, -18)
				--_G.DetailsBubble:FlipHorizontal()
				_G.DetailsBubble:SetBubbleText (Loc ["STRING_DEATHS_HELP"])
				_G.DetailsBubble:ShowBubble()
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
		
		--container_dead_window:SetBackdrop({edgeFile = "Interface\\DialogFrame\\UI-DialogBox-gold-Border", tile = true, tileSize = 16, edgeSize = 5, insets = {left = 1, right = 1, top = 0, bottom = 1},})		
		--container_dead_window:SetBackdropBorderColor (0,0,0,0)
		
		--container_dead_window:SetBackdrop (gump_fundo_backdrop)
		--container_dead_window:SetBackdropBorderColor (1, 1, 1, 1)
		--container_dead_window:SetBackdropColor (0, 0, 0, 0.1)
		
		--container_dead_frame:SetAllPoints (container_dead_window)
		container_dead_frame:SetPoint ("left", container_dead_window, "left")
		container_dead_frame:SetPoint ("right", container_dead_window, "right")
		container_dead_frame:SetPoint ("top", container_dead_window, "top")
		container_dead_frame:SetPoint ("bottom", container_dead_window, "bottom", 0, 10)

		container_dead_frame:SetWidth (170)
		container_dead_frame:SetHeight (60)
		
		container_dead_frame:EnableMouse (true)
		container_dead_frame:SetResizable (false)
		container_dead_frame:SetMovable (true)
		
		container_dead_window:SetWidth (170)
		container_dead_window:SetHeight (70)
		container_dead_window:SetScrollChild (container_dead_frame)
		container_dead_window:SetPoint ("TOPLEFT", frame, "TOPLEFT", 480, -235)

		DetailsFrameWork:NewLabel (container_dead_window, container_dead_window, nil, "titulo", Loc ["STRING_DEATH_LOG"], "QuestFont_Large", 16, {1, 1, 1})
		container_dead_window.titulo:SetPoint ("bottomleft", container_dead_window, "topleft", 0, 3)
		
		DetailsFrameWork:NewScrollBar (container_dead_window, container_dead_frame, 4, -9)
		container_dead_window.slider:Altura (45)
		container_dead_window.slider:cimaPoint (0, 1)
		container_dead_window.slider:baixoPoint (0, -1)
		container_dead_frame.slider = container_dead_window.slider
		
		container_dead_window.gump = container_dead_frame
		container_dead_frame.window = container_dead_window
		container_dead_window.ultimo = 0
		frame.overall_dead = container_dead_window
		
		
	--> funções dos botões das fases
		local disable_func = function (self) self.texto:SetTextColor (.4, .4, .4) end 
		local enable_func = function (self) self.texto:SetTextColor (.7, .7, .7) end 
		
		function frame.ShowOverall()
			return true
		end
		function frame.ShowFase (fase)
			return true
		end
		
	--> Botão Overall
		local botao_overall = DetailsFrameWork:NewDetailsButton (frame, frame, _, frame.ShowOverall, _, nil, 32, 16,
		"Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button_disabled", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button")
		botao_overall:SetPoint ("topleft", frame, "topleft", 480, -50)
		DetailsFrameWork:NewLabel (botao_overall, botao_overall, nil, "texto", "A", "QuestFont_Large", 12, {.7, .7, .7})
		botao_overall.texto:SetPoint ("center", botao_overall, "center", 0, 1)
		botao_overall:SetScript ("OnEnable", enable_func)
		botao_overall:SetScript ("OnDisable", disable_func)
		botao_overall.tooltip = Loc ["STRING_SHOW_ALL_DATA"].."\n|cFFFF0000"..Loc ["STRING_NOT IMPLEMENTED"]
		

	--> Botão Fase 1
		local botao_fase1 = DetailsFrameWork:NewDetailsButton (frame, frame, _, frame.ShowFase, 1, nil, 32, 16,
		"Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button_disabled", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button")
		botao_fase1:SetPoint ("left", botao_overall, "right", 2, 0)
		DetailsFrameWork:NewLabel (botao_fase1, botao_fase1, nil, "texto", "F1", "QuestFont_Large", 12, {.7, .7, .7})
		botao_fase1.texto:SetPoint ("center", botao_fase1, "center", 0, 1)
		botao_fase1:SetScript ("OnEnable", enable_func)
		botao_fase1:SetScript ("OnDisable", disable_func)
		botao_fase1.tooltip = Loc ["STRING_SHOW_PHASE_DATA"].."\n|cFFFF0000"..Loc ["STRING_NOT IMPLEMENTED"]
		
	--> Botão Fase 2	
		local botao_fase2 = DetailsFrameWork:NewDetailsButton (frame, frame, _, frame.ShowFase, 2, nil, 32, 16,
		"Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button_disabled", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button")
		botao_fase2:SetPoint ("left", botao_fase1, "right", 2, 0)
		DetailsFrameWork:NewLabel (botao_fase2, botao_fase2, nil, "texto", "F2", "QuestFont_Large", 12, {.7, .7, .7})
		botao_fase2.texto:SetPoint ("center", botao_fase2, "center", 0, 1)
		botao_fase2:SetScript ("OnEnable", enable_func)
		botao_fase2:SetScript ("OnDisable", disable_func)
		botao_fase2.tooltip = Loc ["STRING_SHOW_PHASE_DATA"].."\n|cFFFF0000"..Loc ["STRING_NOT IMPLEMENTED"]
		
	--> Botão Fase 3
		local botao_fase3 = DetailsFrameWork:NewDetailsButton (frame, frame, _, frame.ShowFase, 3, nil, 32, 16,
		"Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button_disabled", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button")
		botao_fase3:SetPoint ("left", botao_fase2, "right", 2, 0)
		DetailsFrameWork:NewLabel (botao_fase3, botao_fase3, nil, "texto", "F3", "QuestFont_Large", 12, {.7, .7, .7})
		botao_fase3.texto:SetPoint ("center", botao_fase3, "center", 0, 1)
		botao_fase3:SetScript ("OnEnable", enable_func)
		botao_fase3:SetScript ("OnDisable", disable_func)
		botao_fase3.tooltip = Loc ["STRING_SHOW_PHASE_DATA"].."\n|cFFFF0000"..Loc ["STRING_NOT IMPLEMENTED"]
		
	--> Botão Fase 4
		local botao_fase4 = DetailsFrameWork:NewDetailsButton (frame, frame, _, frame.ShowFase, 4, nil, 32, 16,
		"Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button_disabled", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button")
		botao_fase4:SetPoint ("left", botao_fase3, "right", 2, 0)
		DetailsFrameWork:NewLabel (botao_fase4, botao_fase4, nil, "texto", "F4", "QuestFont_Large", 12, {.7, .7, .7})
		botao_fase4.texto:SetPoint ("center", botao_fase4, "center", 0, 1)
		botao_fase4:SetScript ("OnEnable", enable_func)
		botao_fase4:SetScript ("OnDisable", disable_func)
		botao_fase4.tooltip = Loc ["STRING_SHOW_PHASE_DATA"].."\n|cFFFF0000"..Loc ["STRING_NOT IMPLEMENTED"]
		
	--> Botão Fase 5
		local botao_fase5 = DetailsFrameWork:NewDetailsButton (frame, frame, _, frame.ShowFase, 5, nil, 32, 16,
		"Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button_disabled", "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_button")
		botao_fase5:SetPoint ("left", botao_fase4, "right", 2, 0)
		DetailsFrameWork:NewLabel (botao_fase5, botao_fase5, nil, "texto", "F5", "QuestFont_Large", 12, {.7, .7, .7})
		botao_fase5.texto:SetPoint ("center", botao_fase5, "center", 0, 1)
		botao_fase5:SetScript ("OnEnable", enable_func)
		botao_fase5:SetScript ("OnDisable", disable_func)
		botao_fase5.tooltip = Loc ["STRING_SHOW_PHASE_DATA"].."\n|cFFFF0000"..Loc ["STRING_NOT IMPLEMENTED"]
	
	
	botao_overall:SetFrameLevel (frame:GetFrameLevel()+2)
	botao_fase1:SetFrameLevel (frame:GetFrameLevel()+2)
	botao_fase2:SetFrameLevel (frame:GetFrameLevel()+2)
	botao_fase3:SetFrameLevel (frame:GetFrameLevel()+2)
	botao_fase4:SetFrameLevel (frame:GetFrameLevel()+2)
	botao_fase5:SetFrameLevel (frame:GetFrameLevel()+2)
		
		--> os botões das fases estão desativados pois não foram implementados ainda
		--[[
		botao_overall:Disable()
		botao_fase1:Disable()
		botao_fase2:Disable()
		botao_fase3:Disable()
		botao_fase4:Disable()
		botao_fase5:Disable()
		--]]
		
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
	
end
end
