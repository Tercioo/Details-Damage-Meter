
--note: this file need a major clean up especially on function creation.

local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
local _
local gump = 			_detalhes.gump

local atributos = _detalhes.atributos
local sub_atributos = _detalhes.sub_atributos
local segmentos = _detalhes.segmentos

--lua locals
local _cstr = tostring
local _math_ceil = math.ceil
local _math_floor = math.floor
local _ipairs = ipairs
local _pairs = pairs
local _string_lower = string.lower
local _unpack = unpack
--api locals
local _CreateFrame = CreateFrame
local _GetTime = GetTime
local _GetCursorPosition = GetCursorPosition
local _GameTooltip = GameTooltip
local _UIParent = UIParent
local _GetScreenWidth = GetScreenWidth
local _GetScreenHeight = GetScreenHeight
local _IsAltKeyDown = IsAltKeyDown
local _IsShiftKeyDown = IsShiftKeyDown
local _IsControlKeyDown = IsControlKeyDown
local modo_raid = _detalhes._detalhes_props["MODO_RAID"]
local modo_alone = _detalhes._detalhes_props["MODO_ALONE"]
local modo_grupo = _detalhes._detalhes_props["MODO_GROUP"]
local modo_all = _detalhes._detalhes_props["MODO_ALL"]

local gump_fundo_backdrop = {
	bgFile = "Interface\\AddOns\\Details\\images\\background", tile = true, tileSize = 16,
	insets = {left = 0, right = 0, top = 0, bottom = 0}}

function  _detalhes:ScheduleUpdate (instancia)
	instancia.barraS = {nil, nil}
	instancia.update = true
	if (instancia.showing) then
		instancia.atributo = instancia.atributo or 1
		
		if (not instancia.showing [instancia.atributo]) then --> unknow very rare bug where showing transforms into a clean table
			instancia.showing = _detalhes.tabela_vigente
		end
		
		instancia.showing [instancia.atributo].need_refresh = true
	end
end

--> skins TCoords

--	0.00048828125
	
	local DEFAULT_SKIN = [[Interface\AddOns\Details\images\skins\default_skin]]
	
	local COORDS_LEFT_BALL = {0.15673828125, 0.28076171875, 0.08251953125, 0.20654296875} -- x1 160 y1 84 x2 288 y2 212
	local COORDS_LEFT_CONNECTOR = {0.29541015625, 0.30224609375, 0.08251953125, 0.20654296875} --302 84 310 212
	local COORDS_TOP_BACKGROUND = {0.15673828125, 0.65576171875, 0.22314453125, 0.34716796875} -- 160 228 672 356
	local COORDS_RIGHT_BALL = {0.31591796875, 0.43994140625, 0.08251953125, 0.20654296875} --324 84 452 212

	local COORDS_LEFT_SIDE_BAR = {0.76611328125, 0.82861328125, 0.00244140625, 0.50244140625} -- 784 2 849 515
	local COORDS_RIGHT_SIDE_BAR = {0.70068359375, 0.76318359375, 0.00244140625, 0.50244140625} -- 717 2 782 515
	
	local COORDS_SLIDER_TOP = {0.00146484375, 0.03173828125, 0.00244140625, 0.03271484375} -- 1 2 33 34
	local COORDS_SLIDER_MIDDLE = {0.00146484375, 0.03173828125, 0.03955078125, 0.10107421875} -- 1 40 33 104
	local COORDS_SLIDER_DOWN = {0.00146484375, 0.03173828125, 0.10986328125, 0.14013671875} -- 1 112 33 144

	local COORDS_STRETCH = {0.00146484375, 0.03173828125, 0.21435546875, 0.22900390625} -- 1 219 33 235
	local COORDS_RESIZE_RIGHT = {0.00146484375, 0.01611328125, 0.24560546875, 0.26025390625} -- 1 251 17 267
	local COORDS_RESIZE_LEFT = {0.02001953125, 0.03271484375, 0.24560546875, 0.26025390625} -- 20 251 34 267
	
	local COORDS_UNLOCK_BUTTON = {0.00146484375, 0.01611328125, 0.27197265625, 0.28662109375} -- 1 278 17 294
	
	local COORDS_BOTTOM_BACKGROUND = {0.15673828125, 0.65576171875, 0.35400390625, 0.47802734375} -- 160 362 672 490
	local COORDS_PIN_LEFT = {0.00146484375, 0.03173828125, 0.30126953125, 0.33154296875} -- 1 308 33 340
	local COORDS_PIN_RIGHT = {0.03564453125, 0.06591796875, 0.30126953125, 0.33154296875} -- 36 308 68 340
	
	-- icones: 365 = 0.35693359375 // 397 = 0.38720703125
	
function _detalhes:AtualizarScrollBar (x)

	local cabe = self.barrasInfo.cabem --> quantas barras cabem na janela

	if (not self.barraS[1]) then --primeira vez que as barras estão aparecendo
		self.barraS[1] = 1 --primeira barra
		if (cabe < x) then --se a quantidade a ser mostrada for maior que o que pode ser mostrado
			self.barraS[2] = cabe -- B = o que pode ser mostrado
		else
			self.barraS[2] = x -- contrário B = o que esta sendo mostrado
		end
	end
	
	if (not self.rolagem) then
		if (x > cabe) then --> Ligar a ScrollBar
			self.barrasInfo.mostrando = x
			
			if (not self.baseframe.isStretching) then
				self:MostrarScrollBar()
			end
			self.need_rolagem = true
			
			self.barraS[2] = cabe --> B é o total que cabe na barra
		else --> Do contrário B é o total de barras
			self.barrasInfo.mostrando = x
			self.barraS[2] = x
		end
	else
		if (x > self.barrasInfo.mostrando) then --> tem mais barras mostrando agora do que na última atualização
			self.barrasInfo.mostrando = x
			local nao_mostradas = self.barrasInfo.mostrando - self.barrasInfo.cabem
			local slider_height = nao_mostradas*self.barrasInfo.alturaReal
			self.scroll.scrollMax = slider_height
			self.scroll:SetMinMaxValues (0, slider_height)
			
		else	--> diminuiu a quantidade, acontece depois de uma coleta de lixo
			self.barrasInfo.mostrando = x
			local nao_mostradas = self.barrasInfo.mostrando - self.barrasInfo.cabem
			
			if (nao_mostradas < 1) then  --> se estiver mostrando menos do que realmente cabe não precisa scrollbar
				self:EsconderScrollBar()
			else
				--> contrário, basta atualizar o tamanho da scroll
				local slider_height = nao_mostradas*self.barrasInfo.alturaReal
				self.scroll.scrollMax = slider_height
				self.scroll:SetMinMaxValues (0, slider_height)
			end
			
		end
	end
	
	if (self.update) then 
		self.update = false
		self.v_barras = true
		return _detalhes:EsconderBarrasNaoUsadas (self)
	end
end

--> self é a janela das barras
local function move_barras (self, elapsed)
	self._move_func.time = self._move_func.time+elapsed
	if (self._move_func.time > 0.01) then
		if (self._move_func.instancia.bgdisplay_loc == self._move_func._end) then --> se o tamanho atual é igual ao final declarado
			self:SetScript ("OnUpdate", nil)
			self._move_func = nil
		else
			self._move_func.time = 0
			self._move_func.instancia.bgdisplay_loc = self._move_func.instancia.bgdisplay_loc + self._move_func.inc --> inc é -1 ou 1 e irá crescer ou diminuir a janela
			
			for index = 1, self._move_func.instancia.barrasInfo.cabem do
				self._move_func.instancia.barras [index]:SetWidth (self:GetWidth()+self._move_func.instancia.bgdisplay_loc-3)
			end
			self._move_func.instancia.bgdisplay:SetPoint ("BOTTOMRIGHT", self, "BOTTOMRIGHT", self._move_func.instancia.bgdisplay_loc, 0)
			
			self._move_func.instancia.bar_mod = self._move_func.instancia.bgdisplay_loc+(-3)
			
			--> verifica o tamanho do text
			for i  = 1, #self._move_func.instancia.barras do
				local esta_barra = self._move_func.instancia.barras [i]
				_detalhes:name_space (esta_barra)
			end
		end
	end
end

--> self é a instância
function _detalhes:MoveBarrasTo (destino)
	local janela = self.baseframe

	janela._move_func = {
		window = self.baseframe,
		instancia = self,
		time = 0
	}
	
	if (destino > self.bgdisplay_loc) then
		janela._move_func.inc = 1
	else
		janela._move_func.inc = -1
	end
	janela._move_func._end = destino
	janela:SetScript ("OnUpdate", move_barras)
end

function _detalhes:MostrarScrollBar (sem_animacao)

	if (self.rolagem) then
		return
	end
	
	if (not _detalhes.use_scroll) then
		self.baseframe:EnableMouseWheel (true)
		self.scroll:Enable()
		self.scroll:SetValue (0)
		self.rolagem = true
		return
	end

	local main = self.baseframe
	local mover_para = self.largura_scroll*-1
	
	if (not sem_animacao and _detalhes.animate_scroll) then
		self:MoveBarrasTo (mover_para)
	else
		--> set size of rows
		for index = 1, self.barrasInfo.cabem do
			self.barras [index]:SetWidth (self.baseframe:GetWidth()+mover_para -3) --> -3 distance between row end and scroll start
		end
		--> move the semi-background to the left (which moves the scroll)
		self.bgdisplay:SetPoint ("BOTTOMRIGHT", self.baseframe, "BOTTOMRIGHT", mover_para, 0)
		
		self.bar_mod = mover_para + (-3)
		self.bgdisplay_loc = mover_para
		
		--> cancel movement if any
		if (self.baseframe:GetScript ("OnUpdate") and self.baseframe:GetScript ("OnUpdate") == move_barras) then
			self.baseframe:SetScript ("OnUpdate", nil)
		end
	end
	
	local nao_mostradas = self.barrasInfo.mostrando - self.barrasInfo.cabem
	local slider_height = nao_mostradas*self.barrasInfo.alturaReal
	self.scroll.scrollMax = slider_height
	self.scroll:SetMinMaxValues (0, slider_height)
	
	self.rolagem = true
	self.scroll:Enable()
	main:EnableMouseWheel (true)

	self.scroll:SetValue (0) --> set value pode chamar o atualizador
	self.baseframe.button_down:Enable()
	main.resize_direita:SetPoint ("BOTTOMRIGHT", main, "BOTTOMRIGHT", self.largura_scroll*-1, 0)
	
	if (main.isLocked) then
		main.lock_button:SetPoint ("BOTTOMRIGHT", main, "BOTTOMRIGHT", self.largura_scroll*-1, 0)
	end

end

function _detalhes:EsconderScrollBar (sem_animacao, force)

	if (not self.rolagem) then
		return
	end
	
	if (not _detalhes.use_scroll and not force) then
		self.scroll:Disable()
		self.baseframe:EnableMouseWheel (false)
		self.rolagem = false
		return
	end
	
	local main = self.baseframe

	if (not sem_animacao and _detalhes.animate_scroll) then
		self:MoveBarrasTo (self.barrasInfo.espaco.direita + 3) --> 
	else
		for index = 1, self.barrasInfo.cabem do
			self.barras [index]:SetWidth (self.baseframe:GetWidth() - 5) --> -5 space between row end and window right border
		end
		self.bgdisplay:SetPoint ("BOTTOMRIGHT", self.baseframe, "BOTTOMRIGHT", 0, 0) -- voltar o background na pocição inicial
		self.bar_mod = 0 -- zera o bar mod, uma vez que as barras vão estar na pocisão inicial
		self.bgdisplay_loc = -2
		if (self.baseframe:GetScript ("OnUpdate") and self.baseframe:GetScript ("OnUpdate") == move_barras) then
			self.baseframe:SetScript ("OnUpdate", nil)
		end
	end

	self.rolagem = false
	self.scroll:Disable()
	main:EnableMouseWheel (false)
	
	main.resize_direita:SetPoint ("BOTTOMRIGHT", main, "BOTTOMRIGHT", 0, 0)
	if (main.isLocked) then
		main.lock_button:SetPoint ("BOTTOMRIGHT", main, "BOTTOMRIGHT", 0, 0)
	end
end

local function OnLeaveMainWindow (instancia, self)

	if (instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"] and not instancia.baseframe.isLocked) then

		--> resizes and lock button
		gump:Fade (instancia.baseframe.resize_direita, 1)
		gump:Fade (instancia.baseframe.resize_esquerda, 1)
		gump:Fade (instancia.baseframe.lock_button, 1)
		
		--> stretch button
		--gump:Fade (instancia.baseframe.button_stretch, -1)
		gump:Fade (instancia.baseframe.button_stretch, "ALPHA", 0)
		
		--> snaps
		gump:Fade (instancia.botao_separar, 1)
	
	elseif (instancia.baseframe.isLocked) then
		gump:Fade (instancia.baseframe.lock_button, 1)
		gump:Fade (instancia.baseframe.button_stretch, 1)
		
	end
end
_detalhes.OnLeaveMainWindow = OnLeaveMainWindow

local function OnEnterMainWindow (instancia, self)

	if (instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"] and not instancia.baseframe.isLocked) then

		--> resizes and lock button
		gump:Fade (instancia.baseframe.resize_direita, 0)
		gump:Fade (instancia.baseframe.resize_esquerda, 0)
		gump:Fade (instancia.baseframe.lock_button, 0)
		
		--> stretch button
		gump:Fade (instancia.baseframe.button_stretch, 0)
	
		--> snaps
		if (modo == 0) then
			for _, instancia_id in _pairs (instancia.snap) do
				if (instancia_id) then
					instancia.botao_separar.texture:Show()
					instancia.botao_separar.texture:SetTexCoord (unpack (COORDS_UNLOCK_BUTTON))
					gump:Fade (instancia.botao_separar.texture, 0)
					gump:Fade (instancia.botao_separar, 0)
					break
				end
			end
		end
		
	elseif (instancia.baseframe.isLocked) then
		gump:Fade (instancia.baseframe.lock_button, 0)
		gump:Fade (instancia.baseframe.button_stretch, 0)
	
	end
end
_detalhes.OnEnterMainWindow = OnEnterMainWindow

local function resize_fade (instancia, modo)
	if (instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"] and not instancia.baseframe.isLocked) then
		gump:Fade (instancia.baseframe.resize_direita, modo)
		gump:Fade (instancia.baseframe.resize_esquerda, modo)
		gump:Fade (instancia.baseframe.lock_button, modo)
		
		if (modo == 0) then
			for _, instancia_id in _pairs (instancia.snap) do
				if (instancia_id) then
					instancia.botao_separar.texture:Show()
					instancia.botao_separar.texture:SetTexCoord (unpack (COORDS_UNLOCK_BUTTON))
					gump:Fade (instancia.botao_separar.texture, 0)
					gump:Fade (instancia.botao_separar, 0)
					break
				end
			end
		else
			gump:Fade (instancia.botao_separar, 1)
		end
		
	end
end

local function VPL (instancia, esta_instancia)
	--> conferir esquerda
	if (instancia.ponto4.x < esta_instancia.ponto1.x) then --> a janela esta a esquerda
		if (instancia.ponto4.x+20 > esta_instancia.ponto1.x) then --> a janela esta a menos de 20 pixels de distância
			if (instancia.ponto4.y < esta_instancia.ponto1.y + 20 and instancia.ponto4.y > esta_instancia.ponto1.y - 20) then --> a janela esta a +20 ou -20 pixels de distância na vertical
				return 1
			end
		end
	end
	return nil
end

local function VPB (instancia, esta_instancia)
	--> conferir baixo
	if (instancia.ponto1.y+20 < esta_instancia.ponto2.y-16) then --> a janela esta em baixo
		if (instancia.ponto1.x > esta_instancia.ponto2.x-20 and instancia.ponto1.x < esta_instancia.ponto2.x+20) then --> a janela esta a 20 pixels de distância para a esquerda ou para a direita
			if (instancia.ponto1.y+20 > esta_instancia.ponto2.y-16-20) then --> esta a 20 pixels de distância
				return 2
			end
		end
	end
	return nil
end

local function VPR (instancia, esta_instancia)
	--> conferir lateral direita
	if (instancia.ponto2.x > esta_instancia.ponto3.x) then --> a janela esta a direita
		if (instancia.ponto2.x-20 < esta_instancia.ponto3.x) then --> a janela esta a menos de 20 pixels de distância
			if (instancia.ponto2.y < esta_instancia.ponto3.y + 20 and instancia.ponto2.y > esta_instancia.ponto3.y - 20) then --> a janela esta a +20 ou -20 pixels de distância na vertical
				return 3
			end
		end
	end
	return nil
end

local function VPT (instancia, esta_instancia)
	--> conferir cima
	if (instancia.ponto3.y-16 > esta_instancia.ponto4.y+20) then --> a janela esta em cima
		if (instancia.ponto3.x > esta_instancia.ponto4.x-20 and instancia.ponto3.x < esta_instancia.ponto4.x+20) then --> a janela esta a 20 pixels de distância para a esquerda ou para a direita
			if (esta_instancia.ponto4.y+20+20 > instancia.ponto3.y-16) then
				return 4
			end
		end
	end
	return nil
end

local tempo_movendo, precisa_ativar, instancia_alvo, tempo_fades, nao_anexados
local movement_onupdate = function (self, elapsed) 

				if (tempo_movendo and tempo_movendo < 0) then

					if (precisa_ativar) then --> se a instância estiver fechada
						gump:Fade (instancia_alvo.baseframe, "ALPHA", 0.2)
						gump:Fade (instancia_alvo.baseframe.cabecalho.ball, "ALPHA", 0.2)
						gump:Fade (instancia_alvo.baseframe.cabecalho.atributo_icon, "ALPHA", 0.2)
						instancia_alvo:SaveMainWindowPosition()
						instancia_alvo:RestoreMainWindowPosition()
						precisa_ativar = false
						
					elseif (tempo_fades) then
						for lado, livre in _ipairs (nao_anexados) do
							if (livre) then
								if (lado == 1) then
									instancia_alvo.h_esquerda:Flash (tempo_fades, tempo_fades, 2.0, false, 0, 0)
								elseif (lado == 2) then
									instancia_alvo.h_baixo:Flash (tempo_fades, tempo_fades, 2.0, false, 0, 0)
								elseif (lado == 3) then
									instancia_alvo.h_direita:Flash (tempo_fades, tempo_fades, 2.0, false, 0, 0)
								elseif (lado == 4) then
									instancia_alvo.h_cima:Flash (tempo_fades, tempo_fades, 2.0, false, 0, 0)
								end
							end
						end
						
						tempo_movendo = 1
					else
						self:SetScript ("OnUpdate", nil)
						tempo_movendo = 1
					end
					
				else
					tempo_movendo = tempo_movendo - elapsed
				end
			end

local function move_janela (BaseFrame, iniciando, instancia)

	instancia_alvo = _detalhes.tabela_instancias [instancia.meu_id-1]

	if (iniciando) then
	
		BaseFrame.isMoving = true
		instancia:BaseFrameSnap()
		BaseFrame:StartMoving()
		
		local _, ClampLeft, ClampRight = instancia:InstanciasHorizontais()
		local _, ClampBottom, ClampTop = instancia:InstanciasVerticais()
		
		if (ClampTop == 0) then
			ClampTop = 33
		end
		if (ClampBottom == 0) then
			ClampBottom = 13
		end
		
		BaseFrame:SetClampRectInsets (-ClampLeft-8, ClampRight, ClampTop, -ClampBottom)
		
		if (instancia_alvo) then
		
			tempo_fades = 1.0
			nao_anexados = {true, true, true, true}
			tempo_movendo = 1
			
			for lado, snap_to in _pairs (instancia_alvo.snap) do
				if (snap_to) then
					if (snap_to == instancia.meu_id) then
						tempo_fades = nil
						break
					end
					nao_anexados [lado] = false
				end
			end
			
			for lado = 1, 4 do
				if (instancia_alvo.horizontalSnap and instancia.verticalSnap) then
					nao_anexados [lado] = false
				elseif (instancia_alvo.horizontalSnap and lado == 2) then
					nao_anexados [lado] = false
				elseif (instancia_alvo.horizontalSnap and lado == 4) then
					nao_anexados [lado] = false
				elseif (instancia_alvo.verticalSnap and lado == 1) then
					nao_anexados [lado] = false
				elseif (instancia_alvo.verticalSnap and lado == 3) then
					nao_anexados [lado] = false
				end
			end

			local need_start = not instancia_alvo.iniciada
			precisa_ativar = not instancia_alvo.ativa
			
			if (need_start) then --> se a instância não tiver sido aberta ainda

				instancia_alvo:RestauraJanela (instancia_alvo.meu_id, true) --> problema do solo era aqui
				if (instancia_alvo:IsSoloMode()) then
					_detalhes.SoloTables:switch()
				end
				instancia_alvo.ativa = false --> isso não ta legal
				instancia_alvo:SaveMainWindowPosition()
				instancia_alvo:RestoreMainWindowPosition()
				gump:Fade (instancia_alvo.baseframe, 1)
				gump:Fade (instancia_alvo.baseframe.cabecalho.ball, 1)
				gump:Fade (instancia_alvo.baseframe.cabecalho.atributo_icon, 1)
				need_start = false
			end
			
			BaseFrame:SetScript ("OnUpdate", movement_onupdate)
		end
		
	else

		BaseFrame:StopMovingOrSizing()
		BaseFrame.isMoving = false
		BaseFrame:SetScript ("OnUpdate", nil)
		
		BaseFrame:SetClampRectInsets (unpack (_detalhes.window_clamp))

		if (instancia_alvo) then
			instancia:AtualizaPontos()
			
			local esquerda, baixo, direita, cima
			local meu_id = instancia.meu_id --> id da instância que esta sendo movida
			
			local isVertical = instancia_alvo.verticalSnap
			local isHorizontal = instancia_alvo.horizontalSnap
			
			local isSelfVertical = instancia.verticalSnap
			local isSelfHorizontal = instancia.horizontalSnap
			
			local _R, _T, _L, _B
			
			if (isVertical and not isSelfHorizontal) then
				_T, _B = VPB (instancia, instancia_alvo), VPT (instancia, instancia_alvo)
			elseif (isHorizontal and not isSelfVertical) then
				_R, _L = VPL (instancia, instancia_alvo), VPR (instancia, instancia_alvo)
			elseif (not isVertical and not isHorizontal) then
				_R, _T, _L, _B = VPL (instancia, instancia_alvo), VPB (instancia, instancia_alvo), VPR (instancia, instancia_alvo), VPT (instancia, instancia_alvo)
			end
			
			if (_L) then
				if (not instancia:EstaAgrupada (instancia_alvo, _L)) then
					esquerda = instancia_alvo.meu_id
					instancia.horizontalSnap = true
					instancia_alvo.horizontalSnap = true
				end
			end
			
			if (_B) then
				if (not instancia:EstaAgrupada (instancia_alvo, _B)) then
					baixo = instancia_alvo.meu_id
					instancia.verticalSnap = true
					instancia_alvo.verticalSnap = true
				end
			end
			
			if (_R) then
				if (not instancia:EstaAgrupada (instancia_alvo, _R)) then
					direita = instancia_alvo.meu_id
					instancia.horizontalSnap = true
					instancia_alvo.horizontalSnap = true
				end
			end
			
			if (_T) then
				if (not instancia:EstaAgrupada (instancia_alvo, _T)) then
					cima = instancia_alvo.meu_id
					instancia.verticalSnap = true
					instancia_alvo.verticalSnap = true
				end
			end
			
			if (esquerda or baixo or direita or cima) then
				instancia:agrupar_janelas ({esquerda, baixo, direita, cima})
			end

			for _, esta_instancia in _ipairs (_detalhes.tabela_instancias) do
				if (not esta_instancia:IsAtiva() and esta_instancia.iniciada) then
					esta_instancia:ResetaGump()
					gump:Fade (esta_instancia.baseframe, "in", 0.2)
					gump:Fade (esta_instancia.baseframe.cabecalho.ball, "in", 0.2)
					gump:Fade (esta_instancia.baseframe.cabecalho.atributo_icon, "in", 0.2)
					
					if (esta_instancia.modo == modo_raid) then
						_detalhes.raid = nil
					elseif (esta_instancia.modo == modo_alone) then
						_detalhes.SoloTables:switch()
						_detalhes.solo = nil
					end

				elseif (esta_instancia:IsAtiva()) then
					esta_instancia:SaveMainWindowPosition()
					esta_instancia:RestoreMainWindowPosition()
				end
			end
		end
	end
end

local function BGFrame_scripts (BG, BaseFrame, instancia)

	BG:SetScript("OnEnter", function (self)
		--resize_fade (instancia, 0) --mostrar
		--gump:Fade (BaseFrame.button_stretch, "alpha", 0.6)
		OnEnterMainWindow (instancia, self)
	end)
	
	BG:SetScript("OnLeave", function (self)
		--resize_fade (instancia, 1) --esconder
		--gump:Fade (BaseFrame.button_stretch, -1)
		OnLeaveMainWindow (instancia, self)
	end)
	
	BG:SetScript ("OnMouseDown", function (frame, button)
		if (BaseFrame.isMoving) then
			move_janela (BaseFrame, false, instancia)
			instancia:SaveMainWindowPosition()
			return
		end

		if (not BaseFrame.isLocked and button == "LeftButton") then
			move_janela (BaseFrame, true, instancia) --> novo movedor da janela
		elseif (button == "RightButton") then
			_detalhes.switch:ShowMe (instancia)
		end
	end)

	BG:SetScript ("OnMouseUp", function (frame)
		if (BaseFrame.isMoving) then
			move_janela (BaseFrame, false, instancia) --> novo movedor da janela
			instancia:SaveMainWindowPosition()
		end
	end)	
end

function gump:RegisterForDetailsMove (frame, instancia)

	frame:SetScript ("OnMouseDown", function (frame, button)
		if (not instancia.baseframe.isLocked and button == "LeftButton") then
			move_janela (instancia.baseframe, true, instancia) --> novo movedor da janela
		end
	end)

	frame:SetScript ("OnMouseUp", function (frame)
		if (instancia.baseframe.isMoving) then
			move_janela (instancia.baseframe, false, instancia) --> novo movedor da janela
			instancia:SaveMainWindowPosition()
		end
	end)	
end

--> scripts do base frame
local function BFrame_scripts (BaseFrame, instancia)

	BaseFrame:SetScript("OnSizeChanged", function(self)
		instancia:SaveMainWindowPosition()
		instancia:ReajustaGump()
		_detalhes:SendEvent ("DETAILS_INSTANCE_SIZECHANGED", nil, instancia)
	end)

	BaseFrame:SetScript("OnEnter", function (self)
		--resize_fade (instancia, 0) --mostrar
		--gump:Fade (BaseFrame.button_stretch, "alpha", 0.6)
		OnEnterMainWindow (instancia, self)
	end)
	
	BaseFrame:SetScript("OnLeave", function (self)
		--resize_fade (instancia, 1) --esconder
		--gump:Fade (BaseFrame.button_stretch, -1)
		OnLeaveMainWindow (instancia, self)
	end)
	
	BaseFrame:SetScript ("OnMouseDown", function (frame, button)
		if (not BaseFrame.isLocked and button == "LeftButton") then
			move_janela (BaseFrame, true, instancia) --> novo movedor da janela
		end
	end)

	BaseFrame:SetScript ("OnMouseUp", function (frame)
		if (BaseFrame.isMoving) then
			move_janela (BaseFrame, false, instancia) --> novo movedor da janela
			instancia:SaveMainWindowPosition()
		end
	end)	

end

local function BackGroundDisplay_scripts (BackGroundDisplay, BaseFrame, instancia)

	BackGroundDisplay:SetScript ("OnEnter", function (self)
		--resize_fade (instancia, 0) --mostrar
		--gump:Fade (BaseFrame.button_stretch, "alpha", 0.6)
		OnEnterMainWindow (instancia, self)
	end)
	
	BackGroundDisplay:SetScript ("OnLeave", function (self) 
		--resize_fade (instancia, 1) --esconder
		--gump:Fade (BaseFrame.button_stretch, -1)
		OnLeaveMainWindow (instancia, self)
	end)
end

local function instancias_horizontais (instancia, largura, esquerda, direita)
	if (esquerda) then
		for lado, esta_instancia in _pairs (instancia.snap) do 
			if (lado == 1) then --> movendo para esquerda
				local instancia = _detalhes.tabela_instancias [esta_instancia]
				instancia.baseframe:SetWidth (largura)
				instancia.auto_resize = true
				instancia:ReajustaGump()
				instancia.auto_resize = false
				instancias_horizontais (instancia, largura, true, false)
				_detalhes:SendEvent ("DETAILS_INSTANCE_SIZECHANGED", nil, instancia)
			end
		end
	end
	
	if (direita) then
		for lado, esta_instancia in _pairs (instancia.snap) do 
			if (lado == 3) then --> movendo para esquerda
				local instancia = _detalhes.tabela_instancias [esta_instancia]
				instancia.baseframe:SetWidth (largura)
				instancia.auto_resize = true
				instancia:ReajustaGump()
				instancia.auto_resize = false
				instancias_horizontais (instancia, largura, false, true)
				_detalhes:SendEvent ("DETAILS_INSTANCE_SIZECHANGED", nil, instancia)
			end
		end
	end
end

local function instancias_verticais (instancia, altura, esquerda, direita)
	if (esquerda) then
		for lado, esta_instancia in _pairs (instancia.snap) do 
			if (lado == 1) then --> movendo para esquerda
				local instancia = _detalhes.tabela_instancias [esta_instancia]
				instancia.baseframe:SetHeight (altura)
				instancia.auto_resize = true
				instancia:ReajustaGump()
				instancia.auto_resize = false
				instancias_verticais (instancia, altura, true, false)
				_detalhes:SendEvent ("DETAILS_INSTANCE_SIZECHANGED", nil, instancia)
			end
		end
	end
	
	if (direita) then
		for lado, esta_instancia in _pairs (instancia.snap) do 
			if (lado == 3) then --> movendo para esquerda
				local instancia = _detalhes.tabela_instancias [esta_instancia]
				instancia.baseframe:SetHeight (altura)
				instancia.auto_resize = true
				instancia:ReajustaGump()
				instancia.auto_resize = false
				instancias_verticais (instancia, altura, false, true)
				_detalhes:SendEvent ("DETAILS_INSTANCE_SIZECHANGED", nil, instancia)
			end
		end
	end
end

function _detalhes:InstanciasVerticais (instancia)

	instancia = self or instancia

	local linha_vertical, baixo, cima = {}, 0, 0

	local checking = instancia
	local first = true
	
	local check_index_anterior = _detalhes.tabela_instancias [instancia.meu_id-1]
	if (check_index_anterior) then --> possiu uma instância antes de mim
		if (check_index_anterior.snap[4] and check_index_anterior.snap[4] == instancia.meu_id) then --> o index negativo vai para baixo
			for i = instancia.meu_id-1, 1, -1 do 
				local esta_instancia = _detalhes.tabela_instancias [i]
				if (esta_instancia.snap[4] and esta_instancia.snap [4] == checking.meu_id) then
					linha_vertical [#linha_vertical+1] = esta_instancia
					if (first) then
						baixo = baixo + esta_instancia.baseframe:GetHeight()+48
						first = false
					else
						baixo = baixo + esta_instancia.baseframe:GetHeight()+34
					end
					checking = esta_instancia
				else
					break
				end
			end
		elseif (check_index_anterior.snap[2] and check_index_anterior.snap[2] == instancia.meu_id) then --> o index negativo vai para cima
			for i = instancia.meu_id-1, 1, -1 do 
				local esta_instancia = _detalhes.tabela_instancias [i]
				if (esta_instancia.snap[2] and esta_instancia.snap[2] == checking.meu_id) then
					linha_vertical [#linha_vertical+1] = esta_instancia
					if (first) then
						cima = cima + esta_instancia.baseframe:GetHeight() + 64
						first = false
					else
						cima = cima + esta_instancia.baseframe:GetHeight() + 34
					end
					checking = esta_instancia
				else
					break
				end
			end
		end
	end
	
	checking = instancia
	first = true
	
	local check_index_posterior = _detalhes.tabela_instancias [instancia.meu_id+1]
	if (check_index_posterior) then
		if (check_index_posterior.snap[4] and check_index_posterior.snap[4] == instancia.meu_id) then --> o index posterior vai para a esquerda
			for i = instancia.meu_id+1, #_detalhes.tabela_instancias do 
				local esta_instancia = _detalhes.tabela_instancias [i]
				if (esta_instancia.snap[4] and esta_instancia.snap[4] == checking.meu_id) then
					linha_vertical [#linha_vertical+1] = esta_instancia
					if (first) then
						baixo = baixo + esta_instancia.baseframe:GetHeight()+48
						first = true
					else
						baixo = baixo + esta_instancia.baseframe:GetHeight()+34
					end
					checking = esta_instancia
				else
					break
				end
			end
		elseif (check_index_posterior.snap[2] and check_index_posterior.snap[2] == instancia.meu_id) then --> o index posterior vai para a direita
			for i = instancia.meu_id+1, #_detalhes.tabela_instancias do 
				local esta_instancia = _detalhes.tabela_instancias [i]
				if (esta_instancia.snap[2] and esta_instancia.snap[2] == checking.meu_id) then
					linha_vertical [#linha_vertical+1] = esta_instancia
					if (first) then
						cima = cima + esta_instancia.baseframe:GetHeight() + 64
						first = false
					else
						cima = cima + esta_instancia.baseframe:GetHeight() + 34
					end
					checking = esta_instancia
				else
					break
				end
			end
		end
	end

	
	
	return linha_vertical, baixo, cima
	
end

--[[
			lado 4
	-----------------------------------------
	|					|
lado 1	|					| lado 3
	|					|
	|					|
	-----------------------------------------
			lado 2
--]]

function _detalhes:InstanciasHorizontais (instancia)

	instancia = self or instancia

	local linha_horizontal, esquerda, direita = {}, 0, 0
	
	local top, bottom = 0, 0

	local checking = instancia
	
	local check_index_anterior = _detalhes.tabela_instancias [instancia.meu_id-1]
	if (check_index_anterior) then --> possiu uma instância antes de mim
		if (check_index_anterior.snap[3] and check_index_anterior.snap[3] == instancia.meu_id) then --> o index negativo vai para a esquerda
			for i = instancia.meu_id-1, 1, -1 do 
				local esta_instancia = _detalhes.tabela_instancias [i]
				if (esta_instancia.snap[3]) then
					if (esta_instancia.snap[3] == checking.meu_id) then
						linha_horizontal [#linha_horizontal+1] = esta_instancia
						esquerda = esquerda + esta_instancia.baseframe:GetWidth()
						checking = esta_instancia
					end
				else
					break
				end
			end
		elseif (check_index_anterior.snap[1] and check_index_anterior.snap[1] == instancia.meu_id) then --> o index negativo vai para a direita
			for i = instancia.meu_id-1, 1, -1 do 
				local esta_instancia = _detalhes.tabela_instancias [i]
				if (esta_instancia.snap[1]) then
					if (esta_instancia.snap[1] == checking.meu_id) then
						linha_horizontal [#linha_horizontal+1] = esta_instancia
						direita = direita + esta_instancia.baseframe:GetWidth()
						checking = esta_instancia
					end
				else
					break
				end
			end
		end
	end
	
	checking = instancia
	
	local check_index_posterior = _detalhes.tabela_instancias [instancia.meu_id+1]
	if (check_index_posterior) then
		if (check_index_posterior.snap[3] and check_index_posterior.snap[3] == instancia.meu_id) then --> o index posterior vai para a esquerda
			for i = instancia.meu_id+1, #_detalhes.tabela_instancias do 
				local esta_instancia = _detalhes.tabela_instancias [i]
				if (esta_instancia.snap[3]) then
					if (esta_instancia.snap[3] == checking.meu_id) then
						linha_horizontal [#linha_horizontal+1] = esta_instancia
						esquerda = esquerda + esta_instancia.baseframe:GetWidth()
						checking = esta_instancia
					end
				else
					break
				end
			end
		elseif (check_index_posterior.snap[1] and check_index_posterior.snap[1] == instancia.meu_id) then --> o index posterior vai para a direita
			for i = instancia.meu_id+1, #_detalhes.tabela_instancias do 
				local esta_instancia = _detalhes.tabela_instancias [i]
				if (esta_instancia.snap[1]) then
					if (esta_instancia.snap[1] == checking.meu_id) then
						linha_horizontal [#linha_horizontal+1] = esta_instancia
						direita = direita + esta_instancia.baseframe:GetWidth()
						checking = esta_instancia
					end
				else
					break
				end
			end
		end
	end

	return linha_horizontal, esquerda, direita, bottom, top
	
end

local resizeTooltip = {
	{text = "|cff33CC00Click|cffEEEEEE: ".. Loc ["STRING_RESIZE_COMMON"]},
	
	{text = "+|cff33CC00 Click|cffEEEEEE: " .. Loc ["STRING_RESIZE_HORIZONTAL"]},
	{icon = "Interface\\AddOns\\Details\\images\\key_shift", width = 24, height = 14, l = 0, r = 1, t = 0, b =0.640625},
	
	{text = "+|cff33CC00 Click|cffEEEEEE: " .. Loc ["STRING_RESIZE_VERTICAL"]},
	{icon = "Interface\\AddOns\\Details\\images\\key_alt", width = 24, height = 14, l = 0, r = 1, t = 0, b =0.640625},
	
	{text = "+|cff33CC00 Click|cffEEEEEE: " .. Loc ["STRING_RESIZE_ALL"]},
	{icon = "Interface\\AddOns\\Details\\images\\key_ctrl", width = 24, height = 14, l = 0, r = 1, t = 0, b =0.640625}
}

--> search key: ~resizescript
local function resize_scripts (resizer, instancia, ScrollBar, side, baseframe)

	resizer:SetScript ("OnMouseDown", function (self, button) 
	
		_detalhes.popup:ShowMe (false) --> Hide Cooltip
		
		if (not self:GetParent().isLocked and button == "LeftButton" and instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"]) then 
			self:GetParent().isResizing = true
			instancia:BaseFrameSnap()

			local isVertical = instancia.verticalSnap
			local isHorizontal = instancia.horizontalSnap
		
			local agrupadas
			if (instancia.verticalSnap) then
				agrupadas = instancia:InstanciasVerticais()
			elseif (instancia.horizontalSnap) then
				agrupadas = instancia:InstanciasHorizontais()
			end

			instancia.stretchToo = agrupadas
			if (instancia.stretchToo and #instancia.stretchToo > 0) then
				for _, esta_instancia in ipairs (instancia.stretchToo) do 
					esta_instancia.baseframe._place = esta_instancia:SaveMainWindowPosition()
					esta_instancia.baseframe.isResizing = true
				end
			end
			
		----------------
		
			if (side == "<") then
				if (_IsShiftKeyDown()) then
					instancia.baseframe:StartSizing("LEFT")
					instancia.eh_horizontal = true
				elseif (_IsAltKeyDown()) then
					instancia.baseframe:StartSizing("TOP")
					instancia.eh_vertical = true
				elseif (_IsControlKeyDown()) then
					instancia.baseframe:StartSizing("BOTTOMLEFT")
					instancia.eh_tudo = true
				else
					instancia.baseframe:StartSizing("BOTTOMLEFT")
				end
				
				resizer:SetPoint ("BOTTOMLEFT", baseframe, "BOTTOMLEFT", -1, -1)
				resizer.afundado = true
				
			elseif (side == ">") then
				if (_IsShiftKeyDown()) then
					instancia.baseframe:StartSizing("RIGHT")
					instancia.eh_horizontal = true
				elseif (_IsAltKeyDown()) then
					instancia.baseframe:StartSizing("TOP")
					instancia.eh_vertical = true
				elseif (_IsControlKeyDown()) then
					instancia.baseframe:StartSizing("BOTTOMRIGHT")
					instancia.eh_tudo = true
				else
					instancia.baseframe:StartSizing("BOTTOMRIGHT")
				end
				
				if (instancia.rolagem and _detalhes.use_scroll) then
					resizer:SetPoint ("BOTTOMRIGHT", baseframe, "BOTTOMRIGHT", (instancia.largura_scroll*-1) + 1, -1)
				else
					resizer:SetPoint ("BOTTOMRIGHT", baseframe, "BOTTOMRIGHT", 1, -1)
				end
				resizer.afundado = true
			end
			
			_detalhes:SendEvent ("DETAILS_INSTANCE_STARTRESIZE", nil, instancia)
			
		end 
	end)
	
	resizer:SetScript ("OnMouseUp", function (self,button) 
	
			if (resizer.afundado) then
				resizer.afundado = false
				if (resizer.side == 2) then
					if (instancia.rolagem and _detalhes.use_scroll) then
						resizer:SetPoint ("BOTTOMRIGHT", baseframe, "BOTTOMRIGHT", instancia.largura_scroll*-1, 0)
					else
						resizer:SetPoint ("BOTTOMRIGHT", baseframe, "BOTTOMRIGHT", 0, 0)
					end
				else
					resizer:SetPoint ("BOTTOMLEFT", baseframe, "BOTTOMLEFT", 0, 0)
				end
			end
	
			if (self:GetParent().isResizing) then 
			
				self:GetParent():StopMovingOrSizing()
				self:GetParent().isResizing = false
				
				if (instancia.stretchToo and #instancia.stretchToo > 0) then
					for _, esta_instancia in ipairs (instancia.stretchToo) do 
						esta_instancia.baseframe:StopMovingOrSizing()
						esta_instancia.baseframe.isResizing = false
						esta_instancia:ReajustaGump()
						_detalhes:SendEvent ("DETAILS_INSTANCE_SIZECHANGED", nil, esta_instancia)
					end
					instancia.stretchToo = nil
				end	
				
				local largura = instancia.baseframe:GetWidth()
				local altura = instancia.baseframe:GetHeight()
				
				if (instancia.eh_horizontal) then
					instancias_horizontais (instancia, largura, true, true)
					instancia.eh_horizontal = nil
				end
				
				--if (instancia.eh_vertical) then
					instancias_verticais (instancia, altura, true, true)
					instancia.eh_vertical = nil
				--end
				
				_detalhes:SendEvent ("DETAILS_INSTANCE_ENDRESIZE", nil, instancia)
				
				if (instancia.eh_tudo) then
					for _, esta_instancia in _ipairs (_detalhes.tabela_instancias) do
						if (esta_instancia:IsAtiva() and esta_instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"]) then
							esta_instancia.baseframe:ClearAllPoints()
							esta_instancia:SaveMainWindowPosition()
							esta_instancia:RestoreMainWindowPosition()
						end
					end
					
					for _, esta_instancia in _ipairs (_detalhes.tabela_instancias) do
						if (esta_instancia:IsAtiva() and esta_instancia ~= instancia and esta_instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"]) then
							esta_instancia.baseframe:SetWidth (largura)
							esta_instancia.baseframe:SetHeight (altura)
							esta_instancia.auto_resize = true
							esta_instancia:ReajustaGump()
							esta_instancia.auto_resize = false
							_detalhes:SendEvent ("DETAILS_INSTANCE_SIZECHANGED", nil, esta_instancia)
						end
					end

					instancia.eh_tudo = nil
				end
				
				instancia:BaseFrameSnap()
				
				for _, esta_instancia in _ipairs (_detalhes.tabela_instancias) do
					if (esta_instancia:IsAtiva()) then
						esta_instancia:SaveMainWindowPosition()
						esta_instancia:RestoreMainWindowPosition()
					end
				end
			end 
		end)
		
	resizer:SetScript ("OnEnter", function (self) 
	
		OnEnterMainWindow (instancia, self)
	
		if (instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"] and not instancia.baseframe.isLocked) then
			self.texture:SetBlendMode ("ADD")
			self.mostrando = true
			
			_G.GameCooltip:Reset()
			_G.GameCooltip:SetType ("tooltip")
			_G.GameCooltip:AddFromTable (resizeTooltip)
			_G.GameCooltip:SetOption ("NoLastSelectedBar", true)
			_G.GameCooltip:SetOwner (resizer)
			_G.GameCooltip:ShowCooltip()
		end
	end)
	
	resizer:SetScript ("OnLeave", function (self) 

		if (not self.movendo) then
			OnLeaveMainWindow (instancia, self)
		end

		self.texture:SetBlendMode ("BLEND")
		_detalhes.popup:ShowMe (false)

		self.mostrando = false
	end)
end


local function lock_button_scripts (button, instancia)
	button:SetScript ("OnEnter", function(self) 
	
		OnEnterMainWindow (instancia, self)
		
		if (instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"]) then
			self.label:SetTextColor (1, 1, 1, .6)
			self.mostrando = true
		end
		
	end)

	button:SetScript ("OnLeave", function(self) 
	
		OnLeaveMainWindow (instancia, self)
		self.label:SetTextColor (.3, .3, .3, .6)
		self.mostrando = false
		
	end)
end

local lockFunctionOnClick = function (button)
	local BaseFrame = button:GetParent()
	if (BaseFrame.isLocked) then
		BaseFrame.isLocked = false
		BaseFrame.instance.isLocked = false
		button.label:SetText (Loc ["STRING_LOCK_WINDOW"])
		button:SetWidth (button.label:GetStringWidth()+2)
		gump:Fade (BaseFrame.resize_direita, 0)
		gump:Fade (BaseFrame.resize_esquerda, 0)
		button:ClearAllPoints()
		button:SetPoint ("right", BaseFrame.resize_direita, "left", -1, 1.5)		
	else
		BaseFrame.isLocked = true
		BaseFrame.instance.isLocked = true
		button.label:SetText (Loc ["STRING_UNLOCK_WINDOW"])
		button:SetWidth (button.label:GetStringWidth()+2)
		button:ClearAllPoints()
		button:SetPoint ("bottomright", BaseFrame, "bottomright", -3, 0)
		gump:Fade (BaseFrame.resize_direita, 1)
		gump:Fade (BaseFrame.resize_esquerda, 1)
	end
end
_detalhes.lock_instance_function = lockFunctionOnClick

local function bota_separar_script (botao, instancia)
	botao:SetScript ("OnEnter", function (self) 
		OnEnterMainWindow (instancia, self)
		self.mostrando = true
	end)
	
	botao:SetScript ("OnLeave", function (self) 
		OnLeaveMainWindow (instancia, self)
		self.mostrando = false
	end)
end

local function barra_scripts (esta_barra, instancia, i)

	esta_barra:SetScript ("OnEnter", function (self) 
		self.mouse_over = true
		--resize_fade (instancia, 0) --mostrar
		--gump:Fade (instancia.baseframe.button_stretch, "alpha", 0.6)
		OnEnterMainWindow (instancia, esta_barra)

		instancia:MontaTooltip (self, i)
		
		self:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
			tile = true, tileSize = 16,
			insets = {left = 1, right = 1, top = 0, bottom = 1},})	
			self:SetBackdropColor (0.588, 0.588, 0.588, 0.7)
	end)

	esta_barra:SetScript ("OnLeave", function (self) 
		self.mouse_over = false
		--resize_fade (instancia, 1) --esconder
		--gump:Fade (instancia.baseframe.button_stretch, -1)
		OnLeaveMainWindow (instancia, self)
		
		_GameTooltip:Hide()
		_detalhes.popup:ShowMe (false)
		
		self:SetBackdrop({
			bgFile = "", edgeFile = "", tile = true, tileSize = 16, edgeSize = 32,
			insets = {left = 1, right = 1, top = 0, bottom = 1},})	

			self:SetBackdropBorderColor (0, 0, 0, 0)
			self:SetBackdropColor (0, 0, 0, 0)
	end)

	esta_barra:SetScript ("OnMouseDown", function (self, button)
		
		if (esta_barra.fading_in) then
			return
		end

		if (button == "RightButton") then
			return _detalhes.switch:ShowMe (instancia)
		end
	
		esta_barra.texto_esquerdo:SetPoint ("LEFT", esta_barra.icone_classe, "right", 4, -1)
		esta_barra.texto_direita:SetPoint ("RIGHT", esta_barra.statusbar, "RIGHT", 1, -1)
	
		self.mouse_down = _GetTime()
		self.button = button
		local x, y = _GetCursorPosition()
		self.x = _math_floor (x)
		self.y = _math_floor (y)
	
		local parent = instancia.baseframe
		if ((not parent.isLocked) or (parent.isLocked == 0)) then
			GameCooltip:Hide() --> fecha o tooltip
			move_janela (parent, true, instancia) --> novo movedor da janela
		end

	end)
	
	esta_barra:SetScript ("OnMouseUp", function (self, button)
	
		local parent = instancia.baseframe
		if (parent.isMoving) then
		
			move_janela (parent, false, instancia) --> novo movedor da janela
			instancia:SaveMainWindowPosition()
			_GameTooltip:SetOwner (self, "ANCHOR_TOPRIGHT")
			if (instancia:MontaTooltip (self, i)) then
				GameCooltip:Show (esta_barra, 1)
			end
			
		end

		esta_barra.texto_esquerdo:SetPoint ("LEFT", esta_barra.icone_classe, "right", 3, 0)
		esta_barra.texto_direita:SetPoint ("RIGHT", esta_barra.statusbar, "RIGHT")
		
		local x, y = _GetCursorPosition()
		x = _math_floor (x)
		y = _math_floor (y)

		if (self.mouse_down and (self.mouse_down+0.4 > _GetTime() and (x == self.x and y == self.y)) or (x == self.x and y == self.y)) then
			--> a única maneira de abrir a janela de info é por aqui...

			if (self.button == "LeftButton") then
				if (instancia.atributo == 5 or _IsShiftKeyDown()) then 
					--> report
					return _detalhes:ReportSingleLine (instancia, self)
				end
				instancia:AbreJanelaInfo (self.minha_tabela)
			end

		end
	end)

	esta_barra:SetScript ("OnClick", function(self, button)

		end)
end

function _detalhes:ReportSingleLine (instancia, barra)

	local reportar
	if (instancia.atributo == 5) then --> custom
		reportar = {"Details! " .. Loc ["STRING_CUSTOM_REPORT"] .. " " ..instancia.customName}
	else
		reportar = {"Details! " .. Loc ["STRING_REPORT"] .. " " .. _detalhes.sub_atributos [instancia.atributo].lista [instancia.sub_atributo]}
	end

	reportar [#reportar+1] = barra.texto_esquerdo:GetText().." "..barra.texto_direita:GetText()

	return _detalhes:Reportar (reportar, {_no_current = true, _no_inverse = true, _custom = true})
end

local function button_stretch_scripts (BaseFrame, BackGroundDisplay, instancia)
	local button = BaseFrame.button_stretch

	button:SetScript ("OnEnter", function (self)
		self.mouse_over = true
		gump:Fade (self, 0)
	end)
	button:SetScript ("OnLeave", function (self)
		self.mouse_over = false
		gump:Fade (self, "ALPHA", 0)
	end)	

	button:SetScript ("OnMouseDown", function(self)

		if (instancia:IsSoloMode()) then
			return
		end
	
		instancia:EsconderScrollBar (true)
		BaseFrame._place = instancia:SaveMainWindowPosition()
		BaseFrame.isResizing = true
		BaseFrame.isStretching = true
		BaseFrame:SetFrameStrata ("TOOLTIP")
		
		local _r, _g, _b, _a = BaseFrame:GetBackdropColor()
		gump:GradientEffect ( BaseFrame, "frame", _r, _g, _b, _a, _r, _g, _b, 0.9, 1.5)
		if (instancia.wallpaper.enabled) then
			_r, _g, _b = BaseFrame.wallpaper:GetVertexColor()
			_a = BaseFrame.wallpaper:GetAlpha()
			gump:GradientEffect (BaseFrame.wallpaper, "texture", _r, _g, _b, _a, _r, _g, _b, 0.05, 0.5)
		end
		
		BaseFrame:StartSizing ("TOP")
		
		local linha_horizontal = {}
	
		local checking = instancia
		for i = instancia.meu_id-1, 1, -1 do 
			local esta_instancia = _detalhes.tabela_instancias [i]
			if ((esta_instancia.snap[1] and esta_instancia.snap[1] == checking.meu_id) or (esta_instancia.snap[3] and esta_instancia.snap[3] == checking.meu_id)) then
				linha_horizontal [#linha_horizontal+1] = esta_instancia
				checking = esta_instancia
			else
				break
			end
		end
		
		checking = instancia
		for i = instancia.meu_id+1, #_detalhes.tabela_instancias do 
			local esta_instancia = _detalhes.tabela_instancias [i]
			if ((esta_instancia.snap[1] and esta_instancia.snap[1] == checking.meu_id) or (esta_instancia.snap[3] and esta_instancia.snap[3] == checking.meu_id)) then
				linha_horizontal [#linha_horizontal+1] = esta_instancia
				checking = esta_instancia
			else
				break
			end
		end
		
		instancia.stretchToo = linha_horizontal
		if (#instancia.stretchToo > 0) then
			for _, esta_instancia in ipairs (instancia.stretchToo) do 
				esta_instancia:EsconderScrollBar (true)
				esta_instancia.baseframe._place = esta_instancia:SaveMainWindowPosition()
				esta_instancia.baseframe.isResizing = true
				esta_instancia.baseframe.isStretching = true
				esta_instancia.baseframe:SetFrameStrata ("TOOLTIP")
				
				local _r, _g, _b, _a = esta_instancia.baseframe:GetBackdropColor()
				gump:GradientEffect ( esta_instancia.baseframe, "frame", _r, _g, _b, _a, _r, _g, _b, 0.9, 1.5)
				_detalhes:SendEvent ("DETAILS_INSTANCE_STARTSTRETCH", nil, esta_instancia)
				
				if (esta_instancia.wallpaper.enabled) then
					_r, _g, _b = esta_instancia.baseframe.wallpaper:GetVertexColor()
					_a = esta_instancia.baseframe.wallpaper:GetAlpha()
					gump:GradientEffect (esta_instancia.baseframe.wallpaper, "texture", _r, _g, _b, _a, _r, _g, _b, 0.05, 0.5)
				end
				
			end
		end
		
		_detalhes:SnapTextures (true)
		
		_detalhes:SendEvent ("DETAILS_INSTANCE_STARTSTRETCH", nil, instancia)
	end)
	
	button:SetScript ("OnMouseUp", function(self) 
	
		if (instancia:IsSoloMode()) then
			return
		end
	
		if (BaseFrame.isResizing) then 
			BaseFrame:StopMovingOrSizing()
			BaseFrame.isResizing = false
			instancia:RestoreMainWindowPosition (BaseFrame._place)
			instancia:ReajustaGump()
			BaseFrame.isStretching = false
			if (instancia.need_rolagem) then
				instancia:MostrarScrollBar (true)
			end
			_detalhes:SendEvent ("DETAILS_INSTANCE_SIZECHANGED", nil, instancia)
			
			if (instancia.stretchToo and #instancia.stretchToo > 0) then
				for _, esta_instancia in ipairs (instancia.stretchToo) do 
					esta_instancia.baseframe:StopMovingOrSizing()
					esta_instancia.baseframe.isResizing = false
					esta_instancia:RestoreMainWindowPosition (esta_instancia.baseframe._place)
					esta_instancia:ReajustaGump()
					esta_instancia.baseframe.isStretching = false
					if (esta_instancia.need_rolagem) then
						esta_instancia:MostrarScrollBar (true)
					end
					_detalhes:SendEvent ("DETAILS_INSTANCE_SIZECHANGED", nil, esta_instancia)
					
					local _r, _g, _b, _a = esta_instancia.baseframe:GetBackdropColor()
					gump:GradientEffect ( esta_instancia.baseframe, "frame", _r, _g, _b, _a, instancia.bg_r, instancia.bg_g, instancia.bg_b, instancia.bg_alpha, 0.5)
					
					if (esta_instancia.wallpaper.enabled) then
						_r, _g, _b = esta_instancia.baseframe.wallpaper:GetVertexColor()
						_a = esta_instancia.baseframe.wallpaper:GetAlpha()
						gump:GradientEffect (esta_instancia.baseframe.wallpaper, "texture", _r, _g, _b, _a, _r, _g, _b, esta_instancia.baseframe.wallpaper.alpha, 1.0)
					end
					
					esta_instancia.baseframe:SetFrameStrata ("LOW")
					esta_instancia.baseframe.button_stretch:SetFrameStrata ("FULLSCREEN")
					_detalhes:SendEvent ("DETAILS_INSTANCE_ENDSTRETCH", nil, esta_instancia.baseframe)
				end
				instancia.stretchToo = nil
			end
			
		end 
		
		local _r, _g, _b, _a = BaseFrame:GetBackdropColor()
		gump:GradientEffect ( BaseFrame, "frame", _r, _g, _b, _a, instancia.bg_r, instancia.bg_g, instancia.bg_b, instancia.bg_alpha, 0.5)
		if (instancia.wallpaper.enabled) then
			_r, _g, _b = BaseFrame.wallpaper:GetVertexColor()
			_a = BaseFrame.wallpaper:GetAlpha()
			gump:GradientEffect (BaseFrame.wallpaper, "texture", _r, _g, _b, _a, _r, _g, _b, instancia.wallpaper.alpha, 1.0)
		end
		
		BaseFrame:SetFrameStrata ("LOW")
		BaseFrame.button_stretch:SetFrameStrata ("FULLSCREEN")
		
		_detalhes:SnapTextures (false)
		
		_detalhes:SendEvent ("DETAILS_INSTANCE_ENDSTRETCH", nil, instancia)
	end)	
end

local function button_down_scripts (main_frame, BackGroundDisplay, instancia, ScrollBar)
	main_frame.button_down:SetScript ("OnMouseDown", function(self)
		if (not ScrollBar:IsEnabled()) then
			return
		end
		
		local B = instancia.barraS[2]
		if (B < instancia.barrasInfo.mostrando) then
			ScrollBar:SetValue (ScrollBar:GetValue() + instancia.barrasInfo.alturaReal)
		end
		
		self.precionado = true
		self.last_up = -0.3
		self:SetScript ("OnUpdate", function(self, elapsed)
			self.last_up = self.last_up + elapsed
			if (self.last_up > 0.03) then
				self.last_up = 0
				B = instancia.barraS[2]
				if (B < instancia.barrasInfo.mostrando) then
					ScrollBar:SetValue (ScrollBar:GetValue() + instancia.barrasInfo.alturaReal)
				else
					self:Disable()
				end
			end
		end)
	end)
	
	main_frame.button_down:SetScript ("OnMouseUp", function(self) 
		self.precionado = false
		self:SetScript ("OnUpdate", nil)
	end)
end

local function button_up_scripts (main_frame, BackGroundDisplay, instancia, ScrollBar)

	main_frame.button_up:SetScript ("OnMouseDown", function(self) 
		if (not ScrollBar:IsEnabled()) then
			return
		end
		
		local A = instancia.barraS[1]
		if (A > 1) then
			ScrollBar:SetValue (ScrollBar:GetValue() - instancia.barrasInfo.alturaReal)
		end
		
		self.precionado = true
		self.last_up = -0.3
		self:SetScript ("OnUpdate", function(self, elapsed)
			self.last_up = self.last_up + elapsed
			if (self.last_up > 0.03) then
				self.last_up = 0
				A = instancia.barraS[1]
				if (A > 1) then
					ScrollBar:SetValue (ScrollBar:GetValue() - instancia.barrasInfo.alturaReal)
				else
					self:Disable()
				end
			end
		end)
	end)
	
	main_frame.button_up:SetScript ("OnMouseUp", function(self) 
		self.precionado = false
		self:SetScript ("OnUpdate", nil)
	end)	

	main_frame.button_up:SetScript ("OnEnable", function (self)
		local current = ScrollBar:GetValue()
		if (current == 0) then
			main_frame.button_up:Disable()
		end
	end)
end

local function iterate_scroll_scripts (BackGroundDisplay, BackGroundFrame, BaseFrame, ScrollBar, instancia)

	BaseFrame:SetScript ("OnMouseWheel", 
		function (self, delta)
			if (delta > 0) then --> rolou pra cima
				local A = instancia.barraS[1]
				if (A > 1) then
					ScrollBar:SetValue (ScrollBar:GetValue() - instancia.barrasInfo.alturaReal)
				else
					ScrollBar:SetValue (0)
					ScrollBar.ultimo = 0
					BaseFrame.button_up:Disable()
				end
			elseif (delta < 0) then --> rolou pra baixo
				local B = instancia.barraS[2]
				if (B < instancia.barrasInfo.mostrando) then
					ScrollBar:SetValue (ScrollBar:GetValue() + instancia.barrasInfo.alturaReal)
				else
					local _, maxValue = ScrollBar:GetMinMaxValues()
					ScrollBar:SetValue (maxValue)
					ScrollBar.ultimo = maxValue
					BaseFrame.button_down:Disable()
				end
			end

		end)

	ScrollBar:SetScript ("OnValueChanged", function(self)
		local ultimo = self.ultimo
		local meu_valor = self:GetValue()
		if (ultimo == meu_valor) then --> não mudou
			return
		end
		
		--> shortcut
		local minValue, maxValue = ScrollBar:GetMinMaxValues()
		if (minValue == meu_valor) then
			instancia.barraS[1] = 1
			instancia.barraS[2] = instancia.barrasInfo.cabem
			instancia:AtualizaGumpPrincipal (instancia, true)
			self.ultimo = meu_valor
			BaseFrame.button_up:Disable()
				return
		elseif (maxValue == meu_valor) then
			local min = instancia.barrasInfo.mostrando -instancia.barrasInfo.cabem
			min = min+1
			if (min < 1) then
				min = 1
			end
			instancia.barraS[1] = min
			instancia.barraS[2] = instancia.barrasInfo.mostrando
			instancia:AtualizaGumpPrincipal (instancia, true)
			self.ultimo = meu_valor
			BaseFrame.button_down:Disable()
			return
		end
		
		if (not BaseFrame.button_up:IsEnabled()) then
			BaseFrame.button_up:Enable()
		end
		if (not BaseFrame.button_down:IsEnabled()) then
			BaseFrame.button_down:Enable()
		end
		
		if (meu_valor > ultimo) then --> scroll down
		
			local B = instancia.barraS[2]
			if (B < instancia.barrasInfo.mostrando) then --> se o valor maximo não for o máximo de barras a serem mostradas	
				local precisa_passar = ((B+1) * instancia.barrasInfo.alturaReal) - (instancia.barrasInfo.alturaReal*instancia.barrasInfo.cabem)
				if (meu_valor > precisa_passar) then --> o valor atual passou o valor que precisa passar pra locomover
					local diff = meu_valor - ultimo --> pega a diferença de H
					diff = diff / instancia.barrasInfo.alturaReal --> calcula quantas barras ele pulou
					diff = _math_ceil (diff) --> arredonda para cima
					if (instancia.barraS[2]+diff > instancia.barrasInfo.mostrando and ultimo > 0) then
						instancia.barraS[1] = instancia.barrasInfo.mostrando - (instancia.barrasInfo.cabem-1)
						instancia.barraS[2] = instancia.barrasInfo.mostrando
					else
						instancia.barraS[2] = instancia.barraS[2]+diff
						instancia.barraS[1] = instancia.barraS[1]+diff
					end
					instancia:AtualizaGumpPrincipal (instancia, true)
				end
			end
		else --> scroll up
			local A = instancia.barraS[1]
			if (A > 1) then
				local precisa_passar = (A-1) * instancia.barrasInfo.alturaReal
				if (meu_valor < precisa_passar) then
					--> calcula quantas barras passou
					local diff = ultimo - meu_valor
					diff = diff / instancia.barrasInfo.alturaReal
					diff = _math_ceil (diff)
					if (instancia.barraS[1]-diff < 1) then
						instancia.barraS[2] = instancia.barrasInfo.cabem
						instancia.barraS[1] = 1
					else
						instancia.barraS[2] = instancia.barraS[2]-diff
						instancia.barraS[1] = instancia.barraS[1]-diff
					end

					instancia:AtualizaGumpPrincipal (instancia, true)
				end
			end
		end
		self.ultimo = meu_valor
	end)		
end

function _detalhes:HaveInstanceAlert()
	return self.alert:IsShown()
end

function _detalhes:InstanceAlertTime (instance)
	instance.alert:Hide()
	instance.alert.rotate:Stop()
	instance.alert_time = nil
end

function _detalhes:InstanceAlert (msg, icon, time, clickfunc)
	
	if (not self.meu_id) then
		local lower = _detalhes:GetLowerInstanceNumber()
		if (lower) then
			self = _detalhes:GetInstance (lower)
		else
			return
		end
	end
	
	if (type (msg) == "boolean" and not msg) then
		self.alert:Hide()
		self.alert.rotate:Stop()
		self.alert_time = nil
		return
	end
	
	if (msg) then
		self.alert.text:SetText (msg)
	else
		self.alert.text:SetText ("")
	end
	
	if (icon) then
		if (type (icon) == "table") then
			local texture, w, h, animate, l, r, t, b = unpack (icon)
			
			self.alert.icon:SetTexture (texture)
			self.alert.icon:SetWidth (w or 14)
			self.alert.icon:SetHeight (h or 14)
			if (l and r and t and b) then
				self.alert.icon:SetTexCoord (l, r, t, b)
			end
			if (animate) then
				self.alert.rotate:Play()
			end
		else
			self.alert.icon:SetWidth (14)
			self.alert.icon:SetHeight (14)
			self.alert.icon:SetTexture (icon)
			self.alert.icon:SetTexCoord (0, 1, 0, 1)
		end
	else
		self.alert.icon:SetTexture (nil)
	end
	
	if (clickfunc) then
		self.alert.button:SetClickFunction (unpack (clickfunc))
	else
		self.alert.button.clickfunction = nil
	end

	if (time) then
		self.alert_time = time
		_detalhes:ScheduleTimer ("InstanceAlertTime", time, self)
	end
	
	self.alert:Show()
end

function CreateAlertFrame (BaseFrame, instancia)

	local alert_bg = CreateFrame ("frame", nil, BaseFrame)
	alert_bg:SetPoint ("bottom", BaseFrame, "bottom")
	alert_bg:SetPoint ("left", BaseFrame, "left", 3, 0)
	alert_bg:SetPoint ("right", BaseFrame, "right", -3, 0)
	alert_bg:SetHeight (12)
	alert_bg:SetBackdrop ({bgFile = "Interface\\AddOns\\Details\\images\\background", tile = true, tileSize = 16,
	insets = {left = 0, right = 0, top = 0, bottom = 0}})
	alert_bg:SetBackdropColor (.1, .1, .1, 1)
	alert_bg:SetFrameStrata ("HIGH")
	alert_bg:SetFrameLevel (BaseFrame:GetFrameLevel() + 6)
	alert_bg:Hide()

	local toptexture = alert_bg:CreateTexture (nil, "background")
	toptexture:SetTexture ([[Interface\Challenges\challenges-main]])
	--toptexture:SetTexCoord (0.1921484375, 0.523671875, 0.234375, 0.160859375)
	toptexture:SetTexCoord (0.231171875, 0.4846484375, 0.0703125, 0.072265625)
	toptexture:SetPoint ("left", alert_bg, "left")
	toptexture:SetPoint ("right", alert_bg, "right")
	toptexture:SetPoint ("bottom", alert_bg, "top", 0, 0)
	toptexture:SetHeight (1)
	
	local text = alert_bg:CreateFontString (nil, "overlay", "GameFontNormal")
	text:SetPoint ("right", alert_bg, "right", -14, 0)
	_detalhes:SetFontSize (text, 10)
	text:SetTextColor (1, 1, 1, 1)
	
	local rotate_frame = CreateFrame ("frame", nil, alert_bg)
	rotate_frame:SetWidth (12)
	rotate_frame:SetPoint ("right", alert_bg, "right", -2, 0)
	rotate_frame:SetHeight (alert_bg:GetWidth())
	
	local icon = rotate_frame:CreateTexture (nil, "overlay")
	icon:SetPoint ("center", rotate_frame, "center")
	icon:SetWidth (14)
	icon:SetHeight (14)
	
	local button = gump:NewButton (alert_bg, nil, "DetailsInstance"..instancia.meu_id.."AlertButton", nil, 1, 1)
	button:SetAllPoints()
	button:SetHook ("OnMouseUp", function() alert_bg:Hide() end)
	
	local RotateAnimGroup = rotate_frame:CreateAnimationGroup()
	local rotate = RotateAnimGroup:CreateAnimation ("Rotation")
	rotate:SetDegrees (360)
	rotate:SetDuration (6)
	RotateAnimGroup:SetLooping ("repeat")
	
	alert_bg:Hide()	
	
	alert_bg.text = text
	alert_bg.icon = icon
	alert_bg.button = button
	alert_bg.rotate = RotateAnimGroup
	
	instancia.alert = alert_bg
	
	return alert_bg
end

function _detalhes:InstanceMsg (text, icon, textcolor, icontexture, iconcoords, iconcolor)
	if (not text) then
		self.freeze_icon:Hide()
		return self.freeze_texto:Hide()
	end
	
	self.freeze_texto:SetText (text)
	self.freeze_icon:SetTexture (icon)

	self.freeze_icon:Show()
	self.freeze_texto:Show()
	
	if (textcolor) then
		local r, g, b, a = gump:ParseColors (textcolor)
		self.freeze_texto:SetTextColor (r, g, b, a)
	else
		self.freeze_texto:SetTextColor (1, 1, 1, 1)
	end

	if (icontexture) then
		self.freeze_icon:SetTexture (icontexture)
	else
		self.freeze_icon:SetTexture ([[Interface\CHARACTERFRAME\Disconnect-Icon]])
	end
	
	if (iconcoords and type (iconcoords) == "table") then
		self.freeze_icon:SetTexCoord (_unpack (iconcoords))
	else
		self.freeze_icon:SetTexCoord (0, 1, 0, 1)
	end
	
	if (iconcolor) then
		local r, g, b, a = gump:ParseColors (iconcolor)
		self.freeze_icon:SetVertexColor (r, g, b, a)
	else
		self.freeze_icon:SetVertexColor (1, 1, 1, 1)
	end
end

--> inicio
function gump:CriaJanelaPrincipal (ID, instancia, criando)

	local BaseFrame = _CreateFrame ("ScrollFrame", "DetailsBaseFrame"..ID, _UIParent)
	BaseFrame.instance = instancia
	BaseFrame:SetFrameStrata ("LOW")
	BaseFrame:SetFrameLevel (2)

	local BackGroundFrame =  _CreateFrame ("ScrollFrame", "Details_WindowFrame"..ID, BaseFrame) --> janela principal
	local BackGroundDisplay = _CreateFrame ("Frame", "Details_GumpFrame"..ID, BackGroundFrame) --corpo
	BackGroundFrame:SetFrameLevel (3)
	BackGroundDisplay:SetFrameLevel (3)

	local SwitchButton = gump:NewDetailsButton (BackGroundDisplay, BaseFrame, _, function() end, nil, nil, 1, 1, "", "", "", "", 
	{rightFunc = {func = function() _detalhes.switch:ShowMe (instancia) end, param1 = nil, param2 = nil}})
	
	SwitchButton:SetPoint ("topleft", BackGroundDisplay, "topleft")
	SwitchButton:SetPoint ("bottomright", BackGroundDisplay, "bottomright")
	SwitchButton:SetFrameLevel (BackGroundDisplay:GetFrameLevel()+1)

	local ScrollBar = _CreateFrame ("Slider", "Details_ScrollBar"..ID, BackGroundDisplay) --> scroll

-- textura da scroll bar
-------------------------------------------------------------------------------------------------------------------------------------------------
	--> scroll image-node up
	BaseFrame.scroll_up = BackGroundDisplay:CreateTexture (nil, "BACKGROUND")
	BaseFrame.scroll_up:SetPoint ("TOPLEFT", BackGroundDisplay, "TOPRIGHT", 0, 0)
	BaseFrame.scroll_up:SetTexture (DEFAULT_SKIN)
	BaseFrame.scroll_up:SetTexCoord (unpack (COORDS_SLIDER_TOP))
	BaseFrame.scroll_up:SetWidth (32)
	BaseFrame.scroll_up:SetHeight (32)
	--BaseFrame.scroll_up:SetTexture ("Interface\\AddOns\\Details\\images\\scrollbar")
	--BaseFrame.scroll_up:SetTexCoord (0, 1, 0, 0.25)
	
	--> scroll image-node down
	BaseFrame.scroll_down = BackGroundDisplay:CreateTexture (nil, "BACKGROUND")
	BaseFrame.scroll_down:SetPoint ("BOTTOMLEFT", BackGroundDisplay, "BOTTOMRIGHT", 0, 0)
	BaseFrame.scroll_down:SetTexture (DEFAULT_SKIN)
	BaseFrame.scroll_down:SetTexCoord (unpack (COORDS_SLIDER_DOWN))
	BaseFrame.scroll_down:SetWidth (32)
	BaseFrame.scroll_down:SetHeight (32)
	--BaseFrame.scroll_down:SetTexture ("Interface\\AddOns\\Details\\images\\scrollbar")
	--BaseFrame.scroll_down:SetTexCoord (0, 1, 0.751, 1)
	
	--> scroll image-node middle
	BaseFrame.scroll_middle = BackGroundDisplay:CreateTexture (nil, "BACKGROUND")
	BaseFrame.scroll_middle:SetPoint ("TOP", BaseFrame.scroll_up, "BOTTOM", 0, 8)
	BaseFrame.scroll_middle:SetPoint ("BOTTOM", BaseFrame.scroll_down, "TOP", 0, -11)
	BaseFrame.scroll_middle:SetTexture (DEFAULT_SKIN)
	BaseFrame.scroll_middle:SetTexCoord (unpack (COORDS_SLIDER_MIDDLE))
	BaseFrame.scroll_middle:SetWidth (32)
	BaseFrame.scroll_middle:SetHeight (64)
	--BaseFrame.scroll_middle:SetTexCoord (0, 1, 0.251, 0.75)
	--BaseFrame.scroll_middle:SetTexture ("Interface\\AddOns\\Details\\images\\scrollbar")
	
	--> três botões scroll up, down, window strech
	BaseFrame.button_up = _CreateFrame ("Button", nil, BackGroundDisplay)
	BaseFrame.button_down = _CreateFrame ("Button", nil, BackGroundDisplay)
	BaseFrame.button_stretch = _CreateFrame ("Button", nil, BaseFrame)
	
	BaseFrame.button_stretch:SetPoint ("BOTTOM", BaseFrame, "TOP", 0, 20)
	BaseFrame.button_stretch:SetPoint ("RIGHT", BaseFrame, "RIGHT", -27, 0)
	BaseFrame.button_stretch:SetFrameStrata ("FULLSCREEN")
	
	local stretch_texture = BaseFrame.button_stretch:CreateTexture (nil, "overlay")
	stretch_texture:SetTexture (DEFAULT_SKIN)
	stretch_texture:SetTexCoord (unpack (COORDS_STRETCH))
	stretch_texture:SetWidth (32)
	stretch_texture:SetHeight (16)
	stretch_texture:SetAllPoints (BaseFrame.button_stretch)
	BaseFrame.button_stretch.texture = stretch_texture
	
	BaseFrame.button_stretch:SetWidth (32)
	BaseFrame.button_stretch:SetHeight (16)
	gump:Fade (BaseFrame.button_stretch, -1)
	
	BaseFrame.button_stretch:Show()

	BaseFrame.button_up:SetWidth (29)
	BaseFrame.button_up:SetHeight (32)
	BaseFrame.button_up:SetNormalTexture ("Interface\\BUTTONS\\UI-ScrollBar-ScrollUpButton-Up")
	BaseFrame.button_up:SetPushedTexture ("Interface\\BUTTONS\\UI-ScrollBar-ScrollUpButton-Down")
	BaseFrame.button_up:SetDisabledTexture ("Interface\\BUTTONS\\UI-ScrollBar-ScrollUpButton-Disabled")
	BaseFrame.button_up:Disable()

	BaseFrame.button_down:SetWidth (29)
	BaseFrame.button_down:SetHeight (32)
	BaseFrame.button_down:SetNormalTexture ("Interface\\BUTTONS\\UI-ScrollBar-ScrollDownButton-Up")
	BaseFrame.button_down:SetPushedTexture ("Interface\\BUTTONS\\UI-ScrollBar-ScrollDownButton-Down")
	BaseFrame.button_down:SetDisabledTexture ("Interface\\BUTTONS\\UI-ScrollBar-ScrollDownButton-Disabled")
	BaseFrame.button_down:Disable()

	BaseFrame.button_up:SetPoint ("TOPRIGHT", BaseFrame.scroll_up, "TOPRIGHT", -4, 3)
	BaseFrame.button_down:SetPoint ("BOTTOMRIGHT", BaseFrame.scroll_down, "BOTTOMRIGHT", -4, -6)

	ScrollBar:SetPoint ("TOP", BaseFrame.button_up, "BOTTOM", 0, 12)
	ScrollBar:SetPoint ("BOTTOM", BaseFrame.button_down, "TOP", 0, -12)
	ScrollBar:SetPoint ("LEFT", BackGroundDisplay, "RIGHT", 3, 0)
	ScrollBar:Show()
	
	button_stretch_scripts (BaseFrame, BackGroundDisplay, instancia)
	
	button_down_scripts (BaseFrame, BackGroundDisplay, instancia, ScrollBar)
	button_up_scripts (BaseFrame, BackGroundDisplay, instancia, ScrollBar)

	
--slider
-------------------------------------------------------------------------------------------------------------------------------------------------
	ScrollBar.scrollMax = 0 --default - tamanho da janela de fundo
	
	-- coisinha do meio
	ScrollBar.thumb = ScrollBar:CreateTexture (nil, "OVERLAY")
	ScrollBar.thumb:SetTexture ("Interface\\Buttons\\UI-ScrollBar-Knob")
	ScrollBar.thumb:SetSize (29, 30)
	ScrollBar:SetThumbTexture (ScrollBar.thumb)
	
	ScrollBar:SetOrientation ("VERTICAL")
	ScrollBar:SetMinMaxValues(0, ScrollBar.scrollMax)
	ScrollBar:SetValue(0)
	ScrollBar.ultimo = 0

-- janela principal
-------------------------------------------------------------------------------------------------------------------------------------------------

	BaseFrame:SetClampedToScreen (true)
	BaseFrame:SetClampRectInsets (unpack (_detalhes.window_clamp))
	
	BaseFrame:SetWidth (_detalhes.new_window_size.width)
	BaseFrame:SetHeight (_detalhes.new_window_size.height)
	
	BaseFrame:SetPoint ("CENTER", _UIParent)
	BaseFrame:EnableMouseWheel (false)
	BaseFrame:EnableMouse (true)
	BaseFrame:SetMovable (true)
	BaseFrame:SetResizable (true)
	BaseFrame:SetMinResize (150, 40)
	BaseFrame:SetMaxResize (_detalhes.max_window_size.width, _detalhes.max_window_size.height)

	BaseFrame:SetBackdrop (gump_fundo_backdrop)
	BaseFrame:SetBackdropColor (instancia.bg_r, instancia.bg_g, instancia.bg_b, instancia.bg_alpha)
	
-- fundo
-------------------------------------------------------------------------------------------------------------------------------------------------

	BackGroundFrame:SetAllPoints (BaseFrame)
	BackGroundFrame:SetScrollChild (BackGroundDisplay)
	
	BackGroundDisplay:SetResizable (true)
	BackGroundDisplay:SetPoint ("TOPLEFT", BaseFrame, "TOPLEFT")
	BackGroundDisplay:SetPoint ("BOTTOMRIGHT", BaseFrame, "BOTTOMRIGHT")
	BackGroundDisplay:SetBackdrop (gump_fundo_backdrop)
	BackGroundDisplay:SetBackdropColor (instancia.bg_r, instancia.bg_g, instancia.bg_b, instancia.bg_alpha)
	
-- congelamento da instância
-------------------------------------------------------------------------------------------------------------------------------------------------

	instancia.freeze_icon = BackGroundDisplay:CreateTexture (nil, "OVERLAY")
		instancia.freeze_icon:SetWidth (64)
		instancia.freeze_icon:SetHeight (64)
		instancia.freeze_icon:SetPoint ("center", BackGroundDisplay, "center")
		instancia.freeze_icon:SetPoint ("left", BackGroundDisplay, "left")
		instancia.freeze_icon:Hide()
	
	instancia.freeze_texto = BackGroundDisplay:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
		instancia.freeze_texto:SetHeight (64)
		instancia.freeze_texto:SetPoint ("left", instancia.freeze_icon, "right", -18, 0)
		instancia.freeze_texto:SetTextColor (1, 1, 1)
		instancia.freeze_texto:Hide()

	instancia._version = BaseFrame:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
		instancia._version:SetPoint ("left", BackGroundDisplay, "left", 20, 0)
		instancia._version:SetTextColor (1, 1, 1)
		instancia._version:SetText ("this is a alpha version of Details\nyou can help us sending bug reports\nuse the blue button.")
		if (not _detalhes.initializing) then
			instancia._version:Hide()
		end

	BaseFrame.wallpaper = BackGroundDisplay:CreateTexture (nil, "overlay")
	BaseFrame.wallpaper:Hide()
	
	BaseFrame.alert = CreateAlertFrame (BaseFrame, instancia)
	
--cria os 2 resizers
------------------------------------------------------------------------------------------------------------------------------------------------------------

	BaseFrame.resize_direita = _CreateFrame ("Button", "Details_Resize_Direita"..ID, BaseFrame)
	
	local resize_direita_texture = BaseFrame.resize_direita:CreateTexture (nil, "overlay")
	resize_direita_texture:SetWidth (16)
	resize_direita_texture:SetHeight (16)
	resize_direita_texture:SetTexture (DEFAULT_SKIN)
	resize_direita_texture:SetTexCoord (unpack (COORDS_RESIZE_RIGHT))
	resize_direita_texture:SetAllPoints (BaseFrame.resize_direita)
	BaseFrame.resize_direita.texture = resize_direita_texture

	BaseFrame.resize_direita:SetWidth (16)
	BaseFrame.resize_direita:SetHeight (16)
	BaseFrame.resize_direita:SetPoint ("BOTTOMRIGHT", BaseFrame, "BOTTOMRIGHT", 0, 0)
	BaseFrame.resize_direita:EnableMouse (true)
	BaseFrame.resize_direita:SetFrameLevel (BaseFrame:GetFrameLevel() + 6)
	BaseFrame.resize_direita:SetFrameStrata ("HIGH")
	BaseFrame.resize_direita.side = 2

	--> lock window button
	BaseFrame.lock_button = _CreateFrame ("Button", "Details_Lock_Button"..ID, BaseFrame)
	BaseFrame.lock_button:SetPoint ("right", BaseFrame.resize_direita, "left", -1, 1.5)
	BaseFrame.lock_button:SetFrameLevel (BaseFrame:GetFrameLevel() + 6)
	BaseFrame.lock_button:SetWidth (40)
	BaseFrame.lock_button:SetHeight (16)
	BaseFrame.lock_button.label = BaseFrame.lock_button:CreateFontString (nil, "overlay", "GameFontNormal")
	BaseFrame.lock_button.label:SetPoint ("right", BaseFrame.lock_button, "right")
	BaseFrame.lock_button.label:SetTextColor (.3, .3, .3, .6)
	BaseFrame.lock_button.label:SetJustifyH ("right")
	BaseFrame.lock_button.label:SetText (Loc ["STRING_LOCK_WINDOW"])
	BaseFrame.lock_button:SetWidth (BaseFrame.lock_button.label:GetStringWidth()+2)
	BaseFrame.lock_button:SetScript ("OnClick", lockFunctionOnClick)
	
	--> options window button
	--[[
	BaseFrame.options_button = _CreateFrame ("Button", "Details_Options_Button"..ID, BaseFrame)
	BaseFrame.options_button:SetPoint ("right", BaseFrame.lock_button, "left", -1, 0)
	BaseFrame.options_button:SetFrameLevel (BaseFrame:GetFrameLevel() + 3) --> lower then normal rows
	BaseFrame.options_button:SetWidth (40)
	BaseFrame.options_button:SetHeight (16)
	BaseFrame.options_button.label = BaseFrame.options_button:CreateFontString (nil, "overlay", "GameFontNormal")
	BaseFrame.options_button.label:SetPoint ("right", BaseFrame.options_button, "right")
	BaseFrame.options_button.label:SetTextColor (.3, .3, .3, .4)
	BaseFrame.options_button.label:SetJustifyH ("right")
	BaseFrame.options_button.label:SetText (Loc ["STRING_OPTIONS_WINDOW"])
	--]]
	
	BaseFrame.resize_esquerda = _CreateFrame ("Button", "Details_Resize_Esquerda"..ID, BaseFrame)
	
	local resize_esquerda_texture = BaseFrame.resize_esquerda:CreateTexture (nil, "overlay")
	resize_esquerda_texture:SetWidth (16)
	resize_esquerda_texture:SetHeight (16)
	resize_esquerda_texture:SetTexture (DEFAULT_SKIN)
	resize_esquerda_texture:SetTexCoord (unpack (COORDS_RESIZE_LEFT))
	resize_esquerda_texture:SetAllPoints (BaseFrame.resize_esquerda)
	BaseFrame.resize_esquerda.texture = resize_esquerda_texture
	
	--BaseFrame.resize_esquerda:SetNormalTexture ("Interface\\AddOns\\Details\\images\\ResizeGripL")
	--BaseFrame.resize_esquerda:SetHighlightTexture ("Interface\\AddOns\\Details\\images\\ResizeGripL")
	BaseFrame.resize_esquerda:SetWidth (16)
	BaseFrame.resize_esquerda:SetHeight (16)
	BaseFrame.resize_esquerda:SetPoint ("BOTTOMLEFT", BaseFrame, "BOTTOMLEFT", 0, 0)
	BaseFrame.resize_esquerda:EnableMouse (true)
	BaseFrame.resize_esquerda:SetFrameLevel (BaseFrame:GetFrameLevel() + 6)
	BaseFrame.resize_esquerda:SetFrameStrata ("HIGH")
	
	gump:Fade (BaseFrame.resize_esquerda, "in", 3.0)
	gump:Fade (BaseFrame.resize_direita, "in", 3.0)
	
	if (instancia.isLocked) then
		instancia.isLocked = not instancia.isLocked
		lockFunctionOnClick (BaseFrame.lock_button)
	end
	
	gump:Fade (BaseFrame.lock_button, -1, 3.0)
	
	
------------------------------------------------------------------------------------------------------------------------------------------------------------

--seta os scripts dos frames
------------------------------------------------------------------------------------------------------------------------------------------------------------

	
	
	BFrame_scripts (BaseFrame, instancia)
	
	--BackGroundDisplay_scripts (BackGroundDisplay, BaseFrame, instancia)
	
	BGFrame_scripts (SwitchButton, BaseFrame, instancia)
	BGFrame_scripts (BackGroundDisplay, BaseFrame, instancia)
	--BGFrame_scripts (BackGroundFrame, BaseFrame, instancia)
	
	iterate_scroll_scripts (BackGroundDisplay, BackGroundFrame, BaseFrame, ScrollBar, instancia)
	
------------------------------------------------------------------------------------------------------------------------------------------------------------	

--chama função para criar o cabeçalho
------------------------------------------------------------------------------------------------------------------------------------------------------------

	gump:CriaCabecalho (BaseFrame, instancia)

	
-- cria as duas barras laterais
------------------------------------------------------------------------------------------------------------------------------------------------------------
	--> barra borda direita lateral
	
	--> barra borda esquerda lateral
		BaseFrame.barra_esquerda = BaseFrame.cabecalho.fechar:CreateTexture (nil, "ARTWORK")
		--BaseFrame.barra_esquerda:SetTexture ("Interface\\AddOns\\Details\\images\\bar_main_leftright")
		--BaseFrame.barra_esquerda:SetTexCoord (0.5, 1, 0, 1)
		BaseFrame.barra_esquerda:SetTexture (DEFAULT_SKIN)
		BaseFrame.barra_esquerda:SetTexCoord (unpack (COORDS_LEFT_SIDE_BAR))
		BaseFrame.barra_esquerda:SetWidth (64)
		BaseFrame.barra_esquerda:SetHeight	(512)
		BaseFrame.barra_esquerda:SetPoint ("TOPLEFT", BaseFrame, "TOPLEFT", -56, 0)
		BaseFrame.barra_esquerda:SetPoint ("BOTTOMLEFT", BaseFrame, "BOTTOMLEFT", -56, -14)
		
		BaseFrame.barra_direita = BaseFrame.cabecalho.fechar:CreateTexture (nil, "ARTWORK")
		--BaseFrame.barra_direita:SetTexture ("Interface\\AddOns\\Details\\images\\bar_main_leftright")
		--BaseFrame.barra_direita:SetTexCoord (0, 0.5, 0, 1)
		BaseFrame.barra_direita:SetTexture (DEFAULT_SKIN)
		BaseFrame.barra_direita:SetTexCoord (unpack (COORDS_RIGHT_SIDE_BAR))
		BaseFrame.barra_direita:SetWidth (64)
		BaseFrame.barra_direita:SetHeight (512)
		BaseFrame.barra_direita:SetPoint ("TOPRIGHT", BaseFrame, "TOPRIGHT", 56, 0)
		BaseFrame.barra_direita:SetPoint ("BOTTOMRIGHT", BaseFrame, "BOTTOMRIGHT", 56, -14)
		
		
--chama função para criar o rodapé
------------------------------------------------------------------------------------------------------------------------------------------------------------		

	gump:CriaRodape (BaseFrame, instancia)
		
------------------------------------------------------------------------------------------------------------------------------------------------------------

-- BETA -- botão de separar as instâncias que estão agrupadas
	instancia.botao_separar = gump:NewDetailsButton (BaseFrame.cabecalho.fechar, _, instancia, instancia.Desagrupar, instancia, -1, 13, 13)
	instancia.botao_separar:SetPoint ("BOTTOM", BaseFrame.resize_direita, "TOP", -1, 0)
	instancia.botao_separar:SetFrameLevel (BaseFrame:GetFrameLevel() + 5)
	
	local cadeado_texture = instancia.botao_separar:CreateTexture (nil, "overlay")
	cadeado_texture:SetTexture (DEFAULT_SKIN)
	cadeado_texture:SetTexCoord (unpack (COORDS_UNLOCK_BUTTON))
	cadeado_texture:SetAllPoints (instancia.botao_separar)
	instancia.botao_separar.texture = cadeado_texture
	BaseFrame.unlock_texture = cadeado_texture
	
	gump:Fade (instancia.botao_separar, "in", 3.0)
	
	resize_scripts (BaseFrame.resize_direita, instancia, ScrollBar, ">", BaseFrame)
	resize_scripts (BaseFrame.resize_esquerda, instancia, ScrollBar, "<", BaseFrame)
	lock_button_scripts (BaseFrame.lock_button, instancia)
	
	bota_separar_script (instancia.botao_separar, instancia)
	
--------------------------------- BORDAS HIGHLIGHT
	local fcima = CreateFrame ("frame", nil, BaseFrame.cabecalho.fechar)
	fcima:SetPoint ("topleft", BaseFrame.cabecalho.top_bg, "bottomleft", -10, 37)
	fcima:SetPoint ("topright", BaseFrame.cabecalho.ball_r, "bottomright", -33, 37)
	gump:CreateFlashAnimation (fcima)
	fcima:Hide()
	
	instancia.h_cima = fcima:CreateTexture (nil, "OVERLAY")
	instancia.h_cima:SetTexture ("Interface\\AddOns\\Details\\images\\highlight_updown")
	instancia.h_cima:SetTexCoord (0, 1, 0.5, 1)
	instancia.h_cima:SetPoint ("topleft", BaseFrame.cabecalho.top_bg, "bottomleft", -10, 37)
	--instancia.h_cima:SetPoint ("topright", BaseFrame.cabecalho.ball_r, "bottomright", -33, 37)
	instancia.h_cima:SetPoint ("topright", BaseFrame.cabecalho.ball_r, "bottomright", -97, 37)
	--instancia.h_cima:Hide()
	instancia.h_cima = fcima
	--
	local fbaixo = CreateFrame ("frame", nil, BaseFrame.cabecalho.fechar)
	fbaixo:SetPoint ("topleft", BaseFrame.rodape.esquerdo, "bottomleft", 16, 17)
	fbaixo:SetPoint ("topright", BaseFrame.rodape.direita, "bottomright", -16, 17)
	gump:CreateFlashAnimation (fbaixo)
	fbaixo:Hide()
	
	instancia.h_baixo = fbaixo:CreateTexture (nil, "OVERLAY")
	instancia.h_baixo:SetTexture ("Interface\\AddOns\\Details\\images\\highlight_updown")
	instancia.h_baixo:SetTexCoord (0, 1, 0, 0.5)
	instancia.h_baixo:SetPoint ("topleft", BaseFrame.rodape.esquerdo, "bottomleft", 16, 17)
	instancia.h_baixo:SetPoint ("topright", BaseFrame.rodape.direita, "bottomright", -16, 17)
	--instancia.h_baixo:Hide()
	instancia.h_baixo = fbaixo
	--
	local fesquerda = CreateFrame ("frame", nil, BaseFrame.cabecalho.fechar)
	fesquerda:SetPoint ("topleft", BaseFrame.barra_esquerda, "topleft", -8, 0)
	fesquerda:SetPoint ("bottomleft", BaseFrame.barra_esquerda, "bottomleft", -8, 0)
	gump:CreateFlashAnimation (fesquerda)
	fesquerda:Hide()
	
	instancia.h_esquerda = fesquerda:CreateTexture (nil, "OVERLAY")
	instancia.h_esquerda:SetTexture ("Interface\\AddOns\\Details\\images\\highlight_leftright")
	instancia.h_esquerda:SetTexCoord (0.5, 1, 0, 1)
	instancia.h_esquerda:SetPoint ("topleft", BaseFrame.barra_esquerda, "topleft", 40, 0)
	instancia.h_esquerda:SetPoint ("bottomleft", BaseFrame.barra_esquerda, "bottomleft", 40, 0)
	--instancia.h_esquerda:Hide()
	instancia.h_esquerda = fesquerda
	--
	local fdireita = CreateFrame ("frame", nil, BaseFrame.cabecalho.fechar)
	fdireita:SetPoint ("topleft", BaseFrame.barra_direita, "topleft", 8, 18)
	fdireita:SetPoint ("bottomleft", BaseFrame.barra_direita, "bottomleft", 8, 0)
	gump:CreateFlashAnimation (fdireita)	
	fdireita:Hide()
	
	instancia.h_direita = fdireita:CreateTexture (nil, "OVERLAY")
	instancia.h_direita:SetTexture ("Interface\\AddOns\\Details\\images\\highlight_leftright")
	instancia.h_direita:SetTexCoord (0, 0.5, 1, 0)
	instancia.h_direita:SetPoint ("topleft", BaseFrame.barra_direita, "topleft", 8, 18)
	instancia.h_direita:SetPoint ("bottomleft", BaseFrame.barra_direita, "bottomleft", 8, 0)
	--instancia.h_direita:Hide()
	instancia.h_direita = fdireita

	--instancia.botao_separar:Hide()

	if (criando) then
		local CProps = {
			["altura"] = 100,
			["largura"] = 200,
			["barras"] = 50,
			["barrasvisiveis"] = 0,
			["x"] = 0,
			["y"] = 0,
			["w"] = 0,
			["h"] = 0
		}
		instancia.locs = CProps
	end

	return BaseFrame, BackGroundFrame, BackGroundDisplay, ScrollBar
	
end

--> Alias
function gump:NewRow (instancia, index)
	return gump:CriaNovaBarra (instancia, index)
end
--> search key: ~row ~barra
function gump:CriaNovaBarra (instancia, index)

	local BaseFrame = instancia.baseframe
	local esta_barra = _CreateFrame ("Button", "DetailsBarra_"..instancia.meu_id.."_"..index, BaseFrame)
	esta_barra.row_id = index
	local y = instancia.barrasInfo.alturaReal*(index-1)

	y = y*-1
	
	esta_barra:SetPoint ("TOPLEFT", BaseFrame, "TOPLEFT", instancia.barrasInfo.espaco.esquerda, y)
	
	esta_barra:SetHeight (instancia.barrasInfo.altura) --> altura determinada pela instância
	esta_barra:SetWidth (BaseFrame:GetWidth()+instancia.barrasInfo.espaco.direita)

	esta_barra:SetFrameLevel (BaseFrame:GetFrameLevel() + 4)

	esta_barra.last_value = 0
	esta_barra.w_mod = 0

	esta_barra:EnableMouse (true)
	esta_barra:RegisterForClicks ("LeftButtonDown", "RightButtonDown")

	esta_barra.statusbar = _CreateFrame ("StatusBar", nil, esta_barra)
	esta_barra.statusbar:SetAllPoints (esta_barra)
	
	esta_barra.textura = esta_barra.statusbar:CreateTexture (nil, "ARTWORK")
	esta_barra.textura:SetHorizTile (false)
	esta_barra.textura:SetVertTile (false)
	esta_barra.textura:SetTexture (instancia.barrasInfo.textura)
	
	esta_barra.background = esta_barra:CreateTexture (nil, "BACKGROUND")
	esta_barra.background:SetTexture()
	esta_barra.background:SetAllPoints (esta_barra)

	esta_barra.statusbar:SetStatusBarColor (0, 0, 0, 0)
	esta_barra.statusbar:SetStatusBarTexture (esta_barra.textura)
	
	esta_barra.statusbar:SetMinMaxValues (0, 100)
	esta_barra.statusbar:SetValue (100)

	local icone_classe = esta_barra.statusbar:CreateTexture (nil, "OVERLAY")
	icone_classe:SetPoint ("left", esta_barra.statusbar, "left")
	icone_classe:SetHeight (instancia.barrasInfo.altura)
	icone_classe:SetWidth (instancia.barrasInfo.altura)
	icone_classe:SetTexture ("Interface\\AddOns\\Details\\images\\classes_small")
	icone_classe:SetTexCoord (.75, 1, .75, 1)
	esta_barra.icone_classe = icone_classe

	esta_barra.texto_esquerdo = esta_barra.statusbar:CreateFontString (nil, "OVERLAY", "GameFontHighlight")

	esta_barra.texto_esquerdo:SetPoint ("LEFT", esta_barra.icone_classe, "right", 3, 0)
	esta_barra.texto_esquerdo:SetJustifyH ("LEFT")
	esta_barra.texto_esquerdo:SetNonSpaceWrap (true)

	local icone_terceiro = esta_barra.statusbar:CreateTexture (nil, "OVERLAY")
	icone_terceiro:SetPoint ("left", esta_barra.statusbar, "left", 2, 0)
	icone_terceiro:SetHeight (instancia.barrasInfo.altura)
	icone_terceiro:SetWidth (instancia.barrasInfo.altura)
	esta_barra.icone_terceiro = icone_terceiro
	esta_barra.icone_terceiro:Hide()	

	esta_barra.texto_direita = esta_barra.statusbar:CreateFontString (nil, "OVERLAY", "GameFontHighlight")

	esta_barra.texto_direita:SetPoint ("RIGHT", esta_barra.statusbar, "RIGHT")
	esta_barra.texto_direita:SetJustifyH ("RIGHT")
	
	instancia:SetFontSize (esta_barra.texto_esquerdo, instancia.barrasInfo.fontSize)
	instancia:SetFontFace (esta_barra.texto_esquerdo, instancia.barrasInfo.font)
	_detalhes.font_pool:add (esta_barra.texto_esquerdo)
	
	instancia:SetFontSize (esta_barra.texto_direita, instancia.barrasInfo.fontSize)
	instancia:SetFontFace (esta_barra.texto_direita, instancia.barrasInfo.font)
	_detalhes.font_pool:add (esta_barra.texto_direita)
	
	if (instancia.row_textL_outline) then
		instancia:SetFontOutline (esta_barra.texto_esquerdo, instancia.row_textL_outline)
	end
	if (instancia.row_textR_outline) then
		instancia:SetFontOutline (esta_barra.texto_direita, instancia.row_textR_outline)
	end
	
	if (not instancia.row_texture_class_colors) then
		esta_barra.textura:SetVertexColor (_unpack (instancia.fixed_row_texture_color))
	end
	
	if (not instancia.row_textL_class_colors) then
		esta_barra.texto_esquerdo:SetTextColor (_unpack (instancia.fixed_row_text_color))
	end
	if (not instancia.row_textR_class_colors) then
		esta_barra.texto_direita:SetTextColor (_unpack (instancia.fixed_row_text_color))
	end

	--> inicia os scripts da barra
	barra_scripts (esta_barra, instancia, index)
	
	gump:Fade (esta_barra, 1) --> hida a barra
	
	return esta_barra
end

function _detalhes:InstanceRefreshRows (instancia)
	if (instancia) then
		self = instancia
	end
	
	--outline
	local L_outline = self.row_textL_outline
	local R_outline = self.row_textR_outline
	--texture color
	local textureClassColor = self.row_texture_class_colors
	local texture_r, texture_g, texture_b
	if (not textureClassColor) then
		texture_r, texture_g, texture_b = _unpack (self.fixed_row_texture_color)
	end
	--text color
	local leftTextClassColor = self.row_textL_class_colors
	local rightTextClassColor = self.row_textR_class_colors
	local text_r, text_g, text_b
	if (not leftTextClassColor or not rightTextClassColor) then
		text_r, text_g, text_b = _unpack (self.fixed_row_text_color)
	end

	for _, row in _ipairs (self.barras) do 
		
		if (L_outline) then
			self:SetFontOutline (row.texto_esquerdo, L_outline)
		else
			self:SetFontOutline (row.texto_esquerdo, nil)
		end
		if (R_outline) then
			self:SetFontOutline (row.texto_direita, R_outline)
		else
			self:SetFontOutline (row.texto_direita, nil)
		end
		--
		if (not textureClassColor) then
			row.textura:SetVertexColor (texture_r, texture_g, texture_b)
		end
		--
		if (not leftTextClassColor) then
			row.texto_esquerdo:SetTextColor (text_r, text_g, text_b)
		end
		if (not rightTextClassColor) then
			row.texto_direita:SetTextColor (text_r, text_g, text_b)
		end
	end
end

-- search key: ~wallpaper
function _detalhes:InstanceWallpaper (texture, anchor, alpha, texcoord, width, height, overlay)

	local wallpaper = self.wallpaper
	
	if (type (texture) == "boolean" and texture) then
		texture, anchor, alpha, texcoord, width, height, overlay = wallpaper.texture, wallpaper.anchor, wallpaper.alpha, wallpaper.texcoord, wallpaper.width, wallpaper.height, wallpaper.overlay
		
	elseif (type (texture) == "boolean" and not texture) then
		self.wallpaper.enabled = false
		return gump:Fade (self.baseframe.wallpaper, "in")
		
	elseif (type (texture) == "table") then
		anchor = texture.anchor or wallpaper.anchor
		alpha = texture.alpha or wallpaper.alpha
		if (texture.texcoord) then
			texcoord = {unpack (texture.texcoord)}
		else
			texcoord = wallpaper.texcoord
		end
		width = texture.width or wallpaper.width
		height = texture.height or wallpaper.height
		if (texture.overlay) then
			overlay = {unpack (texture.overlay)}
		else
			overlay = wallpaper.overlay
		end
		
		if (type (texture.enabled) == "boolean") then
			if (not texture.enabled) then
				wallpaper.enabled = false
				wallpaper.texture = texture.texture or wallpaper.texture
				wallpaper.anchor = anchor
				wallpaper.alpha = alpha
				wallpaper.texcoord = texcoord
				wallpaper.width = width
				wallpaper.height = height
				wallpaper.overlay = overlay
				return self:InstanceWallpaper (false)
			end
		end
		
		texture = texture.texture or wallpaper.texture

	else
		texture = texture or wallpaper.texture
		anchor = anchor or wallpaper.anchor
		alpha = alpha or wallpaper.alpha
		texcoord = texcoord or wallpaper.texcoord
		width = width or wallpaper.width
		height = height or wallpaper.height
		overlay = overlay or wallpaper.overlay
	end
	
	if (not wallpaper.texture and not texture) then
		local spec = GetSpecialization()
		if (spec) then
			local _, _, _, _, _background = GetSpecializationInfo (spec)
			if (_background) then
				texture = "Interface\\TALENTFRAME\\".._background
			end
		end
		
		texcoord = {0, 1, 0, 0.7}
		alpha = 0.5
		width, height = self:GetSize()
		anchor = "all"
	end
	
	local t = self.baseframe.wallpaper

	t:ClearAllPoints()
	
	if (anchor == "all") then
		t:SetPoint ("topleft", self.baseframe, "topleft")
		t:SetPoint ("bottomright", self.baseframe, "bottomright")
	elseif (anchor == "center") then
		t:SetPoint ("center", self.baseframe, "center", 0, 4)
	elseif (anchor == "stretchLR") then
		t:SetPoint ("center", self.baseframe, "center")
		t:SetPoint ("left", self.baseframe, "left")
		t:SetPoint ("right", self.baseframe, "right")
	elseif (anchor == "stretchTB") then
		t:SetPoint ("center", self.baseframe, "center")
		t:SetPoint ("top", self.baseframe, "top")
		t:SetPoint ("bottom", self.baseframe, "bottom")
	else
		t:SetPoint (anchor, self.baseframe, anchor)
	end
	
	t:SetTexture (texture)
	t:SetAlpha (alpha)
	t:SetTexCoord (unpack (texcoord))
	t:SetWidth (width)
	t:SetHeight (height)
	t:SetVertexColor (unpack (overlay))
	
	wallpaper.enabled = true
	wallpaper.texture = texture
	wallpaper.anchor = anchor
	wallpaper.alpha = alpha
	wallpaper.texcoord = texcoord
	wallpaper.width = width
	wallpaper.height = height
	wallpaper.overlay = overlay

	if (t.faded) then
		gump:Fade (t, "out")
	else
		gump:Fade (t, "AlphaAnim", alpha)
	end
end


function _detalhes:InstanceColor (red, green, blue, alpha)
	if (type (red) ~= "number") then
		red, green, blue, alpha = gump:ParseColors (red)
	end

	local skin = _detalhes.skins [self.skin]
	
	self.baseframe.rodape.esquerdo:SetVertexColor (red, green, blue)
		self.baseframe.rodape.esquerdo:SetAlpha (alpha)
	self.baseframe.rodape.direita:SetVertexColor (red, green, blue)
		self.baseframe.rodape.direita:SetAlpha (alpha)
	self.baseframe.rodape.top_bg:SetVertexColor (red, green, blue)
		self.baseframe.rodape.top_bg:SetAlpha (alpha)
	
	self.baseframe.cabecalho.ball_r:SetVertexColor (red, green, blue)
		self.baseframe.cabecalho.ball_r:SetAlpha (alpha)
	self.baseframe.cabecalho.ball:SetVertexColor (red, green, blue)
		if (skin.can_change_alpha_head) then
			self.baseframe.cabecalho.ball:SetAlpha (alpha)
		end
	self.baseframe.cabecalho.emenda:SetVertexColor (red, green, blue)
		self.baseframe.cabecalho.emenda:SetAlpha (alpha)
	self.baseframe.cabecalho.top_bg:SetVertexColor (red, green, blue)
		self.baseframe.cabecalho.top_bg:SetAlpha (alpha)

	self.baseframe.barra_esquerda:SetVertexColor (red, green, blue)
		self.baseframe.barra_esquerda:SetAlpha (alpha)
	self.baseframe.barra_direita:SetVertexColor (red, green, blue)
		self.baseframe.barra_direita:SetAlpha (alpha)
		
	self.color[1], self.color[2], self.color[3], self.color[4] = red, green, blue, alpha
end

function _detalhes:StatusBarAlertTime (instance)
	instance.baseframe.statusbar:Hide()
end

function _detalhes:StatusBarAlert (text, icon, color, time)

	local statusbar = self.baseframe.statusbar
	
	if (text) then
		if (type (text) == "table") then
			if (text.color) then
				statusbar.text:SetTextColor (gump:ParseColors (text.color))
			else
				statusbar.text:SetTextColor (1, 1, 1, 1)
			end
			
			statusbar.text:SetText (text.text or "")
			
			if (text.size) then
				_detalhes:SetFontSize (statusbar.text, text.size)
			else
				_detalhes:SetFontSize (statusbar.text, 9)
			end
		else
			statusbar.text:SetText (text)
			statusbar.text:SetTextColor (1, 1, 1, 1)
			_detalhes:SetFontSize (statusbar.text, 9)
		end
	else
		statusbar.text:SetText ("")
	end
	
	if (icon) then
		if (type (icon) == "table") then
			local texture, w, h, l, r, t, b = unpack (icon)
			statusbar.icon:SetTexture (texture)
			statusbar.icon:SetWidth (w or 14)
			statusbar.icon:SetHeight (h or 14)
			if (l and r and t and b) then
				statusbar.icon:SetTexCoord (l, r, t, b)
			end
		else
			statusbar.icon:SetTexture (icon)
			statusbar.icon:SetWidth (14)
			statusbar.icon:SetHeight (14)
			statusbar.icon:SetTexCoord (0, 1, 0, 1)
		end
	else
		statusbar.icon:SetTexture (nil)
	end
	
	if (color) then
		statusbar:SetBackdropColor (gump:ParseColors (color))
	else
		statusbar:SetBackdropColor (0, 0, 0, 1)
	end
	
	if (icon or text) then
		statusbar:Show()
		if (time) then
			_detalhes:ScheduleTimer ("StatusBarAlertTime", time, self)
		end
	else
		statusbar:Hide()
	end
end

function gump:CriaRodape (BaseFrame, instancia)

	BaseFrame.rodape = {}
	
	--> esquerdo
	BaseFrame.rodape.esquerdo = BaseFrame.cabecalho.fechar:CreateTexture (nil, "OVERLAY")
	BaseFrame.rodape.esquerdo:SetPoint ("TOPRIGHT", BaseFrame, "BOTTOMLEFT", 16, 0)
	BaseFrame.rodape.esquerdo:SetTexture (DEFAULT_SKIN)
	BaseFrame.rodape.esquerdo:SetTexCoord (unpack (COORDS_PIN_LEFT))
	BaseFrame.rodape.esquerdo:SetWidth (32)
	BaseFrame.rodape.esquerdo:SetHeight (32)
	--BaseFrame.rodape.esquerdo:SetTexture ("Interface\\AddOns\\Details\\images\\bar_down_left")
	
	--> direito
	BaseFrame.rodape.direita = BaseFrame.cabecalho.fechar:CreateTexture (nil, "OVERLAY")
	BaseFrame.rodape.direita:SetPoint ("TOPLEFT", BaseFrame, "BOTTOMRIGHT", -16, 0)
	BaseFrame.rodape.direita:SetTexture (DEFAULT_SKIN)
	BaseFrame.rodape.direita:SetTexCoord (unpack (COORDS_PIN_RIGHT))
	BaseFrame.rodape.direita:SetWidth (32)
	BaseFrame.rodape.direita:SetHeight (32)
	--BaseFrame.rodape.direita:SetTexture ("Interface\\AddOns\\Details\\images\\bar_down_right")
	
	--> barra centro
	BaseFrame.rodape.top_bg = BaseFrame:CreateTexture (nil, "BACKGROUND")
	BaseFrame.rodape.top_bg:SetTexture (DEFAULT_SKIN)
	BaseFrame.rodape.top_bg:SetTexCoord (unpack (COORDS_BOTTOM_BACKGROUND))
	BaseFrame.rodape.top_bg:SetWidth (512)
	BaseFrame.rodape.top_bg:SetHeight (128)
	BaseFrame.rodape.top_bg:SetPoint ("LEFT", BaseFrame.rodape.esquerdo, "RIGHT", -16, -48)
	BaseFrame.rodape.top_bg:SetPoint ("RIGHT", BaseFrame.rodape.direita, "LEFT", 16, -48)

	local StatusBarLeftAnchor = CreateFrame ("frame", nil, BaseFrame)
	StatusBarLeftAnchor:SetPoint ("left", BaseFrame.rodape.top_bg, "left", 5, 57)
	StatusBarLeftAnchor:SetWidth (1)
	StatusBarLeftAnchor:SetHeight (1)
	BaseFrame.rodape.StatusBarLeftAnchor = StatusBarLeftAnchor
	
	local StatusBarCenterAnchor = CreateFrame ("frame", nil, BaseFrame)
	StatusBarCenterAnchor:SetPoint ("center", BaseFrame.rodape.top_bg, "center", 0, 57)
	StatusBarCenterAnchor:SetWidth (1)
	StatusBarCenterAnchor:SetHeight (1)
	
	BaseFrame.rodape.StatusBarCenterAnchor = StatusBarCenterAnchor
	
	--> display frame
		BaseFrame.statusbar = CreateFrame ("frame", nil, BaseFrame.cabecalho.fechar)
		BaseFrame.statusbar:SetFrameLevel (BaseFrame.cabecalho.fechar:GetFrameLevel()+2)
		BaseFrame.statusbar:SetPoint ("LEFT", BaseFrame.rodape.esquerdo, "RIGHT", -13, 10)
		BaseFrame.statusbar:SetPoint ("RIGHT", BaseFrame.rodape.direita, "LEFT", 13, 10)
		BaseFrame.statusbar:SetHeight (14)
		
		local statusbar_icon = BaseFrame.statusbar:CreateTexture (nil, "overlay")
		statusbar_icon:SetWidth (14)
		statusbar_icon:SetHeight (14)
		statusbar_icon:SetPoint ("left", BaseFrame.statusbar, "left")
		
		local statusbar_text = BaseFrame.statusbar:CreateFontString (nil, "overlay", "GameFontNormal")
		statusbar_text:SetPoint ("left", statusbar_icon, "right", 2, 0)
		
		BaseFrame.statusbar:SetBackdrop ({
		bgFile = "Interface\\AddOns\\Details\\images\\background", tile = true, tileSize = 16,
		insets = {left = 0, right = 0, top = 0, bottom = 0}})
		BaseFrame.statusbar:SetBackdropColor (0, 0, 0, 1)
		
		BaseFrame.statusbar.icon = statusbar_icon
		BaseFrame.statusbar.text = statusbar_text
		BaseFrame.statusbar.instancia = instancia
		
		BaseFrame.statusbar:Hide()
	
	--> frame invisível
	BaseFrame.DOWNFrame = CreateFrame ("frame", nil, BaseFrame)
	BaseFrame.DOWNFrame:SetPoint ("LEFT", BaseFrame.rodape.esquerdo, "RIGHT", 0, 10)
	BaseFrame.DOWNFrame:SetPoint ("RIGHT", BaseFrame.rodape.direita, "LEFT", 0, 10)
	BaseFrame.DOWNFrame:SetHeight (14)
	
	BaseFrame.DOWNFrame:Show()
	BaseFrame.DOWNFrame:EnableMouse (true)
	BaseFrame.DOWNFrame:SetMovable (true)
	BaseFrame.DOWNFrame:SetResizable (true)
	
	BGFrame_scripts (BaseFrame.DOWNFrame, BaseFrame, instancia)
end

function _detalhes:CheckConsolidates()
	for meu_id, instancia in ipairs (_detalhes.tabela_instancias) do 
		if (instancia.consolidate and meu_id ~= _detalhes.lower_instance) then
			instancia:UnConsolidateIcons()
		end
	end
end

function _detalhes:ConsolidateIcons()
	self.consolidate = true
	self.consolidateButton:Show()
	return self:DefaultIcons()
end

function _detalhes:UnConsolidateIcons()
	self.consolidate = false
	if (not self.consolidateButton) then
		return self:DefaultIcons()
	end
	self.consolidateButton:Hide()
	return self:DefaultIcons()
end

function _detalhes:DefaultIcons (_mode, _segment, _attributes, _report)

	if (_mode == nil) then
		_mode = self.icons[1]
	end
	if (_segment == nil) then
		_segment = self.icons[2]
	end
	if (_attributes == nil) then
		_attributes = self.icons[3]
	end
	if (_report == nil) then
		_report = self.icons[4]
	end	
	
	if (self.consolidate and not self.consolidateButton:IsShown()) then
		self.consolidateButton:Show()
	elseif (not self.consolidate and self.consolidateButton:IsShown()) then
		self.consolidateButton:Hide()
	end

	local baseToolbar = self.baseframe.cabecalho
	local icons = {baseToolbar.modo_selecao, baseToolbar.segmento, baseToolbar.atributo, baseToolbar.report}
	local options = {_mode, _segment, _attributes, _report}
	local anchors = {{0, 0}, {0, 0}, {0, 0}, {-6, 0}}
	
	for index = 1, #icons do
		if (type (options[index]) == "boolean") then
			if (options[index]) then
				icons [index]:Show()
				self.icons[index] = true
			else
				icons [index]:Hide()
				self.icons[index] = false
			end
		end
	end

	local _gotFirst = false
	for index = 1, #icons do 
		local _thisIcon = icons [index]
		if (_thisIcon:IsShown()) then
			if (not _gotFirst) then
				
				_thisIcon:ClearAllPoints()
				if (self.consolidate) then
					_thisIcon:SetPoint ("TOPLEFT", self.consolidateFrame, "TOPLEFT", -3, -5)
					_thisIcon:SetParent (self.consolidateFrame)
				else
					_thisIcon:SetPoint ("BOTTOMLEFT", baseToolbar.ball, "BOTTOMRIGHT", 6 + anchors[index][1], 2 + anchors[index][2])
					_thisIcon:SetParent (self.baseframe)
					_thisIcon:SetFrameLevel (self.baseframe.UPFrame:GetFrameLevel()+1)
				end
				
				_gotFirst = true
			else
				for dex = index-1, 1, -1 do
					local _thisIcon2 = icons [dex]
					if (_thisIcon2:IsShown()) then
						_thisIcon:ClearAllPoints()
						if (self.consolidate) then
							_thisIcon:SetPoint ("topleft", _thisIcon2.widget or _thisIcon2, "bottomleft", anchors[index][1], anchors[index][2]-2)
							_thisIcon:SetParent (self.consolidateFrame)
						else
							_thisIcon:SetPoint ("left", _thisIcon2.widget or _thisIcon2, "right", 0 + anchors[index][1], 0 + anchors[index][2])
							_thisIcon:SetParent (self.baseframe)
							_thisIcon:SetFrameLevel (self.baseframe.UPFrame:GetFrameLevel()+1)
						end
						break
					end
				end
			end
		end
	end
	
	for index = #icons, 1, -1 do 
		if (icons [index]:IsShown()) then
			self.lastIcon = icons [index]
			break
		end
	end
	
	if (not self.lastIcon) then
		self.lastIcon = baseToolbar.ball
	end
	
	_detalhes.ToolBar:ReorganizeIcons() --> aqui 2553

	return true
end

local parameters_table = {}

local on_leave_menu = function (self, elapsed)
	parameters_table[2] = parameters_table[2] + elapsed
	if (parameters_table[2] > 0.3) then
		if (not _detalhes.popup.mouseOver and not _detalhes.popup.buttonOver) then
			_detalhes.popup:ShowMe (false)
		end
		self:SetScript ("OnUpdate", nil)
	end
end

local build_mode_list = function (self, elapsed)

	local CoolTip = GameCooltip
	local instancia = parameters_table [1]
	parameters_table[2] = parameters_table[2] + elapsed
	
	if (parameters_table[2] > 0.15) then
		self:SetScript ("OnUpdate", nil)
		
		CoolTip:Reset()
		CoolTip:SetType ("menu")
		CoolTip:AddFromTable (parameters_table [4])
		CoolTip:SetLastSelected ("main", parameters_table [3])
		CoolTip:SetFixedParameter (instancia)
		CoolTip:SetColor ("main", "transparent")
		
		CoolTip:SetOption ("TextSize", _detalhes.font_sizes.menus)
		CoolTip:SetOption ("ButtonHeightMod", -5)
		CoolTip:SetOption ("ButtonsYMod", -5)
		CoolTip:SetOption ("YSpacingMod", 1)
		CoolTip:SetOption ("FixedHeight", 106)
		--CoolTip:SetOption ("FixedWidth", 138)
		CoolTip:SetOption ("FixedWidthSub", 146)
		CoolTip:SetOption ("SubMenuIsTooltip", true)
		
		if (_detalhes.tutorial.main_help_button > 9) then
			CoolTip:SetOption ("IgnoreSubMenu", true)
		end
		
		if (instancia.consolidate) then
			CoolTip:SetOwner (self, "topleft", "topright", 3)
		else
			CoolTip:SetOwner (self)
		end
		CoolTip:ShowCooltip()
	end
end

local segments_used = 0
local segments_filled = 0
local empty_segment_color = {1, 1, 1, .4}

-- search key: ~segments
local build_segment_list = function (self, elapsed)

	local CoolTip = GameCooltip
	local instancia = parameters_table [1]
	parameters_table[2] = parameters_table[2] + elapsed
	
	if (parameters_table[2] > 0.15) then
		self:SetScript ("OnUpdate", nil)
	
		--> here we are using normal Add calls
		CoolTip:Reset()
		CoolTip:SetType ("menu")
		CoolTip:SetFixedParameter (instancia)
		CoolTip:SetColor ("main", "transparent")

		----------- segments
		local menuIndex = 0
		_detalhes.segments_amount = math.floor (_detalhes.segments_amount)
		
		local fight_amount = 0
		
		local filled_segments = 0
		for i = 1, _detalhes.segments_amount do
			if (_detalhes.tabela_historico.tabelas [i]) then
				filled_segments = filled_segments + 1
			else
				break
			end
		end

		filled_segments = _detalhes.segments_amount - filled_segments - 2
		local fill = math.abs (filled_segments - _detalhes.segments_amount)
		segments_used = 0
		segments_filled = fill
		
		for i = _detalhes.segments_amount, 1, -1 do
			
			if (i <= fill) then

				local thisCombat = _detalhes.tabela_historico.tabelas [i]
				if (thisCombat) then
					local enemy = thisCombat.is_boss and thisCombat.is_boss.name
					segments_used = segments_used + 1

					if (thisCombat.is_boss and thisCombat.is_boss.name) then
					
						if (thisCombat.is_boss.killed) then
							CoolTip:AddLine (thisCombat.is_boss.name .." (#"..i..")", _, 1, "lime")
						else
							CoolTip:AddLine (thisCombat.is_boss.name .." (#"..i..")", _, 1, "red")
						end
						
						local portrait = _detalhes:GetBossPortrait (thisCombat.is_boss.mapid, thisCombat.is_boss.index)
						if (portrait) then
							CoolTip:AddIcon (portrait, 2, "top", 128, 64)
						end
						CoolTip:AddIcon ([[Interface\AddOns\Details\images\icons]], "main", "left", 16, 16, 0.96875, 1, 0, 0.03125)
					else
						enemy = thisCombat.enemy
						if (enemy) then
							CoolTip:AddLine (thisCombat.enemy .." (#"..i..")", _, 1, "yellow")
						else
							CoolTip:AddLine (segmentos.past..i, _, 1, "silver")
						end
						
						if (thisCombat.is_trash) then
							CoolTip:AddIcon ([[Interface\AddOns\Details\images\icons]], "main", "left", 16, 12, 0.02734375, 0.11328125, 0.19140625, 0.3125)
						else
							CoolTip:AddIcon ("Interface\\QUESTFRAME\\UI-Quest-BulletPoint", "main", "left", 16, 16)
						end
					end
					
					CoolTip:AddMenu (1, instancia.TrocaTabela, i)
					
					CoolTip:AddLine (Loc ["STRING_SEGMENT_ENEMY"] .. ":", enemy, 2, "white", "white")
					
					local decorrido = (thisCombat.end_time or _detalhes._tempo) - thisCombat.start_time
					local minutos, segundos = _math_floor (decorrido/60), _math_floor (decorrido%60)
					CoolTip:AddLine (Loc ["STRING_SEGMENT_TIME"] .. ":", minutos.."m "..segundos.."s", 2, "white", "white")
					
					CoolTip:AddLine (Loc ["STRING_SEGMENT_START"] .. ":", thisCombat.data_inicio, 2, "white", "white")
					CoolTip:AddLine (Loc ["STRING_SEGMENT_END"] .. ":", thisCombat.data_fim or "in progress", 2, "white", "white")
					
					fight_amount = fight_amount + 1
				else
					CoolTip:AddLine (Loc ["STRING_SEGMENT_LOWER"] .. " #" .. i, _, 1, "gray")
					CoolTip:AddMenu (1, instancia.TrocaTabela, i)
					CoolTip:AddIcon ("Interface\\QUESTFRAME\\UI-Quest-BulletPoint", "main", "left", 16, 16, nil, nil, nil, nil, empty_segment_color)
					CoolTip:AddLine (Loc ["STRING_SEGMENT_EMPTY"], _, 2)
				end
				
				if (menuIndex) then
					menuIndex = menuIndex + 1
					if (instancia.segmento == i) then
						CoolTip:SetLastSelected ("main", menuIndex); 
						menuIndex = nil
					end
				end
			
			end
			
		end
		
		----------- current
		CoolTip:AddLine (segmentos.current_standard, _, 1, "white")
		CoolTip:AddMenu (1, instancia.TrocaTabela, 0)
		CoolTip:AddIcon ("Interface\\QUESTFRAME\\UI-Quest-BulletPoint", "main", "left", 16, 16, nil, nil, nil, nil, "orange")
			
			local enemy = _detalhes.tabela_vigente.is_boss and _detalhes.tabela_vigente.is_boss.name or _detalhes.tabela_vigente.enemy or "--x--x--"
			
			if (_detalhes.tabela_vigente.is_boss and _detalhes.tabela_vigente.is_boss.name) then
				local portrait = _detalhes:GetBossPortrait (_detalhes.tabela_vigente.is_boss.mapid, _detalhes.tabela_vigente.is_boss.index)
				if (portrait) then
					CoolTip:AddIcon (portrait, 2, "top", 128, 64)
				end
			end					
			
			CoolTip:AddLine (Loc ["STRING_SEGMENT_ENEMY"] .. ":", enemy, 2, "white", "white")
			
			if (not _detalhes.tabela_vigente.end_time) then
				if (_detalhes.in_combat) then
					local decorrido = _detalhes._tempo - _detalhes.tabela_vigente.start_time
					local minutos, segundos = _math_floor (decorrido/60), _math_floor (decorrido%60)
					CoolTip:AddLine (Loc ["STRING_SEGMENT_TIME"] .. ":", minutos.."m "..segundos.."s", 2, "white", "white") 
				else
					CoolTip:AddLine (Loc ["STRING_SEGMENT_TIME"] .. ":", "--x--x--", 2, "white", "white")
				end
			else
				local decorrido = (_detalhes.tabela_vigente.end_time) - _detalhes.tabela_vigente.start_time
				local minutos, segundos = _math_floor (decorrido/60), _math_floor (decorrido%60)
				CoolTip:AddLine (Loc ["STRING_SEGMENT_TIME"] .. ":", minutos.."m "..segundos.."s", 2, "white", "white") 
			end

			
			CoolTip:AddLine (Loc ["STRING_SEGMENT_START"] .. ":", _detalhes.tabela_vigente.data_inicio, 2, "white", "white")
			CoolTip:AddLine (Loc ["STRING_SEGMENT_END"] .. ":", _detalhes.tabela_vigente.data_fim or "in progress", 2, "white", "white") 
		
			--> fill é a quantidade de menu que esta sendo mostrada
			if (instancia.segmento == 0) then
				if (fill - 2 == menuIndex) then
					CoolTip:SetLastSelected ("main", fill - 1)
				elseif (fill - 1 == menuIndex) then
					CoolTip:SetLastSelected ("main", fill)
				else
					CoolTip:SetLastSelected ("main", fill + 1)
				end

				menuIndex = nil
			end
		
		----------- overall
		--CoolTip:AddLine (segmentos.overall_standard, _, 1, "white") Loc ["STRING_REPORT_LAST"] .. " " .. fight_amount .. " " .. Loc ["STRING_REPORT_FIGHTS"]
		CoolTip:AddLine (Loc ["STRING_SEGMENT_OVERALL"], _, 1, "white")
		CoolTip:AddMenu (1, instancia.TrocaTabela, -1)
		CoolTip:AddIcon ("Interface\\QUESTFRAME\\UI-Quest-BulletPoint", "main", "left", 16, 16, nil, nil, nil, nil, "orange")
		
			CoolTip:AddLine (Loc ["STRING_SEGMENT_ENEMY"] .. ":", "--x--x--", 2, "white", "white")--localize-me
			
			if (not _detalhes.tabela_overall.end_time) then
				if (_detalhes.in_combat) then
					local decorrido = _detalhes._tempo - _detalhes.tabela_overall.start_time
					local minutos, segundos = _math_floor (decorrido/60), _math_floor (decorrido%60)
					CoolTip:AddLine (Loc ["STRING_SEGMENT_TIME"] .. ":", minutos.."m "..segundos.."s", 2, "white", "white") 
				else
					CoolTip:AddLine (Loc ["STRING_SEGMENT_TIME"] .. ":", "--x--x--", 2, "white", "white")
				end
			else
				local decorrido = (_detalhes.tabela_overall.end_time) - _detalhes.tabela_overall.start_time
				local minutos, segundos = _math_floor (decorrido/60), _math_floor (decorrido%60)
				CoolTip:AddLine (Loc ["STRING_SEGMENT_TIME"] .. ":", minutos.."m "..segundos.."s", 2, "white", "white") 
			end
			
			local earlyFight = ""
			for i = _detalhes.segments_amount, 1, -1 do
				if (_detalhes.tabela_historico.tabelas [i]) then
					earlyFight = _detalhes.tabela_historico.tabelas [i].data_inicio
					break
				end
			end
			CoolTip:AddLine (Loc ["STRING_SEGMENT_START"] .. ":", earlyFight, 2, "white", "white")
			
			local lastFight = ""
			for i = 1, _detalhes.segments_amount do
				if (_detalhes.tabela_historico.tabelas [i] and _detalhes.tabela_historico.tabelas [i].data_fim ~= 0) then
					lastFight = _detalhes.tabela_historico.tabelas [i].data_fim
					break
				end
			end
			CoolTip:AddLine (Loc ["STRING_SEGMENT_END"] .. ":", lastFight, 2, "white", "white")
			
			--> fill é a quantidade de menu que esta sendo mostrada
			if (instancia.segmento == -1) then
				if (fill - 2 == menuIndex) then
					CoolTip:SetLastSelected ("main", fill)
				elseif (fill - 1 == menuIndex) then
					CoolTip:SetLastSelected ("main", fill+1)
				else
					CoolTip:SetLastSelected ("main", fill + 2)
				end
				menuIndex = nil
			end
			
		---------------------------------------------
		
		if (instancia.consolidate) then
			CoolTip:SetOwner (self, "topleft", "topright", 3)
		else
			CoolTip:SetOwner (self)
		end
		
		CoolTip:SetOption ("TextSize", _detalhes.font_sizes.menus)
		CoolTip:SetOption ("SubMenuIsTooltip", true)
		
		CoolTip:SetOption ("ButtonHeightMod", -4)
		CoolTip:SetOption ("ButtonsYMod", -4)
		CoolTip:SetOption ("YSpacingMod", 4)
		
		CoolTip:SetOption ("ButtonHeightModSub", 4)
		CoolTip:SetOption ("ButtonsYModSub", 0)
		CoolTip:SetOption ("YSpacingModSub", -4)
		
		CoolTip:ShowCooltip()
		
		self:SetScript ("OnUpdate", nil)
	end	
	
end

local botao_fechar_on_enter = function (self)
	OnEnterMainWindow (self.instancia, self, 3)
end
local botao_fechar_on_leave = function (self)
	OnLeaveMainWindow (self.instancia, self, 3)
end

function _detalhes:ChangeSkin (skin_name)

	if (not skin_name) then
		skin_name = self.skin
	end
	
	local this_skin = _detalhes.skins [skin_name]
	
	if (not this_skin) then
		return false --> throw a msg
	end
	
	self.skin = skin_name
	local skin_file = this_skin.file
	
	self.baseframe.cabecalho.ball:SetTexture (skin_file) --> bola esquerda
	self.baseframe.cabecalho.emenda:SetTexture (skin_file) --> emenda que liga a bola a textura do centro
	
	self.baseframe.cabecalho.ball_r:SetTexture (skin_file) --> bola direita onde fica o botão de fechar
	self.baseframe.cabecalho.top_bg:SetTexture (skin_file) --> top background
	
	self.baseframe.barra_esquerda:SetTexture (skin_file) --> barra lateral
	self.baseframe.barra_direita:SetTexture (skin_file) --> barra lateral
	
	self.baseframe.scroll_up:SetTexture (skin_file) --> scrollbar parte de cima
	self.baseframe.scroll_down:SetTexture (skin_file) --> scrollbar parte de baixo
	self.baseframe.scroll_middle:SetTexture (skin_file) --> scrollbar parte do meio
	
	self.baseframe.rodape.top_bg:SetTexture (skin_file) --> rodape top background
	self.baseframe.rodape.esquerdo:SetTexture (skin_file) --> rodape esquerdo
	self.baseframe.rodape.direita:SetTexture (skin_file) --> rodape direito
	
	self.baseframe.button_stretch.texture:SetTexture (skin_file) --> botão de esticar a janela
	
	self.baseframe.resize_direita.texture:SetTexture (skin_file) --> botão de redimencionar da direita
	self.baseframe.resize_esquerda.texture:SetTexture (skin_file) --> botão de redimencionar da esquerda
	
	self.baseframe.unlock_texture:SetTexture (skin_file) --> cadeado
	
	if (self.modo == 1 or self.modo == 4 or self.atributo == 5) then -- alone e raid
		local icon_anchor = this_skin.icon_anchor_plugins
		self.baseframe.cabecalho.atributo_icon:SetPoint ("TOPRIGHT", self.baseframe.cabecalho.ball_point, "TOPRIGHT", icon_anchor[1], icon_anchor[2])
		if (self.modo == 1) then
			local plugin_index = _detalhes.SoloTables.Mode
			if (plugin_index > 0 and _detalhes.SoloTables.Menu [plugin_index]) then
				self:ChangeIcon (_detalhes.SoloTables.Menu [plugin_index] [2])
			end
		elseif (self.modo == 4) then
			local plugin_index = _detalhes.RaidTables.Mode
			if (plugin_index and _detalhes.RaidTables.Menu [plugin_index]) then
				self:ChangeIcon (_detalhes.RaidTables.Menu [plugin_index] [2])
			end
		end
	else
		local icon_anchor = this_skin.icon_anchor_main --> ancora do icone do canto direito superior
		self.baseframe.cabecalho.atributo_icon:SetPoint ("TOPRIGHT", self.baseframe.cabecalho.ball_point, "TOPRIGHT", icon_anchor[1], icon_anchor[2])
		self:ChangeIcon()
	end
	
	if (not this_skin.can_change_alpha_head) then
		self.baseframe.cabecalho.ball:SetAlpha (100)
	else
		self.baseframe.cabecalho.ball:SetAlpha (self.color[4])
	end
	
end

function gump:CriaCabecalho (BaseFrame, instancia)

-- texturas da barra superior
------------------------------------------------------------------------------------------------------------------------------------------------- 	
	
	BaseFrame.cabecalho = {}
	
	--> FECHAR INSTANCIA ----------------------------------------------------------------------------------------------------------------------------------------------------
	BaseFrame.cabecalho.fechar = _CreateFrame ("Button", nil, BaseFrame, "UIPanelCloseButton")
	BaseFrame.cabecalho.fechar:SetWidth (32)
	BaseFrame.cabecalho.fechar:SetHeight (32)
	BaseFrame.cabecalho.fechar:SetFrameLevel (5) --> altura mais alta que os demais frames
	BaseFrame.cabecalho.fechar:SetPoint ("BOTTOMRIGHT", BaseFrame, "TOPRIGHT", 5, -6) --> seta o ponto dele fixando no base frame
	
	BaseFrame.cabecalho.fechar:SetScript ("OnClick", function() 
		BaseFrame.cabecalho.fechar:Disable()
		instancia:DesativarInstancia() 
		--> não há mais instâncias abertas, então manda msg alertando
		if (_detalhes.opened_windows == 0) then
			print (Loc ["STRING_CLOSEALL"])
		end
	end)
	
	BaseFrame.cabecalho.fechar.instancia = instancia
	BaseFrame.cabecalho.fechar:SetText ("x")
	BaseFrame.cabecalho.fechar:SetScript ("OnEnter", botao_fechar_on_enter)
	BaseFrame.cabecalho.fechar:SetScript ("OnLeave", botao_fechar_on_leave)	

	--> bola do canto esquedo superior --> primeiro criar a armação para apoiar as texturas
	BaseFrame.cabecalho.ball_point = BaseFrame.cabecalho.fechar:CreateTexture (nil, "OVERLAY")
	BaseFrame.cabecalho.ball_point:SetPoint ("BOTTOMLEFT", BaseFrame, "TOPLEFT", -37, 0)
	BaseFrame.cabecalho.ball_point:SetWidth (64)
	BaseFrame.cabecalho.ball_point:SetHeight (32)
	
	--> icone do atributo
	BaseFrame.cabecalho.atributo_icon = _detalhes.listener:CreateTexture (nil, "ARTWORK")
	local icon_anchor = _detalhes.skins ["Default Skin"].icon_anchor_main
	BaseFrame.cabecalho.atributo_icon:SetPoint ("TOPRIGHT", BaseFrame.cabecalho.ball_point, "TOPRIGHT", icon_anchor[1], icon_anchor[2])
	--BaseFrame.cabecalho.atributo_icon:SetTexture ("Interface\\AddOns\\Details\\images\\icon_mainwindow")
	BaseFrame.cabecalho.atributo_icon:SetTexture (DEFAULT_SKIN)
	BaseFrame.cabecalho.atributo_icon:SetWidth (32)
	BaseFrame.cabecalho.atributo_icon:SetHeight (32)
	
	--> bola overlay
	BaseFrame.cabecalho.ball = _detalhes.listener:CreateTexture (nil, "OVERLAY")
	BaseFrame.cabecalho.ball:SetPoint ("BOTTOMLEFT", BaseFrame, "TOPLEFT", -107, 0)
	BaseFrame.cabecalho.ball:SetWidth (128)
	BaseFrame.cabecalho.ball:SetHeight (128)
	
	--BaseFrame.cabecalho.ball:SetTexture ([[Interface\AddOns\Details\images\ball_left]])
	BaseFrame.cabecalho.ball:SetTexture (DEFAULT_SKIN)
	BaseFrame.cabecalho.ball:SetTexCoord (unpack (COORDS_LEFT_BALL))

	--> emenda
	BaseFrame.cabecalho.emenda = BaseFrame:CreateTexture (nil, "OVERLAY")
	BaseFrame.cabecalho.emenda:SetPoint ("bottomleft", BaseFrame.cabecalho.ball, "bottomright")
	BaseFrame.cabecalho.emenda:SetWidth (8)
	BaseFrame.cabecalho.emenda:SetHeight (128)
	--BaseFrame.cabecalho.emenda:SetTexture ([[Interface\AddOns\Details\images\emenda_left]])
	BaseFrame.cabecalho.emenda:SetTexture (DEFAULT_SKIN)
	BaseFrame.cabecalho.emenda:SetTexCoord (unpack (COORDS_LEFT_CONNECTOR))

	BaseFrame.cabecalho.atributo_icon:Hide()
	BaseFrame.cabecalho.ball:Hide()

	--> bola do canto direito superior
	BaseFrame.cabecalho.ball_r = BaseFrame:CreateTexture (nil, "BACKGROUND")
	BaseFrame.cabecalho.ball_r:SetPoint ("BOTTOMRIGHT", BaseFrame, "TOPRIGHT", 96, 0)
	BaseFrame.cabecalho.ball_r:SetWidth (128)
	BaseFrame.cabecalho.ball_r:SetHeight (128)
	--BaseFrame.cabecalho.ball_r:SetTexture ("Interface\\AddOns\\Details\\images\\bar_top_right")
	BaseFrame.cabecalho.ball_r:SetTexture (DEFAULT_SKIN)
	BaseFrame.cabecalho.ball_r:SetTexCoord (unpack (COORDS_RIGHT_BALL))

	--> barra centro
	BaseFrame.cabecalho.top_bg = BaseFrame:CreateTexture (nil, "BACKGROUND")
	--BaseFrame.cabecalho.top_bg:SetPoint ("LEFT", BaseFrame.cabecalho.ball, "RIGHT", -4, 0)
	BaseFrame.cabecalho.top_bg:SetPoint ("LEFT", BaseFrame.cabecalho.emenda, "RIGHT", 0, 0)
	BaseFrame.cabecalho.top_bg:SetPoint ("RIGHT", BaseFrame.cabecalho.ball_r, "LEFT")
	BaseFrame.cabecalho.top_bg:SetTexture (DEFAULT_SKIN)
	BaseFrame.cabecalho.top_bg:SetTexCoord (unpack (COORDS_TOP_BACKGROUND))
	BaseFrame.cabecalho.top_bg:SetWidth (512)
	BaseFrame.cabecalho.top_bg:SetHeight (128)
	--BaseFrame.cabecalho.top_bg:SetTexture ("Interface\\AddOns\\Details\\images\\bar_top_center")

	--> frame invisível
	BaseFrame.UPFrame = _CreateFrame ("frame", nil, BaseFrame)
	BaseFrame.UPFrame:SetPoint ("LEFT", BaseFrame.cabecalho.ball, "RIGHT", 0, -53)
	BaseFrame.UPFrame:SetPoint ("RIGHT", BaseFrame.cabecalho.ball_r, "LEFT", 0, -53)
	BaseFrame.UPFrame:SetHeight (20)
	
	BaseFrame.UPFrame:Show()
	BaseFrame.UPFrame:EnableMouse (true)
	BaseFrame.UPFrame:SetMovable (true)
	BaseFrame.UPFrame:SetResizable (true)
	
	BGFrame_scripts (BaseFrame.UPFrame, BaseFrame, instancia)
	
	
-- botões	
------------------------------------------------------------------------------------------------------------------------------------------------- 	

	local CoolTip = _G.GameCooltip

	--> SELEÇÃO DO MODO ----------------------------------------------------------------------------------------------------------------------------------------------------
	
	BaseFrame.cabecalho.modo_selecao = gump:NewButton (BaseFrame, nil, "DetailsModeButton"..instancia.meu_id, nil, 16, 16, _detalhes.empty_function, nil, nil, [[Interface\GossipFrame\HealerGossipIcon]])
	BaseFrame.cabecalho.modo_selecao:SetFrameLevel (BaseFrame.UPFrame:GetFrameLevel()+1)
	BaseFrame.cabecalho.modo_selecao:SetPoint ("BOTTOMLEFT", BaseFrame.cabecalho.ball, "BOTTOMRIGHT", 0, 2)
	
	--> Generating Cooltip menu from table template
	local modeMenuTable = {
	
		{text = Loc ["STRING_MODE_GROUP"]},
		{func = instancia.AlteraModo, param1 = 2},
		{icon = "Interface\\AddOns\\Details\\images\\modo_icones", l = 32/256, r = 32/256*2, t = 0, b = 1, width = 20, height = 20},
		{text = Loc ["STRING_HELP_MODEGROUP"], type = 2},
		{icon = [[Interface\TUTORIALFRAME\TutorialFrame-QuestionMark]], type = 2, width = 16, height = 16, l = 8/64, r = 1 - (8/64), t = 8/64, b = 1 - (8/64)},

		{text = Loc ["STRING_MODE_ALL"]},
		{func = instancia.AlteraModo, param1 = 3},
		{icon = "Interface\\AddOns\\Details\\images\\modo_icones", l = 32/256*2, r = 32/256*3, t = 0, b = 1, width = 20, height = 20},
		{text = Loc ["STRING_HELP_MODEALL"], type = 2},
		{icon = [[Interface\TUTORIALFRAME\TutorialFrame-QuestionMark]], type = 2, width = 16, height = 16, l = 8/64, r = 1 - (8/64), t = 8/64, b = 1 - (8/64)},		
	
		{text = Loc ["STRING_MODE_SELF"] .. " (|cffa0a0a0" .. Loc ["STRING_MODE_PLUGINS"] .. "|r)"},
		{func = instancia.AlteraModo, param1 = 1},
		{icon = "Interface\\AddOns\\Details\\images\\modo_icones", l = 0, r = 32/256, t = 0, b = 1, width = 20, height = 20},
		{text = Loc ["STRING_HELP_MODESELF"], type = 2},
		{icon = [[Interface\TUTORIALFRAME\TutorialFrame-QuestionMark]], type = 2, width = 16, height = 16, l = 8/64, r = 1 - (8/64), t = 8/64, b = 1 - (8/64)},

		{text = Loc ["STRING_MODE_RAID"] .. " (|cffa0a0a0" .. Loc ["STRING_MODE_PLUGINS"] .. "|r)"},
		{func = instancia.AlteraModo, param1 = 4},
		{icon = "Interface\\AddOns\\Details\\images\\modo_icones", l = 32/256*3, r = 32/256*4, t = 0, b = 1, width = 20, height = 20},
		{text = Loc ["STRING_HELP_MODERAID"], type = 2},
		{icon = [[Interface\TUTORIALFRAME\TutorialFrame-QuestionMark]], type = 2, width = 16, height = 16, l = 8/64, r = 1 - (8/64), t = 8/64, b = 1 - (8/64)},
		
		{text = Loc ["STRING_OPTIONS_WINDOW"]},
		{func = _detalhes.OpenOptionsWindow},
		{icon = "Interface\\AddOns\\Details\\images\\modo_icones", l = 32/256*4, r = 32/256*5, t = 0, b = 1, width = 20, height = 20},
	}
	
	--> Cooltip raw method for enter/leave show/hide
	BaseFrame.cabecalho.modo_selecao:SetScript ("OnEnter", function (self)
	
		--gump:Fade (BaseFrame.button_stretch, "alpha", 0.3)
		OnEnterMainWindow (instancia, self, 3)
		
		_detalhes.popup.buttonOver = true
		BaseFrame.cabecalho.button_mouse_over = true
		
		local passou = 0
		if (_detalhes.popup.active) then
			passou = 0.15
		end

		local checked
		if (instancia.modo == 1) then
			checked = 3
		elseif (instancia.modo == 2) then
			checked = 1
		elseif (instancia.modo == 3) then
			checked = 2
		elseif (instancia.modo == 4) then
			checked = 4
		end

		parameters_table [1] = instancia
		parameters_table [2] = passou
		parameters_table [3] = checked
		parameters_table [4] = modeMenuTable
		
		self:SetScript ("OnUpdate", build_mode_list)
	end)
	
	BaseFrame.cabecalho.modo_selecao:SetScript ("OnLeave", function (self) 
		--gump:Fade (BaseFrame.button_stretch, -1)
		OnLeaveMainWindow (instancia, self, 3)
		
		_detalhes.popup.buttonOver = false
		BaseFrame.cabecalho.button_mouse_over = false
		
		if (_detalhes.popup.active) then
			parameters_table [2] = 0
			self:SetScript ("OnUpdate", on_leave_menu)
		else
			self:SetScript ("OnUpdate", nil)
		end
	end)
	
	--> SELECIONAR O SEGMENTO  ----------------------------------------------------------------------------------------------------------------------------------------------------
	BaseFrame.cabecalho.segmento = gump:NewButton (BaseFrame, nil, "DetailsSegmentButton"..instancia.meu_id, nil, 16, 16, _detalhes.empty_function, nil, nil, [[Interface\GossipFrame\TrainerGossipIcon]])
	BaseFrame.cabecalho.segmento:SetFrameLevel (BaseFrame.UPFrame:GetFrameLevel()+1)

	BaseFrame.cabecalho.segmento:SetHook ("OnMouseUp", function (button, buttontype)

		if (buttontype == "LeftButton") then
		
			local segmento_goal = instancia.segmento + 1
			if (segmento_goal > segments_used) then
				segmento_goal = -1
			elseif (segmento_goal > _detalhes.segments_amount) then
				segmento_goal = -1
			end
			
			local total_shown = segments_filled+2
			local goal = segmento_goal+1
			
			local select_ = math.abs (goal - total_shown)
			GameCooltip:Select (1, select_)
			
			return instancia:TrocaTabela (segmento_goal)
		elseif (buttontype == "RightButton") then
		
			local segmento_goal = instancia.segmento - 1
			if (segmento_goal < -1) then
				segmento_goal = segments_used
			end
			
			local total_shown = segments_filled+2
			local goal = segmento_goal+1
			
			local select_ = math.abs (goal - total_shown)
			GameCooltip:Select (1, select_)
			
			return instancia:TrocaTabela (segmento_goal)
		
		elseif (buttontype == "MiddleButton") then
			
			local segmento_goal = 0
			
			local total_shown = segments_filled+2
			local goal = segmento_goal+1
			
			local select_ = math.abs (goal - total_shown)
			GameCooltip:Select (1, select_)
			
			return instancia:TrocaTabela (segmento_goal)
			
		end
	end)
	BaseFrame.cabecalho.segmento:SetPoint ("left", BaseFrame.cabecalho.modo_selecao, "right", 0, 0)

	--> Cooltip raw method for show/hide onenter/onhide
	BaseFrame.cabecalho.segmento:SetScript ("OnEnter", function (self) 
		--gump:Fade (BaseFrame.button_stretch, "alpha", 0.3)
		OnEnterMainWindow (instancia, self, 3)
		
		_detalhes.popup.buttonOver = true
		BaseFrame.cabecalho.button_mouse_over = true
		
		local passou = 0
		if (_detalhes.popup.active) then
			passou = 0.15
		end

		parameters_table [1] = instancia
		parameters_table [2] = passou
		self:SetScript ("OnUpdate", build_segment_list)
	end)
	
	--> Cooltip raw method
	BaseFrame.cabecalho.segmento:SetScript ("OnLeave", function (self) 
		--gump:Fade (BaseFrame.button_stretch, -1)
		OnLeaveMainWindow (instancia, self, 3)
		
		_detalhes.popup.buttonOver = false
		BaseFrame.cabecalho.button_mouse_over = false
		
		if (_detalhes.popup.active) then
			parameters_table [2] = 0
			self:SetScript ("OnUpdate", on_leave_menu)
		else
			self:SetScript ("OnUpdate", nil)
		end
	end)	

	--> SELECIONAR O ATRIBUTO  ----------------------------------------------------------------------------------------------------------------------------------------------------
	BaseFrame.cabecalho.atributo = gump:NewDetailsButton (BaseFrame, _, instancia, instancia.TrocaTabela, instancia, -3, 16, 16, "Interface\\AddOns\\Details\\images\\sword")
	BaseFrame.cabecalho.atributo:SetFrameLevel (BaseFrame.UPFrame:GetFrameLevel()+1)
	BaseFrame.cabecalho.atributo:SetPoint ("left", BaseFrame.cabecalho.segmento.widget, "right", 0, 0)

	--> Cooltip automatic method through Injection
	
	--> First we declare the function which will build the menu
	local BuildAttributeMenu = function()
		if (_detalhes.solo and _detalhes.solo == instancia.meu_id) then
			return _detalhes:MontaSoloOption (instancia)
		elseif (_detalhes.raid and _detalhes.raid == instancia.meu_id) then
			return _detalhes:MontaRaidOption (instancia)
		else
			return _detalhes:MontaAtributosOption (instancia)
		end
	end
	
	--> Now we create a table with some parameters
	--> your frame need to have a member called CoolTip
	BaseFrame.cabecalho.atributo.CoolTip = {
		Type = "menu", --> the type, menu tooltip tooltipbars
		BuildFunc = BuildAttributeMenu, --> called when user mouse over the frame
		OnEnterFunc = function() BaseFrame.cabecalho.button_mouse_over = true; OnEnterMainWindow (instancia, BaseFrame.cabecalho.atributo, 3) end,
		OnLeaveFunc = function() BaseFrame.cabecalho.button_mouse_over = false; OnLeaveMainWindow (instancia, BaseFrame.cabecalho.atributo, 3) end,
		FixedValue = instancia,
		ShowSpeed = 0.15,
		Options = function()
			if (instancia.consolidate) then
				return {Anchor = instancia.consolidateFrame, MyAnchor = "topleft", RelativeAnchor = "topright", TextSize = _detalhes.font_sizes.menus}
			else
				return {TextSize = _detalhes.font_sizes.menus}
			end
		end}
	
	--> install cooltip
	_detalhes.popup:CoolTipInject (BaseFrame.cabecalho.atributo)

	--> REPORTAR ----------------------------------------------------------------------------------------------------------------------------------------------------
			BaseFrame.cabecalho.report = gump:NewDetailsButton (BaseFrame, _, instancia, _detalhes.Reportar, instancia, nil, 16, 16, [[Interface\COMMON\VOICECHAT-ON]])
			BaseFrame.cabecalho.report:SetPoint ("left", BaseFrame.cabecalho.atributo, "right", -6, 0)
			BaseFrame.cabecalho.report:SetFrameLevel (BaseFrame.UPFrame:GetFrameLevel()+1)
			BaseFrame.cabecalho.report:SetScript ("OnEnter", function (self)
				OnEnterMainWindow (instancia, self, 3)
			end)
			BaseFrame.cabecalho.report:SetScript ("OnLeave", function (self)
				OnLeaveMainWindow (instancia, self, 3)
			end)
			

	--> BOSS INFO ----------------------------------------------------------------------------------------------------------------------------------------------------
			--BaseFrame.cabecalho.boss_info = gump:NewDetailsButton (BaseFrame, BaseFrame, instancia, _detalhes.AbrirEncounterWindow, instancia, nil, 16, 16,
			--"Interface\\COMMON\\help-i", "Interface\\COMMON\\help-i", "Interface\\COMMON\\help-i", "Interface\\COMMON\\help-i")
			--BaseFrame.cabecalho.boss_info:SetPoint ("left", BaseFrame.cabecalho.report, "right", 1, 0)
			--BaseFrame.cabecalho.boss_info:SetFrameLevel (BaseFrame.UPFrame:GetFrameLevel()+1)
	
	--> NOVA INSTANCIA ----------------------------------------------------------------------------------------------------------------------------------------------------
	BaseFrame.cabecalho.novo = _CreateFrame ("Button", nil, BaseFrame, "OptionsButtonTemplate")
	BaseFrame.cabecalho.novo:SetFrameLevel (BaseFrame.UPFrame:GetFrameLevel()+1)
	
	BaseFrame.cabecalho.novo:SetWidth (30)
	BaseFrame.cabecalho.novo:SetHeight (15)
	BaseFrame.cabecalho.novo:SetPoint ("RIGHT", BaseFrame.cabecalho.fechar, "LEFT", 1, 0)
	BaseFrame.cabecalho.novo:SetScript ("OnClick", function() _detalhes:CriarInstancia (_, true); _detalhes.popup:ShowMe (false) end)
	BaseFrame.cabecalho.novo:SetText ("#"..instancia.meu_id)

	--> cooltip through inject
	--> OnClick Function [1] caller [2] fixed param [3] param1 [4] param2
	local OnClickNovoMenu = function (_, _, id)
		_detalhes.CriarInstancia (_, _, id)
		_detalhes.popup:ExecFunc (BaseFrame.cabecalho.novo)
	end
	
	--> Build Menu Function
	local BuildClosedInstanceMenu = function() 
	
		local ClosedInstances = {}
		
		for index = 1, #_detalhes.tabela_instancias, 1 do 
		
			local _this_instance = _detalhes.tabela_instancias [index]
			
			if (not _this_instance.ativa) then --> só reabre se ela estiver ativa
			
				--> pegar o que ela ta mostrando
				local atributo = _this_instance.atributo
				local sub_atributo = _this_instance.sub_atributo
				
				if (atributo == 5) then --> custom
				
					local CustomObject = _detalhes.custom [sub_atributo]
					
					--> as addmenu dont support textcoords we need to add in parts, first adding text and menu, after we add the icon
					--> text and menu can be added in one call if doesnt need more details like color or right text
					CoolTip:AddMenu (1, OnClickNovoMenu, index, nil, nil, "#".. index .. " " .. _detalhes.atributos.lista [atributo] .. " - " .. CustomObject.name, _, true)
					CoolTip:AddIcon (CustomObject.icon, 1, 1, 20, 20, 0, 1, 0, 1)
					
				else
					local modo = _this_instance.modo
					
					if (modo == 1) then --alone
					
						atributo = _detalhes.SoloTables.Mode or 1
						local SoloInfo = _detalhes.SoloTables.Menu [atributo]
						CoolTip:AddMenu (1, OnClickNovoMenu, index, nil, nil, "#".. index .. " " .. SoloInfo [1], _, true)
						CoolTip:AddIcon (SoloInfo [2], 1, 1, 20, 20, 0, 1, 0, 1)
						
					elseif (modo == 4) then --raid
					
						atributo = _detalhes.RaidTables.Mode or 1
						local RaidInfo = _detalhes.RaidTables.Menu [atributo]
						CoolTip:AddMenu (1, OnClickNovoMenu, index, nil, nil, "#".. index .. " " .. RaidInfo [1], _, true)
						CoolTip:AddIcon (RaidInfo [2], 1, 1, 20, 20, 0, 1, 0, 1)	
						
					else
					
						CoolTip:AddMenu (1, OnClickNovoMenu, index, nil, nil, "#".. index .. " " .. _detalhes.atributos.lista [atributo] .. " - " .. _detalhes.sub_atributos [atributo].lista [sub_atributo], _, true)
						CoolTip:AddIcon (_detalhes.sub_atributos [atributo].icones[sub_atributo] [1], 1, 1, 20, 20, unpack (_detalhes.sub_atributos [atributo].icones[sub_atributo] [2]))
					end
				end


			end
		end
		return ClosedInstances
	end
	
	--> Inject Options Table
	BaseFrame.cabecalho.novo.CoolTip = { 
		--> cooltip type "menu" "tooltip" "tooltipbars"
		Type = "menu",
		--> how much time wait with mouse over the frame until cooltip show up
		ShowSpeed = 0.15,
		--> will call for build menu
		BuildFunc = BuildClosedInstanceMenu, 
		--> a hook for OnEnterScript
		OnEnterFunc = function() OnEnterMainWindow (instancia, BaseFrame.cabecalho.novo, 3) end,
		--> a hook for OnLeaveScript
		OnLeaveFunc = function() OnLeaveMainWindow (instancia, BaseFrame.cabecalho.novo, 3) end,
		--> default message if there is no option avaliable
		Default = Loc ["STRING_NOCLOSED_INSTANCES"], 
		--> instancia is the first parameter sent after click, before parameters
		FixedValue = instancia,
		Options = {TextSize = 10, NoLastSelectedBar = true}}
	
	--> Inject
	_detalhes.popup:CoolTipInject (BaseFrame.cabecalho.novo)
	
	--> RESETAR HISTORICO ----------------------------------------------------------------------------------------------------------------------------------------------------
	if (not _detalhes.ResetButton) then
	
		_detalhes.ResetButtonInstance = instancia.meu_id
		_detalhes.ResetButtonMode = 1
	
		function _detalhes:ResetButtonSnapTo (instancia)
			if (type (instancia) == "number") then
				instancia = _detalhes:GetInstance (instancia)
			end
			
			--print (instancia.baseframe, instancia.baseframe:GetObjectType())
			
			if (instancia.baseframe:GetWidth() < 215) then
				_detalhes.ResetButtonMode = 2
			else
				_detalhes.ResetButtonMode = 1
			end
			
			_detalhes.ResetButton:SetParent (instancia.baseframe)
			_detalhes.ResetButton2:SetParent (instancia.baseframe)
			_detalhes.ResetButton:SetPoint ("RIGHT", instancia.baseframe.cabecalho.novo, "LEFT")
			_detalhes.ResetButton2:SetPoint ("RIGHT", instancia.baseframe.cabecalho.novo, "LEFT", 3, 0)
			_detalhes.ResetButton:SetFrameLevel (instancia.baseframe.UPFrame:GetFrameLevel()+1)
			_detalhes.ResetButton2:SetFrameLevel (instancia.baseframe.UPFrame:GetFrameLevel()+1)
			
			if (_detalhes.ResetButtonMode == 1) then
				gump:Fade (_detalhes.ResetButton, 0)
				gump:Fade (_detalhes.ResetButton2, 1)
			else
				gump:Fade (_detalhes.ResetButton, 1)
				gump:Fade (_detalhes.ResetButton2, 0)
			end
			
		end
	
-----------------> big button
		_detalhes.ResetButton = _CreateFrame ("Button", nil, BaseFrame, "OptionsButtonTemplate")
		_detalhes.ResetButton:SetFrameLevel (BaseFrame.UPFrame:GetFrameLevel()+1)
		_detalhes.ResetButton:SetWidth (50)
		_detalhes.ResetButton:SetHeight (15)
		_detalhes.ResetButton:SetPoint ("RIGHT", BaseFrame.cabecalho.novo, "LEFT")
		
		_detalhes.ResetButton:SetText (Loc ["STRING_ERASE"])
		
		_detalhes.ResetButton:SetScript ("OnClick", function() _detalhes.tabela_historico:resetar() end)
		
		_detalhes.ResetButton:SetScript ("OnEnter", function (self) 
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (lower_instance) then
				OnEnterMainWindow (_detalhes:GetInstance (lower_instance), self, 3)
			end
		end)
		
		_detalhes.ResetButton:SetScript ("OnLeave", function (self) 
		
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (lower_instance) then
				OnLeaveMainWindow (_detalhes:GetInstance (lower_instance), self, 3)
			end

			if (_detalhes.popup.active) then
				local passou = 0
				self:SetScript ("OnUpdate", function (self, elapsed)
					passou = passou+elapsed
					if (passou > 0.3) then
						if (not _detalhes.popup.mouse_over and not _detalhes.popup.button_over) then
							_detalhes.popup:ShowMe (false)
						end
						self:SetScript ("OnUpdate", nil)
					end
				end)
			else
				self:SetScript ("OnUpdate", nil)
			end		
		end)	
		
----------------> small button
		_detalhes.ResetButton2 = _CreateFrame ("Button", nil, BaseFrame, "OptionsButtonTemplate")
		_detalhes.ResetButton2:SetFrameLevel (BaseFrame.UPFrame:GetFrameLevel()+1)
		_detalhes.ResetButton2:SetWidth (22)
		_detalhes.ResetButton2:SetHeight (15)
		_detalhes.ResetButton2:SetPoint ("RIGHT", BaseFrame.cabecalho.novo, "LEFT", 2, 0)

		local text = _detalhes.ResetButton2:CreateFontString (nil, "overlay", "GameFont_Gigantic")
		text:SetText ("-")
		_detalhes.ResetButton2:SetFontString (text)
		_detalhes.ResetButton2:SetNormalFontObject ("GameFont_Gigantic")
		_detalhes.ResetButton2:SetHighlightFontObject ("GameFont_Gigantic")
		
		_detalhes.ResetButton2:SetScript ("OnClick", function() _detalhes.tabela_historico:resetar() end)
		_detalhes.ResetButton2:SetScript ("OnEnter", function (self) 
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (lower_instance) then
				OnEnterMainWindow (_detalhes:GetInstance (lower_instance), self, 3)
			end
		end)
		
		_detalhes.ResetButton2:SetScript ("OnLeave", function (self) 
		
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (lower_instance) then
				OnLeaveMainWindow (_detalhes:GetInstance (lower_instance), self, 3)
			end
			
			if (_detalhes.popup.active) then
				local passou = 0
				self:SetScript ("OnUpdate", function (self, elapsed)
					passou = passou+elapsed
					if (passou > 0.3) then
						if (not _detalhes.popup.mouse_over and not _detalhes.popup.button_over) then
							_detalhes.popup:ShowMe (false)
						end
						self:SetScript ("OnUpdate", nil)
					end
				end)
			else
				self:SetScript ("OnUpdate", nil)
			end		
		end)	
	
	end
	
--> fim botão reset

--> Botão de Ajuda ----------------------------------------------------------------------------------------------------------------------------------------------------

	if (instancia.meu_id == 1 and _detalhes.tutorial.main_help_button < 10) then

		_detalhes.tutorial.main_help_button = _detalhes.tutorial.main_help_button + 1
	
		--> help button
		local helpButton = CreateFrame ("button", "DetailsMainWindowHelpButton", BaseFrame, "MainHelpPlateButton")
		helpButton:SetWidth (28)
		helpButton:SetHeight (28)
		helpButton.I:SetWidth (22)
		helpButton.I:SetHeight (22)
		helpButton.Ring:SetWidth (28)
		helpButton.Ring:SetHeight (28)
		helpButton.Ring:SetPoint ("center", 5, -6)
		
		helpButton:SetPoint ("topright", BaseFrame, "topleft", 37, 37)
		
		helpButton:SetFrameLevel (0)
		helpButton:SetFrameStrata ("LOW")

		local mainWindowHelp =  {
			FramePos = {x = 0, y = 10},
			FrameSize = {width = 300, height = 85},
			
			--> modo, segmento e atributo
			[1] ={HighLightBox = {x = 25, y = 10, width = 60, height = 20},
				ButtonPos = { x = 32, y = 40},
				ToolTipDir = "RIGHT",
				ToolTipText = Loc ["STRING_HELP_MENUS"]
			},
			--> delete
			[2] ={HighLightBox = {x = 195, y = 10, width = 47, height = 20},
				ButtonPos = { x = 197, y = 5},
				ToolTipDir = "LEFT",
				ToolTipText = Loc ["STRING_HELP_ERASE"]
			},
			--> menu da instancia
			[3] ={HighLightBox = {x = 244, y = 10, width = 30, height = 20},
				ButtonPos = { x = 237, y = 5},
				ToolTipDir = "RIGHT",
				ToolTipText = Loc ["STRING_HELP_INSTANCE"]
			},
			--> stretch
			[4] ={HighLightBox = {x = 244, y = 30, width = 30, height = 20},
				ButtonPos = { x = 237, y = 57},
				ToolTipDir = "RIGHT",
				ToolTipText = Loc ["STRING_HELP_STRETCH"]
			},
			--> status bar
			[5] ={HighLightBox = {x = 0, y = -101, width = 300, height = 20},
				ButtonPos = { x = 126, y = -88},
				ToolTipDir = "LEFT",
				ToolTipText = Loc ["STRING_HELP_STATUSBAR"]
			},
			--> switch menu
			[6] ={HighLightBox = {x = 0, y = -10, width = 300, height = 95},
				ButtonPos = { x = 127, y = -37},
				ToolTipDir = "LEFT",
				ToolTipText = Loc ["STRING_HELP_SWITCH"]
			},
			--> resizer
			[7] ={HighLightBox = {x = 250, y = -81, width = 50, height = 20},
				ButtonPos = { x = 253, y = -52},
				ToolTipDir = "RIGHT",
				ToolTipText = Loc ["STRING_HELP_RESIZE"]
			},
		}
		
		helpButton:SetScript ("OnClick", function() 
			if (not HelpPlate_IsShowing (mainWindowHelp)) then
			
				instancia:SetSize (300, 95)
			
				HelpPlate_Show (mainWindowHelp, BaseFrame, helpButton, true)
			else
				HelpPlate_Hide (true)
			end
		end)
	
	end

---------> consolidate frame ----------------------------------------------------------------------------------------------------------------------------------------------------

	local consolidateFrame = CreateFrame ("frame", nil, _detalhes.listener)
	consolidateFrame:SetWidth (21)
	consolidateFrame:SetHeight (83)
	consolidateFrame:SetFrameLevel (BaseFrame:GetFrameLevel()-1)
	consolidateFrame:SetPoint ("BOTTOMLEFT", BaseFrame.cabecalho.ball, "BOTTOMRIGHT", 0, 20)
	consolidateFrame:SetFrameStrata ("FULLSCREEN")
	consolidateFrame:Hide()
	instancia.consolidateFrame = consolidateFrame
	
---------> consolidate texture

	local frameTexture = consolidateFrame:CreateTexture (nil, "background")
	frameTexture:SetTexture ("Interface\\AddOns\\Details\\images\\consolidate_frame")
	frameTexture:SetPoint ("top", consolidateFrame, "top", .5, 0)
	frameTexture:SetWidth (32)
	frameTexture:SetHeight (83)
	frameTexture:SetTexCoord (0, 1, 0, 0.6484375)
	
---------> consolidate button

	local consolidateButton = CreateFrame ("button", nil, BaseFrame)
	consolidateButton:SetWidth (16)
	consolidateButton:SetHeight (16)
	consolidateButton:SetFrameLevel (BaseFrame.UPFrame:GetFrameLevel()+1)
	consolidateButton:SetPoint ("BOTTOMLEFT", BaseFrame.cabecalho.ball, "BOTTOMRIGHT", 6, 2)

	local normal_texture = consolidateButton:CreateTexture (nil, "overlay")
	--normal_texture:SetTexture ("Interface\\AddOns\\Details\\images\\consolidate_frame")
	normal_texture:SetTexture ("Interface\\GossipFrame\\HealerGossipIcon")
	normal_texture:SetVertexColor (.9, .8, 0)
	--normal_texture:SetTexCoord (0, .5, 0.875, 1)
	--normal_texture:SetTexCoord (0, 0.375, 0.75, 0.875)
	normal_texture:SetWidth (16)
	normal_texture:SetHeight (16)
	normal_texture:SetPoint ("center", consolidateButton, "center")
	
	consolidateButton:Hide()
	instancia.consolidateButton = consolidateButton
	instancia.consolidateButtonTexture = normal_texture
	
---------> consolidate scripts

	consolidateFrame:SetScript ("OnEnter", function (self)
		consolidateFrame.mouse_over = true
		self:SetScript ("OnUpdate", nil)
	end) 

	consolidateFrame:SetScript ("OnLeave", function (self)
		consolidateFrame.mouse_over = false
		local passou = 0
		self:SetScript ("OnUpdate", function (self, elapsed)
			passou = passou+elapsed
			if (passou > 0.5) then
				if (not _detalhes.popup.active and not BaseFrame.cabecalho.button_mouse_over) then
					consolidateFrame:Hide()
					--normal_texture:SetTexCoord (0, .5, 0.875, 1)
					normal_texture:SetBlendMode ("BLEND")
					self:SetScript ("OnUpdate", nil)
				end
				passou = 0
			end
		end)
	end) 
	
	consolidateButton:SetScript ("OnEnter", function (self)
		gump:Fade (BaseFrame.button_stretch, "alpha", 0.3)
		local passou = 0
		consolidateFrame:SetScript ("OnUpdate", nil)
		--normal_texture:SetTexCoord (.5, 1, 0.875, 1)
		normal_texture:SetBlendMode ("ADD")
		self:SetScript ("OnUpdate", function (self, elapsed)
			passou = passou+elapsed
			if (passou > 0.3) then
				consolidateFrame:Show()
				self:SetScript ("OnUpdate", nil)
			end
		end)
	end)
	
	consolidateButton:SetScript ("OnLeave", function (self) 
		gump:Fade (BaseFrame.button_stretch, -1)
		local passou = 0
		self:SetScript ("OnUpdate", function (self, elapsed)
			passou = passou+elapsed
			if (passou > 0.3) then
				if (not consolidateFrame.mouse_over and not BaseFrame.cabecalho.button_mouse_over and not _detalhes.popup.active) then
					consolidateFrame:Hide()
					normal_texture:SetBlendMode ("BLEND")
					--normal_texture:SetTexCoord (0, .5, 0.875, 1)
				end
				self:SetScript ("OnUpdate", nil)
			end
		end)
	end)
	
	
	
end
