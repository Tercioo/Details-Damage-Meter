	
	local _detalhes =	_G._detalhes
	local Loc =			LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local libwindow	=	LibStub ("LibWindow-1.1")
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers
	
	local _math_floor = math.floor --lua local
	local _type = type --lua local
	local _math_abs = math.abs --lua local
	local _math_min = math.min
	local _ipairs = ipairs --lua local
	
	local _GetScreenWidth = GetScreenWidth --wow api local
	local _GetScreenHeight = GetScreenHeight --wow api local
	local _UIParent = UIParent --wow api local
	
	local gump = _detalhes.gump --details local
	local _
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local end_window_spacement = 0
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	function _detalhes:AnimarSplit (barra, goal)
		barra.inicio = barra.split.barra:GetValue()
		barra.fim = goal
		barra.proximo_update = 0
		barra.tem_animacao = true
		barra:SetScript ("OnUpdate", self.FazerAnimacaoSplit)
	end

	function _detalhes:FazerAnimacaoSplit (elapsed)
		local velocidade = 0.8
		
		if (self.fim > self.inicio) then
			self.inicio = self.inicio+velocidade
			self.split.barra:SetValue (self.inicio)

			self.split.div:SetPoint ("left", self.split.barra, "left", self.split.barra:GetValue()* (self.split.barra:GetWidth()/100) - 4, 0)
			
			if (self.inicio+1 >= self.fim) then
				self.tem_animacao = false
				self:SetScript ("OnUpdate", nil)
			end
		else
			self.inicio = self.inicio-velocidade
			self.split.barra:SetValue (self.inicio)
			
			self.split.div:SetPoint ("left", self.split.barra, "left", self.split.barra:GetValue()* (self.split.barra:GetWidth()/100) - 4, 0)
			
			if (self.inicio-1 <= self.fim) then
				self.tem_animacao = false
				self:SetScript ("OnUpdate", nil)
			end
		end
		self.proximo_update = 0
	end

	function _detalhes:fazer_animacoes (amt_barras)
		--aqui

		if (self.bars_sort_direction == 2) then
		
			for i = _math_min (self.rows_fit_in_window, amt_barras) - 1, 1, -1 do
				local row = self.barras [i]
				local row_proxima = self.barras [i-1]
				
				if (row_proxima and not row.animacao_ignorar) then
					local v = row.statusbar.value
					local v_proxima = row_proxima.statusbar.value
					
					if (v_proxima > v) then
						if (row.animacao_fim >= v_proxima) then
							row:SetValue (v_proxima)
						else
							row:SetValue (row.animacao_fim)
							row_proxima.statusbar:SetValue (row.animacao_fim)
						end
					end
				end
			end
			
			for i = 1, self.rows_fit_in_window -1 do
				local row = self.barras [i]
				if (row.animacao_ignorar) then
					row.animacao_ignorar = nil
					if (row.tem_animacao) then
						row.tem_animacao = false
						row:SetScript ("OnUpdate", nil)
					end
				else
					if (row.animacao_fim ~= row.animacao_fim2) then
						_detalhes:AnimarBarra (row, row.animacao_fim)
						row.animacao_fim2 = row.animacao_fim
					end
				end
			end
		else
			for i = 2, self.rows_fit_in_window do
				local row = self.barras [i]
				local row_proxima = self.barras [i+1]
				
				if (row_proxima and not row.animacao_ignorar) then
					local v = row.statusbar.value
					local v_proxima = row_proxima.statusbar.value
					
					if (v_proxima > v) then
						if (row.animacao_fim >= v_proxima) then
							row:SetValue (v_proxima)
						else
							row:SetValue (row.animacao_fim)
							row_proxima.statusbar:SetValue (row.animacao_fim)
						end
					end
				end
			end
			
			for i = 2, self.rows_fit_in_window do
				local row = self.barras [i]
				if (row.animacao_ignorar) then
					row.animacao_ignorar = nil
					if (row.tem_animacao) then
						row.tem_animacao = false
						row:SetScript ("OnUpdate", nil)
					end
				else
					if (row.animacao_fim ~= row.animacao_fim2) then
						_detalhes:AnimarBarra (row, row.animacao_fim)
						row.animacao_fim2 = row.animacao_fim
					end
				end
			end
		end
		
	end
	
	function _detalhes:AnimarBarra (esta_barra, fim)
		esta_barra.inicio = esta_barra.statusbar.value
		esta_barra.fim = fim
		esta_barra.tem_animacao = true
		
		if (esta_barra.fim > esta_barra.inicio) then
			esta_barra:SetScript ("OnUpdate", self.FazerAnimacao_Direita)
		else
			esta_barra:SetScript ("OnUpdate", self.FazerAnimacao_Esquerda)
		end
	end

	function _detalhes:FazerAnimacao_Esquerda (elapsed)
		self.inicio = self.inicio - 1
		self:SetValue (self.inicio)
		if (self.inicio-1 <= self.fim) then
			self.tem_animacao = false
			self:SetScript ("OnUpdate", nil)
		end
	end
	
	function _detalhes:FazerAnimacao_Direita (elapsed)
		self.inicio = self.inicio + 1
		self:SetValue (self.inicio)
		if (self.inicio+1 >= self.fim) then
			self.tem_animacao = false
			self:SetScript ("OnUpdate", nil)
		end
	end

	function _detalhes:AtualizaPontos()
		local _x, _y = self:GetPositionOnScreen()
		if (not _x) then
 			return
 		end
		
		local _w, _h = self:GetRealSize()
		
		local metade_largura = _w/2
		local metade_altura = _h/2
		
		local statusbar_y_mod = 0
		if (not self.show_statusbar) then
			statusbar_y_mod = 14 * self.baseframe:GetScale()
		end
		
		if (not self.ponto1) then
			self.ponto1 = {x = _x - metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topleft
			self.ponto2 = {x = _x - metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomleft
			self.ponto3 = {x = _x + metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomright
			self.ponto4 = {x = _x + metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topright
		else
			self.ponto1.x = _x - metade_largura
			self.ponto1.y = _y + metade_altura + (statusbar_y_mod*-1)
			self.ponto2.x = _x - metade_largura
			self.ponto2.y = _y - metade_altura + statusbar_y_mod
			self.ponto3.x = _x + metade_largura
			self.ponto3.y = _y - metade_altura + statusbar_y_mod
			self.ponto4.x = _x + metade_largura
			self.ponto4.y = _y + metade_altura + (statusbar_y_mod*-1)
		end

	end
	
--------------------------------------------------------------------------------------------------------

	--> LibWindow-1.1 by Mikk http://www.wowace.com/profiles/mikk/
	--> this is the restore function from Libs\LibWindow-1.1\LibWindow-1.1.lua. 
	--> we can't schedule a new save after restoring, we save it inside the instance without frame references and always attach to UIparent.
	function _detalhes:RestoreLibWindow()
		local frame = self.baseframe
		if (frame) then
			if (self.libwindow.x) then
				
				local x = self.libwindow.x
				local y = self.libwindow.y
				local point = self.libwindow.point
				local s = self.libwindow.scale
				
				if s then
					(frame.lw11origSetScale or frame.SetScale)(frame,s)
				else
					s = frame:GetScale()
				end
				
				if not x or not y then		-- nothing stored in config yet, smack it in the center
					x=0; y=0; point="CENTER"
				end

				x = x/s
				y = y/s
				
				frame:ClearAllPoints()
				if not point and y==0 then	-- errr why did i do this check again? must have been a reason, but i can't remember it =/
					point="CENTER"
				end
				
				--> Details: using UIParent always in order to not break the positioning when using AddonSkin with ElvUI.
				if not point then	-- we have position, but no point, which probably means we're going from data stored by the addon itself before LibWindow was added to it. It was PROBABLY topleft->bottomleft anchored. Most do it that way.
					frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y) --frame:SetPoint("TOPLEFT", frame:GetParent(), "BOTTOMLEFT", x, y)
					-- make it compute a better attachpoint (on next update)
					--_detalhes:ScheduleTimer ("SaveLibWindow", 0.05, self)
					return
				end
				
				frame:SetPoint(point, UIParent, point, x, y)
				
			end
		end
	end
	
	--> LibWindow-1.1 by Mikk http://www.wowace.com/profiles/mikk/
	--> this is the save function from Libs\LibWindow-1.1\LibWindow-1.1.lua. 
	--> we need to make it save inside the instance object without frame references and also we must always use UIParent due to embed settings for ElvUI and LUI.
	
		function _detalhes:SaveLibWindow()
			local frame = self.baseframe
			if (frame) then
				local left = frame:GetLeft()
				if (not left) then
					return _detalhes:ScheduleTimer ("SaveLibWindow", 0.05, self)
				end
					--> Details: we are always using UIParent here or the addon break when using Embeds.
					local parent = UIParent --local parent = frame:GetParent() or nilParent
					-- No, this won't work very well with frames that aren't parented to nil or UIParent
					local s = frame:GetScale()
					local left,top = frame:GetLeft()*s, frame:GetTop()*s
					local right,bottom = frame:GetRight()*s, frame:GetBottom()*s
					local pwidth, pheight = parent:GetWidth(), parent:GetHeight()

					local x,y,point;
					if left < (pwidth-right) and left < abs((left+right)/2 - pwidth/2) then
						x = left;
						point="LEFT";
					elseif (pwidth-right) < abs((left+right)/2 - pwidth/2) then
						x = right-pwidth;
						point="RIGHT";
					else
						x = (left+right)/2 - pwidth/2;
						point="";
					end
					
					if bottom < (pheight-top) and bottom < abs((bottom+top)/2 - pheight/2) then
						y = bottom;
						point="BOTTOM"..point;
					elseif (pheight-top) < abs((bottom+top)/2 - pheight/2) then
						y = top-pheight;
						point="TOP"..point;
					else
						y = (bottom+top)/2 - pheight/2;
						-- point=""..point;
					end
					
					if point=="" then
						point = "CENTER"
					end
					
				----------------------------------------
				--> save inside the instance object
				self.libwindow.x = x
				self.libwindow.y = y
				self.libwindow.point = point
				self.libwindow.scale = scale
			end
		end
		
	--> end for libwindow-1.1
--------------------------------------------------------------------------------------------------------
	
	function _detalhes:SaveMainWindowSize()
	
		local baseframe_width = self.baseframe:GetWidth()
		if (not baseframe_width) then
			return _detalhes:ScheduleTimer ("SaveMainWindowSize", 1, self)
		end
		local baseframe_height = self.baseframe:GetHeight()
		
		--> calc position
		local _x, _y = self:GetPositionOnScreen()
		if (not _x) then
 			return _detalhes:ScheduleTimer ("SaveMainWindowSize", 1, self)
 		end
		
		--> save the position
		local _w = baseframe_width
		local _h = baseframe_height
		
		local mostrando = self.mostrando
		
		self.posicao[mostrando].x = _x
		self.posicao[mostrando].y = _y
		self.posicao[mostrando].w = _w
		self.posicao[mostrando].h = _h
		
		--> update the 4 points for window groups
		local metade_largura = _w/2
		local metade_altura = _h/2
		
		local statusbar_y_mod = 0
		if (not self.show_statusbar) then
			statusbar_y_mod = 14 * self.baseframe:GetScale()
		end
		
		if (not self.ponto1) then
			self.ponto1 = {x = _x - metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topleft
			self.ponto2 = {x = _x - metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomleft
			self.ponto3 = {x = _x + metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomright
			self.ponto4 = {x = _x + metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topright
		else
			self.ponto1.x = _x - metade_largura
			self.ponto1.y = _y + metade_altura + (statusbar_y_mod*-1)
			self.ponto2.x = _x - metade_largura
			self.ponto2.y = _y - metade_altura + statusbar_y_mod
			self.ponto3.x = _x + metade_largura
			self.ponto3.y = _y - metade_altura + statusbar_y_mod
			self.ponto4.x = _x + metade_largura
			self.ponto4.y = _y + metade_altura + (statusbar_y_mod*-1)
		end
		
		self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight() - end_window_spacement --> espaço para o final da janela
		
		return {altura = self.baseframe:GetHeight(), largura = self.baseframe:GetWidth(), x = _x, y = _y}
	end

	function _detalhes:SaveMainWindowPosition (instance)
		
		if (instance) then
			self = instance
		end
		local mostrando = self.mostrando
		
		--> get sizes
		local baseframe_width = self.baseframe:GetWidth()
		if (not baseframe_width) then
			return _detalhes:ScheduleTimer ("SaveMainWindowPosition", 1, self)
		end
		local baseframe_height = self.baseframe:GetHeight()
		
		--> calc position
		local _x, _y = self:GetPositionOnScreen()
		if (not _x) then
 			return _detalhes:ScheduleTimer ("SaveMainWindowPosition", 1, self)
 		end
		
		if (self.mostrando ~= "solo") then
			self:SaveLibWindow()
		end

		--> save the position
		local _w = baseframe_width
		local _h = baseframe_height
		
		self.posicao[mostrando].x = _x
		self.posicao[mostrando].y = _y
		self.posicao[mostrando].w = _w
		self.posicao[mostrando].h = _h
		
		--> update the 4 points for window groups
		local metade_largura = _w/2
		local metade_altura = _h/2
		
		local statusbar_y_mod = 0
		if (not self.show_statusbar) then
			statusbar_y_mod = 14 * self.baseframe:GetScale()
		end
		
		if (not self.ponto1) then
			self.ponto1 = {x = _x - metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topleft
			self.ponto2 = {x = _x - metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomleft
			self.ponto3 = {x = _x + metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomright
			self.ponto4 = {x = _x + metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topright
		else
			self.ponto1.x = _x - metade_largura
			self.ponto1.y = _y + metade_altura + (statusbar_y_mod*-1)
			self.ponto2.x = _x - metade_largura
			self.ponto2.y = _y - metade_altura + statusbar_y_mod
			self.ponto3.x = _x + metade_largura
			self.ponto3.y = _y - metade_altura + statusbar_y_mod
			self.ponto4.x = _x + metade_largura
			self.ponto4.y = _y + metade_altura + (statusbar_y_mod*-1)
		end
		
		self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight() - end_window_spacement --> espaço para o final da janela

		return {altura = self.baseframe:GetHeight(), largura = self.baseframe:GetWidth(), x = _x, y = _y}
	end

	function _detalhes:RestoreMainWindowPosition (pre_defined)
	
		if (not pre_defined and self.libwindow.x and self.mostrando == "normal" and not _detalhes.instances_no_libwindow) then
			local s = self.window_scale
			self.baseframe:SetScale (s)
			self.rowframe:SetScale (s)
		
			self.baseframe:SetWidth (self.posicao[self.mostrando].w)
			self.baseframe:SetHeight (self.posicao[self.mostrando].h)
			
			self:RestoreLibWindow()
			self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight() - end_window_spacement --> espaço para o final da janela
			return
		end
	
		local s = self.window_scale
		self.baseframe:SetScale (s)
		self.rowframe:SetScale (s)
	
		local _scale = self.baseframe:GetEffectiveScale() 
		local _UIscale = _UIParent:GetScale()
		
		local novo_x = self.posicao[self.mostrando].x*_UIscale/_scale
		local novo_y = self.posicao[self.mostrando].y*_UIscale/_scale
		
		if (pre_defined and pre_defined.x) then --> overwrite
			novo_x = pre_defined.x*_UIscale/_scale
			novo_y = pre_defined.y*_UIscale/_scale
			self.posicao[self.mostrando].w = pre_defined.largura
			self.posicao[self.mostrando].h = pre_defined.altura
			
		elseif (pre_defined and not pre_defined.x) then
			_detalhes:Msg ("invalid pre_defined table for resize, please rezise the window manually.")
		end

		self.baseframe:SetWidth (self.posicao[self.mostrando].w)
		self.baseframe:SetHeight (self.posicao[self.mostrando].h)
		
		self.baseframe:ClearAllPoints()
		self.baseframe:SetPoint ("CENTER", _UIParent, "CENTER", novo_x, novo_y)

	end

	function _detalhes:RestoreMainWindowPositionNoResize (pre_defined, x, y)
	
		x = x or 0
		y = y or 0

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
		self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight() - end_window_spacement --> espaço para o final da janela
	end
	
	function _detalhes:CreatePositionTable()
		local t = {pos_table = true}
		
		if (self.libwindow) then
			t.x = self.libwindow.x
			t.y = self.libwindow.y
			t.scale = self.libwindow.scale
			t.point = self.libwindow.point
		end
		
		--> old way to save positions
		t.x_legacy = self.posicao.normal.x
		t.y_legacy = self.posicao.normal.y
		
		--> size
		t.w = self.posicao.normal.w
		t.h = self.posicao.normal.h
		
		return t
	end
	
	function _detalhes:RestorePositionFromPositionTable (t)
		if (not t.pos_table) then
			return
		end
		
		if (t.x) then
			self.libwindow.x = t.x
			self.libwindow.y = t.y
			self.libwindow.scale = t.scale
			self.libwindow.point = t.point
		end
		
		self.posicao.normal.x = t.x_legacy
		self.posicao.normal.y = t.y_legacy
		
		self.posicao.normal.w = t.w
		self.posicao.normal.h = t.h
		
		return self:RestoreMainWindowPosition()
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
		instancia.rows_showing = 0 --> resetou, então não esta mostranho nenhuma barra
		
		for i = 1, instancia.rows_created, 1 do --> limpa a referência do que estava sendo mostrado na barra
			local esta_barra= instancia.barras[i]
			esta_barra.minha_tabela = nil
			esta_barra.animacao_fim = 0
			esta_barra.animacao_fim2 = 0
		end
		
		if (instancia.rolagem) then
			instancia:EsconderScrollBar() --> hida a scrollbar
		end
		instancia.need_rolagem = false
		instancia.bar_mod = nil

	end

	function _detalhes:ReajustaGump()
		
		if (self.mostrando == "normal") then --> somente alterar o tamanho das barras se tiver mostrando o gump normal
		
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
				if (self.baseframe.stretch_direction == "top") then
					for _, instancia in _ipairs (self.stretchToo) do
						instancia.baseframe:SetHeight (self.baseframe:GetHeight())
						local mod = (self.baseframe:GetHeight() - instancia.baseframe._place.altura) / 2
						instancia:RestoreMainWindowPositionNoResize (instancia.baseframe._place, nil, mod)
					end
				elseif (self.baseframe.stretch_direction == "bottom") then
					for _, instancia in _ipairs (self.stretchToo) do
						instancia.baseframe:SetHeight (self.baseframe:GetHeight())
						local mod = (self.baseframe:GetHeight() - instancia.baseframe._place.altura) / 2
						mod = mod * -1
						instancia:RestoreMainWindowPositionNoResize (instancia.baseframe._place, nil, mod)
					end
				end
			end
			
			if (self.stretch_button_side == 2) then
				self:StretchButtonAnchor (2)
			end
			
			--> reajusta o freeze
			if (self.freezed) then
				_detalhes:Freeze (self)
			end
		
			-- -4 difere a precisão de quando a barra será adicionada ou apagada da barra
			self.baseframe.BoxBarrasAltura = (self.baseframe:GetHeight()) - end_window_spacement

			local T = self.rows_fit_in_window
			if (not T) then --> primeira vez que o gump esta sendo reajustado
				T = _math_floor (self.baseframe.BoxBarrasAltura / self.row_height)
			end
			
			--> reajustar o local do relógio
			local meio = self.baseframe:GetWidth() / 2
			local novo_local = meio - 25
			
			self.rows_fit_in_window = _math_floor ( self.baseframe.BoxBarrasAltura / self.row_height)

			--> verifica se precisa criar mais barras
			if (self.rows_fit_in_window > #self.barras) then--> verifica se precisa criar mais barras
				for i  = #self.barras+1, self.rows_fit_in_window, 1 do
					gump:CriaNovaBarra (self, i) --> cria nova barra
				end
				self.rows_created = #self.barras
			end
			
			--> faz um cache do tamanho das barras
			self.cached_bar_width = self.barras[1] and self.barras[1]:GetWidth() or 0
			
			--> seta a largura das barras
			if (self.bar_mod and self.bar_mod ~= 0) then
				for index = 1, self.rows_fit_in_window do
					self.barras [index]:SetWidth (self.baseframe:GetWidth()+self.bar_mod)
				end
			else
				for index = 1, self.rows_fit_in_window do
					self.barras [index]:SetWidth (self.baseframe:GetWidth()+self.row_info.space.right)
				end
			end

			--> verifica se precisa esconder ou mostrar alguma barra
			local A = self.barraS[1]
			if (not A) then --> primeira vez que o resize esta sendo usado, no caso no startup do addon ou ao criar uma nova instância
				--> hida as barras não usadas
				for i = 1, self.rows_created, 1 do
					gump:Fade (self.barras [i], 1)
					self.barras [i].on = false
				end
				return
			end
			
			local X = self.rows_showing
			local C = self.rows_fit_in_window

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
					local barra = self.barras[index]
					if (barra) then
						if (index <= X) then
							--gump:Fade (barra, 0)
							gump:Fade (barra, "out")
						else
							--if (self.baseframe.isStretching or self.auto_resize) then
								gump:Fade (barra, 1)
							--else
							--	gump:Fade (barra, 1)
							--end
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
						local barra = self.barras[index]
						if (barra) then
							if (self.baseframe.isStretching or self.auto_resize) then
								gump:Fade (barra, 1)
							else	
								--gump:Fade (barra, "in", 0.1)
								gump:Fade (barra, 1)
							end
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
					elseif (tabela._refresh_window) then
						tabela:_refresh_window (esta_barra, self)
					else
						tabela:RefreshBarra (esta_barra, self, true)
					end

				end
				
				qual_barra = qual_barra+1
			end
			
			--> força o próximo refresh
			self.showing[self.atributo].need_refresh = true

		end	
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> panels

--> cooltip presets
	local preset3_backdrop = {bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]], edgeFile = [[Interface\AddOns\Details\images\border_3]], tile=true,
	edgeSize = 16, tileSize = 64, insets = {left = 3, right = 3, top = 4, bottom = 4}}
	
	_detalhes.cooltip_preset3_backdrop = preset3_backdrop
	
	local white_table = {1, 1, 1, 1}
	local black_table = {0, 0, 0, 1}
	local gray_table = {0.37, 0.37, 0.37, 0.95}
	
	local preset2_backdrop = {bgFile = [[Interface\AddOns\Details\images\background]], edgeFile = [[Interface\Buttons\WHITE8X8]], tile=true,
	edgeSize = 1, tileSize = 64, insets = {left = 0, right = 0, top = 0, bottom = 0}}
	_detalhes.cooltip_preset2_backdrop = preset2_backdrop
	
	--"Details BarBorder 3"
	function _detalhes:CooltipPreset (preset)
		local GameCooltip = GameCooltip
	
		GameCooltip:Reset()
		
		if (preset == 1) then
			GameCooltip:SetOption ("TextFont", "Friz Quadrata TT")
			GameCooltip:SetOption ("TextColor", "orange")
			GameCooltip:SetOption ("TextSize", 12)
			GameCooltip:SetOption ("ButtonsYMod", -4)
			GameCooltip:SetOption ("YSpacingMod", -4)
			GameCooltip:SetOption ("IgnoreButtonAutoHeight", true)
			GameCooltip:SetColor (1, 0.5, 0.5, 0.5, 0.5)
			
		elseif (preset == 2) then
			GameCooltip:SetOption ("TextFont", "Friz Quadrata TT")
			GameCooltip:SetOption ("TextColor", "orange")
			GameCooltip:SetOption ("TextSize", 12)
			GameCooltip:SetOption ("FixedWidth", 220)
			GameCooltip:SetOption ("ButtonsYMod", -4)
			GameCooltip:SetOption ("YSpacingMod", -4)
			GameCooltip:SetOption ("IgnoreButtonAutoHeight", true)
			GameCooltip:SetColor (1, 0, 0, 0, 0)
			
			GameCooltip:SetOption ("LeftBorderSize", -5)
			GameCooltip:SetOption ("RightBorderSize", 5)
			
			GameCooltip:SetBackdrop (1, preset2_backdrop, gray_table, black_table)	
			
		elseif (preset == 2.1) then
			GameCooltip:SetOption ("TextFont", "Friz Quadrata TT")
			GameCooltip:SetOption ("TextColor", "orange")
			GameCooltip:SetOption ("TextSize", 10)
			GameCooltip:SetOption ("FixedWidth", 220)
			GameCooltip:SetOption ("ButtonsYMod", 0)
			GameCooltip:SetOption ("YSpacingMod", -4)
			GameCooltip:SetOption ("IgnoreButtonAutoHeight", true)
			GameCooltip:SetColor (1, 0, 0, 0, 0)
			
			GameCooltip:SetBackdrop (1, preset2_backdrop, gray_table, black_table)
			
		elseif (preset == 3) then
			GameCooltip:SetOption ("TextFont", "Friz Quadrata TT")
			GameCooltip:SetOption ("TextColor", "orange")
			GameCooltip:SetOption ("TextSize", 12)
			GameCooltip:SetOption ("FixedWidth", 220)
			GameCooltip:SetOption ("ButtonsYMod", -4)
			GameCooltip:SetOption ("YSpacingMod", -4)
			GameCooltip:SetOption ("IgnoreButtonAutoHeight", true)
			GameCooltip:SetColor (1, 0.5, 0.5, 0.5, 0.5)
			
			GameCooltip:SetBackdrop (1, preset3_backdrop, nil, white_table)

		end
	end

--> yes no panel

	do
		_detalhes.yesNo = _detalhes.gump:NewPanel (UIParent, _, "DetailsYesNoWindow", _, 500, 80)
		_detalhes.yesNo:SetPoint ("center", UIParent, "center")
		_detalhes.gump:NewLabel (_detalhes.yesNo, _, "$parentAsk", "ask", "")
		_detalhes.yesNo ["ask"]:SetPoint ("center", _detalhes.yesNo, "center", 0, 25)
		_detalhes.yesNo ["ask"]:SetWidth (480)
		_detalhes.yesNo ["ask"]:SetJustifyH ("center")
		_detalhes.yesNo ["ask"]:SetHeight (22)
		_detalhes.gump:NewButton (_detalhes.yesNo, _, "$parentNo", "no", 100, 30, function() _detalhes.yesNo:Hide() end, nil, nil, nil, Loc ["STRING_NO"])
		_detalhes.gump:NewButton (_detalhes.yesNo, _, "$parentYes", "yes", 100, 30, nil, nil, nil, nil, Loc ["STRING_YES"])
		_detalhes.yesNo ["no"]:SetPoint (10, -45)
		_detalhes.yesNo ["yes"]:SetPoint (390, -45)
		_detalhes.yesNo ["no"]:InstallCustomTexture()
		_detalhes.yesNo ["yes"]:InstallCustomTexture()
		_detalhes.yesNo ["yes"]:SetHook ("OnMouseUp", function() _detalhes.yesNo:Hide() end)
		function _detalhes:Ask (msg, func, ...)
			_detalhes.yesNo ["ask"].text = msg
			local p1, p2 = ...
			_detalhes.yesNo ["yes"]:SetClickFunction (func, p1, p2)
			_detalhes.yesNo:Show()
		end
		_detalhes.yesNo:Hide()
	end
	
--> cria o frame de wait for plugin
	function _detalhes:CreateWaitForPlugin()
	
		local WaitForPluginFrame = CreateFrame ("frame", "DetailsWaitForPluginFrame" .. self.meu_id, UIParent)
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
		
		local bgpanel = gump:NewPanel (UIParent, UIParent, "DetailsWaitFrameBG"..self.meu_id, nil, 120, 30, false, false, false)
		bgpanel:SetPoint ("center", WaitForPluginFrame, "center")
		bgpanel:SetBackdrop ({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
		bgpanel:SetBackdropColor (.2, .2, .2, 1)
		
		local label = gump:NewLabel (UIParent, UIParent, nil, nil, Loc ["STRING_WAITPLUGIN"]) --> localize-me
		label.color = "silver"
		label:SetPoint ("center", WaitForPluginFrame, "center")
		label:SetJustifyH ("center")
		label:Hide()

		WaitForPluginFrame:Hide()	
		self.wait_for_plugin_created = true
		
		function self:WaitForPlugin()
		
			self:ChangeIcon ([[Interface\GossipFrame\ActiveQuestIcon]])
		
			if (WaitForPluginFrame:IsShown() and WaitForPluginFrame:GetParent() == self.baseframe) then
				self.waiting_pid = self:ScheduleTimer ("ExecDelayedPlugin1", 5, self)
			end
		
			WaitForPluginFrame:SetParent (self.baseframe)
			WaitForPluginFrame:SetAllPoints (self.baseframe)
			local size = math.max (self.baseframe:GetHeight()* 0.35, 100) 
			WaitForPluginFrame.wheel:SetWidth (size)
			WaitForPluginFrame.wheel:SetHeight (size)
			WaitForPluginFrame:Show()
			label:Show()
			bgpanel:Show()
			RotateAnimGroup:Play()
			
			self.waiting_raid_plugin = true
			
			self.waiting_pid = self:ScheduleTimer ("ExecDelayedPlugin1", 5, self)
		end
		
		function self:CancelWaitForPlugin()
			RotateAnimGroup:Stop()
			WaitForPluginFrame:Hide()	
			label:Hide()
			bgpanel:Hide()
		end
		
		function self:ExecDelayedPlugin1()
		
			self.waiting_raid_plugin = nil
			self.waiting_pid = nil
		
			RotateAnimGroup:Stop()
			WaitForPluginFrame:Hide()	
			label:Hide()
			bgpanel:Hide()
			
			if (self.meu_id == _detalhes.solo) then
				_detalhes.SoloTables:switch (nil, _detalhes.SoloTables.Mode)
				
			elseif (self.modo == _detalhes._detalhes_props["MODO_RAID"]) then
				_detalhes.RaidTables:EnableRaidMode (self)
				
			end
		end	
	end
	
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
		
			instancia:ChangeIcon ([[Interface\GossipFrame\ActiveQuestIcon]])
		
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
				_detalhes.SoloTables:switch (nil, _detalhes.SoloTables.Mode)
				
			elseif (instancia.meu_id == _detalhes.raid) then
				_detalhes.RaidTables:switch (nil, _detalhes.RaidTables.Mode)
				
			end
		end	
	end

--> tutorial bookmark
	function _detalhes:TutorialBookmark (instance)
	
		_detalhes:SetTutorialCVar ("ATTRIBUTE_SELECT_TUTORIAL1", true)
		
		local func = function()
			local f = CreateFrame ("frame", nil, instance.baseframe)
			f:SetAllPoints();
			f:SetFrameStrata ("FULLSCREEN")
			f:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})
			f:SetBackdropColor (0, 0, 0, 0.8)
			
			f.alert = CreateFrame ("frame", "DetailsTutorialBookmarkAlert", UIParent, "ActionBarButtonSpellActivationAlert")
			f.alert:SetPoint ("topleft", f, "topleft")
			f.alert:SetPoint ("bottomright", f, "bottomright")
			f.alert.animOut:Stop()
			f.alert.animIn:Play()
			
			f.text = f:CreateFontString (nil, "overlay", "GameFontNormal")
			f.text:SetText (Loc ["STRING_MINITUTORIAL_BOOKMARK1"])
			f.text:SetWidth (f:GetWidth()-15)
			f.text:SetPoint ("center", f)
			f.text:SetJustifyH ("center")
			
			f.bg = f:CreateTexture (nil, "border")
			f.bg:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-Parchment-Horizontal-Desaturated]])
			f.bg:SetAllPoints()
			f.bg:SetAlpha (0.8)
			
			f.textbg = f:CreateTexture (nil, "artwork")
			f.textbg:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-RecentHeader]])
			f.textbg:SetPoint ("center", f)
			f.textbg:SetAlpha (0.4)
			f.textbg:SetTexCoord (0, 1, 0, 24/32)

			f:SetScript ("OnMouseDown", function (self, button)
				if (button == "RightButton") then
					f.alert.animIn:Stop()
					f.alert.animOut:Play()
					_detalhes.switch:ShowMe (instance)
					f:Hide()
				end
			end)
		end
		
		_detalhes:GetFramework():ShowTutorialAlertFrame ("How to Use Bookmarks", "switch fast between displays", func)
	end

--> translate window

	function _detalhes:OpenTranslateWindow()
		
	end

--> raid history window ~history
	function _detalhes:OpenRaidHistoryWindow (_raid, _boss, _difficulty, _role, _guild, _player_base, _player_name)
	
		if (not _G.DetailsRaidHistoryWindow) then
		
			local db = _detalhes.storage:OpenRaidStorage()
			if (not db) then
				return _detalhes:Msg ("Fail to open raid storage, may be the addon is disabled.")
			end
		
			local f = CreateFrame ("frame", "DetailsRaidHistoryWindow", UIParent, "ButtonFrameTemplate")
			f:SetPoint ("center", UIParent, "center")
			f:SetFrameStrata ("HIGH")
			f:SetToplevel (true)
			
			f:SetMovable (true)
			f:SetWidth (850)
			f:SetHeight (500)
			tinsert (UISpecialFrames, "DetailsRaidHistoryWindow")
			
			local background = f:CreateTexture (nil, "border")
			background:SetAlpha (0.3)
			background:SetPoint ("topleft", f, "topleft", 6, -65)
			background:SetPoint ("bottomright", f, "bottomright", -10, 28)

			local div = f:CreateTexture (nil, "artwork")
			div:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-MetalBorder-Left]])
			div:SetAlpha (0.3)
			div:SetPoint ("topleft", f, "topleft", 180, -64)
			div:SetHeight (460)
			
			function f:SetBackgroundImage (encounterId)
				local instanceId = _detalhes:GetInstanceIdFromEncounterId (encounterId)
				if (instanceId) then
					local file, L, R, T, B = _detalhes:GetRaidBackground (instanceId)
					background:SetTexture (file)
					background:SetTexCoord (L, R, T, B)
				end
			end
			
			f:SetScript ("OnMouseDown", function(self, button)
				if (self.isMoving) then
					return
				end
				if (button == "RightButton") then
					self:Hide()
				else
					self:StartMoving() 
					self.isMoving = true
				end
			end)
			f:SetScript ("OnMouseUp", function(self, button) 
				if (self.isMoving and button == "LeftButton") then
					self:StopMovingOrSizing()
					self.isMoving = nil
				end
			end)
			
			f.TitleText:SetText ("Raid History")
			f.portrait:SetTexture ([[Interface\AddOns\Details\images\icons2]])
			f.portrait:SetTexCoord (192/512, 258/512, 322/512, 388/512)
			
			local dropdown_size = 160
			local icon = [[Interface\FriendsFrame\battlenet-status-offline]]
			
			local diff_list = {}
			local raid_list = {}
			local boss_list = {}
			local guild_list = {}

			local sort_alphabetical = function(a,b) return a[1] < b[1] end
			local sort_alphabetical2 = function(a,b) return a.value < b.value end
			
			local on_select = function()
				if (f.Refresh) then
					f:Refresh()
				end
			end
			
			--> select raid:
			local on_raid_select = function (_, _, raid)
				on_select()
			end
			local build_raid_list = function()
				return raid_list
			end
			local raid_dropdown = gump:CreateDropDown (f, build_raid_list, 1, dropdown_size, 20, "select_raid")
			local raid_string = gump:CreateLabel (f, "Raid:", _, _, "GameFontNormal", "select_raid_label")
			
			--> select boss:
			local on_boss_select = function (_, _, boss)
				on_select()
			end
			local build_boss_list = function()
				return boss_list
			end
			local boss_dropdown = gump:CreateDropDown (f, build_boss_list, 1, dropdown_size, 20, "select_boss")
			local boss_string = gump:CreateLabel (f, "Boss:", _, _, "GameFontNormal", "select_boss_label")

			--> select difficulty:
			local on_diff_select = function (_, _, diff)
				on_select()
			end
			
			local build_diff_list = function()
				return diff_list
			end
			local diff_dropdown = gump:CreateDropDown (f, build_diff_list, 1, dropdown_size, 20, "select_diff")
			local diff_string = gump:CreateLabel (f, "Difficulty:", _, _, "GameFontNormal", "select_diff_label")
			
			--> select role:
			local on_role_select = function (_, _, role)
				on_select()
			end
			local build_role_list = function()
				return {
					{value = "damage", label = "Damager", icon = icon, onclick = on_role_select},
					{value = "healing", label = "Healer", icon = icon, onclick = on_role_select}
				}
			end
			local role_dropdown = gump:CreateDropDown (f, build_role_list, 1, dropdown_size, 20, "select_role")
			local role_string = gump:CreateLabel (f, "Role:", _, _, "GameFontNormal", "select_role_label")
			
			--> select guild:
			local on_guild_select = function (_, _, guild)
				on_select()
			end
			local build_guild_list = function()
				return guild_list
			end
			local guild_dropdown = gump:CreateDropDown (f, build_guild_list, 1, dropdown_size, 20, "select_guild")
			local guild_string = gump:CreateLabel (f, "Guild:", _, _, "GameFontNormal", "select_guild_label")

			--> select playerbase:
			local on_player_select = function (_, _, player)
				on_select()
			end
			local build_player_list = function()
				return {
					{value = 1, label = "Raid", icon = icon, onclick = on_player_select},
					{value = 2, label = "Individual", icon = icon, onclick = on_player_select},
				}
			end
			local player_dropdown = gump:CreateDropDown (f, build_player_list, 1, dropdown_size, 20, "select_player")
			local player_string = gump:CreateLabel (f, "Player Base:", _, _, "GameFontNormal", "select_player_label")

			--> select player:
			local on_player2_select = function (_, _, player)
				f.latest_player_selected = player
				f:BuildPlayerTable (player)
			end
			local build_player2_list = function()
				local encounterTable, guild, role = unpack (f.build_player2_data or {})
				local t = {}
				local already_listed = {}
				if (encounterTable) then
					for encounterIndex, encounter in ipairs (encounterTable) do
						if (encounter.guild == guild) then
							local roleTable = encounter [role]
							for playerName, _ in pairs (roleTable) do
								if (not already_listed [playerName]) then
									tinsert (t, {value = playerName, label = playerName, icon = icon, onclick = on_player2_select})
									already_listed [playerName] = true
								end
							end
						end
					end
				end
				
				table.sort (t, sort_alphabetical2)
				
				return t
			end
			local player2_dropdown = gump:CreateDropDown (f, build_player2_list, 1, dropdown_size, 20, "select_player2")
			local player2_string = gump:CreateLabel (f, "Player:", _, _, "GameFontNormal", "select_player2_label")

			function f:UpdateDropdowns()
				
				--difficulty
				wipe (diff_list)
				wipe (boss_list)
				wipe (raid_list)
				wipe (guild_list)
				
				local boss_repeated = {}
				local raid_repeated = {}
				local guild_repeated = {}
				
				for difficulty, encounterIdTable in pairs (db) do
				
					if (type (difficulty) == "number") then
						if (difficulty == 14) then
							tinsert (diff_list, {value = 14, label = "Normal", icon = icon, onclick = on_diff_select})
						elseif (difficulty == 15) then
							tinsert (diff_list, {value = 15, label = "Heroic", icon = icon, onclick = on_diff_select})
						elseif (difficulty == 16) then
							tinsert (diff_list, {value = 16, label = "Mythic", icon = icon, onclick = on_diff_select})
						end

						for encounterId, encounterTable in pairs (encounterIdTable) do 
							if (not boss_repeated [encounterId]) then
								local encounter, instance = _detalhes:GetBossEncounterDetailsFromEncounterId (_, encounterId)
								if (encounter) then
									tinsert (boss_list, {value = encounterId, label = encounter.boss, icon = icon, onclick = on_boss_select})
									boss_repeated [encounterId] = true
									
									if (not raid_repeated [instance.name]) then
										tinsert (raid_list, {value = instance.id, label = instance.name, icon = icon, onclick = on_raid_select})
										raid_repeated [instance.name] = true
									end
								end
							end
							
							for index, encounter in ipairs (encounterTable) do
								local guild = encounter.guild
								if (not guild_repeated [guild]) then
									tinsert (guild_list, {value = guild, label = guild, icon = icon, onclick = on_raid_select})
									guild_repeated [guild] = true
								end
							end
						end
					end
				end
				
				diff_dropdown:Refresh()
				diff_dropdown:Select (1, true)
				boss_dropdown:Refresh()
				boss_dropdown:Select (1, true)
				raid_dropdown:Refresh()
				raid_dropdown:Select (1, true)
				guild_dropdown:Refresh()
				guild_dropdown:Select (1, true)
				
			end
			
			--> anchors:
			raid_string:SetPoint ("topleft", f, "topleft", 10, -70)
			raid_dropdown:SetPoint ("topleft", f, "topleft", 10, -85)
			
			boss_string:SetPoint ("topleft", f, "topleft", 10, -110)
			boss_dropdown:SetPoint ("topleft", f, "topleft", 10, -125)
			
			diff_string:SetPoint ("topleft", f, "topleft", 10, -150)
			diff_dropdown:SetPoint ("topleft", f, "topleft", 10, -165)
			
			role_string:SetPoint ("topleft", f, "topleft", 10, -190)
			role_dropdown:SetPoint ("topleft", f, "topleft", 10, -205)
			
			guild_string:SetPoint ("topleft", f, "topleft", 10, -230)
			guild_dropdown:SetPoint ("topleft", f, "topleft", 10, -245)
			
			player_string:SetPoint ("topleft", f, "topleft", 10, -270)
			player_dropdown:SetPoint ("topleft", f, "topleft", 10, -285)
			
			player2_string:SetPoint ("topleft", f, "topleft", 10, -310)
			player2_dropdown:SetPoint ("topleft", f, "topleft", 10, -325)
			player2_string:Hide()
			player2_dropdown:Hide()
			
			--> refresh the window:
			
			function f:BuildPlayerTable (playerName)
				
				local encounterTable, guild, role = unpack (f.build_player2_data or {})
				local data = {}
				
				if (type (playerName) == "string" and string.len (playerName) > 1) then
					for encounterIndex, encounter in ipairs (encounterTable) do
						
						if (encounter.guild == guild) then
							local roleTable = encounter [role]
							
							local date = encounter.date
							date = date:gsub (".*%s", "")
							date = date:sub (1, -4)

							local player = roleTable [playerName]
							
							if (player) then
								tinsert (data, {text = date, value = player[1], data = player, fulldate = encounter.date, elapsed = encounter.elapsed})
							end
						end
					end
					
					--> update graphic
					if (not f.gframe) then
					
						local cooltip_block_bg = {0, 0, 0, 1}
						local menu_wallpaper_tex = {.6, 0.1, 0, 0.64453125}
						local menu_wallpaper_color = {1, 1, 1, 0.1}
						
						local onenter = function (self)
							GameCooltip:Reset()
							GameCooltip:SetType ("tooltip")
							
							GameCooltip:SetOption ("TextSize", _detalhes.tooltip.fontsize)
							GameCooltip:SetOption ("TextFont",  _detalhes.tooltip.fontface)
							GameCooltip:SetOption ("TextColor", _detalhes.tooltip.fontcolor)
							GameCooltip:SetOption ("TextColorRight", _detalhes.tooltip.fontcolor_right)
							GameCooltip:SetOption ("TextShadow", _detalhes.tooltip.fontshadow and "OUTLINE")
							
							GameCooltip:SetOption ("LeftBorderSize", -5)
							GameCooltip:SetOption ("RightBorderSize", 5)
							GameCooltip:SetOption ("MinWidth", 175)
							GameCooltip:SetOption ("StatusBarTexture", [[Interface\AddOns\Details\images\bar_background]])
							
							GameCooltip:AddLine ("Total Done:", _detalhes:ToK2 (self.data.value))
							GameCooltip:AddLine ("Dps:", _detalhes:ToK2 (self.data.value / self.data.elapsed))
							GameCooltip:AddLine ("Item Level:", floor (self.data.data [2]))
							GameCooltip:AddLine ("Date:", self.data.fulldate:gsub (".*%s", ""))
							
							GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], menu_wallpaper_tex, menu_wallpaper_color, true)
							GameCooltip:SetBackdrop (1, _detalhes.tooltip_backdrop, cooltip_block_bg, _detalhes.tooltip_border_color)
							GameCooltip:SetOwner (self.ball.tooltip_anchor)
							GameCooltip:Show()
						end
						local onleave = function (self)
							GameCooltip:Hide()
						end
						f.gframe = gump:CreateGFrame (f, 650, 400, 35, onenter, onleave, "gframe", "$parentGF")
						f.gframe:SetPoint ("topleft", f, "topleft", 190, -65)
					end
					
					f.gframe:Reset()
					f.gframe:UpdateLines (data)
					
				end
			end
			
			local fillpanel = gump:NewFillPanel (f, {}, "$parentFP", "fillpanel", 630, 400, false, false, true, nil)
			fillpanel:SetPoint ("topleft", f, "topleft", 200, -65)
			
			function f:BuildRaidTable (encounterTable, guild, role)
				
				local header = {{name = "Player Name", type = "text"}} -- , width = 90
				local players = {}
				local players_index = {}
				local amt_encounters = 0
				
				for encounterIndex, encounter in ipairs (encounterTable) do
					if (encounter.guild == guild) then
						local roleTable = encounter [role]
						
						local date = encounter.date
						date = date:gsub (".*%s", "")
						date = date:sub (1, -4)
						amt_encounters = amt_encounters + 1
						
						tinsert (header, {name = date, type = "text"})
						
						for playerName, playerTable in pairs (roleTable) do
							local index = players_index [playerName]
							local player
							
							if (not index) then
								player = {playerName}
								for i = 1, amt_encounters-1 do
									tinsert (player, "")
								end
								tinsert (player, _detalhes:ToK2 (playerTable [1] / encounter.elapsed))
								tinsert (players, player)
								players_index [playerName] = #players
								
								--print ("not index", playerName, amt_encounters, date, 2, amt_encounters-1)
							else
								player = players [index]
								for i = #player+1, amt_encounters-1 do
									tinsert (player, "")
								end
								tinsert (player, _detalhes:ToK2 (playerTable [1] / encounter.elapsed))
							end
							
						end
					end
				end
				
				for index, playerTable in ipairs (players) do
					for i = #playerTable, amt_encounters do
						tinsert (playerTable, "")
					end
				end
				
				--_detalhes:DumpTable (players, true)
				
				--table.sort (players, sort_alphabetical)
				
				fillpanel:SetFillFunction (function (index) return players [index] end)
				fillpanel:SetTotalFunction (function() return #players end)

				fillpanel:UpdateRows (header)
				
				fillpanel:Refresh()
				
			end
			
			function f:Refresh (player_name)
				--> build the main table
				local diff = diff_dropdown.value
				local boss = boss_dropdown.value
				local role = role_dropdown.value
				local guild = guild_dropdown.value
				local player = player_dropdown.value
				
				local diffTable = db [diff]
				
				f:SetBackgroundImage (boss)
				
				if (diffTable) then
					local encounters = diffTable [boss]
					if (encounters) then
						if (player == 1) then --> raid
							fillpanel:Show()
							if (f.gframe) then
								f.gframe:Hide()
							end
							player2_string:Hide()
							player2_dropdown:Hide()
							f:BuildRaidTable (encounters, guild, role)
						elseif (player == 2) then --> only one player
							fillpanel:Hide()
							if (f.gframe) then
								f.gframe:Show()
							end
							player2_string:Show()
							player2_dropdown:Show()
							f.build_player2_data = {encounters, guild, role}
							player2_dropdown:Refresh()
							
							player_name = f.latest_player_selected or player_name
							
							if (player_name) then
								player2_dropdown:Select (player_name)
							else
								player2_dropdown:Select (1, true)
							end
							
							f:BuildPlayerTable (player2_dropdown.value)
						end
					else
						if (player == 1) then --> raid
							fillpanel:Show()
							if (f.gframe) then
								f.gframe:Hide()
							end
							player2_string:Hide()
							player2_dropdown:Hide()
							f:BuildRaidTable ({}, guild, role)
						elseif (player == 2) then --> only one player
							fillpanel:Hide()
							if (f.gframe) then
								f.gframe:Show()
							end
							player2_string:Show()
							player2_dropdown:Show()
							f.build_player2_data = {{}, guild, role}
							player2_dropdown:Refresh()
							player2_dropdown:Select (1, true)
							f:BuildPlayerTable (player2_dropdown.value)
						end
					end
				end
			end
		
		end
		
		_G.DetailsRaidHistoryWindow:UpdateDropdowns()
		_G.DetailsRaidHistoryWindow:Refresh()
		_G.DetailsRaidHistoryWindow:Show()
		
		if (_raid) then
			DetailsRaidHistoryWindow.select_raid:Select (_raid)
			_G.DetailsRaidHistoryWindow:Refresh()
		end
		if (_boss) then
			DetailsRaidHistoryWindow.select_boss:Select (_boss)
			_G.DetailsRaidHistoryWindow:Refresh()
		end
		if (_difficulty) then
			DetailsRaidHistoryWindow.select_diff:Select (_difficulty)
			_G.DetailsRaidHistoryWindow:Refresh()
		end
		if (_role) then
			DetailsRaidHistoryWindow.select_role:Select (_role)
			_G.DetailsRaidHistoryWindow:Refresh()
		end
		if (_guild) then
			DetailsRaidHistoryWindow.select_guild:Select (_guild)
			_G.DetailsRaidHistoryWindow:Refresh()
		end
		if (_player_base) then
			DetailsRaidHistoryWindow.select_player:Select (_player_base)
			_G.DetailsRaidHistoryWindow:Refresh()
		end
		if (_player_name) then
			DetailsRaidHistoryWindow.select_player2:Refresh()
			DetailsRaidHistoryWindow.select_player2:Select (_player_name)
			_G.DetailsRaidHistoryWindow:Refresh (_player_name)
		end

	end
	
--> feedback window
	function _detalhes:OpenFeedbackWindow()
		
		if (not _G.DetailsFeedbackPanel) then
			
			gump:CreateSimplePanel (UIParent, 340, 300, Loc ["STRING_FEEDBACK_SEND_FEEDBACK"], "DetailsFeedbackPanel")
			local panel = _G.DetailsFeedbackPanel
			
			local label = gump:CreateLabel (panel, Loc ["STRING_FEEDBACK_PREFERED_SITE"])
			label:SetPoint ("topleft", panel, "topleft", 15, -60)
			
			local wowi = gump:NewImage (panel, [[Interface\AddOns\Details\images\icons2]], 101, 34, "artwork", {0/512, 101/512, 163/512, 200/512})
			local curse = gump:NewImage (panel, [[Interface\AddOns\Details\images\icons2]], 101, 34, "artwork", {0/512, 101/512, 201/512, 242/512})
			local mmoc = gump:NewImage (panel, [[Interface\AddOns\Details\images\icons2]], 101, 34, "artwork", {0/512, 101/512, 243/512, 285/512})
			wowi:SetDesaturated (true)
			curse:SetDesaturated (true)
			mmoc:SetDesaturated (true)
			
			wowi:SetPoint ("topleft", panel, "topleft", 17, -100)
			curse:SetPoint ("topleft", panel, "topleft", 17, -160)
			mmoc:SetPoint ("topleft", panel, "topleft", 17, -220)
			
			local wowi_title = gump:CreateLabel (panel, "Wow Interface:", nil, nil, "GameFontNormal")
			local wowi_desc = gump:CreateLabel (panel, Loc ["STRING_FEEDBACK_WOWI_DESC"], nil, "silver")
			wowi_desc:SetWidth (202)
			
			wowi_title:SetPoint ("topleft", wowi, "topright", 5, 0)
			wowi_desc:SetPoint ("topleft", wowi_title, "bottomleft", 0, -1)
			--
			local curse_title = gump:CreateLabel (panel, "Curse:", nil, nil, "GameFontNormal")
			local curse_desc = gump:CreateLabel (panel, Loc ["STRING_FEEDBACK_CURSE_DESC"], nil, "silver")
			curse_desc:SetWidth (202)
			
			curse_title:SetPoint ("topleft", curse, "topright", 5, 0)
			curse_desc:SetPoint ("topleft", curse_title, "bottomleft", 0, -1)
			--
			local mmoc_title = gump:CreateLabel (panel, "MMO-Champion:", nil, nil, "GameFontNormal")
			local mmoc_desc = gump:CreateLabel (panel, Loc ["STRING_FEEDBACK_MMOC_DESC"], nil, "silver")
			mmoc_desc:SetWidth (202)
			
			mmoc_title:SetPoint ("topleft", mmoc, "topright", 5, 0)
			mmoc_desc:SetPoint ("topleft", mmoc_title, "bottomleft", 0, -1)
			
			local on_enter = function (self, capsule)
				capsule.image:SetDesaturated (false)
			end
			local on_leave = function (self, capsule)
				capsule.image:SetDesaturated (true)
			end
			
			local on_click = function (_, _, website)
				if (website == 1) then
					_detalhes:CopyPaste ([[http://www.wowinterface.com/downloads/addcomment.php?action=addcomment&fileid=23056]])
					
				elseif (website == 2) then
					_detalhes:CopyPaste ([[http://www.curse.com/addons/wow/details]])
					
				elseif (website == 3) then
					_detalhes:CopyPaste ([[http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks]])
					
				end
			end

			local wowi_button = gump:CreateButton (panel, on_click, 103, 34, "", 1)
			wowi_button:SetPoint ("topleft", wowi, "topleft", -1, 0)
			wowi_button:InstallCustomTexture (nil, nil, nil, nil, true)
			wowi_button.image = wowi
			wowi_button:SetHook ("OnEnter", on_enter)
			wowi_button:SetHook ("OnLeave", on_leave)
			
			local curse_button = gump:CreateButton (panel, on_click, 103, 34, "", 2)
			curse_button:SetPoint ("topleft", curse, "topleft", -1, 0)
			curse_button:InstallCustomTexture (nil, nil, nil, nil, true)
			curse_button.image = curse
			curse_button:SetHook ("OnEnter", on_enter)
			curse_button:SetHook ("OnLeave", on_leave)
			
			local mmoc_button = gump:CreateButton (panel, on_click, 103, 34, "", 3)
			mmoc_button:SetPoint ("topleft", mmoc, "topleft", -1, 0)
			mmoc_button:InstallCustomTexture (nil, nil, nil, nil, true)
			mmoc_button.image = mmoc
			mmoc_button:SetHook ("OnEnter", on_enter)
			mmoc_button:SetHook ("OnLeave", on_leave)
			
		end
		
		_G.DetailsFeedbackPanel:Show()
		
	end
	
--> config class colors
	function _detalhes:OpenClassColorsConfig()
		if (not _G.DetailsClassColorManager) then
			gump:CreateSimplePanel (UIParent, 300, 280, Loc ["STRING_OPTIONS_CLASSCOLOR_MODIFY"], "DetailsClassColorManager")
			local panel = _G.DetailsClassColorManager
			local upper_panel = CreateFrame ("frame", nil, panel)
			upper_panel:SetAllPoints (panel)
			upper_panel:SetFrameLevel (panel:GetFrameLevel()+3)
			
			local y = -50
			
			local callback = function (button, r, g, b, a, self)
				self.MyObject.my_texture:SetVertexColor (r, g, b)
				_detalhes.class_colors [self.MyObject.my_class][1] = r
				_detalhes.class_colors [self.MyObject.my_class][2] = g
				_detalhes.class_colors [self.MyObject.my_class][3] = b
				_detalhes:AtualizaGumpPrincipal (-1, true)
			end
			local set_color = function (self, button, class, index)
				local current_class_color = _detalhes.class_colors [class]
				local r, g, b = unpack (current_class_color)
				_detalhes.gump:ColorPick (self, r, g, b, 1, callback)
			end
		local reset_color = function (self, button, class, index)
				local color_table = RAID_CLASS_COLORS [class]
				local r, g, b = color_table.r, color_table.g, color_table.b
				self.MyObject.my_texture:SetVertexColor (r, g, b)
				_detalhes.class_colors [self.MyObject.my_class][1] = r
				_detalhes.class_colors [self.MyObject.my_class][2] = g
				_detalhes.class_colors [self.MyObject.my_class][3] = b
				_detalhes:AtualizaGumpPrincipal (-1, true)
			end
			local on_enter = function (self, capsule)
				--_detalhes:CooltipPreset (1)
				--GameCooltip:AddLine ("right click to reset")
				--GameCooltip:Show (self)
			end
			local on_leave = function (self, capsule)
			--GameCooltip:Hide()
			end
			
			local reset = gump:NewLabel (panel, panel, nil, nil, "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:" .. 20 .. ":" .. 20 .. ":0:1:512:512:8:70:328:409|t " .. Loc ["STRING_OPTIONS_CLASSCOLOR_RESET"])
			reset:SetPoint ("bottomright", panel, "bottomright", -23, 08)
			local reset_texture = gump:CreateImage (panel, [[Interface\MONEYFRAME\UI-MONEYFRAME-BORDER]], 138, 45, "border")
			reset_texture:SetPoint ("center", reset, "center", 0, -7)
			reset_texture:SetDesaturated (true)
			
			panel.buttons = {}
			
			for index, class_name in ipairs (CLASS_SORT_ORDER) do
				
				local icon = gump:CreateImage (upper_panel, [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-CLASSES]], 32, 32, nil, CLASS_ICON_TCOORDS [class_name], "icon_" .. class_name)
				
				if (index%2 ~= 0) then
					icon:SetPoint (10, y)
				else
					icon:SetPoint (150, y)
					y = y - 33
				end
				
				local bg_texture = gump:CreateImage (panel, [[Interface\AddOns\Details\images\bar_skyline]], 135, 30, "artwork")
				bg_texture:SetPoint ("left", icon, "right", -32, 0)
				
				local button = gump:CreateButton (panel, set_color, 135, 30, "set color", class_name, index)
				button:SetPoint ("left", icon, "right", -32, 0)
				button:InstallCustomTexture (nil, nil, nil, nil, true)
				button:SetFrameLevel (panel:GetFrameLevel()+1)
				button.my_icon = icon
				button.my_texture = bg_texture
				button.my_class = class_name
				button:SetHook ("OnEnter", on_enter)
				button:SetHook ("OnLeave", on_leave)
				button:SetClickFunction (reset_color, nil, nil, "RightClick")
				panel.buttons [class_name] = button
				
			end
			
		end
		
		for class, button in pairs (_G.DetailsClassColorManager.buttons) do
			button.my_texture:SetVertexColor (unpack (_detalhes.class_colors [class]))
		end
		
		_G.DetailsClassColorManager:Show()
	end

--> config bookmarks
	function _detalhes:OpenBookmarkConfig()
	
		if (not _G.DetailsBookmarkManager) then
			gump:CreateSimplePanel (UIParent, 300, 480, Loc ["STRING_OPTIONS_MANAGE_BOOKMARKS"], "DetailsBookmarkManager")
			local panel = _G.DetailsBookmarkManager
			panel.blocks = {}
			
			local clear_func = function (self, button, id)
				if (_detalhes.switch.table [id]) then
					_detalhes.switch.table [id].atributo = nil
					_detalhes.switch.table [id].sub_atributo = nil
					panel:Refresh()
					_detalhes.switch:Update()
				end
			end
			
			local select_attribute = function (_, _, _, attribute, sub_atribute)
				if (not sub_atribute) then 
					return
				end
				_detalhes.switch.table [panel.selecting_slot].atributo = attribute
				_detalhes.switch.table [panel.selecting_slot].sub_atributo = sub_atribute
				panel:Refresh()
				_detalhes.switch:Update()
			end
			
			local cooltip_color = {.1, .1, .1, .3}
			local set_att = function (self, button, id)
				panel.selecting_slot = id
				GameCooltip:Reset()
				GameCooltip:SetType (3)
				GameCooltip:SetOwner (self)
				_detalhes:MontaAtributosOption (_detalhes:GetInstance(1), select_attribute)
				GameCooltip:SetColor (1, cooltip_color)
				GameCooltip:SetColor (2, cooltip_color)
				GameCooltip:SetOption ("HeightAnchorMod", -7)
				GameCooltip:SetOption ("TextSize", _detalhes.font_sizes.menus)
				GameCooltip:SetBackdrop (1, _detalhes.tooltip_backdrop, nil, _detalhes.tooltip_border_color)
				GameCooltip:SetBackdrop (2, _detalhes.tooltip_backdrop, nil, _detalhes.tooltip_border_color)
				
				GameCooltip:ShowCooltip()
			end
			
			local button_backdrop = {bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 64, insets = {left=0, right=0, top=0, bottom=0}}
			
			local set_onenter = function (self, capsule)
				self:SetBackdropColor (1, 1, 1, 0.9)
				capsule.icon:SetBlendMode ("ADD")
			end
			local set_onleave = function (self, capsule)
				self:SetBackdropColor (0, 0, 0, 0.5)
				capsule.icon:SetBlendMode ("BLEND")
			end
			
			for i = 1, 40 do
				local clear = gump:CreateButton (panel, clear_func, 16, 16, nil, i, nil, [[Interface\Glues\LOGIN\Glues-CheckBox-Check]])
				if (i%2 ~= 0) then
					--impar
					clear:SetPoint (15, (( i*10 ) * -1) - 35) --left
				else
					--par
					local o = i-1
					clear:SetPoint (150, (( o*10 ) * -1) - 35) --right
				end
			
				local set = gump:CreateButton (panel, set_att, 16, 16, nil, i)
				set:SetPoint ("left", clear, "right")
				set:SetPoint ("right", clear, "right", 110, 0)
				set:SetBackdrop (button_backdrop)
				set:SetBackdropColor (0, 0, 0, 0.5)
				set:SetHook ("OnEnter", set_onenter)
				set:SetHook ("OnLeave", set_onleave)
			
				set:InstallCustomTexture (nil, nil, nil, nil, true)
				
				local bg_texture = gump:CreateImage (set, [[Interface\AddOns\Details\images\bar_skyline]], 135, 30, "background")
				bg_texture:SetAllPoints()
				set.bg = bg_texture
			
				local icon = gump:CreateImage (set, nil, 16, 16, nil, nil, "icon")
				icon:SetPoint ("left", clear, "right", 4, 0)
				
				local label = gump:CreateLabel (set, "")
				label:SetPoint ("left", icon, "right", 2, 0)

				tinsert (panel.blocks, {icon = icon, label = label, bg = set.bg})
			end
			
			local normal_coords = {0, 1, 0, 1}
			local unknown_coords = {157/512, 206/512, 39/512,  89/512}
			function panel:Refresh()
				local bookmarks = _detalhes.switch.table
				
				for i = 1, 40 do
					local bookmark = bookmarks [i]
					local this_block = panel.blocks [i]
					if (bookmark and bookmark.atributo and bookmark.sub_atributo) then
						if (bookmark.atributo == 5) then --> custom
							local CustomObject = _detalhes.custom [bookmark.sub_atributo]
							if (not CustomObject) then --> ele já foi deletado
								this_block.label.text = "-- x -- x --"
								this_block.icon.texture = "Interface\\ICONS\\Ability_DualWield"
								this_block.icon.texcoord = normal_coords
								this_block.bg:SetVertexColor (.4, .1, .1, .12)
							else
								this_block.label.text = CustomObject.name
								this_block.icon.texture = CustomObject.icon
								this_block.icon.texcoord = normal_coords
								this_block.bg:SetVertexColor (.4, .4, .4, .6)
							end
						else
							this_block.label.text = _detalhes.sub_atributos [bookmark.atributo].lista [bookmark.sub_atributo]
							this_block.icon.texture = _detalhes.sub_atributos [bookmark.atributo].icones [bookmark.sub_atributo] [1]
							this_block.icon.texcoord = _detalhes.sub_atributos [bookmark.atributo].icones [bookmark.sub_atributo] [2]
							this_block.bg:SetVertexColor (.4, .4, .4, .6)
						end
					else
						this_block.label.text = "-- x -- x --"
						this_block.icon.texture = [[Interface\AddOns\Details\images\icons]]
						this_block.icon.texcoord = unknown_coords
						this_block.bg:SetVertexColor (.4, .1, .1, .12)
					end
				end
			end
		end

		_G.DetailsBookmarkManager:Show()
		_G.DetailsBookmarkManager:Refresh()
	end
	
--> create bubble
	do 
		local f = CreateFrame ("frame", "DetailsBubble", UIParent)
		f:SetPoint ("center", UIParent, "center")
		f:SetSize (100, 100)
		f:SetFrameStrata ("TOOLTIP")
		f.isHorizontalFlipped = false
		f.isVerticalFlipped = false
		
		local t = f:CreateTexture (nil, "artwork")
		t:SetTexture ([[Interface\AddOns\Details\images\icons]])
		t:SetSize (131 * 1.2, 81 * 1.2)
		--377 328 508 409  0.0009765625
		t:SetTexCoord (0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625)
		t:SetPoint ("center", f, "center")
		
		local line1 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		line1:SetPoint ("topleft", t, "topleft", 24, -10)
		_detalhes:SetFontSize (line1, 9)
		line1:SetTextColor (.9, .9, .9, 1)
		line1:SetSize (110, 12)
		line1:SetJustifyV ("center")
		line1:SetJustifyH ("center")

		local line2 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		line2:SetPoint ("topleft", t, "topleft", 11, -20)
		_detalhes:SetFontSize (line2, 9)
		line2:SetTextColor (.9, .9, .9, 1)
		line2:SetSize (140, 12)
		line2:SetJustifyV ("center")
		line2:SetJustifyH ("center")
		
		local line3 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		line3:SetPoint ("topleft", t, "topleft", 7, -30)
		_detalhes:SetFontSize (line3, 9)
		line3:SetTextColor (.9, .9, .9, 1)
		line3:SetSize (144, 12)
		line3:SetJustifyV ("center")
		line3:SetJustifyH ("center")
		
		local line4 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		line4:SetPoint ("topleft", t, "topleft", 11, -40)
		_detalhes:SetFontSize (line4, 9)
		line4:SetTextColor (.9, .9, .9, 1)
		line4:SetSize (140, 12)
		line4:SetJustifyV ("center")
		line4:SetJustifyH ("center")

		local line5 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		line5:SetPoint ("topleft", t, "topleft", 24, -50)
		_detalhes:SetFontSize (line5, 9)
		line5:SetTextColor (.9, .9, .9, 1)
		line5:SetSize (110, 12)
		line5:SetJustifyV ("center")
		line5:SetJustifyH ("center")
		
		f.lines = {line1, line2, line3, line4, line5}
		
		function f:FlipHorizontal()
			if (not f.isHorizontalFlipped) then
				if (f.isVerticalFlipped) then
					t:SetTexCoord (0.9912109375, 0.7373046875, 0.7978515625, 0.6416015625)
				else
					t:SetTexCoord (0.9912109375, 0.7373046875, 0.6416015625, 0.7978515625)
				end
				f.isHorizontalFlipped = true
			else
				if (f.isVerticalFlipped) then
					t:SetTexCoord (0.7373046875, 0.9912109375, 0.7978515625, 0.6416015625)
				else
					t:SetTexCoord (0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625)
				end
				f.isHorizontalFlipped = false
			end
		end
		
		function f:FlipVertical()
		
			if (not f.isVerticalFlipped) then
				if (f.isHorizontalFlipped) then
					t:SetTexCoord (0.7373046875, 0.9912109375, 0.7978515625, 0.6416015625)
				else
					t:SetTexCoord (0.9912109375, 0.7373046875, 0.7978515625, 0.6416015625)
				end
				f.isVerticalFlipped = true
			else
				if (f.isHorizontalFlipped) then
					t:SetTexCoord (0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625)
				else
					t:SetTexCoord (0.9912109375, 0.7373046875, 0.6416015625, 0.7978515625)
				end
				f.isVerticalFlipped = false
			end
		end
		
		function f:TextConfig (fontsize, fontface, fontcolor)
			for i = 1, 5 do
			
				local line = f.lines [i]
				
				_detalhes:SetFontSize (line, fontsize or 9)
				_detalhes:SetFontFace (line, fontface or [[Fonts\FRIZQT__.TTF]])
				_detalhes:SetFontColor (line, fontcolor or {.9, .9, .9, 1})

			end
		end
		
		function f:SetBubbleText (line1, line2, line3, line4, line5)
			if (not line1) then
				for _, line in ipairs (f.lines) do
					line:SetText ("")
				end
				return
			end
			
			if (line1:find ("\n")) then
				line1, line2, line3, line4, line5 = strsplit ("\n", line1)
			end
			
			f.lines[1]:SetText (line1)
			f.lines[2]:SetText (line2)
			f.lines[3]:SetText (line3)
			f.lines[4]:SetText (line4)
			f.lines[5]:SetText (line5)
		end
		
		function f:SetOwner (frame, myPoint, hisPoint, x, y, alpha)
			f:ClearAllPoints()
			f:TextConfig()
			f:SetBubbleText (nil)
			t:SetTexCoord (0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625)
			f.isHorizontalFlipped = false
			f.isVerticalFlipped = false
			f:SetPoint (myPoint or "bottom", frame, hisPoint or "top", x or 0, y or 0)
			t:SetAlpha (alpha or 1)
		end
		
		function f:ShowBubble()
			f:Show()
		end
		
		function f:HideBubble()
			f:Hide()
		end
		
		f:SetBubbleText (nil)
		
		f:Hide()
	end
	
--> feed back request
	
	function _detalhes:ShowFeedbackRequestWindow()
	
		local feedback_frame = CreateFrame ("FRAME", "DetailsFeedbackWindow", UIParent, "ButtonFrameTemplate")
		tinsert (UISpecialFrames, "DetailsFeedbackWindow")
		feedback_frame:SetPoint ("center", UIParent, "center")
		feedback_frame:SetSize (512, 200)
		feedback_frame.portrait:SetTexture ([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-GNOME]])
		
		feedback_frame.TitleText:SetText ("Help Details! to Improve!")
		
		feedback_frame.uppertext = feedback_frame:CreateFontString (nil, "artwork", "GameFontNormal")
		feedback_frame.uppertext:SetText ("Tell us about your experience using Details!, what you liked most, where we could improve, what things you want to see in the future?")
		feedback_frame.uppertext:SetPoint ("topleft", feedback_frame, "topleft", 60, -32)
		local font, _, flags = feedback_frame.uppertext:GetFont()
		feedback_frame.uppertext:SetFont (font, 10, flags)
		feedback_frame.uppertext:SetTextColor (1, 1, 1, .8)
		feedback_frame.uppertext:SetWidth (440)

		local editbox = _detalhes.gump:NewTextEntry (feedback_frame, nil, "$parentTextEntry", "text", 387, 14)
		editbox:SetPoint (20, -106)
		editbox:SetAutoFocus (false)
		editbox:SetHook ("OnEditFocusGained", function() 
			editbox.text = "http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks" 
			editbox:HighlightText()
		end)
		editbox:SetHook ("OnEditFocusLost", function() 
			editbox.text = "http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks" 
			editbox:HighlightText()
		end)
		editbox:SetHook ("OnChar", function() 
			editbox.text = "http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks"
			editbox:HighlightText()
		end)
		editbox.text = "http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks"
		
		
		feedback_frame.midtext = feedback_frame:CreateFontString (nil, "artwork", "GameFontNormal")
		feedback_frame.midtext:SetText ("visit the link above and let's make Details! stronger!")
		feedback_frame.midtext:SetPoint ("center", editbox.widget, "center")
		feedback_frame.midtext:SetPoint ("top", editbox.widget, "bottom", 0, -2)
		feedback_frame.midtext:SetJustifyH ("center")
		local font, _, flags = feedback_frame.midtext:GetFont()
		feedback_frame.midtext:SetFont (font, 10, flags)
		--feedback_frame.midtext:SetTextColor (1, 1, 1, 1)
		feedback_frame.midtext:SetWidth (440)
		
		
		feedback_frame.gnoma = feedback_frame:CreateTexture (nil, "artwork")
		feedback_frame.gnoma:SetPoint ("topright", feedback_frame, "topright", -1, -59)
		feedback_frame.gnoma:SetTexture ("Interface\\AddOns\\Details\\images\\icons2")
		feedback_frame.gnoma:SetSize (105*1.05, 107*1.05)
		feedback_frame.gnoma:SetTexCoord (0.2021484375, 0, 0.7919921875, 1)

		feedback_frame.close = CreateFrame ("Button", "DetailsFeedbackWindowCloseButton", feedback_frame, "OptionsButtonTemplate")
		feedback_frame.close:SetPoint ("bottomleft", feedback_frame, "bottomleft", 8, 4)
		feedback_frame.close:SetText ("Close")
		feedback_frame.close:SetScript ("OnClick", function (self)
			editbox:ClearFocus()
			feedback_frame:Hide()
		end)
		
		feedback_frame.postpone = CreateFrame ("Button", "DetailsFeedbackWindowPostPoneButton", feedback_frame, "OptionsButtonTemplate")
		feedback_frame.postpone:SetPoint ("bottomright", feedback_frame, "bottomright", -10, 4)
		feedback_frame.postpone:SetText ("Remind-me Later")
		feedback_frame.postpone:SetScript ("OnClick", function (self)
			editbox:ClearFocus()
			feedback_frame:Hide()
			_detalhes.tutorial.feedback_window1 = false
		end)
		feedback_frame.postpone:SetWidth (130)
		
		feedback_frame:SetScript ("OnHide", function() 
			editbox:ClearFocus()
		end)
		
		--0.0009765625 512
		function _detalhes:FeedbackSetFocus()
			DetailsFeedbackWindow:Show()
			DetailsFeedbackWindowTextEntry.MyObject:SetFocus()
			DetailsFeedbackWindowTextEntry.MyObject:HighlightText()
		end
		_detalhes:ScheduleTimer ("FeedbackSetFocus", 5)
	
	end
	
--> interface menu
	local f = CreateFrame ("frame", "DetailsInterfaceOptionsPanel", UIParent)
	f.name = "Details"
	f.logo = f:CreateTexture (nil, "overlay")
	f.logo:SetPoint ("center", f, "center", 0, 0)
	f.logo:SetPoint ("top", f, "top", 25, 56)
	f.logo:SetTexture ([[Interface\AddOns\Details\images\logotipo]])
	f.logo:SetSize (256, 128)
	InterfaceOptions_AddCategory (f)
	
		--> open options panel
		f.options_button = CreateFrame ("button", nil, f, "OptionsButtonTemplate")
		f.options_button:SetText (Loc ["STRING_INTERFACE_OPENOPTIONS"])
		f.options_button:SetPoint ("topleft", f, "topleft", 10, -100)
		f.options_button:SetWidth (170)
		f.options_button:SetScript ("OnClick", function (self)
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (not lower_instance) then
				--> no window opened?
				local instance1 = _detalhes.tabela_instancias [1]
				if (instance1) then
					instance1:Enable()
					return _detalhes:OpenOptionsWindow (instance1)
				else
					instance1 = _detalhes:CriarInstancia (_, true)
					if (instance1) then
						return _detalhes:OpenOptionsWindow (instance1)
					else
						_detalhes:Msg ("couldn't open options panel: no window available.")
					end
				end
			end
			_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
		end)
		
		--> create new window
		f.new_window_button = CreateFrame ("button", nil, f, "OptionsButtonTemplate")
		f.new_window_button:SetText (Loc ["STRING_MINIMAPMENU_NEWWINDOW"])
		f.new_window_button:SetPoint ("topleft", f, "topleft", 10, -125)
		f.new_window_button:SetWidth (170)
		f.new_window_button:SetScript ("OnClick", function (self)
			_detalhes:CriarInstancia (_, true)
		end)	
	
	function _detalhes:CreateWelcomePanel (name, parent, width, height, make_movable)
		local f = CreateFrame ("frame", name, parent or UIParent)
		f:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 128, insets = {left=3, right=3, top=3, bottom=3},
		edgeFile = [[Interface\AddOns\Details\images\border_welcome]], edgeSize = 16})
		f:SetBackdropColor (1, 1, 1, 0.75)
		f:SetSize (width or 1, height or 1)
		
		if (make_movable) then
			f:SetScript ("OnMouseDown", function(self, button)
				if (self.isMoving) then
					return
				end
				if (button == "RightButton") then
					self:Hide()
				else
					self:StartMoving() 
					self.isMoving = true
				end
			end)
			f:SetScript ("OnMouseUp", function(self, button) 
				if (self.isMoving and button == "LeftButton") then
					self:StopMovingOrSizing()
					self.isMoving = nil
				end
			end)
			f:SetToplevel (true)
			f:SetMovable (true)
		end
		
		return f
	end
	
	function _detalhes:OpenBrokerTextEditor()
		
		if (not DetailsWindowOptionsBrokerTextEditor) then

			local panel = _detalhes:CreateWelcomePanel ("DetailsWindowOptionsBrokerTextEditor", nil, 650, 210, true)
			panel:SetPoint ("center", UIParent, "center")
			panel:Hide()
			panel:SetFrameStrata ("FULLSCREEN")
		
			local textentry = _detalhes.gump:NewSpecialLuaEditorEntry (panel, 450, 185, "editbox", "$parentEntry", true)
			textentry:SetPoint ("topleft", panel, "topleft", 10, -12)
			
			textentry.editbox:SetScript ("OnTextChanged", function()
				local text = panel.editbox:GetText()
				_detalhes.data_broker_text = text
				_detalhes:BrokerTick()
				if (_G.DetailsOptionsWindow)  then
					_G.DetailsOptionsWindow19BrokerEntry.MyObject:SetText (_detalhes.data_broker_text)
				end
			end)
			
			local option_selected = 1
			local onclick= function (_, _, value)
				option_selected = value
			end
			local AddOptions = {
				{label = Loc ["STRING_OPTIONS_DATABROKER_TEXT_ADD1"], value = 1, onclick = onclick},
				{label = Loc ["STRING_OPTIONS_DATABROKER_TEXT_ADD2"], value = 2, onclick = onclick},
				{label = Loc ["STRING_OPTIONS_DATABROKER_TEXT_ADD3"], value = 3, onclick = onclick},
				{label = Loc ["STRING_OPTIONS_DATABROKER_TEXT_ADD4"], value = 4, onclick = onclick},
				
				{label = Loc ["STRING_OPTIONS_DATABROKER_TEXT_ADD5"], value = 5, onclick = onclick},
				{label = Loc ["STRING_OPTIONS_DATABROKER_TEXT_ADD6"], value = 6, onclick = onclick},
				{label = Loc ["STRING_OPTIONS_DATABROKER_TEXT_ADD7"], value = 7, onclick = onclick},
				{label = Loc ["STRING_OPTIONS_DATABROKER_TEXT_ADD8"], value = 8, onclick = onclick},
				
				{label = Loc ["STRING_OPTIONS_DATABROKER_TEXT_ADD9"], value = 9, onclick = onclick},
			}
			local buildAddMenu = function()
				return AddOptions
			end
			
			local d = _detalhes.gump:NewDropDown (panel, _, "$parentTextOptionsDropdown", "TextOptionsDropdown", 150, 20, buildAddMenu, 1)
			d:SetPoint ("topright", panel, "topright", -12, -14)
			--d:SetFrameStrata ("TOOLTIP")

			local optiontable = {"{dmg}", "{dps}", "{dpos}", "{ddiff}", "{heal}", "{hps}", "{hpos}", "{hdiff}", "{time}"}
		
			local add_button = _detalhes.gump:NewButton (panel, nil, "$parentAddButton", nil, 20, 20, function() 
				textentry.editbox:Insert (optiontable [option_selected])
			end, 
			nil, nil, nil, "<-")
			add_button:SetPoint ("right", d, "left", -2, 0)
			add_button:InstallCustomTexture()
			
			
			-- code author Saiket from  http://www.wowinterface.com/forums/showpost.php?p=245759&postcount=6
			--- @return StartPos, EndPos of highlight in this editbox.
			local function GetTextHighlight ( self )
				local Text, Cursor = self:GetText(), self:GetCursorPosition();
				self:Insert( "" ); -- Delete selected text
				local TextNew, CursorNew = self:GetText(), self:GetCursorPosition();
				-- Restore previous text
				self:SetText( Text );
				self:SetCursorPosition( Cursor );
				local Start, End = CursorNew, #Text - ( #TextNew - CursorNew );
				self:HighlightText( Start, End );
				return Start, End;
			end
		      
			local StripColors;
			do
				local CursorPosition, CursorDelta;
				--- Callback for gsub to remove unescaped codes.
				local function StripCodeGsub ( Escapes, Code, End )
					if ( #Escapes % 2 == 0 ) then -- Doesn't escape Code
						if ( CursorPosition and CursorPosition >= End - 1 ) then
							CursorDelta = CursorDelta - #Code;
						end
						return Escapes;
					end
				end
				--- Removes a single escape sequence.
				local function StripCode ( Pattern, Text, OldCursor )
					CursorPosition, CursorDelta = OldCursor, 0;
					return Text:gsub( Pattern, StripCodeGsub ), OldCursor and CursorPosition + CursorDelta;
				end
				--- Strips Text of all color escape sequences.
				-- @param Cursor  Optional cursor position to keep track of.
				-- @return Stripped text, and the updated cursor position if Cursor was given.
				function StripColors ( Text, Cursor )
					Text, Cursor = StripCode( "(|*)(|c%x%x%x%x%x%x%x%x)()", Text, Cursor );
					return StripCode( "(|*)(|r)()", Text, Cursor );
				end
			end
			
			local COLOR_END = "|r";
			--- Wraps this editbox's selected text with the given color.
			local function ColorSelection ( self, ColorCode )
				local Start, End = GetTextHighlight( self );
				local Text, Cursor = self:GetText(), self:GetCursorPosition();
				if ( Start == End ) then -- Nothing selected
					--Start, End = Cursor, Cursor; -- Wrap around cursor
					return; -- Wrapping the cursor in a color code and hitting backspace crashes the client!
				end
				-- Find active color code at the end of the selection
				local ActiveColor;
				if ( End < #Text ) then -- There is text to color after the selection
					local ActiveEnd;
					local CodeEnd, _, Escapes, Color = 0;
					while ( true ) do
						_, CodeEnd, Escapes, Color = Text:find( "(|*)(|c%x%x%x%x%x%x%x%x)", CodeEnd + 1 );
						if ( not CodeEnd or CodeEnd > End ) then
							break;
						end
						if ( #Escapes % 2 == 0 ) then -- Doesn't escape Code
							ActiveColor, ActiveEnd = Color, CodeEnd;
						end
					end
		       
					if ( ActiveColor ) then
						-- Check if color gets terminated before selection ends
						CodeEnd = 0;
						while ( true ) do
							_, CodeEnd, Escapes = Text:find( "(|*)|r", CodeEnd + 1 );
							if ( not CodeEnd or CodeEnd > End ) then
								break;
							end
							if ( CodeEnd > ActiveEnd and #Escapes % 2 == 0 ) then -- Terminates ActiveColor
								ActiveColor = nil;
								break;
							end
						end
					end
				end
		     
				local Selection = Text:sub( Start + 1, End );
				-- Remove color codes from the selection
				local Replacement, CursorReplacement = StripColors( Selection, Cursor - Start );
		     
				self:SetText( ( "" ):join(
					Text:sub( 1, Start ),
					ColorCode, Replacement, COLOR_END,
					ActiveColor or "", Text:sub( End + 1 )
				) );
		     
				-- Restore cursor and highlight, adjusting for wrapper text
				Cursor = Start + CursorReplacement;
				if ( CursorReplacement > 0 ) then -- Cursor beyond start of color code
					Cursor = Cursor + #ColorCode;
				end
				if ( CursorReplacement >= #Replacement ) then -- Cursor beyond end of color
					Cursor = Cursor + #COLOR_END;
				end
				
				self:SetCursorPosition( Cursor );
				-- Highlight selection and wrapper
				self:HighlightText( Start, #ColorCode + ( #Replacement - #Selection ) + #COLOR_END + End );
			end
			
			local color_func = function (_, r, g, b, a)
				local hex = _detalhes:hex (a*255).._detalhes:hex (r*255).._detalhes:hex (g*255).._detalhes:hex (b*255)
				ColorSelection ( textentry.editbox, "|c" .. hex)
			end
			
			local color_button = _detalhes.gump:NewColorPickButton (panel, "$parentButton5", nil, color_func)
			color_button:SetSize (80, 20)
			color_button:SetPoint ("topright", panel, "topright", -12, -102)
			color_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_COLOR_TOOLTIP"]
		
			local done = function()
				local text = panel.editbox:GetText()
				_detalhes.data_broker_text = text
				if (_G.DetailsOptionsWindow)  then
					_G.DetailsOptionsWindow19BrokerEntry.MyObject:SetText (_detalhes.data_broker_text)
				end
				_detalhes:BrokerTick()
				panel:Hide()
			end
			
			local ok_button = _detalhes.gump:NewButton (panel, nil, "$parentButtonOk", nil, 80, 20, done, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_DONE"], 1)
			ok_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DONE_TOOLTIP"]
			ok_button:InstallCustomTexture()
			ok_button:SetPoint ("topright", panel, "topright", -12, -174)
			
			local reset_button = _detalhes.gump:NewButton (panel, nil, "$parentDefaultOk", nil, 80, 20, function() textentry.editbox:SetText ("") end, nil, nil, nil, "Reset", 1)
			reset_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_RESET_TOOLTIP"]
			reset_button:InstallCustomTexture()
			reset_button:SetPoint ("topright", panel, "topright", -100, -152)
			
			local cancel_button = _detalhes.gump:NewButton (panel, nil, "$parentDefaultCancel", nil, 80, 20, function() textentry.editbox:SetText (panel.default_text); done(); end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_CANCEL"], 1)
			cancel_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_CANCEL_TOOLTIP"]
			cancel_button:InstallCustomTexture()
			cancel_button:SetPoint ("topright", panel, "topright", -100, -174)			
		
		end
		
		local panel = DetailsWindowOptionsBrokerTextEditor
		
		local text = _detalhes.data_broker_text:gsub ("||", "|")
		panel.default_text = text
		panel.editbox:SetText (text)
		
		panel:Show()
	end
	
--> row text editor

	local panel = _detalhes:CreateWelcomePanel ("DetailsWindowOptionsBarTextEditor", nil, 650, 210, true)
	panel:SetPoint ("center", UIParent, "center")
	panel:Hide()
	panel:SetFrameStrata ("FULLSCREEN")
	
	function panel:Open (text, callback, host, default)
		if (host) then
			panel:SetPoint ("center", host, "center")
		end
		
		text = text:gsub ("||", "|")
		panel.default_text = text
		panel.editbox:SetText (text)
		panel.callback = callback
		panel.default = default or ""
		panel:Show()
	end
	
	local textentry = _detalhes.gump:NewSpecialLuaEditorEntry (panel, 450, 185, "editbox", "$parentEntry", true)
	textentry:SetPoint ("topleft", panel, "topleft", 10, -12)
	
	local arg1_button = _detalhes.gump:NewButton (panel, nil, "$parentButton1", nil, 80, 20, function() textentry.editbox:Insert ("{data1}") end, nil, nil, nil, string.format (Loc ["STRING_OPTIONS_TEXTEDITOR_DATA"], "1"), 1)
	local arg2_button = _detalhes.gump:NewButton (panel, nil, "$parentButton2", nil, 80, 20, function() textentry.editbox:Insert ("{data2}") end, nil, nil, nil, string.format (Loc ["STRING_OPTIONS_TEXTEDITOR_DATA"], "2"), 1)
	local arg3_button = _detalhes.gump:NewButton (panel, nil, "$parentButton3", nil, 80, 20, function() textentry.editbox:Insert ("{data3}") end, nil, nil, nil, string.format (Loc ["STRING_OPTIONS_TEXTEDITOR_DATA"], "3"), 1)
	arg1_button:SetPoint ("topright", panel, "topright", -12, -14)
	arg2_button:SetPoint ("topright", panel, "topright", -12, -36)
	arg3_button:SetPoint ("topright", panel, "topright", -12, -58)
	arg1_button:InstallCustomTexture()
	arg2_button:InstallCustomTexture()
	arg3_button:InstallCustomTexture()
	
	arg1_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DATA_TOOLTIP"]
	arg2_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DATA_TOOLTIP"]
	arg3_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DATA_TOOLTIP"]
	
	-- code author Saiket from  http://www.wowinterface.com/forums/showpost.php?p=245759&postcount=6
	--- @return StartPos, EndPos of highlight in this editbox.
	local function GetTextHighlight ( self )
		local Text, Cursor = self:GetText(), self:GetCursorPosition();
		self:Insert( "" ); -- Delete selected text
		local TextNew, CursorNew = self:GetText(), self:GetCursorPosition();
		-- Restore previous text
		self:SetText( Text );
		self:SetCursorPosition( Cursor );
		local Start, End = CursorNew, #Text - ( #TextNew - CursorNew );
		self:HighlightText( Start, End );
		return Start, End;
	end
      
	local StripColors;
	do
		local CursorPosition, CursorDelta;
		--- Callback for gsub to remove unescaped codes.
		local function StripCodeGsub ( Escapes, Code, End )
			if ( #Escapes % 2 == 0 ) then -- Doesn't escape Code
				if ( CursorPosition and CursorPosition >= End - 1 ) then
					CursorDelta = CursorDelta - #Code;
				end
				return Escapes;
			end
		end
		--- Removes a single escape sequence.
		local function StripCode ( Pattern, Text, OldCursor )
			CursorPosition, CursorDelta = OldCursor, 0;
			return Text:gsub( Pattern, StripCodeGsub ), OldCursor and CursorPosition + CursorDelta;
		end
		--- Strips Text of all color escape sequences.
		-- @param Cursor  Optional cursor position to keep track of.
		-- @return Stripped text, and the updated cursor position if Cursor was given.
		function StripColors ( Text, Cursor )
			Text, Cursor = StripCode( "(|*)(|c%x%x%x%x%x%x%x%x)()", Text, Cursor );
			return StripCode( "(|*)(|r)()", Text, Cursor );
		end
	end
	
	local COLOR_END = "|r";
	--- Wraps this editbox's selected text with the given color.
	local function ColorSelection ( self, ColorCode )
		local Start, End = GetTextHighlight( self );
		local Text, Cursor = self:GetText(), self:GetCursorPosition();
		if ( Start == End ) then -- Nothing selected
			--Start, End = Cursor, Cursor; -- Wrap around cursor
			return; -- Wrapping the cursor in a color code and hitting backspace crashes the client!
		end
		-- Find active color code at the end of the selection
		local ActiveColor;
		if ( End < #Text ) then -- There is text to color after the selection
			local ActiveEnd;
			local CodeEnd, _, Escapes, Color = 0;
			while ( true ) do
				_, CodeEnd, Escapes, Color = Text:find( "(|*)(|c%x%x%x%x%x%x%x%x)", CodeEnd + 1 );
				if ( not CodeEnd or CodeEnd > End ) then
					break;
				end
				if ( #Escapes % 2 == 0 ) then -- Doesn't escape Code
					ActiveColor, ActiveEnd = Color, CodeEnd;
				end
			end
       
			if ( ActiveColor ) then
				-- Check if color gets terminated before selection ends
				CodeEnd = 0;
				while ( true ) do
					_, CodeEnd, Escapes = Text:find( "(|*)|r", CodeEnd + 1 );
					if ( not CodeEnd or CodeEnd > End ) then
						break;
					end
					if ( CodeEnd > ActiveEnd and #Escapes % 2 == 0 ) then -- Terminates ActiveColor
						ActiveColor = nil;
						break;
					end
				end
			end
		end
     
		local Selection = Text:sub( Start + 1, End );
		-- Remove color codes from the selection
		local Replacement, CursorReplacement = StripColors( Selection, Cursor - Start );
     
		self:SetText( ( "" ):join(
			Text:sub( 1, Start ),
			ColorCode, Replacement, COLOR_END,
			ActiveColor or "", Text:sub( End + 1 )
		) );
     
		-- Restore cursor and highlight, adjusting for wrapper text
		Cursor = Start + CursorReplacement;
		if ( CursorReplacement > 0 ) then -- Cursor beyond start of color code
			Cursor = Cursor + #ColorCode;
		end
		if ( CursorReplacement >= #Replacement ) then -- Cursor beyond end of color
			Cursor = Cursor + #COLOR_END;
		end
		
		self:SetCursorPosition( Cursor );
		-- Highlight selection and wrapper
		self:HighlightText( Start, #ColorCode + ( #Replacement - #Selection ) + #COLOR_END + End );
	end
	
	local color_func = function (_, r, g, b, a)
		local hex = _detalhes:hex (a*255).._detalhes:hex (r*255).._detalhes:hex (g*255).._detalhes:hex (b*255)
		ColorSelection ( textentry.editbox, "|c" .. hex)
	end
	
	local func_button = _detalhes.gump:NewButton (panel, nil, "$parentButton4", nil, 80, 20, function() textentry.editbox:Insert ("{func local player = ...; return 0;}") end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_FUNC"], 1)
	local color_button = _detalhes.gump:NewColorPickButton (panel, "$parentButton5", nil, color_func)
	color_button:SetSize (80, 20)
	func_button:SetPoint ("topright", panel, "topright", -12, -80)
	color_button:SetPoint ("topright", panel, "topright", -12, -102)
	func_button:InstallCustomTexture()
	
	color_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_COLOR_TOOLTIP"]
	func_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_FUNC_TOOLTIP"]
	
	--color_button:InstallCustomTexture()
	
	--local comma_button = _detalhes.gump:NewButton (panel, nil, "$parentButtonComma", nil, 80, 20, function() textentry.editbox:Insert ("_detalhes:comma_value ( )") end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_COMMA"])
	--local tok_button = _detalhes.gump:NewButton (panel, nil, "$parentButtonTok", nil, 80, 20, function() textentry.editbox:Insert ("_detalhes:ToK2 ( )") end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_TOK"])
	--comma_button:InstallCustomTexture()
	--tok_button:InstallCustomTexture()
	--comma_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_COMMA_TOOLTIP"]
	--tok_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_TOK_TOOLTIP"]
	
	--comma_button:SetPoint ("topright", panel, "topright", -100, -14)
	--tok_button:SetPoint ("topright", panel, "topright", -100, -36)



	local done = function()
		local text = panel.editbox:GetText()
		--text = text:gsub ("\n", "")
		
		--local test = text
	
		--local function errorhandler(err)
		--	return geterrorhandler()(err)
		--end

		--local code = [[local str = "STR"; str = _detalhes.string.replace (str, 100, 50, 75, {nome = "you", total = 10, total_without_pet = 5, damage_taken = 7, last_dps = 1, friendlyfire_total = 6, totalover = 2, totalabsorb = 4, totalover_without_pet = 6, healing_taken = 1, heal_enemy_amt = 2});]]
		--code = code:gsub ("STR", test)

		--local f = loadstring (code)
		--if (not f) then
		--	print ("loadstring failed:", f)
		--end
		--local err, two = xpcall (f, errorhandler)
		--if (not err) then
		--	return
		--end
		
		panel.callback (text)
		panel:Hide()
	end
	
	local ok_button = _detalhes.gump:NewButton (panel, nil, "$parentButtonOk", nil, 80, 20, done, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_DONE"], 1)
	ok_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DONE_TOOLTIP"]
	ok_button:InstallCustomTexture()
	ok_button:SetPoint ("topright", panel, "topright", -12, -174)
	
	local reset_button = _detalhes.gump:NewButton (panel, nil, "$parentDefaultOk", nil, 80, 20, function() textentry.editbox:SetText (panel.default) end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_RESET"], 1)
	reset_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_RESET_TOOLTIP"]
	reset_button:InstallCustomTexture()
	reset_button:SetPoint ("topright", panel, "topright", -100, -152)
	
	local cancel_button = _detalhes.gump:NewButton (panel, nil, "$parentDefaultCancel", nil, 80, 20, function() textentry.editbox:SetText (panel.default_text); done(); end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_CANCEL"], 1)
	cancel_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_CANCEL_TOOLTIP"]
	cancel_button:InstallCustomTexture()
	cancel_button:SetPoint ("topright", panel, "topright", -100, -174)	
	
	--update window
	function _detalhes:OpenUpdateWindow()
	
		if (not _G.DetailsUpdateDialog) then
			local updatewindow_frame = CreateFrame ("frame", "DetailsUpdateDialog", UIParent, "ButtonFrameTemplate")
			updatewindow_frame:SetFrameStrata ("LOW")
			tinsert (UISpecialFrames, "DetailsUpdateDialog")
			updatewindow_frame:SetPoint ("center", UIParent, "center")
			updatewindow_frame:SetSize (512, 200)
			updatewindow_frame.portrait:SetTexture ([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-GNOME]])
			
			updatewindow_frame.TitleText:SetText ("A New Version Is Available!")

			updatewindow_frame.midtext = updatewindow_frame:CreateFontString (nil, "artwork", "GameFontNormal")
			updatewindow_frame.midtext:SetText ("Good news everyone!\nA new version has been forged and is waiting to be looted.")
			updatewindow_frame.midtext:SetPoint ("topleft", updatewindow_frame, "topleft", 10, -90)
			updatewindow_frame.midtext:SetJustifyH ("center")
			updatewindow_frame.midtext:SetWidth (370)
			
			updatewindow_frame.gnoma = updatewindow_frame:CreateTexture (nil, "artwork")
			updatewindow_frame.gnoma:SetPoint ("topright", updatewindow_frame, "topright", -3, -59)
			updatewindow_frame.gnoma:SetTexture ("Interface\\AddOns\\Details\\images\\icons2")
			updatewindow_frame.gnoma:SetSize (105*1.05, 107*1.05)
			updatewindow_frame.gnoma:SetTexCoord (0.2021484375, 0, 0.7919921875, 1)
			
			local editbox = _detalhes.gump:NewTextEntry (updatewindow_frame, nil, "$parentTextEntry", "text", 387, 14)
			editbox:SetPoint (20, -136)
			editbox:SetAutoFocus (false)
			editbox:SetHook ("OnEditFocusGained", function() 
				editbox.text = "http://www.curse.com/addons/wow/details"
				editbox:HighlightText()
			end)
			editbox:SetHook ("OnEditFocusLost", function() 
				editbox.text = "http://www.curse.com/addons/wow/details"
				editbox:HighlightText()
			end)
			editbox:SetHook ("OnChar", function() 
				editbox.text = "http://www.curse.com/addons/wow/details"
				editbox:HighlightText()
			end)
			editbox.text = "http://www.curse.com/addons/wow/details"
			
			updatewindow_frame.close = CreateFrame ("Button", "DetailsUpdateDialogCloseButton", updatewindow_frame, "OptionsButtonTemplate")
			updatewindow_frame.close:SetPoint ("bottomleft", updatewindow_frame, "bottomleft", 8, 4)
			updatewindow_frame.close:SetText ("Close")
			
			updatewindow_frame.close:SetScript ("OnClick", function (self)
				DetailsUpdateDialog:Hide()
				editbox:ClearFocus()
			end)
			
			updatewindow_frame:SetScript ("OnHide", function()
				editbox:ClearFocus()
			end)
			
			function _detalhes:UpdateDialogSetFocus()
				DetailsUpdateDialog:Show()
				DetailsUpdateDialogTextEntry.MyObject:SetFocus()
				DetailsUpdateDialogTextEntry.MyObject:HighlightText()
			end
			_detalhes:ScheduleTimer ("UpdateDialogSetFocus", 1)
			
		end
		
	end	
	
	function _detalhes:OpenProfiler()
	
		--> isn't first run, so just quit
		if (not _detalhes.character_first_run) then
			return
		elseif (_detalhes.is_first_run) then
			return
		elseif (_detalhes.always_use_profile) then -- and type (_detalhes.always_use_profile) == "string"
			return
		else
			--> check is this is the first run of the addon (after being installed)
			local amount = 0
			for name, profile in pairs (_detalhes_global.__profiles) do 
				amount = amount + 1
			end
			if (amount == 1) then
				return
			end
		end
	
		local f = _detalhes:CreateWelcomePanel (nil, nil, 250, 300, true)
		f:SetPoint ("right", UIParent, "right", -5, 0)

		local logo = f:CreateTexture (nil, "artwork")
		logo:SetTexture ([[Interface\AddOns\Details\images\logotipo]])
		logo:SetSize (256*0.8, 128*0.8)
		logo:SetPoint ("center", f, "center", 0, 0)
		logo:SetPoint ("top", f, "top", 20, 20)
		
		local string_profiler = f:CreateFontString (nil, "artwork", "GameFontNormal")
		string_profiler:SetPoint ("top", logo, "bottom", -20, 10)
		string_profiler:SetText ("Profiler!")
		
		local string_profiler = f:CreateFontString (nil, "artwork", "GameFontNormal")
		string_profiler:SetPoint ("topleft", f, "topleft", 10, -130)
		string_profiler:SetText (Loc ["STRING_OPTIONS_PROFILE_SELECTEXISTING"])
		string_profiler:SetWidth (230)
		_detalhes:SetFontSize (string_profiler, 11)
		_detalhes:SetFontColor (string_profiler, "white")
		
		--> get the new profile name
		local current_profile = _detalhes:GetCurrentProfileName()
		
		local on_select_profile = function (_, _, profilename)
			if (profilename ~= _detalhes:GetCurrentProfileName()) then
				_detalhes:ApplyProfile (profilename)
				if (_G.DetailsOptionsWindow and _G.DetailsOptionsWindow:IsShown()) then
					_detalhes:OpenOptionsWindow (_G.DetailsOptionsWindow.instance)
				end
			end
		end
		
		local texcoord = {5/32, 30/32, 4/32, 28/32}
		
		local fill_dropdown = function()
			local t = {
				{value = current_profile, label = Loc ["STRING_OPTIONS_PROFILE_USENEW"], onclick = on_select_profile, icon = [[Interface\FriendsFrame\UI-Toast-FriendRequestIcon]], texcoord = {4/32, 30/32, 4/32, 28/32}, iconcolor = "orange"}
			}
			for _, profilename in ipairs (_detalhes:GetProfileList()) do
				if (profilename ~= current_profile) then
					t[#t+1] = {value = profilename, label = profilename, onclick = on_select_profile, icon = [[Interface\FriendsFrame\UI-Toast-FriendOnlineIcon]], texcoord = texcoord, iconcolor = "yellow"}
				end
			end
			return t
		end
		
		local dropdown = _detalhes.gump:NewDropDown (f, f, "DetailsProfilerProfileSelectorDropdown", "dropdown", 220, 20, fill_dropdown, 1)
		dropdown:SetPoint (15, -190)
		
		local confirm_func = function()
			if (current_profile ~= _detalhes:GetCurrentProfileName()) then
				_detalhes:EraseProfile (current_profile)
			end
			f:Hide()
		end
		local confirm = _detalhes.gump:NewButton (f, f, "DetailsProfilerProfileConfirmButton", "button", 150, 20, confirm_func, nil, nil, nil, "okey!")
		confirm:SetPoint (50, -250)
		confirm:InstallCustomTexture()
	
	end	
	
	--> minimap icon and hotcorner
	function _detalhes:RegisterMinimap()
	
		local LDB = LibStub ("LibDataBroker-1.1", true)
		local LDBIcon = LDB and LibStub ("LibDBIcon-1.0", true)
		
		if LDB then

			local databroker = LDB:NewDataObject ("Details", {
				type = "data source",
				icon = [[Interface\AddOns\Details\images\minimap]],
				text = "0",
				
				HotCornerIgnore = true,
				
				OnClick = function (self, button)
				
					if (button == "LeftButton") then
					
						--> 1 = open options panel
						if (_detalhes.minimap.onclick_what_todo == 1) then
							local lower_instance = _detalhes:GetLowerInstanceNumber()
							if (not lower_instance) then
								local instance = _detalhes:GetInstance (1)
								_detalhes.CriarInstancia (_, _, 1)
								_detalhes:OpenOptionsWindow (instance)
							else
								_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
							end
						
						--> 2 = reset data
						elseif (_detalhes.minimap.onclick_what_todo == 2) then
							_detalhes.tabela_historico:resetar()
						
						--> 3 = show hide windows
						elseif (_detalhes.minimap.onclick_what_todo == 3) then
							local opened = _detalhes:GetOpenedWindowsAmount()
							
							if (opened == 0) then
								_detalhes:ReabrirTodasInstancias()
							else
								_detalhes:ShutDownAllInstances()
							end
						end
						
					elseif (button == "RightButton") then
					
						GameTooltip:Hide()
						local GameCooltip = GameCooltip
						
						GameCooltip:Reset()
						GameCooltip:SetType ("menu")
						GameCooltip:SetOption ("ButtonsYMod", -5)
						GameCooltip:SetOption ("HeighMod", 5)
						GameCooltip:SetOption ("TextSize", 10)

						--344 427 200 268 0.0009765625
						--0.672851, 0.833007, 0.391601, 0.522460
						
						--GameCooltip:SetBannerImage (1, [[Interface\AddOns\Details\images\icons]], 83*.5, 68*.5, {"bottomleft", "topleft", 1, -4}, {0.672851, 0.833007, 0.391601, 0.522460}, nil)
						--GameCooltip:SetBannerImage (2, "Interface\\PetBattles\\Weather-Windy", 512*.35, 128*.3, {"bottomleft", "topleft", -25, -4}, {0, 1, 1, 0})
						--GameCooltip:SetBannerText (1, "Mini Map Menu", {"left", "right", 2, -5}, "white", 10)
						
						--> reset
						GameCooltip:AddMenu (1, _detalhes.tabela_historico.resetar, true, nil, nil, Loc ["STRING_ERASE_DATA"], nil, true)
						GameCooltip:AddIcon ([[Interface\COMMON\VOICECHAT-MUTED]], 1, 1, 14, 14)
						
						GameCooltip:AddLine ("$div")
						
						--> nova instancia
						GameCooltip:AddMenu (1, _detalhes.CriarInstancia, true, nil, nil, Loc ["STRING_MINIMAPMENU_NEWWINDOW"], nil, true)
						--GameCooltip:AddIcon ([[Interface\Buttons\UI-AttributeButton-Encourage-Up]], 1, 1, 10, 10, 4/16, 12/16, 4/16, 12/16)
						GameCooltip:AddIcon ([[Interface\AddOns\Details\images\icons]], 1, 1, 12, 11, 462/512, 473/512, 1/512, 11/512)
						
						--> reopen all windows
						GameCooltip:AddMenu (1, _detalhes.ReabrirTodasInstancias, true, nil, nil, Loc ["STRING_MINIMAPMENU_REOPENALL"], nil, true)
						GameCooltip:AddIcon ([[Interface\Buttons\UI-MicroStream-Green]], 1, 1, 14, 14, 0.1875, 0.8125, 0.84375, 0.15625)
						--> close all windows
						GameCooltip:AddMenu (1, _detalhes.ShutDownAllInstances, true, nil, nil, Loc ["STRING_MINIMAPMENU_CLOSEALL"], nil, true)
						GameCooltip:AddIcon ([[Interface\Buttons\UI-MicroStream-Red]], 1, 1, 14, 14, 0.1875, 0.8125, 0.15625, 0.84375)

						GameCooltip:AddLine ("$div")
						
						--> lock
						GameCooltip:AddMenu (1, _detalhes.TravasInstancias, true, nil, nil, Loc ["STRING_MINIMAPMENU_LOCK"], nil, true)
						GameCooltip:AddIcon ([[Interface\PetBattles\PetBattle-LockIcon]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125)
						
						GameCooltip:AddMenu (1, _detalhes.DestravarInstancias, true, nil, nil, Loc ["STRING_MINIMAPMENU_UNLOCK"], nil, true)
						GameCooltip:AddIcon ([[Interface\PetBattles\PetBattle-LockIcon]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125, "gray")
						
						GameCooltip:AddLine ("$div")
						
						--> disable minimap icon
						local disable_minimap = function()
							_detalhes.minimap.hide = not value
							
							LDBIcon:Refresh ("Details", _detalhes.minimap)
							if (_detalhes.minimap.hide) then
								LDBIcon:Hide ("Details")
							else
								LDBIcon:Show ("Details")
							end
						end
						GameCooltip:AddMenu (1, disable_minimap, true, nil, nil, Loc ["STRING_MINIMAPMENU_HIDEICON"], nil, true)
						GameCooltip:AddIcon ([[Interface\Buttons\UI-Panel-HideButton-Disabled]], 1, 1, 14, 14, 7/32, 24/32, 8/32, 24/32, "gray")
						
						--
						
						GameCooltip:SetBackdrop (1, _detalhes.tooltip_backdrop, nil, _detalhes.tooltip_border_color)
						GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0.64453125, 0}, {.8, .8, .8, 0.2}, true)
						
						GameCooltip:SetOwner (self, "topright", "bottomleft")
						GameCooltip:ShowCooltip()
						

					end
				end,
				OnTooltipShow = function (tooltip)
					tooltip:AddLine ("Details!", 1, 1, 1)
					if (_detalhes.minimap.onclick_what_todo == 1) then
						tooltip:AddLine (Loc ["STRING_MINIMAP_TOOLTIP1"])
					elseif (_detalhes.minimap.onclick_what_todo == 2) then
						tooltip:AddLine (Loc ["STRING_MINIMAP_TOOLTIP11"])
					elseif (_detalhes.minimap.onclick_what_todo == 3) then
						tooltip:AddLine (Loc ["STRING_MINIMAP_TOOLTIP12"])
					end
					tooltip:AddLine (Loc ["STRING_MINIMAP_TOOLTIP2"])
				end,
			})
			
			if (databroker and not LDBIcon:IsRegistered ("Details")) then
				LDBIcon:Register ("Details", databroker, self.minimap)
			end
			
			_detalhes.databroker = databroker
			
		end
	end
	
	function _detalhes:DoRegisterHotCorner()
		--register lib-hotcorners
		local on_click_on_hotcorner_button = function (frame, button) 
			if (_detalhes.hotcorner_topleft.onclick_what_todo == 1) then
				local lower_instance = _detalhes:GetLowerInstanceNumber()
				if (not lower_instance) then
					local instance = _detalhes:GetInstance (1)
					_detalhes.CriarInstancia (_, _, 1)
					_detalhes:OpenOptionsWindow (instance)
				else
					_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
				end
				
			elseif (_detalhes.hotcorner_topleft.onclick_what_todo == 2) then
				_detalhes.tabela_historico:resetar()
			end
		end

		local quickclick_func1 = function (frame, button) 
			_detalhes.tabela_historico:resetar()
		end
		
		local quickclick_func2 = function (frame, button) 
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (not lower_instance) then
				local instance = _detalhes:GetInstance (1)
				_detalhes.CriarInstancia (_, _, 1)
				_detalhes:OpenOptionsWindow (instance)
			else
				_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
			end
		end
		
		local tooltip_hotcorner = function()
			GameTooltip:AddLine ("Details!", 1, 1, 1, 1)
			if (_detalhes.hotcorner_topleft.onclick_what_todo == 1) then
				GameTooltip:AddLine ("|cFF00FF00Left Click:|r open options panel.", 1, 1, 1, 1)
				
			elseif (_detalhes.hotcorner_topleft.onclick_what_todo == 2) then
				GameTooltip:AddLine ("|cFF00FF00Left Click:|r clear all segments.", 1, 1, 1, 1)
				
			end
		end
		
		if (_G.HotCorners) then
			_G.HotCorners:RegisterHotCornerButton (
				--> absolute name
				"Details",
				--> corner
				"TOPLEFT", 
				--> config table
				_detalhes.hotcorner_topleft,
				--> frame _G name
				"DetailsLeftCornerButton", 
				--> icon
				[[Interface\AddOns\Details\images\minimap]], 
				--> tooltip
				tooltip_hotcorner,
				--> click function
				on_click_on_hotcorner_button, 
				--> menus
				nil, 
				--> quick click
				{
					{func = quickclick_func1, name = "Details! - Reset Data"}, 
					{func = quickclick_func2, name = "Details! - Open Options"}
				},
				--> onenter
				nil,
				--> onleave
				nil,
				--> is install
				true
			)
		end
	end
	
	function _detalhes:TestBarsUpdate()
		local current_combat = _detalhes:GetCombat ("current")
		for index, actor in current_combat[1]:ListActors() do
			actor.total = actor.total + (actor.total / 100 * math.random (1, 5))
			actor.total = actor.total - (actor.total / 100 * math.random (1, 5))
		end
		for index, actor in current_combat[2]:ListActors() do
			actor.total = actor.total + (actor.total / 100 * math.random (1, 5))
			actor.total = actor.total - (actor.total / 100 * math.random (1, 5))
		end
		current_combat[1].need_refresh = true
		current_combat[2].need_refresh = true
	end
	
	function _detalhes:StartTestBarUpdate()
		if (_detalhes.test_bar_update) then
			_detalhes:CancelTimer (_detalhes.test_bar_update)
		end
		_detalhes.test_bar_update = _detalhes:ScheduleRepeatingTimer ("TestBarsUpdate", 0.1)
	end
	function _detalhes:StopTestBarUpdate()
		if (_detalhes.test_bar_update) then
			_detalhes:CancelTimer (_detalhes.test_bar_update)
		end
		_detalhes.test_bar_update = nil
	end
	
	function _detalhes:CreateTestBars()
		local current_combat = _detalhes:GetCombat ("current")
		local pclass = select (2, UnitClass ("player"))
		
		local actors_name = {
				{"Ragnaros", "MAGE", 63},
				{"The Lich King", "DEATHKNIGHT", }, 
				{"Your Neighbor", "SHAMAN", }, 
				{"Your Raid Leader", "MONK", }, 
				{"Huffer", "HUNTER", }, 
				{"Your Internet Girlfriend", "SHAMAN", }, 
				{"Mr. President", "WARRIOR", }, 
				{"Antonidas", "MAGE"}, 
				{"Your Math Teacher", "SHAMAN", }, 
				{"King Djoffrey", "PALADIN", }, 
				{UnitName ("player") .. " Snow", pclass, }, 
				{"A Drunk Dawrf", "MONK", },
				{"Low Dps Guy", "MONK", }, 
				{"Helvis Phresley", "DEATHKNIGHT", }, 
				{"Stormwind Guard", "WARRIOR", }, 
				{"A PvP Player", "ROGUE", }, 
				{"Bolvar Fordragon", "PALADIN", },
				{"Malygos", "MAGE", },
				{"Akama", "ROGUE", },
				{"Nozdormu", "MAGE", },
				{"Lady Blaumeux", "DEATHKNIGHT", },
				{"Cairne Bloodhoof", "WARRIOR", },
				{"Borivar", "ROGUE", },
				{"C'Thun", "WARLOCK", },
				{"Drek'Thar", "DEATHKNIGHT", },
				{"Durotan", "WARRIOR", },
				{"Eonar", "DRUID", },
				{"Malfurion Stormrage", "DRUID", },
				{"Footman Malakai", "WARRIOR", },
				{"Bolvar Fordragon", "PALADIN", },
				{"Fritz Fizzlesprocket", "HUNTER", },
				{"Lisa Gallywix", "ROGUE", },
				{"M'uru", "WARLOCK", },
				{"Priestess MacDonnell", "PRIEST", },
				{"Elune", "PRIEST", },
				{"Nazgrel", "WARRIOR", },
				{"Ner'zhul", "WARLOCK", },
				{"Saria Nightwatcher", "PALADIN", },
				{"Kael'thas Sunstrider", "MAGE", 63},
				{"Velen", "PRIEST"},
				{"Tyrande Whisperwind", "PRIEST", 257},
				{"Sargeras", "WARLOCK", 267},
				{"Arthas", "PALADIN", },
				{"Orman of Stromgarde", "WARRIOR", },
				{"General Rajaxx", "WARRIOR", },
				{"Baron Rivendare", "DEATHKNIGHT", },
				{"Roland", "MAGE", },
				{"Archmage Trelane", "MAGE", },
				{"Lilian Voss", "ROGUE", },
			}
		local actors_classes = CLASS_SORT_ORDER
		
		local total_damage = 0
		local total_heal = 0
		
		for i = 1, 10 do
		
			local who = actors_name [math.random (1, #actors_name)]
		
			local robot = current_combat[1]:PegarCombatente (0x0000000000000, who[1], 0x114, true)
			robot.grupo = true
			
			robot.classe = who [2]
			
			if (who[3]) then
				robot.spec = who[3]
			elseif (robot.classe == "DEATHKNIGHT") then
				local specs = {250, 251, 252}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "DRUID") then
				local specs = {102, 103, 104, 105}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "HUNTER") then
				local specs = {253, 254, 255}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "MAGE") then
				local specs = {62, 63, 64}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "MONK") then
				local specs = {268, 269, 270}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "PALADIN") then
				local specs = {65, 66, 70}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "PRIEST") then
				local specs = {256, 257, 258}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "ROGUE") then
				local specs = {259, 260, 261}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "SHAMAN") then
				local specs = {262, 263, 264}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "WARLOCK") then
				local specs = {265, 266, 267}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "WARRIOR") then
				local specs = {71, 72, 73}
				robot.spec = specs [math.random (1, #specs)]
			end
			
			robot.total = math.random (10000000, 60000000)
			robot.damage_taken = math.random (10000000, 60000000)
			robot.friendlyfire_total = math.random (10000000, 60000000)
			
			total_damage = total_damage + robot.total
			
			if (robot.nome == "King Djoffrey") then
				local robot_death = current_combat[4]:PegarCombatente (0x0000000000000, robot.nome, 0x114, true)
				robot_death.grupo = true
				robot_death.classe = robot.classe
				local esta_morte = {{true, 96648, 100000, time(), 0, "Lady Holenna"}, {true, 96648, 100000, time()-52, 100000, "Lady Holenna"}, {true, 96648, 100000, time()-86, 200000, "Lady Holenna"}, {true, 96648, 100000, time()-101, 300000, "Lady Holenna"}, {false, 55296, 400000, time()-54, 400000, "King Djoffrey"}, {true, 14185, 0, time()-59, 400000, "Lady Holenna"}, {false, 87351, 400000, time()-154, 400000, "King Djoffrey"}, {false, 56236, 400000, time()-158, 400000, "King Djoffrey"} } 
				local t = {esta_morte, time(), robot.nome, robot.classe, 400000, "52m 12s",  ["dead"] = true}
				table.insert (current_combat.last_events_tables, #current_combat.last_events_tables+1, t)
				
			elseif (robot.nome == "Mr. President") then	
				rawset (_detalhes.spellcache, 56488, {"Nuke", 56488, [[Interface\ICONS\inv_gizmo_supersappercharge]]})
				robot.spells:PegaHabilidade (56488, true, "SPELL_DAMAGE")
				robot.spells._ActorTable [56488].total = robot.total
			end
			
			local who = actors_name [math.random (1, #actors_name)]
			local robot = current_combat[2]:PegarCombatente (0x0000000000000, who[1], 0x114, true)
			robot.grupo = true
			robot.classe = who[2]
			
			if (who[3]) then
				robot.spec = who[3]
			elseif (robot.classe == "DEATHKNIGHT") then
				local specs = {250, 251, 252}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "DRUID") then
				local specs = {102, 103, 104, 105}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "HUNTER") then
				local specs = {253, 254, 255}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "MAGE") then
				local specs = {62, 63, 64}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "MONK") then
				local specs = {268, 269, 270}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "PALADIN") then
				local specs = {65, 66, 70}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "PRIEST") then
				local specs = {256, 257, 258}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "ROGUE") then
				local specs = {259, 260, 261}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "SHAMAN") then
				local specs = {262, 263, 264}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "WARLOCK") then
				local specs = {265, 266, 267}
				robot.spec = specs [math.random (1, #specs)]
			elseif (robot.classe == "WARRIOR") then
				local specs = {71, 72, 73}
				robot.spec = specs [math.random (1, #specs)]
			end
			
			robot.total = math.random (10000000, 60000000)
			robot.totalover = math.random (10000000, 60000000)
			robot.totalabsorb = math.random (10000000, 60000000)
			robot.healing_taken = math.random (10000000, 60000000)
			
			total_heal = total_heal + robot.total
			
		end
		
		--current_combat.start_time = time()-360
		current_combat.start_time = GetTime() - 360
		--current_combat.end_time = time()
		current_combat.end_time = GetTime()
		
		current_combat.totals_grupo [1] = total_damage
		current_combat.totals_grupo [2] = total_heal
		current_combat.totals [1] = total_damage
		current_combat.totals [2] = total_heal
		
		for _, instance in ipairs (_detalhes.tabela_instancias) do 
			if (instance:IsEnabled()) then
				instance:InstanceReset()
			end
		end
		
		current_combat.enemy = "Illidan Stormrage"
		
	end	
	
	
	-- ~API
	
	function _detalhes.OpenAPI()
		if (not DetailsAPIPanel) then

		local topics_text = {
[[
Attribute Indexes:
DETAILS_ATTRIBUTE_DAMAGE = 1
DETAILS_ATTRIBUTE_HEAL = 2
DETAILS_ATTRIBUTE_ENERGY = 3
DETAILS_ATTRIBUTE_MISC = 4
]],
[[
Combat Object:
actor = combat:GetActor ( attribute, character_name ) or actor = combat ( attribute, character_name )
returns an actor object

characterList = combat:GetActorList ( attribute )
returns a numeric table with all actors of the specific attribute, contains players, npcs, pets, etc.

combatName = combat:GetCombatName ( try_to_find )
returns the segment name, e.g. "Trainning Dummy", if try_to_find is true, it searches the combat for a enemy name.

bossInfo = combat:GetBossInfo()
returns the table containing informations about the boss encounter.
table members: name, zone, mapid, diff, diff_string, id, ej_instance_id, killed, index

battlegroudInfo = combat:GetPvPInfo()
returns the table containing infos about the battlegroud:
table members: name, mapid

arenaInfo = combat:GetArenaInfo()
returns the table containing infos about the arena:
table members: name, mapid, zone

time = combat:GetCombatTime()
returns the length of the combat in seconds, if the combat is in progress, returns the current elapsed time.

minutes, seconds = GetFormatedCombatTime()
returns the combat time formated with minutes and seconds.

startDate, endDate = combat:GetDate()
returns the start and end date as %H:%M:%S.

isTrash = combat:IsTrash()
returns true if the combat is a trash segment.

encounterDiff = combat:GetDifficulty()
returns the difficulty number of the raid encounter.

deaths = combat:GetDeaths()
returns a numeric table containing the deaths, table is ordered by first death to last death.

combatNumber = combat:GetCombatNumber()
returns the unique ID number for the combat.

container = combat:GetContainer ( attribute )
returns the container table for the requested attribute.

roster = combat:GetRoster()
returns a hash table with player names preset in the raid group at the start of the combat.

chartData = combat:GetTimeData ( chart_data_name )
returns the table containing the data for create a chart.

start_at = GetStartTime()
returns the GetTime() of when the combat started.

ended_at = GetEndTime()
returns the GetTime() of when the combat ended.

DETAILS_TOTALS_ONLYGROUP = true

total = combat:GetTotal ( attribute, subAttribute [, onlyGroup] )
returns the total of the requested attribute.				
]],
[[
ipairs() = container:ListActors()
returns a iterated table of actors inside the container.
Usage: 'for index, actor in container:ListActors() do'
Note: if the container is a spell container, returns pairs() instead: 'for spellid, spelltable in container:ListActors() do'

actor = container:GetActor (character_name)
returns the actor, for spell container use the spellid instead.

container:GetSpell (spellid)
unique for spell container.
e.g. actor.spells:GetSpell (spellid)
return the spelltable for the requested spellid.

amount = container:GetAmount (actorName [, key = "total"])
returns the amount of the requested member key, if key is not passed, "total" is used.

container:SortByKey (keyname)
sort the actor container placing in descending order actors with bigger amounts on their 'keyname'.
*only works for actor container

sourceName = container:GetSpellSource (spellid)
return the name of the first actor found inside the container which used a spell with the desired spellid.
note: this is important for multi-language auras/displays where you doesn't want to hardcode the npc name.
*only works for actor container

total = container:GetTotal (key = "total")
returns the total amount of all actors inside the container, if key is omitted, "total" is used.
*only works for actor container

total = container:GetTotalOnRaid (key = "total", combat)
similar to GetTotal, but only counts the total of raid members.
combat is the combat object owner of this container.
*only works for actor container
]],
[[
name = actor:name()
returns the actor's name.

class = actor:class()
returns the actor class.

guid = actor:guid()
returns the GUID for this actor.

flag = actor:flag()
returns the combatlog flag for the actor.

displayName = actor:GetDisplayName()
returns the name shown on the player bar, can suffer modifications from realm name removed, nicknames, etc.

name = actor:GetOnlyName()
returns only the actor name, remove realm or owner names.

activity = actor:Tempo()
returns the activity time for the actor.

isPlayer = actor:IsPlayer()
return true if the actor is a player.

isGroupMember = actor:IsGroupPlayer()
return true if the actor is a player and member of the raid group.

IsneutralOrEnemy = actor:IsNeutralOrEnemy()
return true if the actor is a neutral of an enemy.

isEnemy = actor:IsEnemy()
return true if the actor is a enemy.

isPet = actor:IsPetOrGuardian()
return true if the actor is a pet or guardian

list = actor:GetSpellList()
returns a hash table with spellid, spelltable.

spell = actor:GetSpell (spellid)
returns a spell table of requested spell id.

r, g, b = actor:GetBarColor()
returns the color which the player bar will be painted on the window, it respects owner, arena team, enemy, monster.

r, g, b = Details:GetClassColor()
returns the class color.

texture, left, right, top, bottom = actor:GetClassIcon()
returns the icon texture path and the texture's texcoords.
]],
[[
members:
actor.total = total of damage done.
actor.total_without_pet = without pet.
actor.damage_taken = total of damage taken.
actor.last_event = when the last event for this actor occured.
actor.start_time = time when this actor started to apply damage.
actor.end_time = time when the actor stopped with damage.
actor.friendlyfire_total = amount of friendlyfire.

tables:
actor.targets = hash table of targets: {[targetName] = amount}.
actor.damage_from = hash table of actors which applied damage to this actor: {[aggresorName] = true}.
actor.pets = numeric table of GUIDs of pets summoned by this actor.
actor.friendlyfire = hash table of friendly fire targets: {[targetName] = table {total = 0, spells = hash table: {[spellId] = amount}}}
actor.spells = spell container.

spell:
spell.total = total of damage by this spell.
spell.counter = how many hits this spell made.
spell.id = spellid

spell.successful_casted = how many times this spell has been casted successfully (only for enemies).
- players has its own spell cast counter inside Misc Container with the member "spell_cast".
- the reason os this is spell_cast holds all spells regardless of its attribute (can hold healing/damage/energy/misc).

spell.m_amt = multistrike hits.
spell.m_dmg = multistrike damage.
spell.m_crit = multistrike critical hits.
spell.n_min = minimal damage made on a normal hit.
spell.n_max = max damage made on a normal hit.
spell.n_amt = amount of normal hits.
spell.n_dmg = total amount made doing only normal hits.
spell.c_min = minimal damage made on a critical hit.
spell.c_max = max damage made on a critical hit.
spell.c_amt = how many times this spell got a critical hit (doesn't count critical by multistrike).
spell.c_dmg = total amount made doing only normal hits.
spell.g_amt = how many glancing blows this spell has.
spell.g_dmg = total damage made by glancing blows.
spell.r_amt = total of times this spell got resisted by the target.
spell.r_dmg = amount of damage made when it got resisted.
spell.b_amt = amount of times this spell got blocked by the enemy.
spell.b_dmg = damage made when the spell got blocked.
spell.a_amt = amount of times this spell got absorbed.
spell.a_dmg = total damage while absorbed.

spell.targets = hash table containing {["targetname"] = total damage done by this spell on this target}

Getting Dps:
For activity time: DPS = actor.total / actor:Tempo() 
For effective time: DPS = actor.total / combat:GetCombatTime()
]],
[[
members:
actor.total = total of healing done.
actor.totalover = total of overheal.
actor.totalabsorb = total of absorbs.
actor.total_without_pet = total without count the healing done from pets.
actor.totalover_without_pet = overheal without pets.
actor.heal_enemy_amt = how much this actor healing an enemy actor.
actor.healing_taken = total of received healing.
actor.last_event = when the last event for this actor occured.
actor.start_time = time when this actor started to apply heals.
actor.end_time = time when the actor stopped with healing.

tables:
actor.spells = spell container.
actor.targets = hash table of targets: {[targetName] = amount}.
actor.targets_overheal = hash table of overhealed targets: {[targetName] = amount}.
actor.targets_absorbs = hash table of shield absorbs: {[targetName] = amount}.
actor.healing_from = hash table of actors which applied healing to this actor: {[healerName] = true}.
actor.pets = numeric table of GUIDs of pets summoned by this actor.
actor.heal_enemy = spells used to heal the enemy: {[spellid] = amount healed}

spell:
spell.total = total healing made by this spell.
spell.counter = how many times this spell healed something.
spell.id = spellid.

spell.totalabsorb = only for shields, tells how much damage this spell prevented.
spell.absorbed = is how many healing has been absorbed by some external mechanic like Befouled on Fel Lord Zakuun encounter.
spell.overheal = amount of overheal made by this spell.
spell.m_amt = multistrike hits.
spell.m_healed = multistrike healed.
spell.m_crit = multistrike critical hits.
spell.n_min = minimal heal made on a normal hit.
spell.n_max = max heal made on a normal hit.
spell.n_amt = amount of normal hits.
spell.n_curado = total amount made doing only normal hits (weird name I know).
spell.c_min = minimal heal made on a critical hit.
spell.c_max = max heal made on a critical hit.
spell.c_amt = how many times this spell got a critical hit (doesn't count critical by multistrike).
spell.c_curado = total amount made doing only normal hits.

spell.targets = hash table containing {["targetname"] = total healing done by this spell on this target}
spell.targets_overheal = hash table containing {["targetname"] = total overhealing by this spell on this target}
spell.targets_absorbs = hash table containing {["targetname"] = total absorbs by shields (damage prevented) done by this spell on this target}

Getting Hps:
For activity time: HPS = actor.total / actor:Tempo() 
For effective time: HPS = actor.total / combat:GetCombatTime()
]],
[[
actor.total = total of energy generated.
actor.received = total of energy received.
actor.resource = total of resource generated.
actor.resource_type = type of the resource used by the actor.

actor.pets = numeric table of GUIDs of pets summoned by this actor.
actor.targets = hash table of targets: {[targetName] = amount}.
actor.spells = spell container.

spell:
total = total energy restored by this spell.
counter = how many times this spell restored energy.
id = spellid

targets = hash table containing {["targetname"] = total energy produced towards this target}
]],
[[
these members and tables may not be present on all actors, depends what the actor performs during the combat, these tables are created on the fly by the parser.

- Crowd Control Done:
actor.cc_done = amount of crowd control done.
actor.cc_done_targets = hash table with target names and amount {[targetName] = amount}.
actor.cc_done_spells = spell container.

spell:
spell.counter = amount of times this spell has been used to perform a crowd control.
spell.targets = hash table containing {["targetname"] = total of times this spell made a CC on this target}


- Interrupts:
actor.interrupt = total amount of interrupts.
actor.interrupt_targets = hash table with target names and amount {[targetName] = amount}.
actor.interrupt_spells = spell container.
actor.interrompeu_oque = hash table which tells what this actor interrupted {[spell interrupted spellid] = amount}

spell:
spell.counter = amount of interrupts performed by this spell.
spell.interrompeu_oque = hash table talling what this spell interrupted {[spell interrupted spellid] = amount}
spell.targets = hash table containing {["castername"] = total of times this spell interrupted something from this caster}


- Aura Uptime:
actor.buff_uptime = seconds of all buffs uptime.
actor.buff_uptime_spells = spell container.
actor.debuff_uptime = seconds of all debuffs uptime.
actor.debuff_uptime_spells = spell container.

spell:
spell.id = spellid
spell.uptime = uptime amount in seconds.


- Cooldowns:
actor.cooldowns_defensive = amount of defensive cooldowns used by this actor.
actor.cooldowns_defensive_targets = in which player the cooldown was been used {[targetName] = amount}.
actor.cooldowns_defensive_spells = spell container.

spell:
spell.id = spellid
spell.counter = how many times the player used this cooldown.
spell.targets = hash table with {["targetname"] = amount}


- Ress
actor.ress = amount of ress performed by this actor.
actor.ress_targets = which actors got ressed by this actor {["targetname"] = amount}
actor.ress_spells = spell container.

spell:
spell.ress = amount of resses made by this spell.
spell.targets = hash table containing player names resurrected by this spell {["playername"] = amount}


- Dispel (members has 2 "L" instead of 1)
actor.dispell = amount of dispels done.
actor.dispell_targets = hash table telling who got dispel from this actor {[targetName] = amount}.
actor.dispell_spells = spell container.
actor.dispell_oque = hash table with the ids of the spells dispelled by this actor {[spellid of the spell dispelled] = amount}

spell:
spell.dispell = amount of dispels by this spell.
spell.dispell_oque = hash table with {[spellid of the spell dispelled]} = amount
spell.targets = hash table with target names dispelled {["targetname"] = amount}


- CC Break
actor.cc_break = amount of times the actor broke a crowd control.
actor.cc_break_targets = hash table containing who this actor broke the CC {[targetName] = amount}.
actor.cc_break_spells = spell container.
actor.cc_break_oque = hash table with spells broken {[CC spell id] = amount}

spell:
spell.cc_break = amount of CC broken by this spell.
spell.cc_break_oque = hash table with {[CC spellid] = amount}
spell.targets = hash table with {["targetname"] = amount}.
]],
[[
Details:GetSourceFromNpcId (npcId)
return the npc name for the specific npcId.
this is a expensive function, once you get a valid result, store the npc name somewhere.

bestResult, encounterTable = Details.storage:GetBestFromPlayer (encounterDiff, encounterId, playerRole, playerName)
query the storage for the best result of the player on the encounter.
encounterDiff = raid difficult ID (15 for heroic, 16 for mythic).
encounterId = may be found on "id" member getting combat:GetBossInfo().
playerRole = "DAMAGER" or "HEALER", tanks are considered "DAMAGER".
playerName = name of the player to query (with server name if the player is from another realm).
bestResult = integer, best damage or healing done on the boss made by the player.
encounterTable = {["date"] = formated time() ["time"] = time() ["elapsed"] = combat time ["guild"] = guild name ["damage"] = all damage players ["healing"] = all healers}

heal_or_damage_done = Details.storage:GetPlayerData (encounterDiff, encounterId, playerName)
query the storage for previous ecounter data for the player.
returns a numeric table with the damage or healing done by the player on all encounters found.
encounterDiff = raid difficult ID (15 for heroic, 16 for mythic).
encounterId = may be found on "id" member getting combat:GetBossInfo().
playerName = name of the player to query (with server name if the player is from another realm).

itemLevel = Details.ilevel:GetIlvl (guid)
returns a table with {name = "actor name", ilvl = itemLevel, time = time() when the item level was gotten}.
return NIL if no data for the player is avaliable yet.

talentsTable = Details:GetTalents (guid)
if available, returns a table with 7 indexes with the talentId selected for each tree {talentId, talentId, talentId, talentId, talentId, talentId, talentId}.
use with GetTalentInfoByID()

spec = Details:GetSpec (guid)
if available, return the spec id of the actor, use with GetSpecializationInfoByID()

Details:SetDeathLogLimit (limit)
Set the amount of lines to store on death log.

npcId = Details:GetNpcIdFromGuid (guid)
Extract the npcId from the actor guid.
]], --custom displays
[[
Cstom Display is a special display where users can set their own rules on searching for what show in the window.
There is 4 scripts which compose the display:

Required:
Search - this is the main script, it's responsible to build a list of actors to show in the window.

Optional:
Tooltip - it runs when the user hover over a bar.
Total - runs when showing the bar, and helps format the total done.
Percent - also runs when showing the bar, it formats the percentage amount.


Search Code:
- The script receives 3 parameters: *Combat, *CustomContainer and *Instance.
*Combat - is the reference for the selected combat shown in the window (the one selected on segments menu).
*CustomContainer - is the place where the display mantain stored the results, Details! get the content inside the container and use to update the window.
*Instance - is the reference of the window where the custom display is shown.

- Also, the script must return three values: total made by all players, the amount of the top player and the amount of players found by the script.
- The search script basically begins getting these three parameters and declaring our three return values:

local Combat, CustomContainer, Instance = ...
local total, top, amount = 0, 0, 0

- Then, we build our search for wherever we want to show, here we are building an example for Damage Done by Pets and Guardians.
- So, as we are working with damage, we want to get a list of Actors from the Damage Container of the combat and iterate it with ipairs:

local damage_container = combat:GetActorList( DETAILS_ATTRIBUTE_DAMAGE )
for i, actor in ipairs( damage_container ) do
	--do stuff
end

- Actor, can be anything, a monster, player, boss, etc, so, we need to check if actor is a pet:

if (actor:IsPetOrGuardian()) then
	--do stuff
end

- Now we found a pet, we need to get the damage done and find who is the owner of this pet, after that, we also need to check if the owner is a player:

local petOwner = actor.owner
if (petOwner:IsPlayer()) then
	local petDamage = actor.total
end

- The next step is add the pet owner into the CustomContainer:

CustomContainer:AddValue (petOwner, petDamage)

- And in the and, we need to get the total, top and amount values. This is generally calculated inside our loop above, but just calling the API for the result is more handy:

total, top = CustomContainer:GetTotalAndHighestValue()
amount = CustomContainer:GetNumActors()
return total, top, amount


The finished script looks like this:

local Combat, CustomContainer, Instance = ...
local total, top, amount = 0, 0, 0

local damage_container = Combat:GetActorList( DETAILS_ATTRIBUTE_DAMAGE )
for i, actor in ipairs( damage_container ) do
	if (actor:IsPetOrGuardian()) then
		local petOwner = actor.owner
		if (petOwner:IsPlayer()) then
			local petDamage = actor.total
			CustomContainer:AddValue( petOwner, petDamage )
		end
	end
end

total, top = CustomContainer:GetTotalAndHighestValue()
amount = CustomContainer:GetNumActors()

return total, top, amount


Tooltip Code:
- The script receives 3 parameters: *Actor, *Combat and *Instance. This script has no return value.
*Actor - in our case, actor is the petOwner.

local Actor, Combat, Instance = ...
local Format = Details:GetCurrentToKFunction()

- What we want where is show all pets the player used in the combat and how much damage each one made.
- The member .pets gives us a table with pet names that belongs to the actor.

local actorPets = Actor.pets

- Next move is iterate this table and get the pet actor from the combat.
- In Details! always use ">= 1" not "> 0", also when not using our format functions, use at least floor()

for i, petName in ipairs( actorPets ) do
	local petActor = Combat( DETAILS_ATTRIBUTE_DAMAGE, petName)
	if (petActor and petActor.total >= 1) then
		--do stuff
	end
end

- With the pet in hands, what we have to do now is add this pet to our tooltip.
- Details! uses 'GameCooltip' which is slight different than 'GameTooltip':

GameCooltip:AddLine( petName, Format( nil, petActor.total ) )
Details:AddTooltipBackgroundStatusbar()


The finished script looks like this:

local Actor, Combat, Instance = ...
local Format = Details:GetCurrentToKFunction()

local actorPets = Actor.pets

for i, petName in ipairs( actorPets ) do
	local petActor = Combat( DETAILS_ATTRIBUTE_DAMAGE, petName)
	if (petActor and petActor.total >= 1) then
		GameCooltip:AddLine( petName, Format( nil, petActor.total ) )
		Details:AddTooltipBackgroundStatusbar()
	end
end



Total Code and Percent Code:
- Details! build the total and the percent automatically, these scripts are for special cases where you want to show something different, e.g. convert total into seconds/minutes.
- Both scripts receives 5 parameters, three are new to us:
*Value - the total made by this actor.
*Top - the value made by the rank 1 actor.
*Total - the total made by all actors.

local value, top, total, combat, instance = ...
local result = floor (value)
return total
]], --custom container
[[
Custom Container Object:
A custom container is primarily used when building custom displays.
Is used to hold values for any kind of actor in Details! and also any other table as long as it has a ".name" or ".id" key.

value = is a number indicating the actor's score, the container doesn't know what kind of actor it is holding, if is a damage actor, energy, a spell, so, it is just nominated 'value'.

container:GetValue ( actor )
returns the current value for the requested actor.

container:AddValue ( actor, amountToAdd, checkTop, nameComplement )
actor is any actor object or any other table containing a member "name" or "id", e.g. {name = "Jeff"} {id = 186451}
amountToAdd is the amount to add to this actor on the container.
checkTop is for some special cases when the top value needs to be calculated immediately.
nameComplement is a string to add on the end of the actor's name, for instance, in cases where the actor is a spell and its name is generated by the container.
returns the current value for the actor.

container:SetValue (actor, amount, nameComplement)
actor is any actor object or any other table containing a member "name" or "id", e.g. {name = "Jeff"} {id = 186451}
amount is the amount to set to this actor on the container.
nameComplement is a string to add on the end of the actor's name, for instance, in cases where the actor is a spell and its name is generated by the container.

container:HasActor (actor)
return true if the container holds a reference for 'actor'.

container:GetNumActors()
returns the amount of actors present inside the container.

container:GetTotalAndHighestValue()
return 'total' and 'top' values.
total is the total of value of all actors together.
top is the amount of value of the actor with more value.

container:WipeCustomActorContainer()
removes all data from a custom container.
this is automatically performed when the search script runs.
]]
}
			local f = gump:CreateSimplePanel (UIParent, 700, 480, "Details! API", "DetailsAPIPanel")

			local text_box = gump:NewSpecialLuaEditorEntry (f, 520, 430, "text", "$parentTextEntry", true)
			text_box:SetPoint ("topleft", f, "topleft", 170, -40)
			local file, size, flags = text_box.editbox:GetFont()
			text_box.editbox:SetFont (file, 12, flags)
			
			local topics = {
				"Attributes List",
				"Object: Combat",
				"Object: Container",
				"Object: Actor",
				"Keys for Damage Actor",
				"Keys for Healing Actor",
				"Keys for Energy Actor",
				"Keys for Misc Actor",
				"General Functions",
				"Custom Displays",
				"Object: Custom Container",
			}
			
			local select_topic = function (self, button, topic)
				text_box:SetText (topics_text [topic])
			end
			
			for i = 1, #topics do
				local title = topics [i]
				local button = gump:CreateButton (f, select_topic, 80, 16, title, i)
				button:SetPoint ("topleft", f, "topleft", 5, (-i*20)-40)
				button:SetIcon ([[Interface\Buttons\UI-GuildButton-PublicNote-Up]], nil, nil, nil, nil, nil, nil, 2)
			end

		end
		
		DetailsAPIPanel:Show()
	end
	
	--old versions dialog
	--[[
	--print ("Last Version:", _detalhes_database.last_version, "Last Interval Version:", _detalhes_database.last_realversion)

	local resetwarning_frame = CreateFrame ("FRAME", "DetailsResetConfigWarningDialog", UIParent, "ButtonFrameTemplate")
	resetwarning_frame:SetFrameStrata ("LOW")
	tinsert (UISpecialFrames, "DetailsResetConfigWarningDialog")
	resetwarning_frame:SetPoint ("center", UIParent, "center")
	resetwarning_frame:SetSize (512, 200)
	resetwarning_frame.portrait:SetTexture ("Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-GNOME")
	resetwarning_frame:SetScript ("OnHide", function()
		DetailsBubble:HideBubble()
	end)
	
	resetwarning_frame.TitleText:SetText ("Noooooooooooo!!!")

	resetwarning_frame.midtext = resetwarning_frame:CreateFontString (nil, "artwork", "GameFontNormal")
	resetwarning_frame.midtext:SetText ("A pack of murlocs has attacked Details! tech center, our gnomes engineers are working on fixing the damage.\n\n If something is messed in your Details!, especially the close, instance and reset buttons, you can either 'Reset Skin' or access the options panel.")
	resetwarning_frame.midtext:SetPoint ("topleft", resetwarning_frame, "topleft", 10, -90)
	resetwarning_frame.midtext:SetJustifyH ("center")
	resetwarning_frame.midtext:SetWidth (370)
	
	resetwarning_frame.gnoma = resetwarning_frame:CreateTexture (nil, "artwork")
	resetwarning_frame.gnoma:SetPoint ("topright", resetwarning_frame, "topright", -3, -80)
	resetwarning_frame.gnoma:SetTexture ("Interface\\AddOns\\Details\\images\\icons2")
	resetwarning_frame.gnoma:SetSize (89*1.00, 97*1.00)
	--resetwarning_frame.gnoma:SetTexCoord (0.212890625, 0.494140625, 0.798828125, 0.99609375) -- 109 409 253 510
	resetwarning_frame.gnoma:SetTexCoord (0.17578125, 0.001953125, 0.59765625, 0.787109375) -- 1 306 90 403
	
	resetwarning_frame.close = CreateFrame ("Button", "DetailsFeedbackWindowCloseButton", resetwarning_frame, "OptionsButtonTemplate")
	resetwarning_frame.close:SetPoint ("bottomleft", resetwarning_frame, "bottomleft", 8, 4)
	resetwarning_frame.close:SetText ("Close")
	resetwarning_frame.close:SetScript ("OnClick", function (self)
		resetwarning_frame:Hide()
	end)

	resetwarning_frame.see_updates = CreateFrame ("Button", "DetailsResetWindowSeeUpdatesButton", resetwarning_frame, "OptionsButtonTemplate")
	resetwarning_frame.see_updates:SetPoint ("bottomright", resetwarning_frame, "bottomright", -10, 4)
	resetwarning_frame.see_updates:SetText ("Update Info")
	resetwarning_frame.see_updates:SetScript ("OnClick", function (self)
		_detalhes.OpenNewsWindow()
		DetailsBubble:HideBubble()
		--resetwarning_frame:Hide()
	end)
	resetwarning_frame.see_updates:SetWidth (130)
	
	resetwarning_frame.reset_skin = CreateFrame ("Button", "DetailsResetWindowResetSkinButton", resetwarning_frame, "OptionsButtonTemplate")
	resetwarning_frame.reset_skin:SetPoint ("right", resetwarning_frame.see_updates, "left", -5, 0)
	resetwarning_frame.reset_skin:SetText ("Reset Skin")
	resetwarning_frame.reset_skin:SetScript ("OnClick", function (self)
		--do the reset
		for index, instance in ipairs (_detalhes.tabela_instancias) do 
			if (not instance.iniciada) then
				instance:RestauraJanela()
				local skin = instance.skin
				instance:ChangeSkin ("WoW Interface")
				instance:ChangeSkin ("Minimalistic")
				instance:ChangeSkin (skin)
				instance:DesativarInstancia()
			else
				local skin = instance.skin
				instance:ChangeSkin ("WoW Interface")
				instance:ChangeSkin ("Minimalistic")
				instance:ChangeSkin (skin)
			end
		end
	end)
	resetwarning_frame.reset_skin:SetWidth (130)
	
	resetwarning_frame.open_options = CreateFrame ("Button", "DetailsResetWindowOpenOptionsButton", resetwarning_frame, "OptionsButtonTemplate")
	resetwarning_frame.open_options:SetPoint ("right", resetwarning_frame.reset_skin, "left", -5, 0)
	resetwarning_frame.open_options:SetText ("Options Panel")
	resetwarning_frame.open_options:SetScript ("OnClick", function (self)
		local lower_instance = _detalhes:GetLowerInstanceNumber()
		if (not lower_instance) then
			local instance = _detalhes:GetInstance (1)
			_detalhes.CriarInstancia (_, _, 1)
			_detalhes:OpenOptionsWindow (instance)
		else
			_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
		end
	end)
	resetwarning_frame.open_options:SetWidth (130)

	function _detalhes:ResetWarningDialog()
		DetailsResetConfigWarningDialog:Show()
		DetailsBubble:SetOwner (resetwarning_frame.gnoma, "bottomright", "topleft", 30, -37, 1)
		DetailsBubble:FlipHorizontal()
		DetailsBubble:SetBubbleText ("", "", "WWHYYYYYYYYY!!!!", "", "")
		DetailsBubble:TextConfig (14, nil, "deeppink")
		DetailsBubble:ShowBubble()


	end
	_detalhes:ScheduleTimer ("ResetWarningDialog", 7)
--]]

--[[
	local background_up = f:CreateTexture (nil, "background")
	background_up:SetPoint ("topleft", f, "topleft")
	background_up:SetSize (250, 150)
	background_up:SetTexture ("Interface\\QuestionFrame\\Question-Main")
	background_up:SetTexCoord (0, 420/512, 320/512, 475/512)
	
	local background_down = f:CreateTexture (nil, "background")
	background_down:SetPoint ("topleft", background_up, "bottomleft")
	background_down:SetSize (250, 150)
	background_down:SetTexture ("Interface\\QuestionFrame\\Question-Main")
	background_down:SetTexCoord (0, 420/512, 156/512, 308/512)
	
	background_up:SetDesaturated (true)
	background_down:SetDesaturated (true)
--]]