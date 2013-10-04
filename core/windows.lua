--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = _G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers
	
	local _math_floor = math.floor --lua local
	local _type = type --lua local
	local _math_abs = math.abs --lua local
	local _ipairs = ipairs --lua local
	
	local _GetScreenWidth = GetScreenWidth --wow api local
	local _GetScreenHeight = GetScreenHeight --wow api local
	local _UIParent = UIParent --wow api local
	
	local gump = _detalhes.gump --details local
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core


	function _detalhes:AnimarSplit (barra, goal)
		barra.inicio = barra.split.barra:GetValue()
		barra.fim = goal
		barra.proximo_update = 0
		barra.tem_animacao = 1
		barra:SetScript ("OnUpdate", self.FazerAnimacaoSplit)
	end

	function _detalhes:FazerAnimacaoSplit (elapsed)

	--[[
		local velocidade = 0.1
		local distancia = self.inicio - self.fim
		if (distancia > 40 or distancia < -40) then
			velocidade = 0.8
		elseif (distancia > 20 or distancia < -20) then
			velocidade = 0.4
		end
	--]]
		local velocidade = 0.8
		
		if (self.fim > self.inicio) then
			self.inicio = self.inicio+velocidade
			self.split.barra:SetValue (self.inicio)

			self.split.div:SetPoint ("left", self.split.barra, "left", self.split.barra:GetValue()* (self.split.barra:GetWidth()/100) - 4, 0)
			
			if (self.inicio+1 >= self.fim) then
				self.tem_animacao = 0
				self:SetScript ("OnUpdate", nil)
			end
		else
			self.inicio = self.inicio-velocidade
			self.split.barra:SetValue (self.inicio)
			
			self.split.div:SetPoint ("left", self.split.barra, "left", self.split.barra:GetValue()* (self.split.barra:GetWidth()/100) - 4, 0)
			
			if (self.inicio-1 <= self.fim) then
				self.tem_animacao = 0
				self:SetScript ("OnUpdate", nil)
			end
		end
		self.proximo_update = 0
	end

	function _detalhes:AnimarBarra (esta_barra, fim)
		esta_barra.inicio = esta_barra.statusbar:GetValue()
		esta_barra.fim = fim
		esta_barra.proximo_update = 0
		esta_barra.tem_animacao = 1
		esta_barra:SetScript ("OnUpdate", self.FazerAnimacao)
	end

	function _detalhes:FazerAnimacao (elapsed)
	
		local velocidade = 0.8
		--[[
		local velocidade = 0.1
		local distancia = self.inicio - self.fim
		if (distancia > 40 or distancia < -40) then
			velocidade = 0.8
		elseif (distancia > 20 or distancia < -20) then
			velocidade = 0.4
		end
		--]]
		if (self.fim > self.inicio) then
			self.inicio = self.inicio+velocidade
			self.statusbar:SetValue (self.inicio)
			if (self.inicio+1 >= self.fim) then
				self.tem_animacao = 0
				self:SetScript ("OnUpdate", nil)
			end
		else
			self.inicio = self.inicio-velocidade
			self.statusbar:SetValue (self.inicio)
			if (self.inicio-1 <= self.fim) then
				self.tem_animacao = 0
				self:SetScript ("OnUpdate", nil)
			end
		end
		self.proximo_update = 0
	end

	function _detalhes:AtualizaPontos()
		local xOfs, yOfs = self.baseframe:GetCenter()
		
		if (not xOfs) then
			return
		end
		
		-- credits to ckknight (http://www.curseforge.com/profiles/ckknight/) 
		local _scale = self.baseframe:GetEffectiveScale()
		local _UIscale = _UIParent:GetScale()
		xOfs = xOfs*_scale - _GetScreenWidth()*_UIscale/2
		yOfs = yOfs*_scale - _GetScreenHeight()*_UIscale/2
		local _x = xOfs/_UIscale
		local _y = yOfs/_UIscale
		local _w = self.baseframe:GetWidth()
		local _h = self.baseframe:GetHeight()
		
		local metade_largura = _w/2
		local metade_altura = _h/2
		
		self.ponto1 = {x = _x - metade_largura, y = _y + metade_altura}
		self.ponto2 = {x = _x - metade_largura, y = _y - metade_altura}
		self.ponto3 = {x = _x + metade_largura, y = _y - metade_altura}
		self.ponto4 = {x = _x + metade_largura, y = _y + metade_altura}
	end

	function _detalhes:SaveMainWindowPosition (instance)
		
		if (instance) then
			self = instance
		end

		local xOfs, yOfs = self.baseframe:GetCenter() 
		
		if (not xOfs) then
			--> this is a small and unknow bug when resizing all windows throgh crtl key (all) the last window of a horizontal row can't 'GetCenter'.
			--> so, the trick is we start a timer to save pos later.
			return _detalhes:ScheduleTimer ("SaveMainWindowPosition", 1, self)
		end
		
		-- credits to ckknight (http://www.curseforge.com/profiles/ckknight/) 
		local _scale = self.baseframe:GetEffectiveScale()
		local _UIscale = _UIParent:GetScale()
		local mostrando = self.mostrando

		xOfs = xOfs*_scale - _GetScreenWidth()*_UIscale/2
		yOfs = yOfs*_scale - _GetScreenHeight()*_UIscale/2
		
		local _w = self.baseframe:GetWidth()
		local _h = self.baseframe:GetHeight()
		local _x = xOfs/_UIscale
		local _y = yOfs/_UIscale
		
		self.posicao[mostrando].x = _x
		self.posicao[mostrando].y = _y
		self.posicao[mostrando].w = _w
		self.posicao[mostrando].h = _h
		
		local metade_largura = _w/2
		local metade_altura = _h/2
		
		self.ponto1 = {x = _x - metade_largura, y = _y + metade_altura}
		self.ponto2 = {x = _x - metade_largura, y = _y - metade_altura}
		self.ponto3 = {x = _x + metade_largura, y = _y - metade_altura}
		self.ponto4 = {x = _x + metade_largura, y = _y + metade_altura}
		
		self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight()-4 --> isso aqui não sei o que esta fazendo aqui
		
		return {altura = self.baseframe:GetHeight(), largura = self.baseframe:GetWidth(), x = xOfs/_UIscale, y = yOfs/_UIscale}
	end

	function _detalhes:RestoreMainWindowPosition (pre_defined)

		-- credits to ckknight (http://www.curseforge.com/profiles/ckknight/) 
		local _scale = self.baseframe:GetEffectiveScale() 
		local _UIscale = _UIParent:GetScale()

		local novo_x = self.posicao[self.mostrando].x*_UIscale/_scale
		local novo_y = self.posicao[self.mostrando].y*_UIscale/_scale
		
		if (pre_defined) then --> overwrite
			novo_x = pre_defined.x*_UIscale/_scale
			novo_y = pre_defined.y*_UIscale/_scale
			self.posicao[self.mostrando].w = pre_defined.largura
			self.posicao[self.mostrando].h = pre_defined.altura
		end

		self.baseframe:ClearAllPoints()
		self.baseframe:SetPoint ("CENTER", _UIParent, "CENTER", novo_x, novo_y)

		self.baseframe:SetWidth (self.posicao[self.mostrando].w) --slider frame
		self.baseframe:SetHeight (self.posicao[self.mostrando].h)

		self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight()-4 --> ?????
	end

	function _detalhes:RestoreMainWindowPositionNoResize (pre_defined, x, y)

		x = x or 0
		y = y or 0

		-- credits to ckknight (http://www.curseforge.com/profiles/ckknight/) 
		local _scale = self.baseframe:GetEffectiveScale() 
		local _UIscale = _UIParent:GetScale()

		local novo_x = self.posicao[self.mostrando].x*_UIscale/_scale
		local novo_y = self.posicao[self.mostrando].y*_UIscale/_scale
		
		if (pre_defined) then --> overwrite
			novo_x = pre_defined.x*_UIscale/_scale
			novo_y = pre_defined.y*_UIscale/_scale
			self.posicao[self.mostrando].w = pre_defined.largura
			self.posicao[self.mostrando].h = pre_defined.altura
		end

		self.baseframe:ClearAllPoints()
		self.baseframe:SetPoint ("CENTER", _UIParent, "CENTER", novo_x + x, novo_y + y)
		self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight()-4 --> ?????
	end

	function _detalhes:ResetaGump (instancia, tipo, segmento)
		if (not instancia or _type (instancia) == "boolean") then
			segmento = tipo
			tipo = instancia
			instancia = self
		end
		
		if (tipo and tipo == 0x1) then --> entrando em combate
			if (instancia.segmento == -1) then --> esta mostrando a tabela overall
				return
			end
		end
		
		if (segmento and instancia.segmento ~= segmento) then
			return
		end

		instancia.barraS = {nil, nil} --> zera o iterator
		instancia.barrasInfo.mostrando = 0 --> resetou, então não esta mostranho nenhuma barra
		
		for i = 1, instancia.barrasInfo.criadas, 1 do --> limpa a referência do que estava sendo mostrado na barra
			local esta_barra= instancia.barras[i]
			esta_barra.minha_tabela = nil
		end
		
		if (instancia.rolagem) then
			instancia:EsconderScrollBar() --> hida a scrollbar
		end
		instancia.need_rolagem = false
		instancia.bar_mod = nil

	end

	function _detalhes:ReajustaGump()
		
		if (self.mostrando == "normal") then --> somente alterar o tamanho das barras se tiver mostrando o gump normal
		
			if (self.meu_id == _detalhes.ResetButtonInstance) then
				if (self.baseframe:GetWidth() < 215) then
					gump:Fade (_detalhes.ResetButton, 1)
					gump:Fade (_detalhes.ResetButton2, 0)
					_detalhes.ResetButtonMode = 2
				else
					gump:Fade (_detalhes.ResetButton, 0)
					gump:Fade (_detalhes.ResetButton2, 1)
					_detalhes.ResetButtonMode = 1
				end
			end
			
			if (not self.baseframe.isStretching and self.stretchToo and #self.stretchToo > 0) then
				if (self.eh_horizontal or self.eh_tudo or (self.verticalSnap and not self.eh_vertical)) then
					for _, instancia in _ipairs (self.stretchToo) do 
						instancia.baseframe:SetWidth (self.baseframe:GetWidth())
						local mod = (self.baseframe:GetWidth() - instancia.baseframe._place.largura) / 2
						instancia:RestoreMainWindowPositionNoResize (instancia.baseframe._place, mod, nil)
						instancia:BaseFrameSnap()
					end
				end
				if ( (self.eh_vertical or self.eh_tudo or not self.eh_horizontal) and (not self.verticalSnap or self.eh_vertical)) then
					for _, instancia in _ipairs (self.stretchToo) do 
						if (instancia.baseframe) then --> esta criada
							instancia.baseframe:SetHeight (self.baseframe:GetHeight())
							local mod
							if (self.eh_vertical) then
								mod = (self.baseframe:GetHeight() - instancia.baseframe._place.altura) / 2
							else
								mod = - (self.baseframe:GetHeight() - instancia.baseframe._place.altura) / 2
							end
							instancia:RestoreMainWindowPositionNoResize (instancia.baseframe._place, nil, mod)
							instancia:BaseFrameSnap()
						end
					end
				end
			elseif (self.baseframe.isStretching and self.stretchToo and #self.stretchToo > 0) then
				for _, instancia in _ipairs (self.stretchToo) do 
					instancia.baseframe:SetHeight (self.baseframe:GetHeight())
					local mod = (self.baseframe:GetHeight() - instancia.baseframe._place.altura) / 2
					instancia:RestoreMainWindowPositionNoResize (instancia.baseframe._place, nil, mod)
				end
			end
			
			if (_detalhes.lower_instance == self.meu_id or self.consolidate) then
				if (not self.consolidate) then
					if (self.baseframe:GetWidth() < 180) then
						--> consolidate menus
						self:ConsolidateIcons()
					end
				else
					if (self.baseframe:GetWidth() > 180 or _detalhes.lower_instance ~= self.meu_id) then
						--> un consolidade menus
						self:UnConsolidateIcons()
					end
				end
			end
			
			if (self.freezed) then
				--> reajusta o freeze
				_detalhes:Freeze (self)
			end
		
			-- -4 difere a precisão de quando a barra será adicionada ou apagada da barra
			self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight()-4

			local T = self.barrasInfo.cabem
			if (not T) then --> primeira vez que o gump esta sendo reajustado
				T = _math_floor (self.baseframe.BoxBarrasAltura / self.barrasInfo.alturaReal)
				-- o que mais precisa por aqui?
			end
			
			--> reajustar o local do relógio
			local meio = self.baseframe:GetWidth() / 2
			local novo_local = meio - 25
			self.barrasInfo.cabem = _math_floor ( self.baseframe.BoxBarrasAltura / self.barrasInfo.alturaReal)

			if (self.barrasInfo.cabem > #self.barras) then--> verifica se precisa criar mais barras
				for i  = #self.barras+1, self.barrasInfo.cabem, 1 do
					local nova_barra = gump:CriaNovaBarra (self, i, 30) --> cria nova barra
					nova_barra.texto_esquerdo:SetText (Loc ["STRING_NEWROW"]) --seta o texto da esqueda
					nova_barra.statusbar:SetValue (100)
					self.barras [i] = nova_barra
				end
				self.barrasInfo.criadas = #self.barras
			end
			
			--> seta a largura das barras
			if (self.bar_mod and self.bar_mod ~= 0) then
				for index = 1, self.barrasInfo.cabem do
					self.barras [index]:SetWidth (self.baseframe:GetWidth()+self.bar_mod)
				end
			else
				for index = 1, self.barrasInfo.cabem do
					self.barras [index]:SetWidth (self.baseframe:GetWidth()+self.barrasInfo.espaco.direita)
				end
			end
			
			local A = self.barraS[1]
			if (not A) then --> primeira vez que o resize esta sendo usado, no caso no startup do addon ou ao criar uma nova instância
				--> hida as barras não usadas
				for i = 1, self.barrasInfo.criadas, 1 do
					gump:Fade (self.barras [i], 1)
					self.barras [i].on = false
				end	
				return
			end
			
			local X = self.barrasInfo.mostrando
			local C = self.barrasInfo.cabem

			--> novo iterator
			local barras_diff = C - T --> aqui pega a quantidade de barras, se aumentou ou diminuiu
			if (barras_diff > 0) then --> ganhou barras_diff novas barras
				local fim_iterator = self.barraS[2] --> posição atual
				fim_iterator = fim_iterator+barras_diff --> nova posição
				local excedeu_iterator = fim_iterator - X --> total que ta sendo mostrado - fim do iterator
				if (excedeu_iterator > 0) then --> extrapolou
					fim_iterator = X --> seta o fim do iterator pra ser na ultima barra
					self.barraS[2] = fim_iterator --> fim do iterator setado
					
					local inicio_iterator = self.barraS[1]
					if (inicio_iterator-excedeu_iterator > 0) then --> se as barras que sobraram preenchem o inicio do iterator
						inicio_iterator = inicio_iterator-excedeu_iterator --> pega o novo valor do iterator
						self.barraS[1] = inicio_iterator
					else
						self.barraS[1] = 1 --> se ganhou mais barras pra cima, ignorar elas e mover o iterator para a pocição inicial
					end
				else
					--> se não extrapolou esta okey e esta mostrando a quantidade de barras correta
					self.barraS[2] = fim_iterator
				end
				
				for index = T+1, C do
					if (index <= X) then
						gump:Fade (self.barras[index], "out")
					else
						--gump:Fade (self.barras[index], "in")
						if (self.baseframe.isStretching or self.auto_resize) then
							gump:Fade (self.barras[index], 1)
						else
							gump:Fade (self.barras[index], "in", 0.1)
						end
					end
				end
				
			elseif (barras_diff < 0) then --> perdeu barras_diff barras
				local fim_iterator = self.barraS[2] --> posição atual
				if (not (fim_iterator == X and fim_iterator < C)) then --> calcula primeiro as barras que foram perdidas são barras que não estavam sendo usadas
					--> perdi X barras, diminui X posições no iterator
					local perdeu = _math_abs (barras_diff)
					
					if (fim_iterator == X) then --> se o iterator tiver na ultima posição
						perdeu = perdeu - (C - X)
					end
					
					fim_iterator = fim_iterator - perdeu
					
					if (fim_iterator < C) then
						fim_iterator = C
					end
					
					self.barraS[2] = fim_iterator
					
					for index = T, C+1, -1 do
						--gump:Fade (self.barras[index], "in")
						if (self.baseframe.isStretching or self.auto_resize) then
							gump:Fade (self.barras[index], 1)
						else
							gump:Fade (self.barras[index], "in", 0.1)
						end
					end
				end
			end

			if (X <= C) then --> desligar a rolagem
				if (self.rolagem and not self.baseframe.isStretching) then
					self:EsconderScrollBar()
				end
				self.need_rolagem = false
			else --> ligar ou atualizar a rolagem
				if (not self.rolagem and not self.baseframe.isStretching) then
					self:MostrarScrollBar()
				end
				self.need_rolagem = true
			end
			
			--> verificar o tamanho dos nomes
			local qual_barra = 1
			for i = self.barraS[1], self.barraS[2], 1 do
				local esta_barra = self.barras [qual_barra]
				local tabela = esta_barra.minha_tabela
				
				if (tabela) then --> a barra esta mostrando alguma coisa
				
					if (tabela._custom) then 
						tabela (esta_barra, self)
					else
						tabela:RefreshBarra (esta_barra, self, true)
					end
					
					if (esta_barra.minha_tabela.enemy) then
						--if (i == 1) then
							--print (esta_barra.texto_esquerdo:GetWrappedWidth())
						--end
						
						--esta_barra.texto_esquerdo:SetText (esta_barra.colocacao.."."..esta_barra.minha_tabela.nome.." |TInterface\\PVPFrame\\PVP-Currency-Horde:14:14|t") --seta o texto da esqueda

						--local texto_len = esta_barra.texto_esquerdo:GetStringWidth()
						--if (esta_barra.texto_esquerdo:IsTruncated()) then
							--local tamanho = esta_barra:GetWidth()-esta_barra.texto_direita:GetStringWidth()-16-esta_barra:GetHeight()
							--esta_barra.icone_secundario:SetPoint ("left", esta_barra.texto_esquerdo, "left", tamanho-2, 0)
							--print ("aqui")
						--else
							--print ("aqui")
							--if (i == 1) then
								--print (esta_barra.texto_esquerdo:GetStringWidth()) --debug
								--print (esta_barra.texto_esquerdo:GetText())
							--end
							--local fonte, size, flags = esta_barra.texto_esquerdo:GetFont()
							--print (fonte, size, flags)
							--esta_barra.icone_secundario:SetPoint ("left", esta_barra.texto_esquerdo, "left", esta_barra.texto_esquerdo:GetStringWidth()+3, 0)
							--esta_barra.texto_esquerdo:SetText (esta_barra.colocacao.."."..esta_barra.minha_tabela.nome.." |TInterface\\PVPFrame\\PVP-Currency-Horde:14:14|t") --seta o texto da esqueda
						--end
					end
				end
				
				qual_barra = qual_barra+1
			end
			
			--> força o próximo refresh
			self.showing[self.atributo].need_refresh = true

		end	
	end

	--> cria o frame de wait for plugin
	do
		local WaitForPluginFrame = CreateFrame ("frame", "DetailsWaitForPluginFrame", UIParent)
		local WaitTexture = WaitForPluginFrame:CreateTexture (nil, "overlay")
		WaitTexture:SetTexture ("Interface\\UNITPOWERBARALT\\Mechanical_Circular_Frame")
		WaitTexture:SetPoint ("center", WaitForPluginFrame)
		WaitTexture:SetWidth (180)
		WaitTexture:SetHeight (180)
		WaitForPluginFrame.wheel = WaitTexture
		local RotateAnimGroup = WaitForPluginFrame:CreateAnimationGroup()
		local rotate = RotateAnimGroup:CreateAnimation ("Rotation")
		rotate:SetDegrees (360)
		rotate:SetDuration (60)
		RotateAnimGroup:SetLooping ("repeat")
		
		local bgpanel = gump:NewPanel (UIParent, UIParent, "DetailsWaitFrameBG", nil, 120, 30, false, false, false)
		bgpanel:SetPoint ("center", WaitForPluginFrame, "center")
		bgpanel:SetBackdrop ({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
		bgpanel:SetBackdropColor (.2, .2, .2, 1)
		
		local label = gump:NewLabel (UIParent, UIParent, nil, nil, Loc ["STRING_WAITPLUGIN"]) --> localize-me
		label.color = "silver"
		label:SetPoint ("center", WaitForPluginFrame, "center")
		label:SetJustifyH ("center")
		label:Hide()

		WaitForPluginFrame:Hide()	
		
		function _detalhes:WaitForSoloPlugin (instancia)
		
			if (WaitForPluginFrame:IsShown() and WaitForPluginFrame:GetParent() == instancia.baseframe) then
				return _detalhes:ScheduleTimer ("ExecDelayedPlugin", 5, instancia)
			end
		
			WaitForPluginFrame:SetParent (instancia.baseframe)
			WaitForPluginFrame:SetAllPoints (instancia.baseframe)
			local size = math.max (instancia.baseframe:GetHeight()* 0.35, 100) 
			WaitForPluginFrame.wheel:SetWidth (size)
			WaitForPluginFrame.wheel:SetHeight (size)
			WaitForPluginFrame:Show()
			label:Show()
			bgpanel:Show()
			RotateAnimGroup:Play()
			
			return _detalhes:ScheduleTimer ("ExecDelayedPlugin", 5, instancia)
		end
		
		function _detalhes:CancelWaitForPlugin()
			RotateAnimGroup:Stop()
			WaitForPluginFrame:Hide()	
			label:Hide()
			bgpanel:Hide()
		end
		
		function _detalhes:ExecDelayedPlugin (instancia)
			RotateAnimGroup:Stop()
			WaitForPluginFrame:Hide()	
			label:Hide()
			bgpanel:Hide()
			if (instancia.meu_id == _detalhes.solo) then
				_detalhes.SoloTables:switch (_, _detalhes.SoloTables.Mode)
			elseif (instancia.meu_id == _detalhes.raid) then
				_detalhes.RaidTables:switch (_, _detalhes.RaidTables.Mode)
			end
		end	
	end
