
--note: this file need a major clean up especially on function creation.

local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
local _
local gump = 			_detalhes.gump
local SharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0")

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
local CreateFrame = CreateFrame
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

--constants
local baseframe_strata = "LOW"
local gump_fundo_backdrop = {
	bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16,
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
	
	--local COORDS_LEFT_BALL = {0.15673828125, 0.27978515625, 0.08251953125, 0.20556640625} -- 160 84 287 211 (updated)
	--160 84 287 211
	local COORDS_LEFT_BALL = {0.15576171875, 0.27978515625, 0.08251953125, 0.20556640625} -- 160 84 287 211 (updated)
	
	local COORDS_LEFT_CONNECTOR = {0.29541015625, 0.30126953125, 0.08251953125, 0.20556640625} --302 84 309 211 (updated)
	local COORDS_LEFT_CONNECTOR_NO_ICON = {0.58837890625, 0.59423828125, 0.08251953125, 0.20556640625} -- 602 84 609 211 (updated)
	local COORDS_TOP_BACKGROUND = {0.15673828125, 0.65478515625, 0.22314453125, 0.34619140625} -- 160 228 671 355 (updated)
	
	--local COORDS_RIGHT_BALL = {0.31591796875, 0.43994140625, 0.08251953125, 0.20556640625} --324 84 451 211 (updated)
	local COORDS_RIGHT_BALL = {0.3154296875+0.00048828125, 0.439453125+0.00048828125, 0.08203125, 0.2060546875-0.00048828125} --323 84 450 211 (updated)
	
	--local COORDS_LEFT_BALL_NO_ICON = {0.44970703125, 0.57275390625, 0.08251953125, 0.20556640625} --460 84 587 211 (updated)
	local COORDS_LEFT_BALL_NO_ICON = {0.44970703125, 0.57275390625, 0.08251953125, 0.20556640625} --460 84 587 211 (updated) 588 212

	local COORDS_LEFT_SIDE_BAR = {0.76611328125, 0.82763671875, 0.00244140625, 0.50146484375} -- 784 2 848 514 (updated)
	--local COORDS_LEFT_SIDE_BAR = {0.76611328125, 0.82666015625, 0.00244140625, 0.50048828125} -- 784 2 848 514 (updated)
	--local COORDS_LEFT_SIDE_BAR = {0.765625, 0.8291015625, 0.00244140625, 0.5029296875} -- 784 2 848 514 (updated)
	--784 2 847 513
	
	--local COORDS_RIGHT_SIDE_BAR = {0.70068359375, 0.76220703125, 0.00244140625, 0.50146484375} -- 717 2 781 514 (updated)
	--local COORDS_RIGHT_SIDE_BAR = {0.7001953125, 0.763671875, 0.00244140625, 0.50146484375} -- 717 2 781 514 (updated)
	local COORDS_RIGHT_SIDE_BAR = {0.7001953125+0.00048828125, 0.76171875, 0.001953125, 0.5009765625} -- --717 2 780 513
	
	local COORDS_BOTTOM_SIDE_BAR = {0.32861328125, 0.82666015625, 0.50537109375, 0.56494140625} -- 336 517 847 579 (updated)
	
	local COORDS_SLIDER_TOP = {0.00146484375, 0.03076171875, 0.00244140625, 0.03173828125} -- 1 2 32 33 -ok
	local COORDS_SLIDER_MIDDLE = {0.00146484375, 0.03076171875, 0.03955078125, 0.10009765625} -- 1 40 32 103 -ok
	local COORDS_SLIDER_DOWN = {0.00146484375, 0.03076171875, 0.10986328125, 0.13916015625} -- 1 112 32 143 -ok

	local COORDS_STRETCH = {0.00146484375, 0.03076171875, 0.21435546875, 0.22802734375} -- 1 219 32 234 -ok
	local COORDS_RESIZE_RIGHT = {0.00146484375, 0.01513671875, 0.24560546875, 0.25927734375} -- 1 251 16 266 -ok
	local COORDS_RESIZE_LEFT = {0.02001953125, 0.03173828125, 0.24560546875, 0.25927734375} -- 20 251 33 266 -ok
	
	local COORDS_UNLOCK_BUTTON = {0.00146484375, 0.01513671875, 0.27197265625, 0.28564453125} -- 1 278 16 293 -ok
	
	local COORDS_BOTTOM_BACKGROUND = {0.15673828125, 0.65478515625, 0.35400390625, 0.47705078125} -- 160 362 671 489 -ok
	local COORDS_PIN_LEFT = {0.00146484375, 0.03076171875, 0.30126953125, 0.33056640625} -- 1 308 32 339 -ok
	local COORDS_PIN_RIGHT = {0.03564453125, 0.06494140625, 0.30126953125, 0.33056640625} -- 36 308 67 339 -ok
	
	-- icones: 365 = 0.35693359375 // 397 = 0.38720703125
	
function _detalhes:AtualizarScrollBar (x)

	local cabe = self.rows_fit_in_window --> quantas barras cabem na janela

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
			self.rows_showing = x
			
			if (not self.baseframe.isStretching) then
				self:MostrarScrollBar()
			end
			self.need_rolagem = true
			
			self.barraS[2] = cabe --> B é o total que cabe na barra
		else --> Do contrário B é o total de barras
			self.rows_showing = x
			self.barraS[2] = x
		end
	else
		if (x > self.rows_showing) then --> tem mais barras mostrando agora do que na última atualização
			self.rows_showing = x
			local nao_mostradas = self.rows_showing - self.rows_fit_in_window
			local slider_height = nao_mostradas*self.row_height
			self.scroll.scrollMax = slider_height
			self.scroll:SetMinMaxValues (0, slider_height)
			
		else	--> diminuiu a quantidade, acontece depois de uma coleta de lixo
			self.rows_showing = x
			local nao_mostradas = self.rows_showing - self.rows_fit_in_window
			
			if (nao_mostradas < 1) then  --> se estiver mostrando menos do que realmente cabe não precisa scrollbar
				self:EsconderScrollBar()
			else
				--> contrário, basta atualizar o tamanho da scroll
				local slider_height = nao_mostradas*self.row_height
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
			
			for index = 1, self._move_func.instancia.rows_fit_in_window do
				self._move_func.instancia.barras [index]:SetWidth (self:GetWidth()+self._move_func.instancia.bgdisplay_loc-3)
			end
			self._move_func.instancia.bgdisplay:SetPoint ("bottomright", self, "bottomright", self._move_func.instancia.bgdisplay_loc, 0)
			
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
		for index = 1, self.rows_fit_in_window do
			self.barras [index]:SetWidth (self.baseframe:GetWidth()+mover_para -3) --> -3 distance between row end and scroll start
		end
		--> move the semi-background to the left (which moves the scroll)
		self.bgdisplay:SetPoint ("bottomright", self.baseframe, "bottomright", mover_para, 0)
		
		self.bar_mod = mover_para + (-3)
		self.bgdisplay_loc = mover_para
		
		--> cancel movement if any
		if (self.baseframe:GetScript ("OnUpdate") and self.baseframe:GetScript ("OnUpdate") == move_barras) then
			self.baseframe:SetScript ("OnUpdate", nil)
		end
	end
	
	local nao_mostradas = self.rows_showing - self.rows_fit_in_window
	local slider_height = nao_mostradas*self.row_height
	self.scroll.scrollMax = slider_height
	self.scroll:SetMinMaxValues (0, slider_height)
	
	self.rolagem = true
	self.scroll:Enable()
	main:EnableMouseWheel (true)

	self.scroll:SetValue (0) --> set value pode chamar o atualizador
	self.baseframe.button_down:Enable()
	main.resize_direita:SetPoint ("bottomright", main, "bottomright", self.largura_scroll*-1, 0)
	
	if (main.isLocked) then
		main.lock_button:SetPoint ("bottomright", main, "bottomright", self.largura_scroll*-1, 0)
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
		self:MoveBarrasTo (self.row_info.space.right + 3) --> 
	else
		for index = 1, self.rows_fit_in_window do
			self.barras [index]:SetWidth (self.baseframe:GetWidth() - 5) --> -5 space between row end and window right border
		end
		self.bgdisplay:SetPoint ("bottomright", self.baseframe, "bottomright", 0, 0) -- voltar o background na pocição inicial
		self.bar_mod = 0 -- zera o bar mod, uma vez que as barras vão estar na pocisão inicial
		self.bgdisplay_loc = -2
		if (self.baseframe:GetScript ("OnUpdate") and self.baseframe:GetScript ("OnUpdate") == move_barras) then
			self.baseframe:SetScript ("OnUpdate", nil)
		end
	end

	self.rolagem = false
	self.scroll:Disable()
	main:EnableMouseWheel (false)
	
	main.resize_direita:SetPoint ("bottomright", main, "bottomright", 0, 0)
	if (main.isLocked) then
		main.lock_button:SetPoint ("bottomright", main, "bottomright", 0, 0)
	end
end

local function OnLeaveMainWindow (instancia, self)

	instancia.is_interacting = false
	instancia:SetMenuAlpha (nil, nil, nil, nil, true)
	instancia:SetAutoHideMenu (nil, nil, true)
	
	if (instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"] and not instancia.baseframe.isLocked) then

		--> resizes and lock button
		instancia.baseframe.resize_direita:SetAlpha (0)
		instancia.baseframe.resize_esquerda:SetAlpha (0)
		gump:Fade (instancia.baseframe.lock_button, 1)
		
		--> stretch button
		--gump:Fade (instancia.baseframe.button_stretch, -1)
		gump:Fade (instancia.baseframe.button_stretch, "ALPHA", 0)
		
		--> snaps
		instancia.botao_separar:Hide()
	
	elseif (instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"] and instancia.baseframe.isLocked) then
		gump:Fade (instancia.baseframe.lock_button, 1)
		gump:Fade (instancia.baseframe.button_stretch, "ALPHA", 0)
		instancia.botao_separar:Hide()
		
	end
end
_detalhes.OnLeaveMainWindow = OnLeaveMainWindow

local function OnEnterMainWindow (instancia, self)

	instancia.is_interacting = true
	instancia:SetMenuAlpha (nil, nil, nil, nil, true)
	instancia:SetAutoHideMenu (nil, nil, true)

	if (instancia.baseframe:GetFrameLevel() > instancia.rowframe:GetFrameLevel()) then
		instancia.rowframe:SetFrameLevel (instancia.baseframe:GetFrameLevel())
	end
	
	if (instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"] and not instancia.baseframe.isLocked) then

		--> resizes and lock button
		instancia.baseframe.resize_direita:SetAlpha (1)
		instancia.baseframe.resize_esquerda:SetAlpha (1)

		gump:Fade (instancia.baseframe.lock_button, 0)
		
		--> stretch button
		gump:Fade (instancia.baseframe.button_stretch, "ALPHA", 0.6)
	
		--> snaps
		for _, instancia_id in _pairs (instancia.snap) do
			if (instancia_id) then
				instancia.botao_separar:Show()
				break
			end
		end
		
	elseif (instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"] and instancia.baseframe.isLocked) then
		gump:Fade (instancia.baseframe.lock_button, 0)
		gump:Fade (instancia.baseframe.button_stretch, "ALPHA", 0.6)
		
		--> snaps
		for _, instancia_id in _pairs (instancia.snap) do
			if (instancia_id) then
				instancia.botao_separar:Show()
				break
			end
		end
	
	end
end
_detalhes.OnEnterMainWindow = OnEnterMainWindow

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

local tempo_movendo, precisa_ativar, instancia_alvo, tempo_fades, nao_anexados, flash_bounce
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
					
						if (flash_bounce == 0) then
						
							flash_bounce = 1

							local tem_livre = false
							
							for lado, livre in _ipairs (nao_anexados) do
								if (livre) then
									if (lado == 1) then
										instancia_alvo.h_esquerda:Flash (1, 1, 2.0, false, 0, 0)
										tem_livre = true
									elseif (lado == 2) then
										instancia_alvo.h_baixo:Flash (1, 1, 2.0, false, 0, 0)
										tem_livre = true
									elseif (lado == 3) then
										instancia_alvo.h_direita:Flash (1, 1, 2.0, false, 0, 0)
										tem_livre = true
									elseif (lado == 4) then
										instancia_alvo.h_cima:Flash (1, 1, 2.0, false, 0, 0)
										tem_livre = true
									end
								end
							end
							
							if (tem_livre) then
								if (not _detalhes.snap_alert.playing) then
									instancia_alvo:SnapAlert()
									_detalhes.snap_alert.playing = true
									
									_detalhes.MicroButtonAlert.Text:SetText (string.format (Loc ["STRING_ATACH_DESC"], self.instance.meu_id, instancia_alvo.meu_id))
									_detalhes.MicroButtonAlert:SetPoint ("bottom", instancia_alvo.baseframe.cabecalho.novo, "top", 0, 18)
									_detalhes.MicroButtonAlert:SetHeight (200)
									_detalhes.MicroButtonAlert:Show()
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

local function move_janela (baseframe, iniciando, instancia)

	instancia_alvo = _detalhes.tabela_instancias [instancia.meu_id-1]

	if (iniciando) then
	
		baseframe.isMoving = true
		instancia:BaseFrameSnap()
		baseframe:StartMoving()
		
		local _, ClampLeft, ClampRight = instancia:InstanciasHorizontais()
		local _, ClampBottom, ClampTop = instancia:InstanciasVerticais()
		
		if (ClampTop == 0) then
			ClampTop = 0
		end
		if (ClampBottom == 0) then
			ClampBottom = 0
		end
		
		baseframe:SetClampRectInsets (-ClampLeft, ClampRight, ClampTop, -ClampBottom)
		
		if (instancia_alvo) then
		
			tempo_fades = 1.0
			nao_anexados = {true, true, true, true}
			tempo_movendo = 1
			flash_bounce = 0
			
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

				instancia_alvo:RestauraJanela (instancia_alvo.meu_id, true)
				if (instancia_alvo:IsSoloMode()) then
					_detalhes.SoloTables:switch()
				end
				
				instancia_alvo.ativa = false
				
				instancia_alvo:SaveMainWindowPosition()
				instancia_alvo:RestoreMainWindowPosition()
				
				gump:Fade (instancia_alvo.baseframe, 1)
				gump:Fade (instancia_alvo.rowframe, 1)
				gump:Fade (instancia_alvo.baseframe.cabecalho.ball, 1)
				
				need_start = false
			end
			
			baseframe:SetScript ("OnUpdate", movement_onupdate)
		end
		
	else

		baseframe:StopMovingOrSizing()
		baseframe.isMoving = false
		baseframe:SetScript ("OnUpdate", nil)
		
		--baseframe:SetClampRectInsets (unpack (_detalhes.window_clamp))

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
--# /tar Disassembled Crawler
--# /tar Deactivated Laser Turrets
		_detalhes.snap_alert.playing = false
		_detalhes.snap_alert.animIn:Stop()
		_detalhes.snap_alert.animOut:Play()
		_detalhes.MicroButtonAlert:Hide()

		if (instancia_alvo) then
			instancia_alvo.h_esquerda:Stop()
			instancia_alvo.h_baixo:Stop()
			instancia_alvo.h_direita:Stop()
			instancia_alvo.h_cima:Stop()
		end
		
	end
end

local function BGFrame_scripts (BG, baseframe, instancia)

	BG:SetScript("OnEnter", function (self)
		OnEnterMainWindow (instancia, self)
	end)
	
	BG:SetScript("OnLeave", function (self)
		OnLeaveMainWindow (instancia, self)
	end)
	
	BG:SetScript ("OnMouseDown", function (frame, button)
		if (baseframe.isMoving) then
			move_janela (baseframe, false, instancia)
			instancia:SaveMainWindowPosition()
			return
		end

		if (not baseframe.isLocked and button == "LeftButton") then
			move_janela (baseframe, true, instancia) --> novo movedor da janela
		elseif (button == "RightButton") then
			if (_detalhes.switch.current_instancia and _detalhes.switch.current_instancia == instancia) then
				_detalhes.switch:CloseMe()
			else
				_detalhes.switch:ShowMe (instancia)
			end
		end
	end)

	BG:SetScript ("OnMouseUp", function (frame)
		if (baseframe.isMoving) then
			move_janela (baseframe, false, instancia) --> novo movedor da janela
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
local function BFrame_scripts (baseframe, instancia)

	baseframe:SetScript("OnSizeChanged", function (self)
		instancia:SaveMainWindowPosition()
		instancia:ReajustaGump()
		instancia.oldwith = baseframe:GetWidth()
		_detalhes:SendEvent ("DETAILS_INSTANCE_SIZECHANGED", nil, instancia)
	end)

	baseframe:SetScript("OnEnter", function (self)
		OnEnterMainWindow (instancia, self)
	end)
	
	baseframe:SetScript("OnLeave", function (self)
		OnLeaveMainWindow (instancia, self)
	end)
	
	baseframe:SetScript ("OnMouseDown", function (frame, button)
		if (not baseframe.isLocked and button == "LeftButton") then
			move_janela (baseframe, true, instancia) --> novo movedor da janela
		end
	end)

	baseframe:SetScript ("OnMouseUp", function (frame)
		if (baseframe.isMoving) then
			move_janela (baseframe, false, instancia) --> novo movedor da janela
			instancia:SaveMainWindowPosition()
		end
	end)	

end

local function backgrounddisplay_scripts (backgrounddisplay, baseframe, instancia)

	backgrounddisplay:SetScript ("OnEnter", function (self)
		OnEnterMainWindow (instancia, self)
	end)
	
	backgrounddisplay:SetScript ("OnLeave", function (self) 
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
	{icon = [[Interface\AddOns\Details\images\key_shift]], width = 24, height = 14, l = 0, r = 1, t = 0, b =0.640625},
	
	{text = "+|cff33CC00 Click|cffEEEEEE: " .. Loc ["STRING_RESIZE_VERTICAL"]},
	{icon = [[Interface\AddOns\Details\images\key_alt]], width = 24, height = 14, l = 0, r = 1, t = 0, b =0.640625},
	
	{text = "+|cff33CC00 Click|cffEEEEEE: " .. Loc ["STRING_RESIZE_ALL"]},
	{icon = [[Interface\AddOns\Details\images\key_ctrl]], width = 24, height = 14, l = 0, r = 1, t = 0, b =0.640625}
}

--> search key: ~resizescript
local function resize_scripts (resizer, instancia, scrollbar, side, baseframe)

	resizer:SetScript ("OnMouseDown", function (self, button) 
	
		_G.GameCooltip:ShowMe (false) --> Hide Cooltip
		
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
					instancia.baseframe:StartSizing("left")
					instancia.eh_horizontal = true
				elseif (_IsAltKeyDown()) then
					instancia.baseframe:StartSizing("top")
					instancia.eh_vertical = true
				elseif (_IsControlKeyDown()) then
					instancia.baseframe:StartSizing("bottomleft")
					instancia.eh_tudo = true
				else
					instancia.baseframe:StartSizing("bottomleft")
				end
				
				resizer:SetPoint ("bottomleft", baseframe, "bottomleft", -1, -1)
				resizer.afundado = true
				
			elseif (side == ">") then
				if (_IsShiftKeyDown()) then
					instancia.baseframe:StartSizing("right")
					instancia.eh_horizontal = true
				elseif (_IsAltKeyDown()) then
					instancia.baseframe:StartSizing("top")
					instancia.eh_vertical = true
				elseif (_IsControlKeyDown()) then
					instancia.baseframe:StartSizing("bottomright")
					instancia.eh_tudo = true
				else
					instancia.baseframe:StartSizing("bottomright")
				end
				
				if (instancia.rolagem and _detalhes.use_scroll) then
					resizer:SetPoint ("bottomright", baseframe, "bottomright", (instancia.largura_scroll*-1) + 1, -1)
				else
					resizer:SetPoint ("bottomright", baseframe, "bottomright", 1, -1)
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
						resizer:SetPoint ("bottomright", baseframe, "bottomright", instancia.largura_scroll*-1, 0)
					else
						resizer:SetPoint ("bottomright", baseframe, "bottomright", 0, 0)
					end
				else
					resizer:SetPoint ("bottomleft", baseframe, "bottomleft", 0, 0)
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
		
	resizer:SetScript ("OnHide", function (self) 
		if (self.going_hide) then
			_G.GameCooltip:ShowMe (false)
			self.going_hide = nil
		end
	end)
	
	resizer:SetScript ("OnEnter", function (self) 
		if (instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"] and not instancia.baseframe.isLocked and not self.mostrando) then

			OnEnterMainWindow (instancia, self)
		
			self.texture:SetBlendMode ("ADD")
			self.mostrando = true
			
			_G.GameCooltip:Reset()
			_G.GameCooltip:SetType ("tooltip")
			_G.GameCooltip:AddFromTable (resizeTooltip)
			_G.GameCooltip:SetOption ("NoLastSelectedBar", true)
			_G.GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
			_G.GameCooltip:SetOwner (resizer)
			_G.GameCooltip:ShowCooltip()
		end
	end)
	
	resizer:SetScript ("OnLeave", function (self) 

		if (self.mostrando) then

			resizer.going_hide = true
			if (not self.movendo) then
				OnLeaveMainWindow (instancia, self)
			end

			self.texture:SetBlendMode ("BLEND")
			self.mostrando = false
			
			_G.GameCooltip:ShowMe (false)
		end
	end)
end

local lockButtonTooltip = {
	{text = Loc ["STRING_LOCK_DESC"]},
	{icon = [[Interface\PetBattles\PetBattle-LockIcon]], width = 14, height = 14, l = 0.0703125, r = 0.9453125, t = 0.0546875, b = 0.9453125, color = "orange"},
}

local lockFunctionOnEnter = function (self)
	OnEnterMainWindow (self.instancia, self)
	
	if (self.instancia.modo ~= _detalhes._detalhes_props["MODO_ALONE"]) then
		self.label:SetTextColor (1, 1, 1, .6)
		self.mostrando = true
		
		GameCooltip:Reset()
		GameCooltip:AddFromTable (lockButtonTooltip)
		GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
		GameCooltip:ShowCooltip (self, "tooltip")
		
	end
end
 
local lockFunctionOnLeave = function (self)
	OnLeaveMainWindow (self.instancia, self)
	self.label:SetTextColor (.3, .3, .3, .6)
	self.mostrando = false
	GameCooltip:Hide()
end

local lockFunctionOnClick = function (button)
	local baseframe = button:GetParent()
	if (baseframe.isLocked) then
		baseframe.isLocked = false
		baseframe.instance.isLocked = false
		button.label:SetText (Loc ["STRING_LOCK_WINDOW"])
		button:SetWidth (button.label:GetStringWidth()+2)
		baseframe.resize_direita:SetAlpha (1)
		baseframe.resize_esquerda:SetAlpha (1)
		button:ClearAllPoints()
		button:SetPoint ("right", baseframe.resize_direita, "left", -1, 1.5)		
	else
		baseframe.isLocked = true
		baseframe.instance.isLocked = true
		button.label:SetText (Loc ["STRING_UNLOCK_WINDOW"])
		button:SetWidth (button.label:GetStringWidth()+2)
		button:ClearAllPoints()
		button:SetPoint ("bottomright", baseframe, "bottomright", -3, 0)
		baseframe.resize_direita:SetAlpha (0)
		baseframe.resize_esquerda:SetAlpha (0)
	end
end
_detalhes.lock_instance_function = lockFunctionOnClick

local unSnapButtonTooltip = {
	{text = Loc ["STRING_DETACH_DESC"]},
	{icon = [[Interface\CURSOR\CURSORICONSNEW]], width = 14, height = 14, l = 4/128, r = 24/128, t = 34/256, b = 60/256, color = "orange"},
}

local unSnapButtonOnEnter = function (self)
	OnEnterMainWindow (self.instancia, self)
	self.mostrando = true
	
	GameCooltip:Reset()
	GameCooltip:AddFromTable (unSnapButtonTooltip)
	GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
	GameCooltip:ShowCooltip (self, "tooltip")
	
end

local unSnapButtonOnLeave = function (self)
	OnLeaveMainWindow (self.instancia, self)
	self.mostrando = false
	GameCooltip:Hide()
end

local shift_monitor = function (self)
	if (_IsShiftKeyDown()) then
		if (not self.showing_allspells) then
			self.showing_allspells = true
			local instancia = _detalhes:GetInstance (self.instance_id)
			instancia:MontaTooltip (self, self.row_id, "shift")
		end
		
	elseif (self.showing_allspells) then
		self.showing_allspells = false
		local instancia = _detalhes:GetInstance (self.instance_id)
		instancia:MontaTooltip (self, self.row_id)
	end
	
	if (_IsControlKeyDown()) then
		if (not self.showing_alltargets) then
			self.showing_alltargets = true
			local instancia = _detalhes:GetInstance (self.instance_id)
			instancia:MontaTooltip (self, self.row_id, "ctrl")
		end
		
	elseif (self.showing_alltargets) then
		self.showing_alltargets = false
		local instancia = _detalhes:GetInstance (self.instance_id)
		instancia:MontaTooltip (self, self.row_id)
	end
	
	if (_IsAltKeyDown()) then
		if (not self.showing_allpets) then
			self.showing_allpets = true
			local instancia = _detalhes:GetInstance (self.instance_id)
			instancia:MontaTooltip (self, self.row_id, "alt")
		end
		
	elseif (self.showing_allpets) then
		self.showing_allpets = false
		local instancia = _detalhes:GetInstance (self.instance_id)
		instancia:MontaTooltip (self, self.row_id)
	end
end

local function barra_scripts (esta_barra, instancia, i)

	esta_barra:SetScript ("OnEnter", function (self) 
		self.mouse_over = true
		OnEnterMainWindow (instancia, esta_barra)

		instancia:MontaTooltip (self, i)
		
		self:SetBackdrop({
			bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], 
			tile = true, tileSize = 16,
			insets = {left = 1, right = 1, top = 0, bottom = 1},})	
			self:SetBackdropColor (0.588, 0.588, 0.588, 0.7)
			
		self:SetScript ("OnUpdate", shift_monitor)
			
	end)

	esta_barra:SetScript ("OnLeave", function (self) 
		self.mouse_over = false
		OnLeaveMainWindow (instancia, self)
		
		_GameTooltip:Hide()
		_G.GameCooltip:ShowMe (false)
		
		self:SetBackdrop({
			bgFile = "", edgeFile = "", tile = true, tileSize = 16, edgeSize = 32,
			insets = {left = 1, right = 1, top = 0, bottom = 1},})	

			self:SetBackdropBorderColor (0, 0, 0, 0)
			self:SetBackdropColor (0, 0, 0, 0)
		
		self.showing_allspells = false
		self:SetScript ("OnUpdate", nil)
		
	end)

	esta_barra:SetScript ("OnMouseDown", function (self, button)
		
		if (esta_barra.fading_in) then
			return
		end

		if (button == "RightButton") then
			return _detalhes.switch:ShowMe (instancia)
		end
	
		esta_barra.texto_direita:SetPoint ("right", esta_barra.statusbar, "right", 1, -1)
		if (instancia.row_info.no_icon) then
			esta_barra.texto_esquerdo:SetPoint ("left", esta_barra.statusbar, "left", 3, -1)
		else
			esta_barra.texto_esquerdo:SetPoint ("left", esta_barra.icone_classe, "right", 4, -1)
		end
	
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

		esta_barra.texto_direita:SetPoint ("right", esta_barra.statusbar, "right")
		if (instancia.row_info.no_icon) then
			esta_barra.texto_esquerdo:SetPoint ("left", esta_barra.statusbar, "left", 2, 0)
		else
			esta_barra.texto_esquerdo:SetPoint ("left", esta_barra.icone_classe, "right", 3, 0)
		end
		
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

	esta_barra:SetScript ("OnClick", function (self, button)

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

local function button_stretch_scripts (baseframe, backgrounddisplay, instancia)
	local button = baseframe.button_stretch

	button:SetScript ("OnEnter", function (self)
		self.mouse_over = true
		gump:Fade (self, "ALPHA", 1)
	end)
	button:SetScript ("OnLeave", function (self)
		self.mouse_over = false
		gump:Fade (self, "ALPHA", 0)
	end)	

	button:SetScript ("OnMouseDown", function (self)

		if (instancia:IsSoloMode()) then
			return
		end
	
		instancia:EsconderScrollBar (true)
		baseframe._place = instancia:SaveMainWindowPosition()
		baseframe.isResizing = true
		baseframe.isStretching = true
		baseframe:SetFrameStrata ("TOOLTIP")
		instancia.rowframe:SetFrameStrata ("TOOLTIP")
		
		local _r, _g, _b, _a = baseframe:GetBackdropColor()
		gump:GradientEffect ( baseframe, "frame", _r, _g, _b, _a, _r, _g, _b, 0.9, 1.5)
		if (instancia.wallpaper.enabled) then
			_r, _g, _b = baseframe.wallpaper:GetVertexColor()
			_a = baseframe.wallpaper:GetAlpha()
			gump:GradientEffect (baseframe.wallpaper, "texture", _r, _g, _b, _a, _r, _g, _b, 0.05, 0.5)
		end
		
		if (instancia.stretch_button_side == 1) then
			baseframe:StartSizing ("top")
		elseif (instancia.stretch_button_side == 2) then
			baseframe:StartSizing ("bottom")
		end
		
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
				esta_instancia.rowframe:SetFrameStrata ("TOOLTIP")
				
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
	
		if (baseframe.isResizing) then 
			baseframe:StopMovingOrSizing()
			baseframe.isResizing = false
			instancia:RestoreMainWindowPosition (baseframe._place)
			instancia:ReajustaGump()
			baseframe.isStretching = false
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
					
					esta_instancia.baseframe:SetFrameStrata (esta_instancia.strata)
					esta_instancia.rowframe:SetFrameStrata (esta_instancia.strata)
					esta_instancia:StretchButtonAlwaysOnTop()
					
					_detalhes:SendEvent ("DETAILS_INSTANCE_ENDSTRETCH", nil, esta_instancia.baseframe)
				end
				instancia.stretchToo = nil
			end
			
		end 
		
		local _r, _g, _b, _a = baseframe:GetBackdropColor()
		gump:GradientEffect ( baseframe, "frame", _r, _g, _b, _a, instancia.bg_r, instancia.bg_g, instancia.bg_b, instancia.bg_alpha, 0.5)
		if (instancia.wallpaper.enabled) then
			_r, _g, _b = baseframe.wallpaper:GetVertexColor()
			_a = baseframe.wallpaper:GetAlpha()
			gump:GradientEffect (baseframe.wallpaper, "texture", _r, _g, _b, _a, _r, _g, _b, instancia.wallpaper.alpha, 1.0)
		end
		
		baseframe:SetFrameStrata (instancia.strata)
		instancia.rowframe:SetFrameStrata (instancia.strata)
		instancia:StretchButtonAlwaysOnTop()
		
		_detalhes:SnapTextures (false)
		
		_detalhes:SendEvent ("DETAILS_INSTANCE_ENDSTRETCH", nil, instancia)
	end)	
end

local function button_down_scripts (main_frame, backgrounddisplay, instancia, scrollbar)
	main_frame.button_down:SetScript ("OnMouseDown", function(self)
		if (not scrollbar:IsEnabled()) then
			return
		end
		
		local B = instancia.barraS[2]
		if (B < instancia.rows_showing) then
			scrollbar:SetValue (scrollbar:GetValue() + instancia.row_height)
		end
		
		self.precionado = true
		self.last_up = -0.3
		self:SetScript ("OnUpdate", function(self, elapsed)
			self.last_up = self.last_up + elapsed
			if (self.last_up > 0.03) then
				self.last_up = 0
				B = instancia.barraS[2]
				if (B < instancia.rows_showing) then
					scrollbar:SetValue (scrollbar:GetValue() + instancia.row_height)
				else
					self:Disable()
				end
			end
		end)
	end)
	
	main_frame.button_down:SetScript ("OnMouseUp", function (self) 
		self.precionado = false
		self:SetScript ("OnUpdate", nil)
	end)
end

local function button_up_scripts (main_frame, backgrounddisplay, instancia, scrollbar)

	main_frame.button_up:SetScript ("OnMouseDown", function(self) 

		if (not scrollbar:IsEnabled()) then
			return
		end
		
		local A = instancia.barraS[1]
		if (A > 1) then
			scrollbar:SetValue (scrollbar:GetValue() - instancia.row_height)
		end
		
		self.precionado = true
		self.last_up = -0.3
		self:SetScript ("OnUpdate", function (self, elapsed)
			self.last_up = self.last_up + elapsed
			if (self.last_up > 0.03) then
				self.last_up = 0
				A = instancia.barraS[1]
				if (A > 1) then
					scrollbar:SetValue (scrollbar:GetValue() - instancia.row_height)
				else
					self:Disable()
				end
			end
		end)
	end)
	
	main_frame.button_up:SetScript ("OnMouseUp", function (self) 
		self.precionado = false
		self:SetScript ("OnUpdate", nil)
	end)	

	main_frame.button_up:SetScript ("OnEnable", function (self)
		local current = scrollbar:GetValue()
		if (current == 0) then
			main_frame.button_up:Disable()
		end
	end)
end

function DetailsKeyBindScrollUp()

	local last_key_pressed = _detalhes.KeyBindScrollUpLastPressed or GetTime()-0.3
	
	local to_top = false
	if (last_key_pressed+0.2 > GetTime()) then
		to_top = true
	end
	
	_detalhes.KeyBindScrollUpLastPressed = GetTime()
	
	for index, instance in ipairs (_detalhes.tabela_instancias) do
		if (instance:IsEnabled()) then
			
			local scrollbar = instance.scroll
			
			local A = instance.barraS[1]
			if (A and A > 1) then
				if (to_top) then
					scrollbar:SetValue (0)
					scrollbar.ultimo = 0
					instance.baseframe.button_up:Disable()
				else
					scrollbar:SetValue (scrollbar:GetValue() - instance.row_height*2)
				end
			elseif (A) then
				scrollbar:SetValue (0)
				scrollbar.ultimo = 0
				instance.baseframe.button_up:Disable()
			end
			
		end
	end
end

function DetailsKeyBindScrollDown()
	for index, instance in ipairs (_detalhes.tabela_instancias) do
		if (instance:IsEnabled()) then
			
			local scrollbar = instance.scroll
			
			local B = instance.barraS[2]
			if (B and B < instance.rows_showing) then
				scrollbar:SetValue (scrollbar:GetValue() + instance.row_height*2)
			elseif (B) then
				local _, maxValue = scrollbar:GetMinMaxValues()
				scrollbar:SetValue (maxValue)
				scrollbar.ultimo = maxValue
				instance.baseframe.button_down:Disable()
			end
			
		end
	end
end

local function iterate_scroll_scripts (backgrounddisplay, backgroundframe, baseframe, scrollbar, instancia)

	baseframe:SetScript ("OnMouseWheel", 
		function (self, delta)
			if (delta > 0) then --> rolou pra cima
				local A = instancia.barraS[1]
				if (A > 1) then
					scrollbar:SetValue (scrollbar:GetValue() - instancia.row_height)
				else
					scrollbar:SetValue (0)
					scrollbar.ultimo = 0
					baseframe.button_up:Disable()
				end
			elseif (delta < 0) then --> rolou pra baixo
				local B = instancia.barraS[2]
				if (B < instancia.rows_showing) then
					scrollbar:SetValue (scrollbar:GetValue() + instancia.row_height)
				else
					local _, maxValue = scrollbar:GetMinMaxValues()
					scrollbar:SetValue (maxValue)
					scrollbar.ultimo = maxValue
					baseframe.button_down:Disable()
				end
			end

		end)

	scrollbar:SetScript ("OnValueChanged", function (self)
		local ultimo = self.ultimo
		local meu_valor = self:GetValue()
		if (ultimo == meu_valor) then --> não mudou
			return
		end
		
		--> shortcut
		local minValue, maxValue = scrollbar:GetMinMaxValues()
		if (minValue == meu_valor) then
			instancia.barraS[1] = 1
			instancia.barraS[2] = instancia.rows_fit_in_window
			instancia:AtualizaGumpPrincipal (instancia, true)
			self.ultimo = meu_valor
			baseframe.button_up:Disable()
				return
		elseif (maxValue == meu_valor) then
			local min = instancia.rows_showing -instancia.rows_fit_in_window
			min = min+1
			if (min < 1) then
				min = 1
			end
			instancia.barraS[1] = min
			instancia.barraS[2] = instancia.rows_showing
			instancia:AtualizaGumpPrincipal (instancia, true)
			self.ultimo = meu_valor
			baseframe.button_down:Disable()
			return
		end
		
		if (not baseframe.button_up:IsEnabled()) then
			baseframe.button_up:Enable()
		end
		if (not baseframe.button_down:IsEnabled()) then
			baseframe.button_down:Enable()
		end
		
		if (meu_valor > ultimo) then --> scroll down
		
			local B = instancia.barraS[2]
			if (B < instancia.rows_showing) then --> se o valor maximo não for o máximo de barras a serem mostradas	
				local precisa_passar = ((B+1) * instancia.row_height) - (instancia.row_height*instancia.rows_fit_in_window)
				if (meu_valor > precisa_passar) then --> o valor atual passou o valor que precisa passar pra locomover
					local diff = meu_valor - ultimo --> pega a diferença de H
					diff = diff / instancia.row_height --> calcula quantas barras ele pulou
					diff = _math_ceil (diff) --> arredonda para cima
					if (instancia.barraS[2]+diff > instancia.rows_showing and ultimo > 0) then
						instancia.barraS[1] = instancia.rows_showing - (instancia.rows_fit_in_window-1)
						instancia.barraS[2] = instancia.rows_showing
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
				local precisa_passar = (A-1) * instancia.row_height
				if (meu_valor < precisa_passar) then
					--> calcula quantas barras passou
					local diff = ultimo - meu_valor
					diff = diff / instancia.row_height
					diff = _math_ceil (diff)
					if (instancia.barraS[1]-diff < 1) then
						instancia.barraS[2] = instancia.rows_fit_in_window
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
			local texture, w, h, animate, l, r, t, b, r, g, b, a = unpack (icon)
			
			self.alert.icon:SetTexture (texture)
			self.alert.icon:SetWidth (w or 14)
			self.alert.icon:SetHeight (h or 14)
			if (l and r and t and b) then
				self.alert.icon:SetTexCoord (l, r, t, b)
			end
			if (animate) then
				self.alert.rotate:Play()
			end
			if (r and g and b) then
				self.alert.icon:SetVertexColor (r, g, b, a or 1)
			end
		else
			self.alert.icon:SetWidth (14)
			self.alert.icon:SetHeight (14)
			self.alert.icon:SetTexture (icon)
			self.alert.icon:SetVertexColor (1, 1, 1, 1)
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
	
	self.alert:SetPoint ("bottom", self.baseframe, "bottom", 0, -12)
	self.alert:SetPoint ("left", self.baseframe, "left", 3, 0)
	self.alert:SetPoint ("right", self.baseframe, "right", -3, 0)
	
	self.alert:Show()
	self.alert:Play()
end

function CreateAlertFrame (baseframe, instancia)

	local frame_upper = CreateFrame ("scrollframe", "DetailsAlertFrameScroll" .. instancia.meu_id, baseframe)
	frame_upper:SetPoint ("bottom", baseframe, "bottom")
	frame_upper:SetPoint ("left", baseframe, "left", 3, 0)
	frame_upper:SetPoint ("right", baseframe, "right", -3, 0)
	frame_upper:SetHeight (13)
	frame_upper:SetFrameStrata ("fullscreen")
	
	local frame_lower = CreateFrame ("frame", "DetailsAlertFrameScrollChild" .. instancia.meu_id, frame_upper)
	frame_lower:SetHeight (25)
	frame_lower:SetPoint ("left", frame_upper, "left")
	frame_lower:SetPoint ("right", frame_upper, "right")
	frame_upper:SetScrollChild (frame_lower)

	local alert_bg = CreateFrame ("frame", "DetailsAlertFrame" .. instancia.meu_id, frame_lower)
	alert_bg:SetPoint ("bottom", baseframe, "bottom")
	alert_bg:SetPoint ("left", baseframe, "left", 3, 0)
	alert_bg:SetPoint ("right", baseframe, "right", -3, 0)
	alert_bg:SetHeight (12)
	alert_bg:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16,
	insets = {left = 0, right = 0, top = 0, bottom = 0}})
	alert_bg:SetBackdropColor (.1, .1, .1, 1)
	alert_bg:SetFrameStrata ("HIGH")
	alert_bg:SetFrameLevel (baseframe:GetFrameLevel() + 6)
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
	
	local rotate_frame = CreateFrame ("frame", "DetailsAlertFrameRotate" .. instancia.meu_id, alert_bg)
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
	
	local anime = alert_bg:CreateAnimationGroup()
	anime.group = anime:CreateAnimation ("Translation")
	anime.group:SetDuration (0.15)
	--anime.group:SetSmoothing ("OUT")
	anime.group:SetOffset (0, 10)
	anime:SetScript ("OnFinished", function(self) 
		alert_bg:Show()
		alert_bg:SetPoint ("bottom", baseframe, "bottom", 0, 0)
		alert_bg:SetPoint ("left", baseframe, "left", 3, 0)
		alert_bg:SetPoint ("right", baseframe, "right", -3, 0)
	end)
	
	function alert_bg:Play()
		anime:Play()
	end
	
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

function _detalhes:schedule_hide_anti_overlap (self)
	self:Hide()
	self.schdule = nil
end
local function hide_anti_overlap (self)
	if (self.schdule) then
		_detalhes:CancelTimer (self.schdule)
		self.schdule = nil
	end
	local schdule = _detalhes:ScheduleTimer ("schedule_hide_anti_overlap", 0.3, self)
	self.schdule = schdule
end

local function show_anti_overlap (instance, host, side)

	local anti_menu_overlap = instance.baseframe.anti_menu_overlap

	if (anti_menu_overlap.schdule) then
		_detalhes:CancelTimer (anti_menu_overlap.schdule)
		anti_menu_overlap.schdule = nil
	end

	anti_menu_overlap:ClearAllPoints()
	if (side == "top") then
		anti_menu_overlap:SetPoint ("bottom", host, "top")
	elseif (side == "bottom") then
		anti_menu_overlap:SetPoint ("top", host, "bottom")
	end
	anti_menu_overlap:Show()
end

_detalhes.snap_alert = CreateFrame ("frame", "DetailsSnapAlertFrame", UIParent, "ActionBarButtonSpellActivationAlert")
_detalhes.snap_alert:Hide()
_detalhes.snap_alert:SetFrameStrata ("FULLSCREEN")

function _detalhes:SnapAlert()
	_detalhes.snap_alert:ClearAllPoints()
	_detalhes.snap_alert:SetPoint ("topleft", self.baseframe.cabecalho.novo, "topleft", -8, 6)
	_detalhes.snap_alert:SetPoint ("bottomright", self.baseframe.cabecalho.novo, "bottomright", 8, -6)
	_detalhes.snap_alert.animOut:Stop()
	_detalhes.snap_alert.animIn:Play()
end

do

	local tooltip_anchor = CreateFrame ("frame", "DetailsTooltipAnchor", UIParent)
	tooltip_anchor:SetSize (140, 20)
	tooltip_anchor:SetAlpha (0)
	tooltip_anchor:SetMovable (false)
	tooltip_anchor:SetClampedToScreen (true)
	tooltip_anchor.locked = true
	tooltip_anchor:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]], edgeSize = 10, insets = {left = 1, right = 1, top = 2, bottom = 1}})
	tooltip_anchor:SetBackdropColor (0, 0, 0, 1)

	tooltip_anchor:SetScript ("OnEnter", function (self)
		tooltip_anchor.alert.animIn:Stop()
		tooltip_anchor.alert.animOut:Play()
		GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine (Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TEXT_DESC"])
		GameTooltip:Show()
	end)
	
	tooltip_anchor:SetScript ("OnLeave", function (self)
		GameTooltip:Hide()
	end)
	
	tooltip_anchor:SetScript ("OnMouseDown", function (self, button)
		if (not self.moving and button == "LeftButton") then
			self:StartMoving()
			self.moving = true
		end
	end)
	
	tooltip_anchor:SetScript ("OnMouseUp", function (self, button)
		if (self.moving) then
			self:StopMovingOrSizing()
			self.moving = false
			local xofs, yofs = self:GetCenter() 
			local scale = self:GetEffectiveScale()
			local UIscale = UIParent:GetScale()
			xofs = xofs * scale - GetScreenWidth() * UIscale / 2
			yofs = yofs * scale - GetScreenHeight() * UIscale / 2
			_detalhes.tooltip.anchor_screen_pos[1] = xofs / UIscale
			_detalhes.tooltip.anchor_screen_pos[2] = yofs / UIscale
			
		elseif (button == "RightButton" and not self.moving) then
			tooltip_anchor:MoveAnchor()
		end
	end)
	
	function tooltip_anchor:MoveAnchor()
		if (self.locked) then
			self:SetAlpha (1)
			self:EnableMouse (true)
			self:SetMovable (true)
			self:SetFrameStrata ("FULLSCREEN")
			self.locked = false
			tooltip_anchor.alert.animOut:Stop()
			tooltip_anchor.alert.animIn:Play()
		else
			self:SetAlpha (0)
			self:EnableMouse (false)
			self:SetFrameStrata ("MEDIUM")
			self:SetMovable (false)
			self.locked = true
			tooltip_anchor.alert.animIn:Stop()
			tooltip_anchor.alert.animOut:Play()
		end
	end
	
	function tooltip_anchor:Restore()
		local x, y = _detalhes.tooltip.anchor_screen_pos[1], _detalhes.tooltip.anchor_screen_pos[2]
		local scale = self:GetEffectiveScale() 
		local UIscale = UIParent:GetScale()
		x = x * UIscale / scale
		y = y * UIscale / scale
		self:ClearAllPoints()
		self:SetParent (UIParent)
		self:SetPoint ("center", UIParent, "center", x, y)
	end
	
	tooltip_anchor.alert = CreateFrame ("frame", "DetailsTooltipAnchorAlert", UIParent, "ActionBarButtonSpellActivationAlert")
	tooltip_anchor.alert:SetFrameStrata ("FULLSCREEN")
	tooltip_anchor.alert:Hide()
	tooltip_anchor.alert:SetPoint ("topleft", tooltip_anchor, "topleft", -60, 6)
	tooltip_anchor.alert:SetPoint ("bottomright", tooltip_anchor, "bottomright", 40, -6)

	local icon = tooltip_anchor:CreateTexture (nil, "overlay")
	icon:SetTexture ([[Interface\AddOns\Details\images\minimap]])
	icon:SetPoint ("left", tooltip_anchor, "left", 4, 0)
	icon:SetSize (18, 18)
	
	local text = tooltip_anchor:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
	text:SetPoint ("left", icon, "right", 6, 0)
	text:SetText (Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TEXT"])
	
	tooltip_anchor:EnableMouse (false)

end

--> ~inicio ~janela ~window ~nova
function gump:CriaJanelaPrincipal (ID, instancia, criando)

-- main frames -----------------------------------------------------------------------------------------------------------------------------------------------

	local baseframe = CreateFrame ("scrollframe", "DetailsBaseFrame"..ID, _UIParent) --> main frame
	baseframe.instance = instancia
	baseframe:SetFrameStrata (baseframe_strata)
	baseframe:SetFrameLevel (2)

	local backgroundframe =  CreateFrame ("scrollframe", "Details_WindowFrame"..ID, baseframe) --> main window
	local backgrounddisplay = CreateFrame ("frame", "Details_GumpFrame"..ID, backgroundframe) --> background window
	backgroundframe:SetFrameLevel (3)
	backgrounddisplay:SetFrameLevel (3)
	backgroundframe.instance = instancia
	backgrounddisplay.instance = instancia

	local rowframe = CreateFrame ("frame", "DetailsRowFrame"..ID, _UIParent) --> main frame
	rowframe:SetAllPoints (baseframe)
	rowframe:SetFrameStrata (baseframe_strata)
	rowframe:SetFrameLevel (2)
	instancia.rowframe = rowframe
	
	local switchbutton = gump:NewDetailsButton (backgrounddisplay, baseframe, nil, function() end, nil, nil, 1, 1, "", "", "", "", 
	{rightFunc = {func = function() _detalhes.switch:ShowMe (instancia) end, param1 = nil, param2 = nil}}, "Details_SwitchButtonFrame" ..  ID)
	
	switchbutton:SetPoint ("topleft", backgrounddisplay, "topleft")
	switchbutton:SetPoint ("bottomright", backgrounddisplay, "bottomright")
	switchbutton:SetFrameLevel (backgrounddisplay:GetFrameLevel()+1)
	
	local anti_menu_overlap = CreateFrame ("frame", "Details_WindowFrameAntiMenuOverlap" .. ID, baseframe)
	anti_menu_overlap:SetSize (100, 13)
	anti_menu_overlap:SetFrameStrata ("DIALOG")
	anti_menu_overlap:EnableMouse (true)
	anti_menu_overlap:Hide()
	--anti_menu_overlap:SetBackdrop (gump_fundo_backdrop)
	baseframe.anti_menu_overlap = anti_menu_overlap

-- scroll bar -----------------------------------------------------------------------------------------------------------------------------------------------

	local scrollbar = CreateFrame ("slider", "Details_ScrollBar"..ID, backgrounddisplay) --> scroll
	
	--> scroll image-node up
		baseframe.scroll_up = backgrounddisplay:CreateTexture (nil, "background")
		baseframe.scroll_up:SetPoint ("topleft", backgrounddisplay, "topright", 0, 0)
		baseframe.scroll_up:SetTexture (DEFAULT_SKIN)
		baseframe.scroll_up:SetTexCoord (unpack (COORDS_SLIDER_TOP))
		baseframe.scroll_up:SetWidth (32)
		baseframe.scroll_up:SetHeight (32)
	
	--> scroll image-node down
		baseframe.scroll_down = backgrounddisplay:CreateTexture (nil, "background")
		baseframe.scroll_down:SetPoint ("bottomleft", backgrounddisplay, "bottomright", 0, 0)
		baseframe.scroll_down:SetTexture (DEFAULT_SKIN)
		baseframe.scroll_down:SetTexCoord (unpack (COORDS_SLIDER_DOWN))
		baseframe.scroll_down:SetWidth (32)
		baseframe.scroll_down:SetHeight (32)
	
	--> scroll image-node middle
		baseframe.scroll_middle = backgrounddisplay:CreateTexture (nil, "background")
		baseframe.scroll_middle:SetPoint ("top", baseframe.scroll_up, "bottom", 0, 8)
		baseframe.scroll_middle:SetPoint ("bottom", baseframe.scroll_down, "top", 0, -11)
		baseframe.scroll_middle:SetTexture (DEFAULT_SKIN)
		baseframe.scroll_middle:SetTexCoord (unpack (COORDS_SLIDER_MIDDLE))
		baseframe.scroll_middle:SetWidth (32)
		baseframe.scroll_middle:SetHeight (64)
	
	--> scroll widgets
		baseframe.button_up = CreateFrame ("button", "DetailsScrollUp" .. instancia.meu_id, backgrounddisplay)
		baseframe.button_down = CreateFrame ("button", "DetailsScrollDown" .. instancia.meu_id, backgrounddisplay)
	
		baseframe.button_up:SetWidth (29)
		baseframe.button_up:SetHeight (32)
		baseframe.button_up:SetNormalTexture ([[Interface\BUTTONS\UI-ScrollBar-ScrollUpButton-Up]])
		baseframe.button_up:SetPushedTexture ([[Interface\BUTTONS\UI-ScrollBar-ScrollUpButton-Down]])
		baseframe.button_up:SetDisabledTexture ([[Interface\BUTTONS\UI-ScrollBar-ScrollUpButton-Disabled]])
		baseframe.button_up:Disable()

		baseframe.button_down:SetWidth (29)
		baseframe.button_down:SetHeight (32)
		baseframe.button_down:SetNormalTexture ([[Interface\BUTTONS\UI-ScrollBar-ScrollDownButton-Up]])
		baseframe.button_down:SetPushedTexture ([[Interface\BUTTONS\UI-ScrollBar-ScrollDownButton-Down]])
		baseframe.button_down:SetDisabledTexture ([[Interface\BUTTONS\UI-ScrollBar-ScrollDownButton-Disabled]])
		baseframe.button_down:Disable()

		baseframe.button_up:SetPoint ("topright", baseframe.scroll_up, "topright", -4, 3)
		baseframe.button_down:SetPoint ("bottomright", baseframe.scroll_down, "bottomright", -4, -6)

		scrollbar:SetPoint ("top", baseframe.button_up, "bottom", 0, 12)
		scrollbar:SetPoint ("bottom", baseframe.button_down, "top", 0, -12)
		scrollbar:SetPoint ("left", backgrounddisplay, "right", 3, 0)
		scrollbar:Show()

		--> config set
		scrollbar:SetOrientation ("VERTICAL")
		scrollbar.scrollMax = 0 --default - tamanho da janela de fundo
		scrollbar:SetMinMaxValues (0, 0)
		scrollbar:SetValue (0)
		scrollbar.ultimo = 0
		
		--> thumb
		scrollbar.thumb = scrollbar:CreateTexture (nil, "overlay")
		scrollbar.thumb:SetTexture ([[Interface\Buttons\UI-ScrollBar-Knob]])
		scrollbar.thumb:SetSize (29, 30)
		scrollbar:SetThumbTexture (scrollbar.thumb)
		
		--> scripts
		button_down_scripts (baseframe, backgrounddisplay, instancia, scrollbar)
		button_up_scripts (baseframe, backgrounddisplay, instancia, scrollbar)
	
-- stretch button -----------------------------------------------------------------------------------------------------------------------------------------------

		baseframe.button_stretch = CreateFrame ("button", "DetailsButtonStretch" .. instancia.meu_id, baseframe)
		baseframe.button_stretch:SetPoint ("bottom", baseframe, "top", 0, 20)
		baseframe.button_stretch:SetPoint ("right", baseframe, "right", -27, 0)
		baseframe.button_stretch:SetFrameLevel (15)
		--baseframe.button_stretch:SetFrameStrata ("FULLSCREEN")
	
		local stretch_texture = baseframe.button_stretch:CreateTexture (nil, "overlay")
		stretch_texture:SetTexture (DEFAULT_SKIN)
		stretch_texture:SetTexCoord (unpack (COORDS_STRETCH))
		stretch_texture:SetWidth (32)
		stretch_texture:SetHeight (16)
		stretch_texture:SetAllPoints (baseframe.button_stretch)
		baseframe.button_stretch.texture = stretch_texture
		
		baseframe.button_stretch:SetWidth (32)
		baseframe.button_stretch:SetHeight (16)
		
		baseframe.button_stretch:Show()
		gump:Fade (baseframe.button_stretch, "ALPHA", 0)

		button_stretch_scripts (baseframe, backgrounddisplay, instancia)

-- main window config -------------------------------------------------------------------------------------------------------------------------------------------------

		baseframe:SetClampedToScreen (true)
		--baseframe:SetClampRectInsets (unpack (_detalhes.window_clamp))
		
		baseframe:SetSize (_detalhes.new_window_size.width, _detalhes.new_window_size.height)
		
		baseframe:SetPoint ("center", _UIParent)
		baseframe:EnableMouseWheel (false)
		baseframe:EnableMouse (true)
		baseframe:SetMovable (true)
		baseframe:SetResizable (true)
		baseframe:SetMinResize (150, 7)
		baseframe:SetMaxResize (_detalhes.max_window_size.width, _detalhes.max_window_size.height)

		baseframe:SetBackdrop (gump_fundo_backdrop)
		baseframe:SetBackdropColor (instancia.bg_r, instancia.bg_g, instancia.bg_b, instancia.bg_alpha)
	
-- background window config -------------------------------------------------------------------------------------------------------------------------------------------------

		backgroundframe:SetAllPoints (baseframe)
		backgroundframe:SetScrollChild (backgrounddisplay)
		
		backgrounddisplay:SetResizable (true)
		backgrounddisplay:SetPoint ("topleft", baseframe, "topleft")
		backgrounddisplay:SetPoint ("bottomright", baseframe, "bottomright")
		backgrounddisplay:SetBackdrop (gump_fundo_backdrop)
		backgrounddisplay:SetBackdropColor (instancia.bg_r, instancia.bg_g, instancia.bg_b, instancia.bg_alpha)
	
-- instance mini widgets -------------------------------------------------------------------------------------------------------------------------------------------------

	--> freeze icon
		instancia.freeze_icon = backgrounddisplay:CreateTexture (nil, "overlay")
			instancia.freeze_icon:SetWidth (64)
			instancia.freeze_icon:SetHeight (64)
			instancia.freeze_icon:SetPoint ("center", backgrounddisplay, "center")
			instancia.freeze_icon:SetPoint ("left", backgrounddisplay, "left")
			instancia.freeze_icon:Hide()
	
		instancia.freeze_texto = backgrounddisplay:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
			instancia.freeze_texto:SetHeight (64)
			instancia.freeze_texto:SetPoint ("left", instancia.freeze_icon, "right", -18, 0)
			instancia.freeze_texto:SetTextColor (1, 1, 1)
			instancia.freeze_texto:Hide()
	
	--> details version
		instancia._version = baseframe:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
			--instancia._version:SetPoint ("left", backgrounddisplay, "left", 20, 0)
			instancia._version:SetTextColor (1, 1, 1)
			instancia._version:SetText ("this is a alpha version of Details\nyou can help us sending bug reports\nuse the blue button.")
			if (not _detalhes.initializing) then
				
			end
			instancia._version:Hide()
			

	--> wallpaper
		baseframe.wallpaper = backgrounddisplay:CreateTexture (nil, "overlay")
		baseframe.wallpaper:Hide()
	
	--> alert frame
		baseframe.alert = CreateAlertFrame (baseframe, instancia)
	
-- resizers & lock button ------------------------------------------------------------------------------------------------------------------------------------------------------------

	--> right resizer
		baseframe.resize_direita = CreateFrame ("button", "Details_Resize_Direita"..ID, baseframe)
		
		local resize_direita_texture = baseframe.resize_direita:CreateTexture (nil, "overlay")
		resize_direita_texture:SetWidth (16)
		resize_direita_texture:SetHeight (16)
		resize_direita_texture:SetTexture (DEFAULT_SKIN)
		resize_direita_texture:SetTexCoord (unpack (COORDS_RESIZE_RIGHT))
		resize_direita_texture:SetAllPoints (baseframe.resize_direita)
		baseframe.resize_direita.texture = resize_direita_texture

		baseframe.resize_direita:SetWidth (16)
		baseframe.resize_direita:SetHeight (16)
		baseframe.resize_direita:SetPoint ("bottomright", baseframe, "bottomright", 0, 0)
		baseframe.resize_direita:EnableMouse (true)
		baseframe.resize_direita:SetFrameStrata ("HIGH")
		baseframe.resize_direita:SetFrameLevel (baseframe:GetFrameLevel() + 6)
		baseframe.resize_direita.side = 2

	--> lock window button
		baseframe.lock_button = CreateFrame ("button", "Details_Lock_Button"..ID, baseframe)
		baseframe.lock_button:SetPoint ("right", baseframe.resize_direita, "left", -1, 1.5)
		baseframe.lock_button:SetFrameLevel (baseframe:GetFrameLevel() + 6)
		baseframe.lock_button:SetWidth (40)
		baseframe.lock_button:SetHeight (16)
		baseframe.lock_button.label = baseframe.lock_button:CreateFontString (nil, "overlay", "GameFontNormal")
		baseframe.lock_button.label:SetPoint ("right", baseframe.lock_button, "right")
		baseframe.lock_button.label:SetTextColor (.3, .3, .3, .6)
		baseframe.lock_button.label:SetJustifyH ("right")
		baseframe.lock_button.label:SetText (Loc ["STRING_LOCK_WINDOW"])
		baseframe.lock_button:SetWidth (baseframe.lock_button.label:GetStringWidth()+2)
		baseframe.lock_button:SetScript ("OnClick", lockFunctionOnClick)
		baseframe.lock_button:SetScript ("OnEnter", lockFunctionOnEnter)
		baseframe.lock_button:SetScript ("OnLeave", lockFunctionOnLeave)
		baseframe.lock_button:SetFrameStrata ("HIGH")
		baseframe.lock_button:SetFrameLevel (baseframe:GetFrameLevel() + 6)
		baseframe.lock_button.instancia = instancia
		
	--> left resizer
		baseframe.resize_esquerda = CreateFrame ("button", "Details_Resize_Esquerda"..ID, baseframe)
		
		local resize_esquerda_texture = baseframe.resize_esquerda:CreateTexture (nil, "overlay")
		resize_esquerda_texture:SetWidth (16)
		resize_esquerda_texture:SetHeight (16)
		resize_esquerda_texture:SetTexture (DEFAULT_SKIN)
		resize_esquerda_texture:SetTexCoord (unpack (COORDS_RESIZE_LEFT))
		resize_esquerda_texture:SetAllPoints (baseframe.resize_esquerda)
		baseframe.resize_esquerda.texture = resize_esquerda_texture

		baseframe.resize_esquerda:SetWidth (16)
		baseframe.resize_esquerda:SetHeight (16)
		baseframe.resize_esquerda:SetPoint ("bottomleft", baseframe, "bottomleft", 0, 0)
		baseframe.resize_esquerda:EnableMouse (true)
		baseframe.resize_esquerda:SetFrameStrata ("HIGH")
		baseframe.resize_esquerda:SetFrameLevel (baseframe:GetFrameLevel() + 6)
	
		baseframe.resize_esquerda:SetAlpha (0)
		baseframe.resize_direita:SetAlpha (0)
	
		if (instancia.isLocked) then
			instancia.isLocked = not instancia.isLocked
			lockFunctionOnClick (baseframe.lock_button)
		end
	
		gump:Fade (baseframe.lock_button, -1, 3.0)

-- scripts ------------------------------------------------------------------------------------------------------------------------------------------------------------

	BFrame_scripts (baseframe, instancia)

	BGFrame_scripts (switchbutton, baseframe, instancia)
	BGFrame_scripts (backgrounddisplay, baseframe, instancia)
	
	iterate_scroll_scripts (backgrounddisplay, backgroundframe, baseframe, scrollbar, instancia)
	

-- create toolbar ----------------------------------------------------------------------------------------------------------------------------------------------------------

	gump:CriaCabecalho (baseframe, instancia)
	
-- create statusbar ----------------------------------------------------------------------------------------------------------------------------------------------------------		

	gump:CriaRodape (baseframe, instancia)

-- left and right side bars ------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ~barra ~bordas ~border
		local floatingframe = CreateFrame ("frame", "DetailsInstance"..ID.."BorderHolder", baseframe)
		floatingframe:SetFrameLevel (baseframe:GetFrameLevel()+7)
		instancia.floatingframe = floatingframe
	--> left
		baseframe.barra_esquerda = floatingframe:CreateTexture (nil, "artwork")
		baseframe.barra_esquerda:SetTexture (DEFAULT_SKIN)
		baseframe.barra_esquerda:SetTexCoord (unpack (COORDS_LEFT_SIDE_BAR))
		baseframe.barra_esquerda:SetWidth (64)
		baseframe.barra_esquerda:SetHeight	(512)
		baseframe.barra_esquerda:SetPoint ("topleft", baseframe, "topleft", -56, 0)
		baseframe.barra_esquerda:SetPoint ("bottomleft", baseframe, "bottomleft", -56, -14)
	--> right
		baseframe.barra_direita = floatingframe:CreateTexture (nil, "artwork")
		baseframe.barra_direita:SetTexture (DEFAULT_SKIN)
		baseframe.barra_direita:SetTexCoord (unpack (COORDS_RIGHT_SIDE_BAR))
		baseframe.barra_direita:SetWidth (64)
		baseframe.barra_direita:SetHeight (512)
		baseframe.barra_direita:SetPoint ("topright", baseframe, "topright", 56, 0)
		baseframe.barra_direita:SetPoint ("bottomright", baseframe, "bottomright", 56, -14)
	--> bottom
		baseframe.barra_fundo = floatingframe:CreateTexture (nil, "artwork")
		baseframe.barra_fundo:SetTexture (DEFAULT_SKIN)
		baseframe.barra_fundo:SetTexCoord (unpack (COORDS_BOTTOM_SIDE_BAR))
		baseframe.barra_fundo:SetWidth (512)
		baseframe.barra_fundo:SetHeight (64)
		baseframe.barra_fundo:SetPoint ("bottomleft", baseframe, "bottomleft", 0, -56)
		baseframe.barra_fundo:SetPoint ("bottomright", baseframe, "bottomright", 0, -56)

-- break snap button ----------------------------------------------------------------------------------------------------------------------------------------------------------

		instancia.botao_separar = CreateFrame ("button", "DetailsBreakSnapButton" .. ID, baseframe.cabecalho.fechar)
		instancia.botao_separar:SetPoint ("bottom", baseframe.resize_direita, "top", -1, 0)
		instancia.botao_separar:SetFrameLevel (baseframe:GetFrameLevel() + 5)
		instancia.botao_separar:SetSize (13, 13)
		
		instancia.botao_separar.instancia = instancia
		
		instancia.botao_separar:SetScript ("OnClick", function()
			instancia:Desagrupar (-1)
		end)
		
		instancia.botao_separar:SetScript ("OnEnter", unSnapButtonOnEnter)
		instancia.botao_separar:SetScript ("OnLeave", unSnapButtonOnLeave)
		

		instancia.botao_separar:SetNormalTexture (DEFAULT_SKIN)
		instancia.botao_separar:SetDisabledTexture (DEFAULT_SKIN)
		instancia.botao_separar:SetHighlightTexture (DEFAULT_SKIN, "ADD")
		instancia.botao_separar:SetPushedTexture (DEFAULT_SKIN)
		
		instancia.botao_separar:GetNormalTexture():SetTexCoord (unpack (COORDS_UNLOCK_BUTTON))
		instancia.botao_separar:GetDisabledTexture():SetTexCoord (unpack (COORDS_UNLOCK_BUTTON))
		instancia.botao_separar:GetHighlightTexture():SetTexCoord (unpack (COORDS_UNLOCK_BUTTON))
		instancia.botao_separar:GetPushedTexture():SetTexCoord (unpack (COORDS_UNLOCK_BUTTON))
		
		instancia.botao_separar:Hide()
	
-- scripts ------------------------------------------------------------------------------------------------------------------------------------------------------------	
	
		resize_scripts (baseframe.resize_direita, instancia, scrollbar, ">", baseframe)
		resize_scripts (baseframe.resize_esquerda, instancia, scrollbar, "<", baseframe)
	
-- side bars highlights ------------------------------------------------------------------------------------------------------------------------------------------------------------

	--> top
		local fcima = CreateFrame ("frame", "DetailsTopSideBarHighlight" .. instancia.meu_id, baseframe.cabecalho.fechar)
		fcima:SetPoint ("topleft", baseframe.cabecalho.top_bg, "bottomleft", -10, 37)
		fcima:SetPoint ("topright", baseframe.cabecalho.ball_r, "bottomright", -33, 37)
		gump:CreateFlashAnimation (fcima)
		fcima:Hide()
		
		instancia.h_cima = fcima:CreateTexture (nil, "overlay")
		instancia.h_cima:SetTexture ([[Interface\AddOns\Details\images\highlight_updown]])
		instancia.h_cima:SetTexCoord (0, 1, 0.5, 1)
		instancia.h_cima:SetPoint ("topleft", baseframe.cabecalho.top_bg, "bottomleft", -10, 37)
		instancia.h_cima:SetPoint ("topright", baseframe.cabecalho.ball_r, "bottomright", -97, 37)
		instancia.h_cima = fcima
		
	--> bottom
		local fbaixo = CreateFrame ("frame", "DetailsBottomSideBarHighlight" .. instancia.meu_id, baseframe.cabecalho.fechar)
		fbaixo:SetPoint ("topleft", baseframe.rodape.esquerdo, "bottomleft", 16, 17)
		fbaixo:SetPoint ("topright", baseframe.rodape.direita, "bottomright", -16, 17)
		gump:CreateFlashAnimation (fbaixo)
		fbaixo:Hide()
		
		instancia.h_baixo = fbaixo:CreateTexture (nil, "overlay")
		instancia.h_baixo:SetTexture ([[Interface\AddOns\Details\images\highlight_updown]])
		instancia.h_baixo:SetTexCoord (0, 1, 0, 0.5)
		instancia.h_baixo:SetPoint ("topleft", baseframe.rodape.esquerdo, "bottomleft", 16, 17)
		instancia.h_baixo:SetPoint ("topright", baseframe.rodape.direita, "bottomright", -16, 17)
		instancia.h_baixo = fbaixo
		
	--> left
		local fesquerda = CreateFrame ("frame", "DetailsLeftSideBarHighlight" .. instancia.meu_id, baseframe.cabecalho.fechar)
		fesquerda:SetPoint ("topleft", baseframe.barra_esquerda, "topleft", -8, 0)
		fesquerda:SetPoint ("bottomleft", baseframe.barra_esquerda, "bottomleft", -8, 0)
		gump:CreateFlashAnimation (fesquerda)
		fesquerda:Hide()
		
		instancia.h_esquerda = fesquerda:CreateTexture (nil, "overlay")
		instancia.h_esquerda:SetTexture ([[Interface\AddOns\Details\images\highlight_leftright]])
		instancia.h_esquerda:SetTexCoord (0.5, 1, 0, 1)
		instancia.h_esquerda:SetPoint ("topleft", baseframe.barra_esquerda, "topleft", 40, 0)
		instancia.h_esquerda:SetPoint ("bottomleft", baseframe.barra_esquerda, "bottomleft", 40, 0)
		instancia.h_esquerda = fesquerda
		
	--> right
		local fdireita = CreateFrame ("frame", "DetailsRightSideBarHighlight" .. instancia.meu_id, baseframe.cabecalho.fechar)
		fdireita:SetPoint ("topleft", baseframe.barra_direita, "topleft", 8, 18)
		fdireita:SetPoint ("bottomleft", baseframe.barra_direita, "bottomleft", 8, 0)
		gump:CreateFlashAnimation (fdireita)	
		fdireita:Hide()
		
		instancia.h_direita = fdireita:CreateTexture (nil, "overlay")
		instancia.h_direita:SetTexture ([[Interface\AddOns\Details\images\highlight_leftright]])
		instancia.h_direita:SetTexCoord (0, 0.5, 1, 0)
		instancia.h_direita:SetPoint ("topleft", baseframe.barra_direita, "topleft", 8, 18)
		instancia.h_direita:SetPoint ("bottomleft", baseframe.barra_direita, "bottomleft", 8, 0)
		instancia.h_direita = fdireita

--> done

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

	return baseframe, backgroundframe, backgrounddisplay, scrollbar
	
end

function _detalhes:SetBarGrowDirection (direction)

	if (not direction) then
		direction = self.bars_grow_direction
	end
	
	self.bars_grow_direction = direction
	
	local x = self.row_info.space.left
	
	if (direction == 1) then --> top to bottom
		for index, row in _ipairs (self.barras) do
			local y = self.row_height * (index - 1)
			y = y * -1
			row:ClearAllPoints()
			row:SetPoint ("topleft", self.baseframe, "topleft", x, y)
			
		end
		
	elseif (direction == 2) then --> bottom to top
		for index, row in _ipairs (self.barras) do
			local y = self.row_height * (index - 1)
			row:ClearAllPoints()
			row:SetPoint ("bottomleft", self.baseframe, "bottomleft", x, y + 2)
		end
		
	end
	
	--> update all row width
	if (self.bar_mod and self.bar_mod ~= 0) then
		for index = 1, #self.barras do
			self.barras [index]:SetWidth (self.baseframe:GetWidth() + self.bar_mod)
		end
	else
		for index = 1, #self.barras do
			self.barras [index]:SetWidth (self.baseframe:GetWidth()+self.row_info.space.right)
		end
	end
end

--> Alias
function gump:NewRow (instancia, index)
	return gump:CriaNovaBarra (instancia, index)
end

_detalhes.barras_criadas = 0

--> search key: ~row ~barra
function gump:CriaNovaBarra (instancia, index)

	local baseframe = instancia.baseframe
	local rowframe = instancia.rowframe
	
	local esta_barra = CreateFrame ("button", "DetailsBarra_"..instancia.meu_id.."_"..index, rowframe)
	
	esta_barra.row_id = index
	esta_barra.instance_id = instancia.meu_id
	local y = instancia.row_height*(index-1)

	if (instancia.bars_grow_direction == 1) then
		y = y*-1
		esta_barra:SetPoint ("topleft", baseframe, "topleft", instancia.row_info.space.left, y)
		
	elseif (instancia.bars_grow_direction == 2) then
		esta_barra:SetPoint ("bottomleft", baseframe, "bottomleft", instancia.row_info.space.left, y + 2)
	end
	
	esta_barra:SetHeight (instancia.row_info.height) --> altura determinada pela instância
	esta_barra:SetWidth (baseframe:GetWidth()+instancia.row_info.space.right)

	esta_barra:SetFrameLevel (baseframe:GetFrameLevel() + 4)

	esta_barra.last_value = 0
	esta_barra.w_mod = 0

	esta_barra:EnableMouse (true)
	esta_barra:RegisterForClicks ("LeftButtonDown", "RightButtonDown")

	esta_barra.statusbar = CreateFrame ("StatusBar", "DetailsBarra_Statusbar_"..instancia.meu_id.."_"..index, esta_barra)
	
	esta_barra.border = CreateFrame ("Frame", "DetailsBarra_Border_" .. instancia.meu_id .. "_" .. index, esta_barra.statusbar)
	esta_barra.border:SetFrameLevel (esta_barra.statusbar:GetFrameLevel()+1)
	esta_barra.border:SetAllPoints (esta_barra)

	esta_barra.textura = esta_barra.statusbar:CreateTexture (nil, "artwork")
	esta_barra.textura:SetHorizTile (false)
	esta_barra.textura:SetVertTile (false)
	
	esta_barra.background = esta_barra:CreateTexture (nil, "background")
	esta_barra.background:SetTexture()
	esta_barra.background:SetAllPoints (esta_barra)

	esta_barra.statusbar:SetStatusBarColor (0, 0, 0, 0)
	esta_barra.statusbar:SetStatusBarTexture (esta_barra.textura)
	
	esta_barra.statusbar:SetMinMaxValues (0, 100)
	esta_barra.statusbar:SetValue (100)

	local icone_classe = esta_barra.statusbar:CreateTexture (nil, "overlay")
	icone_classe:SetHeight (instancia.row_info.height)
	icone_classe:SetWidth (instancia.row_info.height)
	icone_classe:SetTexture (instancia.row_info.icon_file)
	icone_classe:SetTexCoord (.75, 1, .75, 1)
	esta_barra.icone_classe = icone_classe

	icone_classe:SetPoint ("left", esta_barra, "left")
	
	esta_barra.statusbar:SetPoint ("topleft", icone_classe, "topright")
	esta_barra.statusbar:SetPoint ("bottomright", esta_barra, "bottomright")
	
	esta_barra.texto_esquerdo = esta_barra.statusbar:CreateFontString (nil, "overlay", "GameFontHighlight")

	esta_barra.texto_esquerdo:SetPoint ("left", esta_barra.icone_classe, "right", 3, 0)
	esta_barra.texto_esquerdo:SetJustifyH ("left")
	esta_barra.texto_esquerdo:SetNonSpaceWrap (true)

	esta_barra.texto_direita = esta_barra.statusbar:CreateFontString (nil, "overlay", "GameFontHighlight")

	esta_barra.texto_direita:SetPoint ("right", esta_barra.statusbar, "right")
	esta_barra.texto_direita:SetJustifyH ("right")
	
	--> inicia os scripts da barra
	barra_scripts (esta_barra, instancia, index)

	--> hida a barra
	gump:Fade (esta_barra, 1) 

	--> adiciona ela ao container de barras
	instancia.barras [index] = esta_barra
	
	--> seta o texto da esqueda
	esta_barra.texto_esquerdo:SetText (Loc ["STRING_NEWROW"])
	esta_barra.statusbar:SetValue (100)
	
	instancia:InstanceRefreshRows()
	
	return esta_barra
end

function _detalhes:SetBarTextSettings (size, font, fixedcolor, leftcolorbyclass, rightcolorbyclass, leftoutline, rightoutline, customrighttextenabled, customrighttext, percentage_type)
	
	--> size
	if (size) then
		self.row_info.font_size = size
	end

	--> font
	if (font) then
		self.row_info.font_face = font
		self.row_info.font_face_file = SharedMedia:Fetch ("font", font)
	end

	--> fixed color
	if (fixedcolor) then
		local red, green, blue, alpha = gump:ParseColors (fixedcolor)
		local c = self.row_info.fixed_text_color
		c[1], c[2], c[3], c[4] = red, green, blue, alpha
	end
	
	--> left color by class
	if (type (leftcolorbyclass) == "boolean") then
		self.row_info.textL_class_colors = leftcolorbyclass
	end
	
	--> right color by class
	if (type (rightcolorbyclass) == "boolean") then
		self.row_info.textR_class_colors = rightcolorbyclass
	end
	
	--> left text outline
	if (type (leftoutline) == "boolean") then
		self.row_info.textL_outline = leftoutline
	end
	
	--> right text outline
	if (type (rightoutline) == "boolean") then
		self.row_info.textR_outline = rightoutline
	end
	
	--> custom right text
	if (type (customrighttextenabled) == "boolean") then
		self.row_info.textR_enable_custom_text = customrighttextenabled
	end
	if (customrighttext) then
		self.row_info.textR_custom_text = customrighttext
	end
	
	--> percent type
	if (percentage_type) then
		self.row_info.percent_type = percentage_type
	end
	
	self:InstanceReset()
	self:InstanceRefreshRows()
end

function _detalhes:SetBarBackdropSettings (enabled, size, color, texture)

	if (type (enabled) ~= "boolean") then
		enabled = self.row_info.backdrop.enabled
	end
	if (not size) then
		size = self.row_info.backdrop.size
	end
	if (not color) then
		color = self.row_info.backdrop.color
	end
	if (not texture) then
		texture = self.row_info.backdrop.texture
	end
	
	self.row_info.backdrop.enabled = enabled
	self.row_info.backdrop.size = size
	self.row_info.backdrop.color = color
	self.row_info.backdrop.texture = texture
	
	self:InstanceReset()
	self:InstanceRefreshRows()
	self:ReajustaGump()
end

function _detalhes:SetBarSettings (height, texture, colorclass, fixedcolor, backgroundtexture, backgroundcolorclass, backgroundfixedcolor, alpha, iconfile, barstart, spacement)
	
	--> bar start
	if (type (barstart) == "boolean") then
		self.row_info.start_after_icon = barstart
	end
	
	--> icon file
	if (iconfile) then
		self.row_info.icon_file = iconfile
		if (iconfile == "") then
			self.row_info.no_icon = true
		else
			self.row_info.no_icon = false
		end
	end
	
	--> alpha
	if (alpha) then
		self.row_info.alpha = alpha
	end
	
	--> height
	if (height) then
		self.row_info.height = height
		self.row_height = height + self.row_info.space.between
	end
	
	--> spacement
	if (spacement) then
		self.row_info.space.between = spacement
		self.row_height = self.row_info.height + spacement
	end
	
	--> texture
	if (texture) then
		self.row_info.texture = texture
		self.row_info.texture_file = SharedMedia:Fetch ("statusbar", texture)
	end
	
	--> color by class
	if (type (colorclass) == "boolean") then
		self.row_info.texture_class_colors = colorclass
	end
	
	--> fixed color
	if (fixedcolor) then
		local red, green, blue, alpha = gump:ParseColors (fixedcolor)
		local c = self.row_info.fixed_texture_color
		c[1], c[2], c[3], c[4] = red, green, blue, alpha
	end
	
	--> background texture
	if (backgroundtexture) then
		self.row_info.texture_background = backgroundtexture
		self.row_info.texture_background_file = SharedMedia:Fetch ("statusbar", backgroundtexture)
	end
	
	--> background color by class
	if (type (backgroundcolorclass) == "boolean") then
		self.row_info.texture_background_class_color = backgroundcolorclass
	end
	
	--> background fixed color
	if (backgroundfixedcolor) then
		local red, green, blue, alpha = gump:ParseColors (backgroundfixedcolor)
		local c =  self.row_info.fixed_texture_background_color
		c [1], c [2], c [3], c [4] = red, green, blue, alpha
	end

	self:InstanceReset()
	self:InstanceRefreshRows()
	self:ReajustaGump()

end

--/script _detalhes:InstanceRefreshRows (_detalhes.tabela_instancias[1])

-- search key: ~row
function _detalhes:InstanceRefreshRows (instancia)

	if (instancia) then
		self = instancia
	end

	if (not self.barras or not self.barras[1]) then
		return
	end
	
	--> texture
		local texture_file = SharedMedia:Fetch ("statusbar", self.row_info.texture)
		local texture_file2 = SharedMedia:Fetch ("statusbar", self.row_info.texture_background)
	
	--> outline values
		local left_text_outline = self.row_info.textL_outline
		local right_text_outline = self.row_info.textR_outline
	
	--> texture color values
		local texture_class_color = self.row_info.texture_class_colors
		local texture_r, texture_g, texture_b
		if (not texture_class_color) then
			texture_r, texture_g, texture_b = _unpack (self.row_info.fixed_texture_color)
		end
	
	--text color
		local left_text_class_color = self.row_info.textL_class_colors
		local right_text_class_color = self.row_info.textR_class_colors
		local text_r, text_g, text_b
		if (not left_text_class_color or not right_text_class_color) then
			text_r, text_g, text_b = _unpack (self.row_info.fixed_text_color)
		end
		
		local height = self.row_info.height
	
	--alpha
		local alpha = self.row_info.alpha
	
	--icons
		local no_icon = self.row_info.no_icon
		local icon_texture = self.row_info.icon_file
		local start_after_icon = self.row_info.start_after_icon
	
	--custom right text
		local custom_right_text_enabled = self.row_info.textR_enable_custom_text
		local custom_right_text = self.row_info.textR_custom_text

	--backdrop
		local backdrop = self.row_info.backdrop.enabled
		local backdrop_color
		if (backdrop) then
			backdrop = {edgeFile = SharedMedia:Fetch ("border", self.row_info.backdrop.texture), edgeSize = self.row_info.backdrop.size}
			backdrop_color = self.row_info.backdrop.color
		end
		
	-- do it

	for _, row in _ipairs (self.barras) do 

		--> positioning and size
		row:SetHeight (height)
		row.icone_classe:SetHeight (height)
		row.icone_classe:SetWidth (height)
		
		--> icon
		if (no_icon) then
			row.statusbar:SetPoint ("topleft", row, "topleft")
			row.statusbar:SetPoint ("bottomright", row, "bottomright")
			row.texto_esquerdo:SetPoint ("left", row.statusbar, "left", 2, 0)
			row.icone_classe:Hide()
		else
			if (start_after_icon) then
				row.statusbar:SetPoint ("topleft", row.icone_classe, "topright")
			else
				row.statusbar:SetPoint ("topleft", row, "topleft")
			end
			
			row.statusbar:SetPoint ("bottomright", row, "bottomright")
			row.texto_esquerdo:SetPoint ("left", row.icone_classe, "right", 3, 0)
			row.icone_classe:Show()
		end
	
		if (not self.row_info.texture_background_class_color) then
			local c = self.row_info.fixed_texture_background_color
			row.background:SetVertexColor (c[1], c[2], c[3], c[4])
		else
			local c = self.row_info.fixed_texture_background_color
			local r, g, b = row.background:GetVertexColor()
			row.background:SetVertexColor (r, g, b, c[4])
		end
	
		--> outline
		if (left_text_outline) then
			_detalhes:SetFontOutline (row.texto_esquerdo, left_text_outline)
		else
			_detalhes:SetFontOutline (row.texto_esquerdo, nil)
		end
		
		if (right_text_outline) then
			self:SetFontOutline (row.texto_direita, right_text_outline)
		else
			self:SetFontOutline (row.texto_direita, nil)
		end
		
		--> texture:
		row.textura:SetTexture (texture_file)
		row.background:SetTexture (texture_file2)
		
		--> texture class color: if true color changes on the fly through class refresh
		if (not texture_class_color) then
			row.textura:SetVertexColor (texture_r, texture_g, texture_b, alpha)
		else
			local r, g, b = row.textura:GetVertexColor()
			row.textura:SetVertexColor (r, g, b, alpha)
		end
		
		--> text class color: if true color changes on the fly through class refresh
		if (not left_text_class_color) then
			row.texto_esquerdo:SetTextColor (text_r, text_g, text_b)
		end
		if (not right_text_class_color) then
			row.texto_direita:SetTextColor (text_r, text_g, text_b)
		end
		
		--> text size
		_detalhes:SetFontSize (row.texto_esquerdo, self.row_info.font_size or height * 0.75)
		_detalhes:SetFontSize (row.texto_direita, self.row_info.font_size or height * 0.75)
		
		--> text font
		_detalhes:SetFontFace (row.texto_esquerdo, self.row_info.font_face_file or "GameFontHighlight")
		_detalhes:SetFontFace (row.texto_direita, self.row_info.font_face_file or "GameFontHighlight")

		--backdrop
		if (backdrop) then
			row.border:SetBackdrop (backdrop)
			row.border:SetBackdropBorderColor (_unpack (backdrop_color))
		else
			row.border:SetBackdrop (nil)
		end
		
	end
	
	self:SetBarGrowDirection()

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

	t:Show()
	--t:SetAlpha (alpha)
	gump:Fade (t, "ALPHAANIM", alpha)

end

function _detalhes:GetTextures()
	local t = {}
	t [1] = self.baseframe.rodape.esquerdo
	t [2] = self.baseframe.rodape.direita
	t [3] = self.baseframe.rodape.top_bg
	
	t [4] = self.baseframe.cabecalho.ball_r
	t [5] = self.baseframe.cabecalho.ball
	t [6] = self.baseframe.cabecalho.emenda
	t [7] = self.baseframe.cabecalho.top_bg
	
	t [8] = self.baseframe.barra_esquerda
	t [9] = self.baseframe.barra_direita
	t [10] = self.baseframe.UPFrame
	return t
	--atributo_icon é uma exceção
end

function _detalhes:SetWindowAlphaForInteract (alpha)
	
	local ignorebars = self.menu_alpha.ignorebars
	
	if (self.is_interacting) then
		--> entrou
		self.baseframe:SetAlpha (alpha)
		
		if (ignorebars) then
			self.rowframe:SetAlpha (1)
		else
			self.rowframe:SetAlpha (alpha)
		end
	else
		--> saiu
		if (self.combat_changes_alpha) then --> combat alpha
			self.baseframe:SetAlpha (self.combat_changes_alpha)
			self.rowframe:SetAlpha (self.combat_changes_alpha) --alpha do combate é absoluta
		else
			self.baseframe:SetAlpha (alpha)
			if (ignorebars) then
				self.rowframe:SetAlpha (1)
			else
				self.rowframe:SetAlpha (alpha)
			end
		end

	end
	
end

function _detalhes:SetWindowAlphaForCombat (entering_in_combat, true_hide)

	local amount, rowsamount

	--get the values
	if (entering_in_combat) then
		amount = self.hide_in_combat_alpha / 100
		self.combat_changes_alpha = amount
		rowsamount = amount
		if (_detalhes.pet_battle) then
			amount = 0
			rowsamount = 0
		end
	else
		if (self.menu_alpha.enabled) then --auto transparency
			if (self.is_interacting) then
				amount = self.menu_alpha.onenter
				if (self.menu_alpha.ignorebars) then
					rowsamount = 1
				else
					rowsamount = amount
				end
			else
				amount = self.menu_alpha.onleave
				if (self.menu_alpha.ignorebars) then
					rowsamount = 1
				else
					rowsamount = amount
				end
			end
		else
			amount = self.color [4]
			rowsamount = 1
		end
		self.combat_changes_alpha = nil
	end

	--apply
	if (true_hide and amount == 0) then
		gump:Fade (self.baseframe, _unpack (_detalhes.windows_fade_in))
		gump:Fade (self.rowframe, _unpack (_detalhes.windows_fade_in))
	else
		gump:Fade (self.baseframe, "ALPHAANIM", amount)
		gump:Fade (self.rowframe, "ALPHAANIM", rowsamount)
	end
	
	if (self.show_statusbar) then
		self.baseframe.barra_fundo:Hide()
	end
	if (self.hide_icon) then
		self.baseframe.cabecalho.atributo_icon:Hide()
	end

end

function _detalhes:InstanceButtonsColors (red, green, blue, alpha, no_save, only_left, only_right)
	
	if (not red) then
		red, green, blue, alpha = unpack (self.color_buttons)
	end
	
	if (type (red) ~= "number") then
		red, green, blue, alpha = gump:ParseColors (red)
	end
	
	if (not no_save) then
		self.color_buttons [1] = red
		self.color_buttons [2] = green
		self.color_buttons [3] = blue
		self.color_buttons [4] = alpha
	end
	
	local baseToolbar = self.baseframe.cabecalho
	

	if (only_left) then
	
		local icons = {baseToolbar.modo_selecao, baseToolbar.segmento, baseToolbar.atributo, baseToolbar.report}
		
		for _, button in _ipairs (icons) do 
			button:SetAlpha (alpha)
		end

		if (self:IsLowerInstance()) then
			for _, ThisButton in _ipairs (_detalhes.ToolBar.Shown) do
				ThisButton:SetAlpha (alpha)
			end
		end
		
	elseif (only_right) then
	
		local icons = {baseToolbar.novo, baseToolbar.fechar, baseToolbar.reset}
		
		for _, button in _ipairs (icons) do 
			button:SetAlpha (alpha)
		end

	else
		
		local icons = {baseToolbar.modo_selecao, baseToolbar.segmento, baseToolbar.atributo, baseToolbar.report, baseToolbar.novo, baseToolbar.fechar, baseToolbar.reset}
		
		for _, button in _ipairs (icons) do 
			button:SetAlpha (alpha)
		end
		
		if (self:IsLowerInstance()) then
			for _, ThisButton in _ipairs (_detalhes.ToolBar.Shown) do
				ThisButton:SetAlpha (alpha)
			end
		end
	
	end
end

function _detalhes:InstanceColor (red, green, blue, alpha, no_save, change_statusbar)

	if (not red) then
		red, green, blue, alpha = unpack (self.color)
		no_save = true
	end

	if (type (red) ~= "number") then
		red, green, blue, alpha = gump:ParseColors (red)
	end

	if (not no_save) then
		--> saving
		self.color [1] = red
		self.color [2] = green
		self.color [3] = blue
		self.color [4] = alpha
		if (change_statusbar) then
			self:StatusBarColor (red, green, blue, alpha)
		end
	else
		--> not saving
		self:StatusBarColor (nil, nil, nil, alpha, true)
	end

	local skin = _detalhes.skins [self.skin]
	
	--[[
	self.baseframe.rodape.esquerdo:SetVertexColor (red, green, blue)
		self.baseframe.rodape.esquerdo:SetAlpha (alpha)
	self.baseframe.rodape.direita:SetVertexColor (red, green, blue)
		self.baseframe.rodape.direita:SetAlpha (alpha)
	self.baseframe.rodape.top_bg:SetVertexColor (red, green, blue)
		self.baseframe.rodape.top_bg:SetAlpha (alpha)
	--]]
	
	self.baseframe.cabecalho.ball_r:SetVertexColor (red, green, blue)
		self.baseframe.cabecalho.ball_r:SetAlpha (alpha)
		
	self.baseframe.cabecalho.ball:SetVertexColor (red, green, blue)
	self.baseframe.cabecalho.ball:SetAlpha (alpha)
	
	self.baseframe.cabecalho.atributo_icon:SetAlpha (alpha)

	self.baseframe.cabecalho.emenda:SetVertexColor (red, green, blue)
		self.baseframe.cabecalho.emenda:SetAlpha (alpha)
	self.baseframe.cabecalho.top_bg:SetVertexColor (red, green, blue)
		self.baseframe.cabecalho.top_bg:SetAlpha (alpha)

	self.baseframe.barra_esquerda:SetVertexColor (red, green, blue)
		self.baseframe.barra_esquerda:SetAlpha (alpha)
	self.baseframe.barra_direita:SetVertexColor (red, green, blue)
		self.baseframe.barra_direita:SetAlpha (alpha)
	self.baseframe.barra_fundo:SetVertexColor (red, green, blue)
		self.baseframe.barra_fundo:SetAlpha (alpha)
		
	self.baseframe.UPFrame:SetAlpha (alpha)

	--self.color[1], self.color[2], self.color[3], self.color[4] = red, green, blue, alpha
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


function gump:CriaRodape (baseframe, instancia)

	baseframe.rodape = {}
	
	--> esquerdo
	baseframe.rodape.esquerdo = baseframe.cabecalho.fechar:CreateTexture (nil, "overlay")
	baseframe.rodape.esquerdo:SetPoint ("topright", baseframe, "bottomleft", 16, 0)
	baseframe.rodape.esquerdo:SetTexture (DEFAULT_SKIN)
	baseframe.rodape.esquerdo:SetTexCoord (unpack (COORDS_PIN_LEFT))
	baseframe.rodape.esquerdo:SetWidth (32)
	baseframe.rodape.esquerdo:SetHeight (32)
	
	--> direito
	baseframe.rodape.direita = baseframe.cabecalho.fechar:CreateTexture (nil, "overlay")
	baseframe.rodape.direita:SetPoint ("topleft", baseframe, "bottomright", -16, 0)
	baseframe.rodape.direita:SetTexture (DEFAULT_SKIN)
	baseframe.rodape.direita:SetTexCoord (unpack (COORDS_PIN_RIGHT))
	baseframe.rodape.direita:SetWidth (32)
	baseframe.rodape.direita:SetHeight (32)
	
	--> barra centro
	baseframe.rodape.top_bg = baseframe:CreateTexture (nil, "background")
	baseframe.rodape.top_bg:SetTexture (DEFAULT_SKIN)
	baseframe.rodape.top_bg:SetTexCoord (unpack (COORDS_BOTTOM_BACKGROUND))
	baseframe.rodape.top_bg:SetWidth (512)
	baseframe.rodape.top_bg:SetHeight (128)
	baseframe.rodape.top_bg:SetPoint ("left", baseframe.rodape.esquerdo, "right", -16, -48)
	baseframe.rodape.top_bg:SetPoint ("right", baseframe.rodape.direita, "left", 16, -48)

	local StatusBarLeftAnchor = CreateFrame ("frame", "DetailsStatusBarAnchorLeft" .. instancia.meu_id, baseframe)
	StatusBarLeftAnchor:SetPoint ("left", baseframe.rodape.top_bg, "left", 5, 57)
	StatusBarLeftAnchor:SetWidth (1)
	StatusBarLeftAnchor:SetHeight (1)
	baseframe.rodape.StatusBarLeftAnchor = StatusBarLeftAnchor
	
	local StatusBarCenterAnchor = CreateFrame ("frame", "DetailsStatusBarAnchorCenter" .. instancia.meu_id, baseframe)
	StatusBarCenterAnchor:SetPoint ("center", baseframe.rodape.top_bg, "center", 0, 57)
	StatusBarCenterAnchor:SetWidth (1)
	StatusBarCenterAnchor:SetHeight (1)
	baseframe.rodape.StatusBarCenterAnchor = StatusBarCenterAnchor
	
	--> display frame
		baseframe.statusbar = CreateFrame ("frame", "DetailsStatusBar" .. instancia.meu_id, baseframe.cabecalho.fechar)
		baseframe.statusbar:SetFrameLevel (baseframe.cabecalho.fechar:GetFrameLevel()+2)
		baseframe.statusbar:SetPoint ("left", baseframe.rodape.esquerdo, "right", -13, 10)
		baseframe.statusbar:SetPoint ("right", baseframe.rodape.direita, "left", 13, 10)
		baseframe.statusbar:SetHeight (14)
		
		local statusbar_icon = baseframe.statusbar:CreateTexture (nil, "overlay")
		statusbar_icon:SetWidth (14)
		statusbar_icon:SetHeight (14)
		statusbar_icon:SetPoint ("left", baseframe.statusbar, "left")
		
		local statusbar_text = baseframe.statusbar:CreateFontString (nil, "overlay", "GameFontNormal")
		statusbar_text:SetPoint ("left", statusbar_icon, "right", 2, 0)
		
		baseframe.statusbar:SetBackdrop ({
		bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16,
		insets = {left = 0, right = 0, top = 0, bottom = 0}})
		baseframe.statusbar:SetBackdropColor (0, 0, 0, 1)
		
		baseframe.statusbar.icon = statusbar_icon
		baseframe.statusbar.text = statusbar_text
		baseframe.statusbar.instancia = instancia
		
		baseframe.statusbar:Hide()
	
	--> frame invisível
	baseframe.DOWNFrame = CreateFrame ("frame", "DetailsDownFrame" .. instancia.meu_id, baseframe)
	baseframe.DOWNFrame:SetPoint ("left", baseframe.rodape.esquerdo, "right", 0, 10)
	baseframe.DOWNFrame:SetPoint ("right", baseframe.rodape.direita, "left", 0, 10)
	baseframe.DOWNFrame:SetHeight (14)
	
	baseframe.DOWNFrame:Show()
	baseframe.DOWNFrame:EnableMouse (true)
	baseframe.DOWNFrame:SetMovable (true)
	baseframe.DOWNFrame:SetResizable (true)
	
	BGFrame_scripts (baseframe.DOWNFrame, baseframe, instancia)
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
	
	self:ToolbarMenuButtons()
	
	return self:MenuAnchor()
end

function _detalhes:UnConsolidateIcons()

	self.consolidate = false
	
	if (not self.consolidateButton) then
		return self:ToolbarMenuButtons()
	end
	
	self.consolidateButton:Hide()
	
	self:ToolbarMenuButtons()
	
	return self:MenuAnchor()
end

function _detalhes:GetMenuAnchorPoint()
	local toolbar_side = self.toolbar_side
	local menu_side = self.menu_anchor.side
	
	if (menu_side == 1) then --left
		if (toolbar_side == 1) then --top
			return self.menu_points [1], "bottomleft", "bottomright"
		elseif (toolbar_side == 2) then --bottom
			return self.menu_points [1], "topleft", "topright"
		end
	elseif (menu_side == 2) then --right
		if (toolbar_side == 1) then --top
			return self.menu_points [2], "topleft", "bottomleft"
		elseif (toolbar_side == 2) then --bottom
			return self.menu_points [2], "topleft", "topleft"
		end
	end
end
function _detalhes:GetMenu2AnchorPoint()
	local toolbar_side = self.toolbar_side
	if (toolbar_side == 1) then --top
		return self.menu2_points [1], "topright", "bottomleft"
	elseif (toolbar_side == 2) then --bottom
		return self.menu2_points [1], "topleft", "topleft"
	end
end

--> search key: ~icon
function _detalhes:ToolbarMenuButtonsSize (size)
	size = size or self.menu_icons_size
	self.menu_icons_size = size
	return self:ToolbarMenuButtons()
end
function _detalhes:ToolbarMenu2ButtonsSize (size)
	size = size or self.menu2_icons_size
	self.menu2_icons_size = size
	return self:ToolbarMenu2Buttons()
end
function _detalhes:ToolbarMenuButtons (_mode, _segment, _attributes, _report)

	if (_mode == nil) then
		_mode = self.menu_icons[1]
	end
	if (_segment == nil) then
		_segment = self.menu_icons[2]
	end
	if (_attributes == nil) then
		_attributes = self.menu_icons[3]
	end
	if (_report == nil) then
		_report = self.menu_icons[4]
	end	

	self.menu_icons[1] = _mode
	self.menu_icons[2] = _segment
	self.menu_icons[3] = _attributes
	self.menu_icons[4] = _report
	
	local buttons = {self.baseframe.cabecalho.modo_selecao, self.baseframe.cabecalho.segmento, self.baseframe.cabecalho.atributo, self.baseframe.cabecalho.report}
	
	local anchor_frame, point1, point2 = self:GetMenuAnchorPoint()
	local got_anchor = false
	self.lastIcon = nil
	
	local size = self.menu_icons_size
	
	--> normal buttons
	for index, button in ipairs (buttons) do
		if (self.menu_icons [index]) then
			button:ClearAllPoints()
			if (got_anchor) then
				button:SetPoint ("left", self.lastIcon, "right")
			else
				button:SetPoint (point1, anchor_frame, point2)
				got_anchor = button
			end
			self.lastIcon = button
			button:SetParent (self.baseframe)
			button:SetFrameLevel (self.baseframe.UPFrame:GetFrameLevel()+1)
			button:Show()
			
			if (buttons[4] == button) then
				button:SetSize (8*size, 16*size)
			else
				button:SetSize (16*size, 16*size)
			end
		else
			button:Hide()
		end
	end
	
	--> plugins buttons
	if (self:IsLowerInstance()) then
		if (#_detalhes.ToolBar.Shown > 0) then
			for index, button in ipairs (_detalhes.ToolBar.Shown) do 
				button:ClearAllPoints()
				if (got_anchor) then
					if (self.plugins_grow_direction == 2) then --right (default)
						if (self.lastIcon == buttons[4]) then
							button:SetPoint ("left", self.lastIcon.widget or self.lastIcon, "right", 2, 0) --, button.x, button.y
						else
							button:SetPoint ("left", self.lastIcon.widget or self.lastIcon, "right") --, button.x, button.y
						end
					elseif (self.plugins_grow_direction == 1) then --left
						if (index == 1) then
							button:SetPoint ("right", got_anchor.widget or got_anchor, "left") --, button.x, button.y
						else
							button:SetPoint ("right", self.lastIcon.widget or self.lastIcon, "left") --, button.x, button.y
						end
					end
				else
					button:SetPoint (point1, anchor_frame, point2)
					got_anchor = button
				end
				self.lastIcon = button
				button:SetParent (self.baseframe)
				button:SetFrameLevel (self.baseframe.UPFrame:GetFrameLevel()+1)
				button:Show()
				
				button:SetSize (16*size, 16*size)
			end
		end
	end
	
	return true
end

function _detalhes:ToolbarMenu2Buttons (_close, _instance, _reset)
	if (_close == nil) then
		_close = self.menu2_icons[1]
	end
	if (_instance == nil) then
		_instance = self.menu2_icons[2]
	end
	if (_reset == nil) then
		_reset = self.menu2_icons[3]
	end
	
	self.menu2_icons[1] = _close
	self.menu2_icons[2] = _instance
	self.menu2_icons[3] = _reset
	
	local buttons = {self.baseframe.cabecalho.fechar, self.baseframe.cabecalho.novo, self.baseframe.cabecalho.reset}
	local config = {self.closebutton_config, self.instancebutton_config, self.resetbutton_config}
	
	local anchor_frame, point1, point2 = self:GetMenu2AnchorPoint() -- self.menu2_points [1], "topleft", "bottomleft"
	local got_anchor = false
	local lastIcon = nil
	
	local size = self.menu2_icons_size
	local default_texcoord = {0, 1, 0, 1}
	local default_vertexcolor = {1, 1, 1, 1}
	--> normal buttons
	for index, button in ipairs (buttons) do
		if (self.menu2_icons [index]) then

			local button_config = config [index]
			button:ClearAllPoints()
			
			if (got_anchor) then
				button:SetPoint ("right", lastIcon, "left", button_config.anchor [1], button_config.anchor [2])
			else
				button:SetPoint (point1, anchor_frame, point2, button_config.anchor [1], button_config.anchor [2])
				got_anchor = button
			end
			
			button:SetSize (button_config.size[1] * size, button_config.size[2] * size)
			
			local normal_texture = button:GetNormalTexture()
			local highlight_texture = button:GetHighlightTexture()
			local pushed_texture = button:GetPushedTexture()
			
			normal_texture:SetTexture (button_config.normal_texture)
			highlight_texture:SetTexture (button_config.highlight_texture or button_config.normal_texture)
			pushed_texture:SetTexture (button_config.pushed_texture or button_config.normal_texture)
			
			if (button_config.normal_texcoord) then
				normal_texture:SetTexCoord (unpack (button_config.normal_texcoord))
			else
				normal_texture:SetTexCoord (unpack (default_texcoord))
			end

			if (button_config.highlight_texcoord) then
				highlight_texture:SetTexCoord (unpack (button_config.highlight_texcoord))
			else
				if (button_config.normal_texcoord and button_config.normal_texture == button_config.highlight_texture) then
					highlight_texture:SetTexCoord (unpack (button_config.normal_texcoord))
				else
					highlight_texture:SetTexCoord (unpack (default_texcoord))
				end
			end
			
			if (button_config.pushed_texcoord) then
				pushed_texture:SetTexCoord (unpack (button_config.pushed_texcoord))
			else
				if (button_config.normal_texcoord and (not button_config.pushed_texture or button_config.normal_texture == button_config.pushed_texture)) then
					pushed_texture:SetTexCoord (unpack (button_config.normal_texcoord))
				else
					pushed_texture:SetTexCoord (unpack (default_texcoord))
				end
			end
			
			if (button_config.normal_vertexcolor) then
				normal_texture:SetVertexColor (unpack (button_config.normal_vertexcolor))
			else
				normal_texture:SetVertexColor (unpack (default_vertexcolor))
			end
			
			if (button_config.highlight_vertexcolor) then
				highlight_texture:SetVertexColor (unpack (button_config.highlight_vertexcolor))
			else
				if (button_config.normal_vertexcolor and button_config.normal_texture == button_config.highlight_texture) then
					highlight_texture:SetVertexColor (unpack (button_config.normal_vertexcolor))
				else
					highlight_texture:SetVertexColor (unpack (default_vertexcolor))
				end
			end
			
			if (button_config.pushed_vertexcolor) then
				pushed_texture:SetVertexColor (unpack (button_config.pushed_vertexcolor))
			else
				if (button_config.normal_vertexcolor and button_config.normal_texture == button_config.pushed_texture) then
					pushed_texture:SetVertexColor (unpack (button_config.normal_vertexcolor))
				else
					pushed_texture:SetVertexColor (unpack (default_vertexcolor))
				end
			end

			lastIcon = button
			button:SetParent (self.baseframe)
			button:SetFrameLevel (self.baseframe.UPFrame:GetFrameLevel()+1)
			button:Show()
			
		else
			button:Hide()
		end
	end
	
	self:ToolbarMenu2InstanceButtonSettings()
	
	return true
end

function _detalhes:ToolbarMenu2InstanceButtonSettings (color, font, size, shadow)
	
	if (not color) then
		color = self.instancebutton_config.textcolor
	end
	if (not font) then
		font = self.instancebutton_config.textfont
	end
	if (not size) then
		size = self.instancebutton_config.textsize
	end
	if (shadow == nil) then
		shadow = self.instancebutton_config.textshadow
	end
	
	self.instancebutton_config.textcolor = color
	self.instancebutton_config.textfont = font
	self.instancebutton_config.textsize = size
	self.instancebutton_config.textshadow = shadow
	
	local fontstring = self.baseframe.cabecalho.novo:GetFontString()
	
	_detalhes:SetFontSize (fontstring, size)
	_detalhes:SetFontFace (fontstring, SharedMedia:Fetch ("font", font))
	_detalhes:SetFontColor (fontstring, color)
	_detalhes:SetFontOutline (fontstring, shadow)

end

local parameters_table = {}

local on_leave_menu = function (self, elapsed)
	parameters_table[2] = parameters_table[2] + elapsed
	if (parameters_table[2] > 0.3) then
		if (not _G.GameCooltip.mouseOver and not _G.GameCooltip.buttonOver and (not _G.GameCooltip:GetOwner() or _G.GameCooltip:GetOwner() == self)) then
			_G.GameCooltip:ShowMe (false)
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
		CoolTip:SetLastSelected ("main", parameters_table [3])
		CoolTip:SetFixedParameter (instancia)
		CoolTip:SetColor ("main", "transparent")
		
		CoolTip:SetOption ("TextSize", _detalhes.font_sizes.menus)
		CoolTip:SetOption ("ButtonHeightModSub", -5)
		CoolTip:SetOption ("ButtonHeightMod", -5)
		CoolTip:SetOption ("ButtonsYModSub", -5)
		CoolTip:SetOption ("ButtonsYMod", -5)
		CoolTip:SetOption ("YSpacingModSub", 1)
		CoolTip:SetOption ("YSpacingMod", 1)
		CoolTip:SetOption ("FixedHeight", 106)
		CoolTip:SetOption ("FixedWidthSub", 146)
		
		--CoolTip:SetOption ("SubMenuIsTooltip", true)
		
		--if (_detalhes.tutorial.logons > 9) then
			--CoolTip:SetOption ("IgnoreSubMenu", true)
		--end
		
		CoolTip:AddLine (Loc ["STRING_MODE_GROUP"])
		CoolTip:AddMenu (1, instancia.AlteraModo, 2, true)
		CoolTip:AddIcon ([[Interface\AddOns\Details\images\modo_icones]], 1, 1, 20, 20, 32/256, 32/256*2, 0, 1)
		--CoolTip:AddLine (Loc ["STRING_HELP_MODEGROUP"], nil, 2)
		--CoolTip:AddIcon ([[Interface\TUTORIALFRAME\TutorialFrame-QuestionMark]], 2, 1, 16, 16, 8/64, 1 - (8/64), 8/64, 1 - (8/64))
		
		CoolTip:AddLine (Loc ["STRING_MODE_ALL"])
		CoolTip:AddMenu (1, instancia.AlteraModo, 3, true)
		CoolTip:AddIcon ([[Interface\AddOns\Details\images\modo_icones]], 1, 1, 20, 20, 32/256*2, 32/256*3, 0, 1)
		--CoolTip:AddLine (Loc ["STRING_HELP_MODEALL"], nil, 2)
		--CoolTip:AddIcon ([[Interface\TUTORIALFRAME\TutorialFrame-QuestionMark]], 2, 1, 16, 16, 8/64, 1 - (8/64), 8/64, 1 - (8/64))
	
		CoolTip:AddLine (Loc ["STRING_MODE_RAID"])
		CoolTip:AddMenu (1, instancia.AlteraModo, 4, true)
		CoolTip:AddIcon ([[Interface\AddOns\Details\images\modo_icones]], 1, 1, 20, 20, 32/256*3, 32/256*4, 0, 1)
		--CoolTip:AddLine (Loc ["STRING_HELP_MODERAID"], nil, 2)
		--CoolTip:AddIcon ([[Interface\TUTORIALFRAME\TutorialFrame-QuestionMark]], 2, 1, 16, 16, 8/64, 1 - (8/64), 8/64, 1 - (8/64))

		--build raid plugins list
		local available_plugins = _detalhes.RaidTables:GetAvailablePlugins()

		if (#available_plugins >= 0) then
			local amt = 0
			
			for index, ptable in _ipairs (available_plugins) do
				if (ptable [3].__enabled) then
					CoolTip:AddMenu (2, _detalhes.RaidTables.EnableRaidMode, instancia, ptable [4], true, ptable [1], ptable [2], true) --PluginName, PluginIcon, PluginObject, PluginAbsoluteName
					amt = amt + 1
				end
			end
			
			CoolTip:SetWallpaper (2, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
			
			if (amt <= 3) then
				CoolTip:SetOption ("SubFollowButton", true)
			end
		end
		
		CoolTip:AddLine (Loc ["STRING_MODE_SELF"])
		CoolTip:AddMenu (1, instancia.AlteraModo, 1, true)
		CoolTip:AddIcon ([[Interface\AddOns\Details\images\modo_icones]], 1, 1, 20, 20, 0, 32/256, 0, 1)
		--CoolTip:AddLine (Loc ["STRING_HELP_MODESELF"], nil, 2)
		--CoolTip:AddIcon ([[Interface\TUTORIALFRAME\TutorialFrame-QuestionMark]], 2, 1, 16, 16, 8/64, 1 - (8/64), 8/64, 1 - (8/64))
		
		--build self plugins list
		
		CoolTip:AddLine (Loc ["STRING_OPTIONS_WINDOW"])
		CoolTip:AddMenu (1, _detalhes.OpenOptionsWindow)
		CoolTip:AddIcon ([[Interface\AddOns\Details\images\modo_icones]], 1, 1, 20, 20, 32/256*4, 32/256*5, 0, 1)
		
		--CoolTip:AddFromTable (parameters_table [4])
		
		if (instancia.consolidate) then
			CoolTip:SetOwner (self, "topleft", "topright", 3)
		else
			if (instancia.toolbar_side == 1) then
				CoolTip:SetOwner (self)
			elseif (instancia.toolbar_side == 2) then --> bottom
				CoolTip:SetOwner (self, "bottom", "top", 0, 0) -- -7
			end
		end
		
		--CoolTip:SetWallpaper (1, [[Interface\ACHIEVEMENTFRAME\UI-Achievement-Parchment-Horizontal-Desaturated]], nil, {1, 1, 1, 0.3})
		CoolTip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
		
		show_anti_overlap (instancia, self, "top")
		
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

		CoolTip:SetOption ("FixedWidthSub", 175)
		CoolTip:SetOption ("RightTextWidth", 105)
		CoolTip:SetOption ("RightTextHeight", 12)
		
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
					
						if (thisCombat.instance_type == "party") then
							CoolTip:AddLine (thisCombat.is_boss.name .." (#"..i..")", _, 1, {170/255, 167/255, 255/255, 1})
						elseif (thisCombat.is_boss.killed) then
							CoolTip:AddLine (thisCombat.is_boss.name .." (#"..i..")", _, 1, "lime")
						else
							CoolTip:AddLine (thisCombat.is_boss.name .." (#"..i..")", _, 1, "red")
						end
						
						local portrait = _detalhes:GetBossPortrait (thisCombat.is_boss.mapid, thisCombat.is_boss.index)
						if (portrait) then
							CoolTip:AddIcon (portrait, 2, "top", 128, 64)
						end
						CoolTip:AddIcon ([[Interface\AddOns\Details\images\icons]], "main", "left", 16, 16, 0.96875, 1, 0, 0.03125)
						
						local background = _detalhes:GetRaidIcon (thisCombat.is_boss.mapid)
						if (background) then
							CoolTip:SetWallpaper (2, background, nil, {1, 1, 1, 0.5})
						elseif (thisCombat.instance_type == "party") then
							local ej_id = thisCombat.is_boss.ej_instance_id
							if (ej_id) then
								local name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = EJ_GetInstanceInfo (ej_id)
								if (bgImage) then
									CoolTip:SetWallpaper (2, bgImage, {0.09, 0.698125, 0, 0.833984375}, {1, 1, 1, 0.5})
								end
							end
						else
							CoolTip:SetWallpaper (2, [[Interface\BlackMarket\HotItemBanner]], {0.14453125, 0.9296875, 0.2625, 0.6546875}, {1, 1, 1, 0.5}, true)
						end
					
					elseif (thisCombat.is_arena) then
						
						local file, coords = _detalhes:GetArenaInfo (thisCombat.is_arena.mapid)
						
						enemy = thisCombat.is_arena.name

						CoolTip:AddLine (thisCombat.is_arena.name, _, 1, "yellow")
						
						--131 105 157 127
						--0.255859375 0.306640625 0.205078125 0.248046875
						CoolTip:AddIcon ([[Interface\AddOns\Details\images\icons]], "main", "left", 16, 12, 0.251953125, 0.306640625, 0.205078125, 0.248046875)
						--CoolTip:AddIcon ([[Interface\WorldStateFrame\CombatSwords]], "main", "left", 12, 12, 0, 0.453125, 0.015625, 0.46875)
						
						if (file) then
							CoolTip:SetWallpaper (2, "Interface\\Glues\\LOADINGSCREENS\\" .. file, coords, {1, 1, 1, 0.4})
						end
						
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
							CoolTip:AddIcon ([[Interface\QUESTFRAME\UI-Quest-BulletPoint]], "main", "left", 16, 16)
						end
						
						CoolTip:SetWallpaper (2, [[Interface\ACHIEVEMENTFRAME\UI-Achievement-StatsBackground]], {0.5078125, 0.1171875, 0.017578125, 0.1953125}, {1, 1, 1, .5})
						
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
					CoolTip:AddIcon ([[Interface\QUESTFRAME\UI-Quest-BulletPoint]], "main", "left", 16, 16, nil, nil, nil, nil, empty_segment_color)
					CoolTip:AddLine (Loc ["STRING_SEGMENT_EMPTY"], _, 2)
					CoolTip:AddIcon ([[Interface\CHARACTERFRAME\Disconnect-Icon]], 2, 1, 12, 12, 0.3125, 0.65625, 0.265625, 0.671875)
					CoolTip:SetWallpaper (2, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
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
		CoolTip:AddIcon ([[Interface\QUESTFRAME\UI-Quest-BulletPoint]], "main", "left", 16, 16, nil, nil, nil, nil, "orange")
			
			local enemy = _detalhes.tabela_vigente.is_boss and _detalhes.tabela_vigente.is_boss.name or _detalhes.tabela_vigente.enemy or "--x--x--"
			
			if (_detalhes.tabela_vigente.is_boss and _detalhes.tabela_vigente.is_boss.name) then
				local portrait = _detalhes:GetBossPortrait (_detalhes.tabela_vigente.is_boss.mapid, _detalhes.tabela_vigente.is_boss.index)
				if (portrait) then
					CoolTip:AddIcon (portrait, 2, "top", 128, 64)
				end
				
				local background = _detalhes:GetRaidIcon (_detalhes.tabela_vigente.is_boss.mapid)
				if (background) then
					CoolTip:SetWallpaper (2, background, nil, {1, 1, 1, 0.5})
				elseif (_detalhes.tabela_vigente.instance_type == "party") then
					local ej_id = _detalhes.tabela_vigente.is_boss.ej_instance_id
					if (ej_id) then
						local name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = EJ_GetInstanceInfo (ej_id)
						if (bgImage) then
							CoolTip:SetWallpaper (2, bgImage, {0.09, 0.698125, 0, 0.833984375}, {1, 1, 1, 0.5})
						end
					end
				end
			else
				CoolTip:SetWallpaper (2, [[Interface\ACHIEVEMENTFRAME\UI-Achievement-StatsBackground]], {0.5078125, 0.1171875, 0.017578125, 0.1953125}, {1, 1, 1, .5})
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
		CoolTip:AddIcon ([[Interface\QUESTFRAME\UI-Quest-BulletPoint]], "main", "left", 16, 16, nil, nil, nil, nil, "orange")
		
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
			
			CoolTip:SetWallpaper (2, [[Interface\ACHIEVEMENTFRAME\UI-Achievement-StatsBackground]], {0.5078125, 0.1171875, 0.017578125, 0.1953125}, {1, 1, 1, .5})
			
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
			if (instancia.toolbar_side == 1) then
				CoolTip:SetOwner (self)
			elseif (instancia.toolbar_side == 2) then --> bottom
				CoolTip:SetOwner (self, "bottom", "top", 0, 0) -- -7
			end
		end
		
		CoolTip:SetOption ("TextSize", _detalhes.font_sizes.menus)
		CoolTip:SetOption ("SubMenuIsTooltip", true)
		
		CoolTip:SetOption ("ButtonHeightMod", -4)
		CoolTip:SetOption ("ButtonsYMod", -4)
		CoolTip:SetOption ("YSpacingMod", 4)
		
		CoolTip:SetOption ("ButtonHeightModSub", 4)
		CoolTip:SetOption ("ButtonsYModSub", 0)
		CoolTip:SetOption ("YSpacingModSub", -4)
		
		--CoolTip:SetWallpaper (1, [[Interface\ACHIEVEMENTFRAME\UI-Achievement-Parchment-Horizontal-Desaturated]], nil, {1, 1, 1, 0.3})
		CoolTip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
		
		show_anti_overlap (instancia, self, "top")
		
		CoolTip:ShowCooltip()
		
		self:SetScript ("OnUpdate", nil)
	end	
	
end

-- ~skin
function _detalhes:ChangeSkin (skin_name)

	if (not skin_name) then
		skin_name = self.skin
	end

	local this_skin = _detalhes.skins [skin_name]

	if (not this_skin) then
		skin_name = "Default Skin"
		this_skin = _detalhes.skins [skin_name]
	end

	local just_updating = false
	if (self.skin == skin_name) then
		just_updating = true
	end

	if (not just_updating) then

		--> skin updater
		if (self.bgframe.skin_script) then
			self.bgframe:SetScript ("OnUpdate", nil)
			self.bgframe.skin_script = false
		end
	
		--> reset all config
			self:ResetInstanceConfig()
	
		--> overwrites
			local overwrite_cprops = this_skin.instance_cprops
			if (overwrite_cprops) then
				
				local copy = table_deepcopy (overwrite_cprops)
				
				for cprop, value in _pairs (copy) do
					if (type (value) == "table") then
						for cprop2, value2 in _pairs (value) do
							self [cprop] [cprop2] = value2
						end
					else
						self [cprop] = value
					end
				end
				
			end
			
		--> reset micro frames
			_detalhes.StatusBar:Reset (self)

		--> customize micro frames
			if (this_skin.micro_frames) then
				if (this_skin.micro_frames.left) then
					_detalhes.StatusBar:SetPlugin (self, this_skin.micro_frames.left, "left")
				end
				if (this_skin.micro_frames.color) then
					_detalhes.StatusBar:ApplyOptions (self.StatusBar.left, "textcolor", this_skin.micro_frames.color)
					_detalhes.StatusBar:ApplyOptions (self.StatusBar.center, "textcolor", this_skin.micro_frames.color)
					_detalhes.StatusBar:ApplyOptions (self.StatusBar.right, "textcolor", this_skin.micro_frames.color)
				end
				if (this_skin.micro_frames.font) then
					_detalhes.StatusBar:ApplyOptions (self.StatusBar.left, "textface", this_skin.micro_frames.font)
					_detalhes.StatusBar:ApplyOptions (self.StatusBar.center, "textface", this_skin.micro_frames.font)
					_detalhes.StatusBar:ApplyOptions (self.StatusBar.right, "textface", this_skin.micro_frames.font)
				end
				if (this_skin.micro_frames.size) then
					_detalhes.StatusBar:ApplyOptions (self.StatusBar.left, "textsize", this_skin.micro_frames.size)
					_detalhes.StatusBar:ApplyOptions (self.StatusBar.center, "textsize", this_skin.micro_frames.size)
					_detalhes.StatusBar:ApplyOptions (self.StatusBar.right, "textsize", this_skin.micro_frames.size)
				end
			end
			
	end
	
	self.skin = skin_name

	local skin_file = this_skin.file

	--> set textures
		self.baseframe.cabecalho.ball:SetTexture (skin_file) --> bola esquerda
		self.baseframe.cabecalho.emenda:SetTexture (skin_file) --> emenda que liga a bola a textura do centro
		
		self.baseframe.cabecalho.ball_r:SetTexture (skin_file) --> bola direita onde fica o botão de fechar
		self.baseframe.cabecalho.top_bg:SetTexture (skin_file) --> top background
		
		self.baseframe.barra_esquerda:SetTexture (skin_file) --> barra lateral
		self.baseframe.barra_direita:SetTexture (skin_file) --> barra lateral
		self.baseframe.barra_fundo:SetTexture (skin_file) --> barra inferior
		
		self.baseframe.scroll_up:SetTexture (skin_file) --> scrollbar parte de cima
		self.baseframe.scroll_down:SetTexture (skin_file) --> scrollbar parte de baixo
		self.baseframe.scroll_middle:SetTexture (skin_file) --> scrollbar parte do meio
		
		self.baseframe.rodape.top_bg:SetTexture (skin_file) --> rodape top background
		self.baseframe.rodape.esquerdo:SetTexture (skin_file) --> rodape esquerdo
		self.baseframe.rodape.direita:SetTexture (skin_file) --> rodape direito
		
		self.baseframe.button_stretch.texture:SetTexture (skin_file) --> botão de esticar a janela
		
		self.baseframe.resize_direita.texture:SetTexture (skin_file) --> botão de redimencionar da direita
		self.baseframe.resize_esquerda.texture:SetTexture (skin_file) --> botão de redimencionar da esquerda
		
		self.botao_separar:SetNormalTexture (skin_file) --> cadeado
		self.botao_separar:SetDisabledTexture (skin_file)
		self.botao_separar:SetHighlightTexture (skin_file, "ADD")
		self.botao_separar:SetPushedTexture (skin_file)

----------> icon anchor and size
	
	if (self.modo == 1 or self.modo == 4 or self.atributo == 5) then -- alone e raid
		local icon_anchor = this_skin.icon_anchor_plugins
		self.baseframe.cabecalho.atributo_icon:SetPoint ("topright", self.baseframe.cabecalho.ball_point, "topright", icon_anchor[1], icon_anchor[2])
		if (self.modo == 1) then
			if (_detalhes.SoloTables.Plugins [1] and _detalhes.SoloTables.Mode) then
				local plugin_index = _detalhes.SoloTables.Mode
				if (plugin_index > 0 and _detalhes.SoloTables.Menu [plugin_index]) then
					self:ChangeIcon (_detalhes.SoloTables.Menu [plugin_index] [2])
				end
			end

		elseif (self.modo == 4) then
			--if (_detalhes.RaidTables.Plugins [1] and _detalhes.RaidTables.Mode) then
			--	local plugin_index = _detalhes.RaidTables.Mode
			--	if (plugin_index and _detalhes.RaidTables.Menu [plugin_index]) then
					--self:ChangeIcon (_detalhes.RaidTables.Menu [plugin_index] [2])
			--	end
			--end
		end
	else
		local icon_anchor = this_skin.icon_anchor_main --> ancora do icone do canto direito superior
		self.baseframe.cabecalho.atributo_icon:SetPoint ("topright", self.baseframe.cabecalho.ball_point, "topright", icon_anchor[1], icon_anchor[2])
		self:ChangeIcon()
	end
	
----------> lock alpha head	
	
	if (not this_skin.can_change_alpha_head) then
		self.baseframe.cabecalho.ball:SetAlpha (100)
	else
		self.baseframe.cabecalho.ball:SetAlpha (self.color[4])
	end

----------> update abbreviation function on the class files
	
	_detalhes.atributo_damage:UpdateSelectedToKFunction()
	_detalhes.atributo_heal:UpdateSelectedToKFunction()
	_detalhes.atributo_energy:UpdateSelectedToKFunction()
	_detalhes.atributo_misc:UpdateSelectedToKFunction()
	
----------> call widgets handlers	
		self:SetBarSettings (self.row_info.height)
		self:SetBarBackdropSettings()
	
	--> update toolbar
		self:ToolbarSide()
	
	--> update stretch button
		self:StretchButtonAnchor()
	
	--> update side bars
		if (self.show_sidebars) then
			self:ShowSideBars()
		else
			self:HideSideBars()
		end

	--> refresh the side of the micro displays
		self:MicroDisplaysSide()
		
	--> update statusbar
		if (self.show_statusbar) then
			self:ShowStatusBar()
		else
			self:HideStatusBar()
		end

	--> update wallpaper
		if (self.wallpaper.enabled) then
			self:InstanceWallpaper (true)
		else
			self:InstanceWallpaper (false)
		end
	
	--> update instance color
		self:InstanceColor()
		self:SetBackgroundColor()
		self:SetBackgroundAlpha()
		self:SetAutoHideMenu()
		self:SetBackdropTexture()

	--> refresh all bars
		
		self:InstanceRefreshRows()

	--> update menu saturation
		self:DesaturateMenu()
		self:DesaturateMenu2()
	
	--> update statusbar color
		self:StatusBarColor()
	
	--> update attribute string
		self:AttributeMenu()
	
	--> update top menus
		self:LeftMenuAnchorSide()
		self:Menu2Anchor()
		
	--> update window strata level
		self:SetFrameStrata()
	
	--> update the combat alphas
		self:SetCombatAlpha (nil, nil, true)
		
	--> update icons
		_detalhes.ToolBar:ReorganizeIcons (true) --call self:SetMenuAlpha()
		
	--> refresh options panel if opened
		if (_G.DetailsOptionsWindow and _G.DetailsOptionsWindow:IsShown()) then
			_detalhes:OpenOptionsWindow (self)
		end
	
	if (not just_updating or _detalhes.initializing) then
		if (this_skin.callback) then
			this_skin:callback (self, just_updating)
		end
		
		if (this_skin.control_script) then
			if (this_skin.control_script_on_start) then
				this_skin:control_script_on_start (self)
			end
			self.bgframe:SetScript ("OnUpdate", this_skin.control_script)
			self.bgframe.skin_script = true
			self.bgframe.skin = this_skin
			--self.bgframe.skin_script_instance = true
		end

	end

end

function _detalhes:SetCombatAlpha (modify_type, alpha_amount, interacting)

	if (interacting) then
		
		if (self.hide_in_combat_type == 1) then --None
			return
			
		elseif (self.hide_in_combat_type == 2) then --While In Combat
			if (UnitAffectingCombat ("player") or InCombatLockdown()) then
				self:SetWindowAlphaForCombat (true, true) --> hida a janela
			else
				self:SetWindowAlphaForCombat (false) --> deshida a janela
			end
			
		elseif (self.hide_in_combat_type == 3) then --"While Out of Combat"
			if (UnitAffectingCombat ("player") or InCombatLockdown()) then
				self:SetWindowAlphaForCombat (false) --> deshida a janela
			else
				self:SetWindowAlphaForCombat (true, true) --> hida a janela
			end
			
		elseif (self.hide_in_combat_type == 4) then --"While Out of a Group"
			if (_detalhes.in_group) then
				self:SetWindowAlphaForCombat (false) --> deshida a janela
			else
				self:SetWindowAlphaForCombat (true, true) --> hida a janela
			end
		end
		
		return
	end

	if (not modify_type) then
		modify_type = self.hide_in_combat_type
	else
		if (modify_type == 1) then --> changed to none
			self:SetWindowAlphaForCombat (false)
		end
	end
	
	if (not alpha_amount) then
		alpha_amount = self.hide_in_combat_alpha
	end
	
	self.hide_in_combat_type = modify_type
	self.hide_in_combat_alpha = alpha_amount
	
	self:SetCombatAlpha (nil, nil, true)
	
end

function _detalhes:SetFrameStrata (strata)
	
	if (not strata) then
		strata = self.strata
	end
	
	self.strata = strata
	
	self.rowframe:SetFrameStrata (strata)
	self.baseframe:SetFrameStrata (strata)
	
	if (strata == "BACKGROUND") then
		self.botao_separar:SetFrameStrata ("LOW")
		self.baseframe.resize_esquerda:SetFrameStrata ("LOW")
		self.baseframe.resize_direita:SetFrameStrata ("LOW")
		self.baseframe.lock_button:SetFrameStrata ("LOW")
		
	elseif (strata == "LOW") then
		self.botao_separar:SetFrameStrata ("MEDIUM")
		self.baseframe.resize_esquerda:SetFrameStrata ("MEDIUM")
		self.baseframe.resize_direita:SetFrameStrata ("MEDIUM")
		self.baseframe.lock_button:SetFrameStrata ("MEDIUM")
		
	elseif (strata == "MEDIUM") then
		self.botao_separar:SetFrameStrata ("HIGH")
		self.baseframe.resize_esquerda:SetFrameStrata ("HIGH")
		self.baseframe.resize_direita:SetFrameStrata ("HIGH")
		self.baseframe.lock_button:SetFrameStrata ("HIGH")
		
	elseif (strata == "HIGH") then
		self.botao_separar:SetFrameStrata ("DIALOG")
		self.baseframe.resize_esquerda:SetFrameStrata ("DIALOG")
		self.baseframe.resize_direita:SetFrameStrata ("DIALOG")
		self.baseframe.lock_button:SetFrameStrata ("DIALOG")
		
	elseif (strata == "DIALOG") then
		self.botao_separar:SetFrameStrata ("FULLSCREEN")
		self.baseframe.resize_esquerda:SetFrameStrata ("FULLSCREEN")
		self.baseframe.resize_direita:SetFrameStrata ("FULLSCREEN")
		self.baseframe.lock_button:SetFrameStrata ("FULLSCREEN")
		
	end
	
	self:StretchButtonAlwaysOnTop()
	
end

function _detalhes:LeftMenuAnchorSide (side)
	
	if (not side) then
		side = self.menu_anchor.side
	end
	
	self.menu_anchor.side = side
	
	return self:MenuAnchor()
	
end

-- ~attributemenu (text with attribute name)
function _detalhes:AttributeMenu (enabled, pos_x, pos_y, font, size, color, side, shadow)

	if (type (enabled) ~= "boolean") then
		enabled = self.attribute_text.enabled
	end
	
	if (not pos_x) then
		pos_x = self.attribute_text.anchor [1]
	end
	if (not pos_y) then
		pos_y = self.attribute_text.anchor [2]
	end
	
	if (not font) then
		font = self.attribute_text.text_face
	end
	
	if (not size) then
		size = self.attribute_text.text_size
	end
	
	if (not color) then
		color = self.attribute_text.text_color
	end
	
	if (not side) then
		side = self.attribute_text.side
	end
	
	if (type (shadow) ~= "boolean") then
		shadow = self.attribute_text.shadow
	end
	
	self.attribute_text.enabled = enabled
	self.attribute_text.anchor [1] = pos_x
	self.attribute_text.anchor [2] = pos_y
	self.attribute_text.text_face = font
	self.attribute_text.text_size = size
	self.attribute_text.text_color = color
	self.attribute_text.side = side
	self.attribute_text.shadow = shadow

	--> enabled
	if (not enabled and self.menu_attribute_string) then
		return self.menu_attribute_string:Hide()
	elseif (not enabled) then
		return
	end
	
	--> protection against failed clean up framework table
	if (self.menu_attribute_string and not getmetatable (self.menu_attribute_string)) then
		self.menu_attribute_string = nil
	end
	
	if (not self.menu_attribute_string) then

		local label = gump:NewLabel (self.floatingframe, nil, "DetailsAttributeStringInstance" .. self.meu_id, nil, "", "GameFontHighlightSmall")
		self.menu_attribute_string = label
		self.menu_attribute_string.text = _detalhes:GetSubAttributeName (self.atributo, self.sub_atributo)
		self.menu_attribute_string.owner_instance = self
		
		self.menu_attribute_string.Enabled = true
		self.menu_attribute_string.__enabled = true
		
		function self.menu_attribute_string:OnEvent (instance, attribute, subAttribute)
			if (instance == label.owner_instance) then
				local sName = instance:GetInstanceAttributeText()
				label.text = sName
			end
		end
		
		_detalhes:RegisterEvent (self.menu_attribute_string, "DETAILS_INSTANCE_CHANGEATTRIBUTE", self.menu_attribute_string.OnEvent)
		_detalhes:RegisterEvent (self.menu_attribute_string, "DETAILS_INSTANCE_CHANGEMODE", self.menu_attribute_string.OnEvent)

	end

	self.menu_attribute_string:Show()
	
	--> anchor
	if (side == 1) then --> a string esta no lado de cima
		if (self.toolbar_side == 1) then -- a toolbar esta em cima
			self.menu_attribute_string:ClearAllPoints()
			self.menu_attribute_string:SetPoint ("bottomleft", self.baseframe.cabecalho.ball, "bottomright", self.attribute_text.anchor [1], self.attribute_text.anchor [2])
			
		elseif (self.toolbar_side == 2) then --a toolbar esta em baixo
			self.menu_attribute_string:ClearAllPoints()
			self.menu_attribute_string:SetPoint ("bottomleft", self.baseframe, "topleft", self.attribute_text.anchor [1] + 21, self.attribute_text.anchor [2])

		end
		
	elseif (side == 2) then --> a string esta no lado de baixo
		if (self.toolbar_side == 1) then --toolbar esta em cima
			self.menu_attribute_string:ClearAllPoints()
			self.menu_attribute_string:SetPoint ("left", self.baseframe.rodape.StatusBarLeftAnchor, "left", self.attribute_text.anchor [1] + 16, self.attribute_text.anchor [2] - 6)

		elseif (self.toolbar_side == 2) then --toolbar esta em baixo
			self.menu_attribute_string:SetPoint ("bottomleft", self.baseframe.cabecalho.ball, "topright", self.attribute_text.anchor [1], self.attribute_text.anchor [2] - 19)

		end
	end
	
	--font face
	local fontPath = SharedMedia:Fetch ("font", font)
	_detalhes:SetFontFace (self.menu_attribute_string, fontPath)
	
	--font size
	_detalhes:SetFontSize (self.menu_attribute_string, size)
	
	--color
	_detalhes:SetFontColor (self.menu_attribute_string, color)
	
	--shadow
	_detalhes:SetFontOutline (self.menu_attribute_string, shadow)
	
end

-- ~backdrop
function _detalhes:SetBackdropTexture (texturename)
	
	if (not texturename) then
		texturename = self.backdrop_texture
	end
	
	self.backdrop_texture = texturename
	
	local texture_path = SharedMedia:Fetch ("background", texturename)
	
	self.baseframe:SetBackdrop ({
		bgFile = texture_path, tile = true, tileSize = 128,
		insets = {left = 0, right = 0, top = 0, bottom = 0}}
	)
	self.bgdisplay:SetBackdrop ({
		bgFile = texture_path, tile = true, tileSize = 128,
		insets = {left = 0, right = 0, top = 0, bottom = 0}}
	)
	
	self:SetBackgroundAlpha (self.bg_alpha)
	
end

-- ~alpha (transparency of buttons on the toolbar)
function _detalhes:SetAutoHideMenu (left, right, interacting)

	if (interacting) then
		if (self.is_interacting) then
			if (self.auto_hide_menu.left) then
				local r, g, b = unpack (self.color_buttons)
				self:InstanceButtonsColors (r, g, b, 1, true, true) --no save, only left
			end
			if (self.auto_hide_menu.right) then
				local r, g, b = unpack (self.color_buttons)
				self:InstanceButtonsColors (r, g, b, 1, true, nil, true) --no save, only right
			end
		else
			if (self.auto_hide_menu.left) then
				local r, g, b = unpack (self.color_buttons)
				self:InstanceButtonsColors (r, g, b, 0, true, true) --no save, only left
			end
			if (self.auto_hide_menu.right) then
				local r, g, b = unpack (self.color_buttons)
				self:InstanceButtonsColors (r, g, b, 0, true, nil, true) --no save, only right
			end
		end
		return
	end

	if (left == nil) then
		left = self.auto_hide_menu.left
	end
	if (right == nil) then
		right = self.auto_hide_menu.right
	end

	self.auto_hide_menu.left = left
	self.auto_hide_menu.right = right
	
	local r, g, b = unpack (self.color_buttons)
	
	if (not left) then
		--auto hide is off
		self:InstanceButtonsColors (r, g, b, 1, true, true) --no save, only left
	else
		if (self.is_interacting) then
			self:InstanceButtonsColors (r, g, b, 1, true, true) --no save, only left
		else
			self:InstanceButtonsColors (0, 0, 0, 0, true, true) --no save, only left
		end
	end
	
	if (not right) then
		--auto hide is off
		self:InstanceButtonsColors (r, g, b, 1, true, nil, true) --no save, only right
	else
		if (self.is_interacting) then
			self:InstanceButtonsColors (r, g, b, 1, true, nil, true) --no save, only right
		else
			self:InstanceButtonsColors (0, 0, 0, 0, true, nil, true) --no save, only right
		end
	end
	
	--auto_hide_menu = {left = false, right = false},

end

-- transparency for toolbar, borders and statusbar
function _detalhes:SetMenuAlpha (enabled, onenter, onleave, ignorebars, interacting)

	if (interacting) then --> called from a onenter or onleave script
		if (self.menu_alpha.enabled) then
			if (self.is_interacting) then
				return self:SetWindowAlphaForInteract (self.menu_alpha.onenter)
			else
				return self:SetWindowAlphaForInteract (self.menu_alpha.onleave)
			end
		end
		return
	end

	--ignorebars
	
	if (enabled == nil) then
		enabled = self.menu_alpha.enabled
	end
	if (not onenter) then
		onenter = self.menu_alpha.onenter
	end
	if (not onleave) then
		onleave = self.menu_alpha.onleave
	end
	if (ignorebars == nil) then
		ignorebars = self.menu_alpha.ignorebars
	end

	self.menu_alpha.enabled = enabled
	self.menu_alpha.onenter = onenter
	self.menu_alpha.onleave = onleave
	self.menu_alpha.ignorebars = ignorebars
	
	if (not enabled) then
		--> aqui esta mandando setar a alpha do baseframe
		self.baseframe:SetAlpha (1)
		return self:InstanceColor (unpack (self.color))
		--return self:SetWindowAlphaForInteract (self.color [4])
	else
		local r, g, b = unpack (self.color)
		self:InstanceColor (r, g, b, 1)
		r, g, b = unpack (self.statusbar_info.overlay)
		self:StatusBarColor (r, g, b, 1)
	end

	if (self.is_interacting) then
		return self:SetWindowAlphaForInteract (onenter) --> set alpha
	else
		return self:SetWindowAlphaForInteract (onleave) --> set alpha
	end
	
end

function _detalhes:GetInstanceCurrentAlpha()
	if (self.menu_alpha.enabled) then
		if (self:IsInteracting()) then
			return self.menu_alpha.onenter
		else
			return self.menu_alpha.onleave
		end
	else
		return self.color [4]
	end
end

function _detalhes:GetInstanceIconsCurrentAlpha()
	if (self.menu_alpha.enabled and self.menu_alpha.iconstoo) then
		if (self:IsInteracting()) then
			return self.menu_alpha.onenter
		else
			return self.menu_alpha.onleave
		end
	else
		return 1
	end
end

function _detalhes:MicroDisplaysSide (side, fromuser)
	if (not side) then
		side = self.micro_displays_side
	end
	
	self.micro_displays_side = side
	
	_detalhes.StatusBar:ReloadAnchors (self)
	
	if (self.micro_displays_side == 2 and not self.show_statusbar) then --> bottom side
		_detalhes.StatusBar:Hide (self)
		if (fromuser) then
			_detalhes:Msg (Loc ["STRING_OPTIONS_MICRODISPLAYWARNING"])
		end
	elseif (self.micro_displays_side == 2) then
		_detalhes.StatusBar:Show (self)
	elseif (self.micro_displays_side == 1) then
		_detalhes.StatusBar:Show (self)
	end
	
end

function _detalhes:ToolbarSide (side)
	
	if (not side) then
		side = self.toolbar_side
	end
	
	self.toolbar_side = side
	
	local skin = _detalhes.skins [self.skin]
	
	if (side == 1) then --> top
		--> ball point
		self.baseframe.cabecalho.ball_point:ClearAllPoints()
		self.baseframe.cabecalho.ball_point:SetPoint ("bottomleft", self.baseframe, "topleft", unpack (skin.icon_point_anchor))
		--> ball
		self.baseframe.cabecalho.ball:SetTexCoord (unpack (COORDS_LEFT_BALL))
		self.baseframe.cabecalho.ball:ClearAllPoints()
		self.baseframe.cabecalho.ball:SetPoint ("bottomleft", self.baseframe, "topleft", unpack (skin.left_corner_anchor))

		--> ball r
		self.baseframe.cabecalho.ball_r:SetTexCoord (unpack (COORDS_RIGHT_BALL))
		self.baseframe.cabecalho.ball_r:ClearAllPoints()
		self.baseframe.cabecalho.ball_r:SetPoint ("bottomright", self.baseframe, "topright", unpack (skin.right_corner_anchor))

		--> tex coords
		self.baseframe.cabecalho.emenda:SetTexCoord (unpack (COORDS_LEFT_CONNECTOR))
		self.baseframe.cabecalho.top_bg:SetTexCoord (unpack (COORDS_TOP_BACKGROUND))
		
	else --> bottom
	
		local y = 0
		if (self.show_statusbar) then
			y = -14
		end
	
		--> ball point
		self.baseframe.cabecalho.ball_point:ClearAllPoints()
		local _x, _y = unpack (skin.icon_point_anchor_bottom)
		self.baseframe.cabecalho.ball_point:SetPoint ("topleft", self.baseframe, "bottomleft", _x, _y + y)
		--> ball
		self.baseframe.cabecalho.ball:ClearAllPoints()
		local _x, _y = unpack (skin.left_corner_anchor_bottom)
		self.baseframe.cabecalho.ball:SetPoint ("topleft", self.baseframe, "bottomleft", _x, _y + y)
		local l, r, t, b = unpack (COORDS_LEFT_BALL)
		self.baseframe.cabecalho.ball:SetTexCoord (l, r, b, t)

		--> ball r
		self.baseframe.cabecalho.ball_r:ClearAllPoints()
		local _x, _y = unpack (skin.right_corner_anchor_bottom)
		self.baseframe.cabecalho.ball_r:SetPoint ("topright", self.baseframe, "bottomright", _x, _y + y)
		local l, r, t, b = unpack (COORDS_RIGHT_BALL)
		self.baseframe.cabecalho.ball_r:SetTexCoord (l, r, b, t)
		
		--> tex coords
		local l, r, t, b = unpack (COORDS_LEFT_CONNECTOR)
		self.baseframe.cabecalho.emenda:SetTexCoord (l, r, b, t)
		local l, r, t, b = unpack (COORDS_TOP_BACKGROUND)
		self.baseframe.cabecalho.top_bg:SetTexCoord (l, r, b, t)

	end
	
	--> update top menus
		self:LeftMenuAnchorSide()
		self:Menu2Anchor()
	
	self:StretchButtonAnchor()
	
	self:HideMainIcon()
	
	if (self.show_sidebars) then
		self:ShowSideBars()
	end
	
	self:AttributeMenu()
	
end

function _detalhes:StretchButtonAlwaysOnTop (on_top)
	
	if (type (on_top) ~= "boolean") then
		on_top = self.grab_on_top
	end
	
	self.grab_on_top = on_top
	
	if (self.grab_on_top) then
		self.baseframe.button_stretch:SetFrameStrata ("FULLSCREEN")
	else
		self.baseframe.button_stretch:SetFrameStrata (self.strata)
	end
	
end

function _detalhes:StretchButtonAnchor (side)
	
	if (not side) then
		side = self.stretch_button_side
	end
	
	if (side == 1 or string.lower (side) == "top") then
	
		self.baseframe.button_stretch:ClearAllPoints()
		
		local y = 0
		if (self.toolbar_side == 2) then --bottom
			y = -20
		end
		
		self.baseframe.button_stretch:SetPoint ("bottom", self.baseframe, "top", 0, 20 + y)
		self.baseframe.button_stretch:SetPoint ("right", self.baseframe, "right", -27, 0)
		self.baseframe.button_stretch.texture:SetTexCoord (unpack (COORDS_STRETCH))
		self.stretch_button_side = 1
		
	elseif (side == 2 or string.lower (side) == "bottom") then
	
		self.baseframe.button_stretch:ClearAllPoints()
		
		local y = 0
		if (self.toolbar_side == 2) then --bottom
			y = y -20
		end
		if (self.show_statusbar) then
			y = y -14
		end
		
		self.baseframe.button_stretch:SetPoint ("center", self.baseframe, "center")
		self.baseframe.button_stretch:SetPoint ("top", self.baseframe, "bottom", 0, y)
		
		local l, r, t, b = unpack (COORDS_STRETCH)
		self.baseframe.button_stretch.texture:SetTexCoord (r, l, b, t)
		
		self.stretch_button_side = 2
		
	end
	
end

function _detalhes:MenuAnchor (x, y)

	if (self.toolbar_side == 1) then --top
		if (not x) then
			x = self.menu_anchor [1]
		end
		if (not y) then
			y = self.menu_anchor [2]
		end
		self.menu_anchor [1] = x
		self.menu_anchor [2] = y
		
	elseif (self.toolbar_side == 2) then --bottom
		if (not x) then
			x = self.menu_anchor_down [1]
		end
		if (not y) then
			y = self.menu_anchor_down [2]
		end
		self.menu_anchor_down [1] = x
		self.menu_anchor_down [2] = y
	end
	
	local menu_points = self.menu_points -- = {MenuAnchorLeft, MenuAnchorRight}
	
	if (self.menu_anchor.side == 1) then --> left
		--self.baseframe.cabecalho.modo_selecao:ClearAllPoints()
	
		menu_points [1]:ClearAllPoints()
		if (self.toolbar_side == 1) then --> top
			--self.baseframe.cabecalho.modo_selecao:SetPoint ("bottomleft", self.baseframe.cabecalho.ball, "bottomright", x, y)
			menu_points [1]:SetPoint ("bottomleft", self.baseframe.cabecalho.ball, "bottomright", x, y+2)
			
		else --> bottom
			--self.baseframe.cabecalho.modo_selecao:SetPoint ("topleft", self.baseframe.cabecalho.ball, "topright", x, y*-1)
			menu_points [1]:SetPoint ("topleft", self.baseframe.cabecalho.ball, "topright", x, (y*-1) - 4)

		end
	
	elseif (self.menu_anchor.side == 2) then --> right
		--self.baseframe.cabecalho.modo_selecao:ClearAllPoints()
		menu_points [2]:ClearAllPoints()
		if (self.toolbar_side == 1) then --> top
			--self.baseframe.cabecalho.modo_selecao:SetPoint ("topleft", self.baseframe.cabecalho.ball_r, "bottomleft", x, y+16)
			menu_points [2]:SetPoint ("topleft", self.baseframe.cabecalho.ball_r, "bottomleft", x, y+16)
			
		else --> bottom
			--self.baseframe.cabecalho.modo_selecao:SetPoint ("topleft", self.baseframe.cabecalho.ball_r, "topleft", x, y*-1)
			menu_points [2]:SetPoint ("topleft", self.baseframe.cabecalho.ball_r, "topleft", x, (y*-1) - 4)

		end
	end
	
	self:ToolbarMenuButtons()
	
end

function _detalhes:Menu2Anchor (x, y)

	if (self.toolbar_side == 1) then --top
		if (not x) then
			x = self.menu2_anchor [1]
		end
		if (not y) then
			y = self.menu2_anchor [2]
		end
		self.menu2_anchor [1] = x
		self.menu2_anchor [2] = y
		
	elseif (self.toolbar_side== 2) then --bottom
		if (not x) then
			x = self.menu2_anchor_down [1]
		end
		if (not y) then
			y = self.menu2_anchor_down [2]
		end
		self.menu2_anchor_down [1] = x
		self.menu2_anchor_down [2] = y
	end
	
	local anchor = self.menu2_points [1]
	anchor:ClearAllPoints()
	
	if (self.toolbar_side == 1) then --> top
		anchor:SetPoint ("topleft", self.baseframe.cabecalho.ball_r, "bottomleft", x, y+16)
		
	else --> bottom
		anchor:SetPoint ("topleft", self.baseframe.cabecalho.ball_r, "topleft", x-17, (y*-1) + 1)

	end
	
	self:ToolbarMenu2Buttons()
	
end

function _detalhes:HideMainIcon (value)

	if (type (value) ~= "boolean") then
		value = self.hide_icon
	end

	if (value) then
	
		self.hide_icon = true
		gump:Fade (self.baseframe.cabecalho.atributo_icon, 1)
		--self.baseframe.cabecalho.ball:SetParent (self.baseframe)
		
		if (self.toolbar_side == 1) then
			self.baseframe.cabecalho.ball:SetTexCoord (unpack (COORDS_LEFT_BALL_NO_ICON))
			self.baseframe.cabecalho.emenda:SetTexCoord (unpack (COORDS_LEFT_CONNECTOR_NO_ICON))
			
		elseif (self.toolbar_side == 2) then
			local l, r, t, b = unpack (COORDS_LEFT_BALL_NO_ICON)
			self.baseframe.cabecalho.ball:SetTexCoord (l, r, b, t)
			local l, r, t, b = unpack (COORDS_LEFT_CONNECTOR_NO_ICON)
			self.baseframe.cabecalho.emenda:SetTexCoord (l, r, b, t)
		
		end
		
	else
		self.hide_icon = false
		gump:Fade (self.baseframe.cabecalho.atributo_icon, 0)
		--self.baseframe.cabecalho.ball:SetParent (_detalhes.listener)
		
		if (self.toolbar_side == 1) then

			self.baseframe.cabecalho.ball:SetTexCoord (unpack (COORDS_LEFT_BALL))
			self.baseframe.cabecalho.emenda:SetTexCoord (unpack (COORDS_LEFT_CONNECTOR))
			
		elseif (self.toolbar_side == 2) then

			local l, r, t, b = unpack (COORDS_LEFT_BALL)
			self.baseframe.cabecalho.ball:SetTexCoord (l, r, b, t)
			local l, r, t, b = unpack (COORDS_LEFT_CONNECTOR)
			self.baseframe.cabecalho.emenda:SetTexCoord (l, r, b, t)
		end
	end
	
end

--> search key: ~desaturate
function _detalhes:DesaturateMenu (value)

	if (value == nil) then
		value = self.desaturated_menu
	end

	if (value) then
	
		self.desaturated_menu = true
		self.baseframe.cabecalho.modo_selecao:GetNormalTexture():SetDesaturated (true)
		self.baseframe.cabecalho.segmento:GetNormalTexture():SetDesaturated (true)
		self.baseframe.cabecalho.atributo:GetNormalTexture():SetDesaturated (true)
		self.baseframe.cabecalho.report:GetNormalTexture():SetDesaturated (true)
		
		if (self.meu_id == _detalhes:GetLowerInstanceNumber()) then
			for _, button in _ipairs (_detalhes.ToolBar.AllButtons) do
				button:GetNormalTexture():SetDesaturated (true)
			end
		end
		
	else
	
		self.desaturated_menu = false
		self.baseframe.cabecalho.modo_selecao:GetNormalTexture():SetDesaturated (false)
		self.baseframe.cabecalho.segmento:GetNormalTexture():SetDesaturated (false)
		self.baseframe.cabecalho.atributo:GetNormalTexture():SetDesaturated (false)
		self.baseframe.cabecalho.report:GetNormalTexture():SetDesaturated (false)
		
		if (self.meu_id == _detalhes:GetLowerInstanceNumber()) then
			for _, button in _ipairs (_detalhes.ToolBar.AllButtons) do
				button:GetNormalTexture():SetDesaturated (false)
			end
		end
		
	end
end

function _detalhes:DesaturateMenu2 (value)

	if (value == nil) then
		value = self.desaturated_menu2
	end

	if (value) then
		self.desaturated_menu2 = true
		self.baseframe.cabecalho.fechar:GetNormalTexture():SetDesaturated (true)
		self.baseframe.cabecalho.novo:GetNormalTexture():SetDesaturated (true)
		self.baseframe.cabecalho.reset:GetNormalTexture():SetDesaturated (true)
	else
		self.desaturated_menu2 = false
		self.baseframe.cabecalho.fechar:GetNormalTexture():SetDesaturated (false)
		self.baseframe.cabecalho.novo:GetNormalTexture():SetDesaturated (false)
		self.baseframe.cabecalho.reset:GetNormalTexture():SetDesaturated (false)
	end
end

function _detalhes:ShowSideBars (instancia)
	if (instancia) then
		self = instancia
	end
	
	self.show_sidebars = true
	
	self.baseframe.barra_esquerda:Show()
	self.baseframe.barra_direita:Show()
	
	--> set default spacings
	local this_skin = _detalhes.skins [self.skin]
	if (this_skin.instance_cprops and this_skin.instance_cprops.row_info and this_skin.instance_cprops.row_info.space) then
		self.row_info.space.left = this_skin.instance_cprops.row_info.space.left
		self.row_info.space.right = this_skin.instance_cprops.row_info.space.right
	else
		self.row_info.space.left = 3
		self.row_info.space.right = -5
	end

	if (self.show_statusbar) then
		self.baseframe.barra_esquerda:SetPoint ("bottomleft", self.baseframe, "bottomleft", -56, -14)
		self.baseframe.barra_direita:SetPoint ("bottomright", self.baseframe, "bottomright", 56, -14)
		
		if (self.toolbar_side == 2) then
			self.baseframe.barra_fundo:Show()
			local l, r, t, b = unpack (COORDS_BOTTOM_SIDE_BAR)
			self.baseframe.barra_fundo:SetTexCoord (l, r, b, t)
			self.baseframe.barra_fundo:ClearAllPoints()
			self.baseframe.barra_fundo:SetPoint ("bottomleft", self.baseframe, "topleft", 0, -6)
			self.baseframe.barra_fundo:SetPoint ("bottomright", self.baseframe, "topright", -1, -6)
		else
			self.baseframe.barra_fundo:Hide()
		end
	else
		self.baseframe.barra_esquerda:SetPoint ("bottomleft", self.baseframe, "bottomleft", -56, 0)
		self.baseframe.barra_direita:SetPoint ("bottomright", self.baseframe, "bottomright", 56, 0)
		
		self.baseframe.barra_fundo:Show()
		
		if (self.toolbar_side == 2) then --tooltbar on bottom
			local l, r, t, b = unpack (COORDS_BOTTOM_SIDE_BAR)
			self.baseframe.barra_fundo:SetTexCoord (l, r, b, t)
			self.baseframe.barra_fundo:ClearAllPoints()
			self.baseframe.barra_fundo:SetPoint ("bottomleft", self.baseframe, "topleft", 0, -6)
			self.baseframe.barra_fundo:SetPoint ("bottomright", self.baseframe, "topright", -1, -6)
		else --tooltbar on top
			self.baseframe.barra_fundo:SetTexCoord (unpack (COORDS_BOTTOM_SIDE_BAR))
			self.baseframe.barra_fundo:ClearAllPoints()
			self.baseframe.barra_fundo:SetPoint ("bottomleft", self.baseframe, "bottomleft", 0, -56)
			self.baseframe.barra_fundo:SetPoint ("bottomright", self.baseframe, "bottomright", -1, -56)
		end
	end
	
	self:SetBarGrowDirection()
	
end

function _detalhes:HideSideBars (instancia)
	if (instancia) then
		self = instancia
	end
	
	self.show_sidebars = false
	
	self.row_info.space.left = 0
	self.row_info.space.right = 0
	
	self.baseframe.barra_esquerda:Hide()
	self.baseframe.barra_direita:Hide()
	self.baseframe.barra_fundo:Hide()
	
	self:SetBarGrowDirection()
end

function _detalhes:HideStatusBar (instancia)
	if (instancia) then
		self = instancia
	end
	
	self.show_statusbar = false
	
	self.baseframe.rodape.esquerdo:Hide()
	self.baseframe.rodape.direita:Hide()
	self.baseframe.rodape.top_bg:Hide()
	self.baseframe.rodape.StatusBarLeftAnchor:Hide()
	self.baseframe.rodape.StatusBarCenterAnchor:Hide()
	self.baseframe.DOWNFrame:Hide()
	
	if (self.toolbar_side == 2) then
		self:ToolbarSide()
	end
	
	if (self.show_sidebars) then
		self:ShowSideBars()
	end
	
	self:StretchButtonAnchor()
	
	if (self.micro_displays_side == 2) then --> bottom side
		_detalhes.StatusBar:Hide (self) --> mini displays widgets
	end
end

function _detalhes:StatusBarColor (r, g, b, a, no_save)

	if (not r) then
		r, g, b = unpack (self.statusbar_info.overlay)
		a = a or self.statusbar_info.alpha
	end

	if (not no_save) then
		self.statusbar_info.overlay [1] = r
		self.statusbar_info.overlay [2] = g
		self.statusbar_info.overlay [3] = b
		self.statusbar_info.alpha = a
	end
	
	self.baseframe.rodape.esquerdo:SetVertexColor (r, g, b)
	self.baseframe.rodape.esquerdo:SetAlpha (a)
	self.baseframe.rodape.direita:SetVertexColor (r, g, b)
	self.baseframe.rodape.direita:SetAlpha (a)
	self.baseframe.rodape.top_bg:SetVertexColor (r, g, b)
	self.baseframe.rodape.top_bg:SetAlpha (a)
	
end

function _detalhes:ShowStatusBar (instancia)
	if (instancia) then
		self = instancia
	end
	
	self.show_statusbar = true
	
	self.baseframe.rodape.esquerdo:Show()
	self.baseframe.rodape.direita:Show()
	self.baseframe.rodape.top_bg:Show()
	self.baseframe.rodape.StatusBarLeftAnchor:Show()
	self.baseframe.rodape.StatusBarCenterAnchor:Show()
	self.baseframe.DOWNFrame:Show()
	
	self:ToolbarSide()
	self:StretchButtonAnchor()
	
	if (self.micro_displays_side == 2) then --> bottom side
		_detalhes.StatusBar:Show (self) --> mini displays widgets
	end
end

--> reset button functions
	local reset_button_onenter = function (self)
	
		OnEnterMainWindow (self.instance, self)
		GameCooltip.buttonOver = true
		self.instance.baseframe.cabecalho.button_mouse_over = true
		
		GameCooltip:Reset()
		GameCooltip:SetOption ("ButtonsYMod", -2)
		GameCooltip:SetOption ("YSpacingMod", 0)
		GameCooltip:SetOption ("TextHeightMod", 0)
		GameCooltip:SetOption ("IgnoreButtonAutoHeight", false)
		
		local font = SharedMedia:Fetch ("font", "Friz Quadrata TT")
		
		GameCooltip:AddLine (Loc ["STRING_ERASE_DATA"], nil, 1, "white", nil, 10, font)
		GameCooltip:AddIcon ([[Interface\Buttons\UI-StopButton]], 1, 1, 14, 14, 0, 1, 0, 1, "red")
		GameCooltip:AddMenu (1, _detalhes.tabela_historico.resetar)
		
		GameCooltip:AddLine (Loc ["STRING_ERASE_DATA_OVERALL"], nil, 1, "white", nil, 10, font)
		GameCooltip:AddIcon ([[Interface\Buttons\UI-StopButton]], 1, 1, 14, 14, 0, 1, 0, 1, "orange")
		GameCooltip:AddMenu (1, _detalhes.tabela_historico.resetar_overall)
		
		GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
		
		show_anti_overlap (self.instance, self, "top")
		
		GameCooltip:ShowCooltip (self, "menu")
	end
	
	local reset_button_onleave = function (self)
		OnLeaveMainWindow (self.instance, self)
		
		hide_anti_overlap (self.instance.baseframe.anti_menu_overlap)
		
		GameCooltip.buttonOver = false
		self.instance.baseframe.cabecalho.button_mouse_over = false
		
		if (GameCooltip.active) then
			parameters_table [2] = 0
			self:SetScript ("OnUpdate", on_leave_menu)
		else
			self:SetScript ("OnUpdate", nil)
		end
		
	end
	
--> close button functions

	local close_button_onclick = function (self, _, button)
		self = self or button
	
		self:Disable()
		self.instancia:DesativarInstancia() 
		
		--> não há mais instâncias abertas, então manda msg alertando
		if (_detalhes.opened_windows == 0) then
			_detalhes:Msg (Loc ["STRING_CLOSEALL"])
		end
		
		GameCooltip:Hide()
	end

	local close_button_onenter = function (self)
		OnEnterMainWindow (self.instance, self, 3)

		GameCooltip.buttonOver = true
		self.instance.baseframe.cabecalho.button_mouse_over = true
		
		GameCooltip:Reset()
		GameCooltip:SetOption ("ButtonsYMod", -2)
		GameCooltip:SetOption ("ButtonsYModSub", -2)
		GameCooltip:SetOption ("YSpacingMod", 0)
		GameCooltip:SetOption ("YSpacingModSub", -3)
		GameCooltip:SetOption ("TextHeightMod", 0)
		GameCooltip:SetOption ("TextHeightModSub", 0)
		GameCooltip:SetOption ("IgnoreButtonAutoHeight", false)
		GameCooltip:SetOption ("IgnoreButtonAutoHeightSub", false)
		GameCooltip:SetOption ("SubMenuIsTooltip", true)
		GameCooltip:SetOption ("FixedWidthSub", 180)
		
		local font = SharedMedia:Fetch ("font", "Friz Quadrata TT")
		GameCooltip:AddLine (Loc ["STRING_MENU_CLOSE_INSTANCE"], nil, 1, "white", nil, 10, font)
		GameCooltip:AddIcon ([[Interface\Buttons\UI-Panel-MinimizeButton-Up]], 1, 1, 14, 14, 0.2, 0.8, 0.2, 0.8)
		GameCooltip:AddMenu (1, close_button_onclick, self)
		
		GameCooltip:AddLine (Loc ["STRING_MENU_CLOSE_INSTANCE_DESC"], nil, 2, "white", nil, 10, font)
		GameCooltip:AddIcon ([[Interface\CHATFRAME\UI-ChatIcon-Minimize-Up]], 2, 1, 18, 18)
		
		GameCooltip:AddLine (Loc ["STRING_MENU_CLOSE_INSTANCE_DESC2"], nil, 2, "white", nil, 10, font)
		GameCooltip:AddIcon ([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]], 2, 1, 18, 18)
		
		GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
		GameCooltip:SetWallpaper (2, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
		
		
		show_anti_overlap (self.instance, self, "top")
		
		GameCooltip:ShowCooltip (self, "menu")
	end
	
	local close_button_onleave = function (self)
		OnLeaveMainWindow (self.instance, self, 3)

		hide_anti_overlap (self.instance.baseframe.anti_menu_overlap)
		
		GameCooltip.buttonOver = false
		self.instance.baseframe.cabecalho.button_mouse_over = false
		
		if (GameCooltip.active) then
			parameters_table [2] = 0
			self:SetScript ("OnUpdate", on_leave_menu)
		else
			self:SetScript ("OnUpdate", nil)
		end
		
	end
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> build upper menu bar

function gump:CriaCabecalho (baseframe, instancia)

	baseframe.cabecalho = {}
	
	--> FECHAR INSTANCIA ----------------------------------------------------------------------------------------------------------------------------------------------------
	baseframe.cabecalho.fechar = CreateFrame ("button", "DetailsCloseInstanceButton" .. instancia.meu_id, baseframe) --, "UIPanelCloseButton"
	baseframe.cabecalho.fechar:SetWidth (18)
	baseframe.cabecalho.fechar:SetHeight (18)
	baseframe.cabecalho.fechar:SetFrameLevel (5) --> altura mais alta que os demais frames
	baseframe.cabecalho.fechar:SetPoint ("bottomright", baseframe, "topright", 5, -6) --> seta o ponto dele fixando no base frame
	
	baseframe.cabecalho.fechar:SetNormalTexture ([[Interface\Buttons\UI-Panel-MinimizeButton-Up]])
	baseframe.cabecalho.fechar:SetHighlightTexture ([[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]])
	baseframe.cabecalho.fechar:SetPushedTexture ([[Interface\Buttons\UI-Panel-MinimizeButton-Down]])
	
	baseframe.cabecalho.fechar.instancia = instancia
	baseframe.cabecalho.fechar.instance = instancia
	
	baseframe.cabecalho.fechar:SetScript ("OnEnter", close_button_onenter)
	baseframe.cabecalho.fechar:SetScript ("OnLeave", close_button_onleave)
	
	baseframe.cabecalho.fechar:SetScript ("OnClick", close_button_onclick)

	--> bola do canto esquedo superior --> primeiro criar a armação para apoiar as texturas
	baseframe.cabecalho.ball_point = baseframe.cabecalho.fechar:CreateTexture (nil, "overlay")
	baseframe.cabecalho.ball_point:SetPoint ("bottomleft", baseframe, "topleft", -37, 0)
	baseframe.cabecalho.ball_point:SetWidth (64)
	baseframe.cabecalho.ball_point:SetHeight (32)
	
	--> icone do atributo
	--baseframe.cabecalho.atributo_icon = _detalhes.listener:CreateTexture (nil, "artwork")
	baseframe.cabecalho.atributo_icon = baseframe:CreateTexture (nil, "background")
	local icon_anchor = _detalhes.skins ["Default Skin"].icon_anchor_main
	baseframe.cabecalho.atributo_icon:SetPoint ("topright", baseframe.cabecalho.ball_point, "topright", icon_anchor[1], icon_anchor[2])
	baseframe.cabecalho.atributo_icon:SetTexture (DEFAULT_SKIN)
	baseframe.cabecalho.atributo_icon:SetWidth (32)
	baseframe.cabecalho.atributo_icon:SetHeight (32)
	
	--> bola overlay
	--baseframe.cabecalho.ball = _detalhes.listener:CreateTexture (nil, "overlay")
	baseframe.cabecalho.ball = baseframe:CreateTexture (nil, "overlay")
	baseframe.cabecalho.ball:SetPoint ("bottomleft", baseframe, "topleft", -107, 0)
	baseframe.cabecalho.ball:SetWidth (128)
	baseframe.cabecalho.ball:SetHeight (128)
	
	baseframe.cabecalho.ball:SetTexture (DEFAULT_SKIN)
	baseframe.cabecalho.ball:SetTexCoord (unpack (COORDS_LEFT_BALL))

	--> emenda
	baseframe.cabecalho.emenda = baseframe:CreateTexture (nil, "background")
	baseframe.cabecalho.emenda:SetPoint ("bottomleft", baseframe.cabecalho.ball, "bottomright")
	baseframe.cabecalho.emenda:SetWidth (8)
	baseframe.cabecalho.emenda:SetHeight (128)
	baseframe.cabecalho.emenda:SetTexture (DEFAULT_SKIN)
	baseframe.cabecalho.emenda:SetTexCoord (unpack (COORDS_LEFT_CONNECTOR))

	baseframe.cabecalho.atributo_icon:Hide()
	baseframe.cabecalho.ball:Hide()

	--> bola do canto direito superior
	baseframe.cabecalho.ball_r = baseframe:CreateTexture (nil, "background")
	baseframe.cabecalho.ball_r:SetPoint ("bottomright", baseframe, "topright", 96, 0)
	baseframe.cabecalho.ball_r:SetWidth (128)
	baseframe.cabecalho.ball_r:SetHeight (128)
	baseframe.cabecalho.ball_r:SetTexture (DEFAULT_SKIN)
	baseframe.cabecalho.ball_r:SetTexCoord (unpack (COORDS_RIGHT_BALL))

	--> barra centro
	baseframe.cabecalho.top_bg = baseframe:CreateTexture (nil, "background")
	baseframe.cabecalho.top_bg:SetPoint ("left", baseframe.cabecalho.emenda, "right", 0, 0)
	baseframe.cabecalho.top_bg:SetPoint ("right", baseframe.cabecalho.ball_r, "left")
	baseframe.cabecalho.top_bg:SetTexture (DEFAULT_SKIN)
	baseframe.cabecalho.top_bg:SetTexCoord (unpack (COORDS_TOP_BACKGROUND))
	baseframe.cabecalho.top_bg:SetWidth (512)
	baseframe.cabecalho.top_bg:SetHeight (128)

	--> frame invisível
	baseframe.UPFrame = CreateFrame ("frame", "DetailsUpFrameInstance"..instancia.meu_id, baseframe)
	baseframe.UPFrame:SetPoint ("left", baseframe.cabecalho.ball, "right", 0, -53)
	baseframe.UPFrame:SetPoint ("right", baseframe.cabecalho.ball_r, "left", 0, -53)
	baseframe.UPFrame:SetHeight (20)
	
	baseframe.UPFrame:Show()
	baseframe.UPFrame:EnableMouse (true)
	baseframe.UPFrame:SetMovable (true)
	baseframe.UPFrame:SetResizable (true)
	
	BGFrame_scripts (baseframe.UPFrame, baseframe, instancia)
	
	--> corrige o vão entre o baseframe e o upframe
	baseframe.UPFrameConnect = CreateFrame ("frame", "DetailsAntiGap"..instancia.meu_id, baseframe)
	baseframe.UPFrameConnect:SetPoint ("bottomleft", baseframe, "topleft", 0, -1)
	baseframe.UPFrameConnect:SetPoint ("bottomright", baseframe, "topright", 0, -1)
	baseframe.UPFrameConnect:SetHeight (2)
	baseframe.UPFrameConnect:EnableMouse (true)
	baseframe.UPFrameConnect:SetMovable (true)
	baseframe.UPFrameConnect:SetResizable (true)
	BGFrame_scripts (baseframe.UPFrameConnect, baseframe, instancia)
	
	baseframe.UPFrameLeftPart = CreateFrame ("frame", "DetailsUpFrameLeftPart"..instancia.meu_id, baseframe)
	baseframe.UPFrameLeftPart:SetPoint ("bottomleft", baseframe, "topleft", 0, 0)
	baseframe.UPFrameLeftPart:SetSize (22, 20)
	baseframe.UPFrameLeftPart:EnableMouse (true)
	baseframe.UPFrameLeftPart:SetMovable (true)
	baseframe.UPFrameLeftPart:SetResizable (true)
	BGFrame_scripts (baseframe.UPFrameLeftPart, baseframe, instancia)

	--> anchors para os micro displays no lado de cima da janela
	local StatusBarLeftAnchor = CreateFrame ("frame", "DetailsStatusBarLeftAnchor" .. instancia.meu_id, baseframe)
	StatusBarLeftAnchor:SetPoint ("bottomleft", baseframe, "topleft", 0, 9)
	StatusBarLeftAnchor:SetWidth (1)
	StatusBarLeftAnchor:SetHeight (1)
	baseframe.cabecalho.StatusBarLeftAnchor = StatusBarLeftAnchor
	
	local StatusBarCenterAnchor = CreateFrame ("frame", "DetailsStatusBarCenterAnchor" .. instancia.meu_id, baseframe)
	StatusBarCenterAnchor:SetPoint ("center", baseframe, "center")
	StatusBarCenterAnchor:SetPoint ("bottom", baseframe, "top", 0, 9)
	StatusBarCenterAnchor:SetWidth (1)
	StatusBarCenterAnchor:SetHeight (1)
	baseframe.cabecalho.StatusBarCenterAnchor = StatusBarCenterAnchor	

	local StatusBarRightAnchor = CreateFrame ("frame", "DetailsStatusBarRightAnchor" .. instancia.meu_id, baseframe)
	StatusBarRightAnchor:SetPoint ("bottomright", baseframe, "topright", 0, 9)
	StatusBarRightAnchor:SetWidth (1)
	StatusBarRightAnchor:SetHeight (1)
	baseframe.cabecalho.StatusBarRightAnchor = StatusBarRightAnchor
	
	local MenuAnchorLeft = CreateFrame ("frame", "DetailsMenuAnchorLeft"..instancia.meu_id, baseframe)
	MenuAnchorLeft:SetSize (1, 1)
	
	local MenuAnchorRight = CreateFrame ("frame", "DetailsMenuAnchorRight"..instancia.meu_id, baseframe)
	MenuAnchorRight:SetSize (1, 1)
	
	local Menu2AnchorRight = CreateFrame ("frame", "DetailsMenu2AnchorRight"..instancia.meu_id, baseframe)
	Menu2AnchorRight:SetSize (1, 1)
	
	instancia.menu_points = {MenuAnchorLeft, MenuAnchorRight}
	instancia.menu2_points = {Menu2AnchorRight}
	
-- botões	
------------------------------------------------------------------------------------------------------------------------------------------------- 	

	local CoolTip = _G.GameCooltip

	--> SELEÇÃO DO MODO ----------------------------------------------------------------------------------------------------------------------------------------------------
	
	baseframe.cabecalho.modo_selecao = gump:NewButton (baseframe, nil, "DetailsModeButton"..instancia.meu_id, nil, 16, 16, _detalhes.empty_function, nil, nil, [[Interface\GossipFrame\HealerGossipIcon]])
	baseframe.cabecalho.modo_selecao:SetPoint ("bottomleft", baseframe.cabecalho.ball, "bottomright", instancia.menu_anchor [1], instancia.menu_anchor [2])
	baseframe.cabecalho.modo_selecao:SetFrameLevel (baseframe:GetFrameLevel()+5)
	
	--> Generating Cooltip menu from table template
	local modeMenuTable = {
	
		{text = Loc ["STRING_MODE_GROUP"]},
		{func = instancia.AlteraModo, param1 = 2},
		{icon = [[Interface\AddOns\Details\images\modo_icones]], l = 32/256, r = 32/256*2, t = 0, b = 1, width = 20, height = 20},
		{text = Loc ["STRING_HELP_MODEGROUP"], type = 2},
		{icon = [[Interface\TUTORIALFRAME\TutorialFrame-QuestionMark]], type = 2, width = 16, height = 16, l = 8/64, r = 1 - (8/64), t = 8/64, b = 1 - (8/64)},

		{text = Loc ["STRING_MODE_ALL"]},
		{func = instancia.AlteraModo, param1 = 3},
		{icon = [[Interface\AddOns\Details\images\modo_icones]], l = 32/256*2, r = 32/256*3, t = 0, b = 1, width = 20, height = 20},
		{text = Loc ["STRING_HELP_MODEALL"], type = 2},
		{icon = [[Interface\TUTORIALFRAME\TutorialFrame-QuestionMark]], type = 2, width = 16, height = 16, l = 8/64, r = 1 - (8/64), t = 8/64, b = 1 - (8/64)},		

		{text = Loc ["STRING_MODE_RAID"]}, -- .. " (|cffa0a0a0" .. Loc ["STRING_MODE_PLUGINS"] .. "|r)"
		{func = instancia.AlteraModo, param1 = 4},
		{icon = [[Interface\AddOns\Details\images\modo_icones]], l = 32/256*3, r = 32/256*4, t = 0, b = 1, width = 20, height = 20},
		{text = Loc ["STRING_HELP_MODERAID"], type = 2},
		{icon = [[Interface\TUTORIALFRAME\TutorialFrame-QuestionMark]], type = 2, width = 16, height = 16, l = 8/64, r = 1 - (8/64), t = 8/64, b = 1 - (8/64)},
		
		{text = Loc ["STRING_MODE_SELF"]}, -- .. " (|cffa0a0a0" .. Loc ["STRING_MODE_PLUGINS"] .. "|r)"
		{func = instancia.AlteraModo, param1 = 1},
		{icon = [[Interface\AddOns\Details\images\modo_icones]], l = 0, r = 32/256, t = 0, b = 1, width = 20, height = 20},
		{text = Loc ["STRING_HELP_MODESELF"], type = 2},
		{icon = [[Interface\TUTORIALFRAME\TutorialFrame-QuestionMark]], type = 2, width = 16, height = 16, l = 8/64, r = 1 - (8/64), t = 8/64, b = 1 - (8/64)},

		{text = Loc ["STRING_OPTIONS_WINDOW"]},
		{func = _detalhes.OpenOptionsWindow},
		{icon = [[Interface\AddOns\Details\images\modo_icones]], l = 32/256*4, r = 32/256*5, t = 0, b = 1, width = 20, height = 20},
	}
	
	--> Cooltip raw method for enter/leave show/hide
	baseframe.cabecalho.modo_selecao:SetScript ("OnEnter", function (self)
	
		--gump:Fade (baseframe.button_stretch, "alpha", 0.3)
		OnEnterMainWindow (instancia, self, 3)
		
		if (instancia.desaturated_menu) then
			self:GetNormalTexture():SetDesaturated (false)
		end
		
		_G.GameCooltip.buttonOver = true
		baseframe.cabecalho.button_mouse_over = true
		
		local passou = 0
		if (_G.GameCooltip.active) then
			passou = 0.15
		end

		local checked
		if (instancia.modo == 1) then
			checked = 4
		elseif (instancia.modo == 2) then
			checked = 1
		elseif (instancia.modo == 3) then
			checked = 2
		elseif (instancia.modo == 4) then
			checked = 3
		end

		parameters_table [1] = instancia
		parameters_table [2] = passou
		parameters_table [3] = checked
		parameters_table [4] = modeMenuTable
		
		self:SetScript ("OnUpdate", build_mode_list)
	end)
	
	baseframe.cabecalho.modo_selecao:SetScript ("OnLeave", function (self) 
		OnLeaveMainWindow (instancia, self, 3)
		
		hide_anti_overlap (instancia.baseframe.anti_menu_overlap)
		
		if (instancia.desaturated_menu) then
			self:GetNormalTexture():SetDesaturated (true)
		end
		
		_G.GameCooltip.buttonOver = false
		baseframe.cabecalho.button_mouse_over = false
		
		if (_G.GameCooltip.active) then
			parameters_table [2] = 0
			self:SetScript ("OnUpdate", on_leave_menu)
		else
			self:SetScript ("OnUpdate", nil)
		end
	end)
	
	--> SELECIONAR O SEGMENTO  ----------------------------------------------------------------------------------------------------------------------------------------------------
	baseframe.cabecalho.segmento = gump:NewButton (baseframe, nil, "DetailsSegmentButton"..instancia.meu_id, nil, 16, 16, _detalhes.empty_function, nil, nil, [[Interface\GossipFrame\TrainerGossipIcon]])
	baseframe.cabecalho.segmento:SetFrameLevel (baseframe.UPFrame:GetFrameLevel()+1)

	baseframe.cabecalho.segmento:SetHook ("OnMouseUp", function (button, buttontype)

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
	baseframe.cabecalho.segmento:SetPoint ("left", baseframe.cabecalho.modo_selecao, "right", 0, 0)

	--> Cooltip raw method for show/hide onenter/onhide
	baseframe.cabecalho.segmento:SetScript ("OnEnter", function (self) 
		--gump:Fade (baseframe.button_stretch, "alpha", 0.3)
		OnEnterMainWindow (instancia, self, 3)
		
		if (instancia.desaturated_menu) then
			self:GetNormalTexture():SetDesaturated (false)
		end
		
		_G.GameCooltip.buttonOver = true
		baseframe.cabecalho.button_mouse_over = true
		
		local passou = 0
		if (_G.GameCooltip.active) then
			passou = 0.15
		end

		parameters_table [1] = instancia
		parameters_table [2] = passou
		self:SetScript ("OnUpdate", build_segment_list)
	end)
	
	--> Cooltip raw method
	baseframe.cabecalho.segmento:SetScript ("OnLeave", function (self) 
		--gump:Fade (baseframe.button_stretch, -1)
		OnLeaveMainWindow (instancia, self, 3)

		hide_anti_overlap (instancia.baseframe.anti_menu_overlap)
		
		if (instancia.desaturated_menu) then
			self:GetNormalTexture():SetDesaturated (true)
		end
		
		_G.GameCooltip.buttonOver = false
		baseframe.cabecalho.button_mouse_over = false
		
		if (_G.GameCooltip.active) then
			parameters_table [2] = 0
			self:SetScript ("OnUpdate", on_leave_menu)
		else
			self:SetScript ("OnUpdate", nil)
		end
	end)	

	--> SELECIONAR O ATRIBUTO  ----------------------------------------------------------------------------------------------------------------------------------------------------
	baseframe.cabecalho.atributo = gump:NewButton (baseframe, nil, "DetailsAttributeButton"..instancia.meu_id, nil, 16, 16, instancia.TrocaTabela, instancia, -3, [[Interface\AddOns\Details\images\sword]])
	--baseframe.cabecalho.atributo = gump:NewDetailsButton (baseframe, _, instancia, instancia.TrocaTabela, instancia, -3, 16, 16, [[Interface\AddOns\Details\images\sword]])
	baseframe.cabecalho.atributo:SetFrameLevel (baseframe.UPFrame:GetFrameLevel()+1)
	baseframe.cabecalho.atributo:SetPoint ("left", baseframe.cabecalho.segmento.widget, "right", 0, 0)

	--> Cooltip automatic method through Injection
	
	--> First we declare the function which will build the menu
	local BuildAttributeMenu = function()
		if (_detalhes.solo and _detalhes.solo == instancia.meu_id) then
			return _detalhes:MontaSoloOption (instancia)
		elseif (instancia:IsRaidMode()) then
			local have_plugins = _detalhes:MontaRaidOption (instancia)
			if (not have_plugins) then
				GameCooltip:SetType ("tooltip")
				GameCooltip:SetOption ("ButtonsYMod", 0)
				GameCooltip:SetOption ("YSpacingMod", 0)
				GameCooltip:SetOption ("TextHeightMod", 0)
				GameCooltip:SetOption ("IgnoreButtonAutoHeight", false)
				GameCooltip:AddLine ("All raid plugins already\nin use or disabled.", nil, 1, "white", nil, 10, SharedMedia:Fetch ("font", "Friz Quadrata TT"))
				GameCooltip:AddIcon ([[Interface\GROUPFRAME\UI-GROUP-ASSISTANTICON]], 1, 1)
				GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
			end
		else
			return _detalhes:MontaAtributosOption (instancia)
		end
	end
	
	--> Now we create a table with some parameters
	--> your frame need to have a member called CoolTip
	baseframe.cabecalho.atributo.CoolTip = {
		Type = "menu", --> the type, menu tooltip tooltipbars
		BuildFunc = BuildAttributeMenu, --> called when user mouse over the frame
		OnEnterFunc = function (self) 
			baseframe.cabecalho.button_mouse_over = true; 
			OnEnterMainWindow (instancia, baseframe.cabecalho.atributo, 3) 
			show_anti_overlap (instancia, self, "top")
			if (instancia.desaturated_menu) then
				self:GetNormalTexture():SetDesaturated (false)
			end
		end,
		OnLeaveFunc = function (self) 
			baseframe.cabecalho.button_mouse_over = false; 
			OnLeaveMainWindow (instancia, baseframe.cabecalho.atributo, 3) 
			hide_anti_overlap (instancia.baseframe.anti_menu_overlap)
			if (instancia.desaturated_menu) then
				self:GetNormalTexture():SetDesaturated (true)
			end
		end,
		FixedValue = instancia,
		ShowSpeed = 0.15,
		Options = function()
			if (instancia.consolidate) then
				return {Anchor = instancia.consolidateFrame, MyAnchor = "topleft", RelativeAnchor = "topright", TextSize = _detalhes.font_sizes.menus}
			else
				if (instancia.toolbar_side == 1) then --top
					return {TextSize = _detalhes.font_sizes.menus}
				elseif (instancia.toolbar_side == 2) then --bottom
					return {TextSize = _detalhes.font_sizes.menus, HeightAnchorMod = 0} -- -7
				end
			end
		end}
	
	--> install cooltip
	_G.GameCooltip:CoolTipInject (baseframe.cabecalho.atributo)

	--> REPORTAR ~report ----------------------------------------------------------------------------------------------------------------------------------------------------
			baseframe.cabecalho.report = gump:NewButton (baseframe, nil, "DetailsReportButton"..instancia.meu_id, nil, 8, 16, _detalhes.Reportar, instancia, nil, [[Interface\Addons\Details\Images\report_button]])
			--baseframe.cabecalho.report = gump:NewDetailsButton (baseframe, _, instancia, _detalhes.Reportar, instancia, nil, 16, 16, [[Interface\COMMON\VOICECHAT-ON]])
			baseframe.cabecalho.report:SetPoint ("left", baseframe.cabecalho.atributo, "right", -6, 0)
			baseframe.cabecalho.report:SetFrameLevel (baseframe.UPFrame:GetFrameLevel()+1)
			baseframe.cabecalho.report:SetScript ("OnEnter", function (self)
				OnEnterMainWindow (instancia, self, 3)
				if (instancia.desaturated_menu) then
					self:GetNormalTexture():SetDesaturated (false)
				end
				
				GameCooltip.buttonOver = true
				baseframe.cabecalho.button_mouse_over = true
				
				GameCooltip:Reset()
				GameCooltip:SetOption ("ButtonsYMod", -3)
				GameCooltip:SetOption ("YSpacingMod", 0)
				GameCooltip:SetOption ("TextHeightMod", 0)
				GameCooltip:SetOption ("IgnoreButtonAutoHeight", false)
				
				GameCooltip:AddLine ("Report Results", nil, 1, "white", nil, 10, SharedMedia:Fetch ("font", "Friz Quadrata TT"))
				GameCooltip:AddIcon ([[Interface\Addons\Details\Images\report_button]], 1, 1, 12, 19)
				GameCooltip:AddMenu (1, _detalhes.Reportar, instancia)
				
				GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
				
				show_anti_overlap (instancia, self, "top")
				
				GameCooltip:ShowCooltip (self, "menu")
				
			end)
			baseframe.cabecalho.report:SetScript ("OnLeave", function (self)
			
				OnLeaveMainWindow (instancia, self, 3)
				
				hide_anti_overlap (instancia.baseframe.anti_menu_overlap)
				
				GameCooltip.buttonOver = false
				baseframe.cabecalho.button_mouse_over = false
				
				if (instancia.desaturated_menu) then
					self:GetNormalTexture():SetDesaturated (true)
				end
				
				if (GameCooltip.active) then
					parameters_table [2] = 0
					self:SetScript ("OnUpdate", on_leave_menu)
				else
					self:SetScript ("OnUpdate", nil)
				end

			end)

	--> NOVA INSTANCIA ----------------------------------------------------------------------------------------------------------------------------------------------------
	baseframe.cabecalho.novo = CreateFrame ("button", "DetailsInstanceButton"..instancia.meu_id, baseframe) --, "OptionsButtonTemplate"
	baseframe.cabecalho.novo:SetFrameLevel (baseframe.UPFrame:GetFrameLevel()+1)
	
	baseframe.cabecalho.novo:SetNormalTexture (1, 1, 1, 1)
	baseframe.cabecalho.novo:SetHighlightTexture ([[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]])
	baseframe.cabecalho.novo:SetPushedTexture (1, 1, 1, 1)
	
	baseframe.cabecalho.novo:SetWidth (20)
	baseframe.cabecalho.novo:SetHeight (16)

	baseframe.cabecalho.novo:SetPoint ("bottomright", baseframe, "topright", instancia.instance_button_anchor [1], instancia.instance_button_anchor [2])
	
	baseframe.cabecalho.novo:SetScript ("OnClick", function() _detalhes:CriarInstancia (_, true); _G.GameCooltip:ShowMe (false) end)
	baseframe.cabecalho.novo:SetText ("#"..instancia.meu_id)
	baseframe.cabecalho.novo:SetNormalFontObject ("GameFontHighlightSmall")

	--> cooltip through inject
	--> OnClick Function [1] caller [2] fixed param [3] param1 [4] param2
	local OnClickNovoMenu = function (_, _, id)
		_detalhes.CriarInstancia (_, _, id)
		_G.GameCooltip:ExecFunc (baseframe.cabecalho.novo)
	end
	
	--> Build Menu Function
	local BuildClosedInstanceMenu = function() 
	
		local ClosedInstances = 0
		
		for index = 1, math.min (#_detalhes.tabela_instancias, _detalhes.instances_amount), 1 do 
		
			local _this_instance = _detalhes.tabela_instancias [index]
			
			if (not _this_instance.ativa) then --> só reabre se ela estiver ativa
			
				--> pegar o que ela ta mostrando
				local atributo = _this_instance.atributo
				local sub_atributo = _this_instance.sub_atributo
				ClosedInstances = ClosedInstances + 1
				
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
						if (SoloInfo) then
							CoolTip:AddMenu (1, OnClickNovoMenu, index, nil, nil, "#".. index .. " " .. SoloInfo [1], _, true)
							CoolTip:AddIcon (SoloInfo [2], 1, 1, 20, 20, 0, 1, 0, 1)
						else
							CoolTip:AddMenu (1, OnClickNovoMenu, index, nil, nil, "#".. index .. " Unknown Plugin", _, true)
						end
						
					elseif (modo == 4) then --raid
					
						local plugin_name = _this_instance.current_raid_plugin or _this_instance.last_raid_plugin
						if (plugin_name) then
							local plugin_object = _detalhes:GetPlugin (plugin_name)
							if (plugin_object) then
								CoolTip:AddMenu (1, OnClickNovoMenu, index, nil, nil, "#".. index .. " " .. plugin_object.__name, _, true)
								CoolTip:AddIcon (plugin_object.__icon, 1, 1, 20, 20, 0, 1, 0, 1)	
							else
								CoolTip:AddMenu (1, OnClickNovoMenu, index, nil, nil, "#".. index .. " Unknown Plugin", _, true)
							end
						else
							CoolTip:AddMenu (1, OnClickNovoMenu, index, nil, nil, "#".. index .. " Unknown Plugin", _, true)
						end
						
					else
					
						CoolTip:AddMenu (1, OnClickNovoMenu, index, nil, nil, "#".. index .. " " .. _detalhes.atributos.lista [atributo] .. " - " .. _detalhes.sub_atributos [atributo].lista [sub_atributo], _, true)
						CoolTip:AddIcon (_detalhes.sub_atributos [atributo].icones[sub_atributo] [1], 1, 1, 20, 20, unpack (_detalhes.sub_atributos [atributo].icones[sub_atributo] [2]))
						
					end
				end


			end
		end
		
		if (ClosedInstances == 0) then
			CoolTip:AddMenu (1, _detalhes.CriarInstancia, true, nil, nil, Loc ["STRING_NOCLOSED_INSTANCES"], _, true)
			CoolTip:AddIcon ([[Interface\Buttons\UI-AttributeButton-Encourage-Up]], 1, 1, 16, 16)
		end
		
		GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
		
		return ClosedInstances
	end
	
	--> Inject Options Table
	baseframe.cabecalho.novo.CoolTip = { 
		--> cooltip type "menu" "tooltip" "tooltipbars"
		Type = "menu",
		--> how much time wait with mouse over the frame until cooltip show up
		ShowSpeed = 0.15,
		--> will call for build menu
		BuildFunc = BuildClosedInstanceMenu, 
		--> a hook for OnEnterScript
		OnEnterFunc = function() OnEnterMainWindow (instancia, baseframe.cabecalho.novo, 3) end,
		--> a hook for OnLeaveScript
		OnLeaveFunc = function() OnLeaveMainWindow (instancia, baseframe.cabecalho.novo, 3) end,
		--> default message if there is no option avaliable
		Default = Loc ["STRING_NOCLOSED_INSTANCES"],
		--> instancia is the first parameter sent after click, before parameters
		FixedValue = instancia,
		Options = function()
			if (instancia.toolbar_side == 1) then --top
				return {TextSize = 10, NoLastSelectedBar = true, ButtonsYMod = -2}
			elseif (instancia.toolbar_side == 2) then --bottom
				return {HeightAnchorMod = -7, TextSize = 10, NoLastSelectedBar = true}
			end
		end
	}
	
	--> Inject
	_G.GameCooltip:CoolTipInject (baseframe.cabecalho.novo)
	
	-- ~delete ~erase
	--> RESETAR HISTORICO ----------------------------------------------------------------------------------------------------------------------------------------------------

	baseframe.cabecalho.reset = CreateFrame ("button", "DetailsClearSegmentsButton" .. instancia.meu_id, baseframe)
	baseframe.cabecalho.reset:SetFrameLevel (baseframe.UPFrame:GetFrameLevel()+1)
	baseframe.cabecalho.reset:SetSize (10, 16)
	baseframe.cabecalho.reset:SetPoint ("right", baseframe.cabecalho.novo, "left")
	baseframe.cabecalho.reset.instance = instancia
	baseframe.cabecalho.reset:SetScript ("OnClick", function() _detalhes.tabela_historico:resetar() end)
	baseframe.cabecalho.reset:SetScript ("OnEnter", reset_button_onenter)
	baseframe.cabecalho.reset:SetScript ("OnLeave", reset_button_onleave)
	
	baseframe.cabecalho.reset:SetNormalTexture ([[Interface\Addons\Details\Images\reset_button]])
	baseframe.cabecalho.reset:SetHighlightTexture ([[Interface\Addons\Details\Images\reset_button]])
	baseframe.cabecalho.reset:SetPushedTexture ([[Interface\Addons\Details\Images\reset_button]])
	
--> fim botão reset

--> Botão de Ajuda ----------------------------------------------------------------------------------------------------------------------------------------------------

	--> disabled
	if (instancia.meu_id == 1 and _detalhes.tutorial.logons < 0) then
	
		--> help button
		local helpButton = CreateFrame ("button", "DetailsMainWindowHelpButton", baseframe, "MainHelpPlateButton")
		helpButton:SetWidth (28)
		helpButton:SetHeight (28)
		helpButton.I:SetWidth (22)
		helpButton.I:SetHeight (22)
		helpButton.Ring:SetWidth (28)
		helpButton.Ring:SetHeight (28)
		helpButton.Ring:SetPoint ("center", 5, -6)
		
		helpButton:SetPoint ("topright", baseframe, "topleft", 37, 37)
		
		helpButton:SetFrameLevel (0)
		helpButton:SetFrameStrata ("LOW")

		local mainWindowHelp =  {
			FramePos = {x = 0, y = 10},
			FrameSize = {width = 300, height = 85},
			
			--> modo, segmento e atributo
			[1] ={HighLightBox = {x = 25, y = 10, width = 60, height = 20},
				ButtonPos = { x = 32, y = 40},
				ToolTipDir = "right",
				ToolTipText = Loc ["STRING_HELP_MENUS"]
			},
			--> delete
			[2] ={HighLightBox = {x = 195, y = 10, width = 47, height = 20},
				ButtonPos = { x = 197, y = 5},
				ToolTipDir = "left",
				ToolTipText = Loc ["STRING_HELP_ERASE"]
			},
			--> menu da instancia
			[3] ={HighLightBox = {x = 244, y = 10, width = 30, height = 20},
				ButtonPos = { x = 237, y = 5},
				ToolTipDir = "right",
				ToolTipText = Loc ["STRING_HELP_INSTANCE"]
			},
			--> stretch
			[4] ={HighLightBox = {x = 244, y = 30, width = 30, height = 20},
				ButtonPos = { x = 237, y = 57},
				ToolTipDir = "right",
				ToolTipText = Loc ["STRING_HELP_STRETCH"]
			},
			--> status bar
			[5] ={HighLightBox = {x = 0, y = -101, width = 300, height = 20},
				ButtonPos = { x = 126, y = -88},
				ToolTipDir = "left",
				ToolTipText = Loc ["STRING_HELP_STATUSBAR"]
			},
			--> switch menu
			[6] ={HighLightBox = {x = 0, y = -10, width = 300, height = 95},
				ButtonPos = { x = 127, y = -37},
				ToolTipDir = "left",
				ToolTipText = Loc ["STRING_HELP_SWITCH"]
			},
			--> resizer
			[7] ={HighLightBox = {x = 250, y = -81, width = 50, height = 20},
				ButtonPos = { x = 253, y = -52},
				ToolTipDir = "right",
				ToolTipText = Loc ["STRING_HELP_RESIZE"]
			},
		}
		
		helpButton:SetScript ("OnClick", function() 
			if (not HelpPlate_IsShowing (mainWindowHelp)) then
			
				instancia:SetSize (300, 95)
			
				HelpPlate_Show (mainWindowHelp, baseframe, helpButton, true)
			else
				HelpPlate_Hide (true)
			end
		end)
	
	end

---------> consolidate frame ----------------------------------------------------------------------------------------------------------------------------------------------------

	local consolidateFrame = CreateFrame ("frame", "DetailsConsolidateFrame" .. instancia.meu_id, _detalhes.listener)
	consolidateFrame:SetWidth (21)
	consolidateFrame:SetHeight (83)
	consolidateFrame:SetFrameLevel (baseframe:GetFrameLevel()-1)
	--consolidateFrame:SetPoint ("bottomleft", baseframe.cabecalho.ball, "bottomright", 0, 20)
	consolidateFrame:SetFrameStrata ("FULLSCREEN")
	consolidateFrame:Hide()
	instancia.consolidateFrame = consolidateFrame
	
---------> consolidate texture

	local frameTexture = consolidateFrame:CreateTexture (nil, "background")
	frameTexture:SetTexture ([[Interface\AddOns\Details\images\consolidate_frame]])
	frameTexture:SetPoint ("top", consolidateFrame, "top", .5, 0)
	frameTexture:SetWidth (32)
	frameTexture:SetHeight (83)
	frameTexture:SetTexCoord (0, 1, 0, 0.6484375)
	
---------> consolidate button

	local consolidateButton = CreateFrame ("button", "DetailsConsolidateButton" .. instancia.meu_id, baseframe)
	consolidateButton:SetWidth (16)
	consolidateButton:SetHeight (16)
	consolidateButton:SetFrameLevel (baseframe.UPFrame:GetFrameLevel()+1)
	consolidateButton:SetPoint ("bottomleft", baseframe.cabecalho.ball, "bottomright", 6, 2)
	consolidateFrame:SetPoint ("bottom", consolidateButton, "top", 3, 0)

	local normal_texture = consolidateButton:CreateTexture (nil, "overlay")
	normal_texture:SetTexture ([[Interface\GossipFrame\HealerGossipIcon]])
	normal_texture:SetVertexColor (.9, .8, 0)
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
				if (not _G.GameCooltip.active and not baseframe.cabecalho.button_mouse_over) then
					consolidateFrame:Hide()
					normal_texture:SetBlendMode ("BLEND")
					self:SetScript ("OnUpdate", nil)
				end
				passou = 0
			end
		end)
	end) 
	
	consolidateButton:SetScript ("OnEnter", function (self)
		gump:Fade (baseframe.button_stretch, "alpha", 0.3)
		local passou = 0
		consolidateFrame:SetScript ("OnUpdate", nil)
		normal_texture:SetBlendMode ("ADD")
		self:SetScript ("OnUpdate", function (self, elapsed)
			passou = passou+elapsed
			if (passou > 0.3) then
				consolidateFrame:SetPoint ("bottom", self, "top", 3, 0)
				consolidateFrame:Show()
				self:SetScript ("OnUpdate", nil)
			end
		end)
	end)
	
	consolidateButton:SetScript ("OnLeave", function (self) 
		gump:Fade (baseframe.button_stretch, -1)
		local passou = 0
		self:SetScript ("OnUpdate", function (self, elapsed)
			passou = passou+elapsed
			if (passou > 0.3) then
				if (not consolidateFrame.mouse_over and not baseframe.cabecalho.button_mouse_over and not _G.GameCooltip.active) then
					consolidateFrame:Hide()
					normal_texture:SetBlendMode ("BLEND")
				end
				self:SetScript ("OnUpdate", nil)
			end
		end)
	end)
	
	
	
end
