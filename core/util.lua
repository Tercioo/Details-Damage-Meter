--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = _G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local _
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _table_insert = table.insert --lua local
	local _upper = string.upper --lua local
	local _ipairs = ipairs --lua local
	local _pairs = pairs --lua local
	local _string_format = string.format --lua local
	local _math_floor = math.floor --lua local
	local _math_max = math.max --lua local
	local _type = type --lua local
	local _string_match = string.match --lua local
	
	local _UnitClass = UnitClass --wow api local
	local _IsInRaid = IsInRaid --wow api local
	local _IsInGroup = IsInGroup --wow api local
	local _GetNumGroupMembers = GetNumGroupMembers --wow api local
	local _UnitAffectingCombat = UnitAffectingCombat --wow api local
	local _GameTooltip = GameTooltip --wow api local
	local _UIFrameFadeIn = UIFrameFadeIn --wow api local
	local _UIFrameFadeOut = UIFrameFadeOut --wow api local
	local _InCombatLockdown = InCombatLockdown --wow api local

	local gump = _detalhes.gump --details local

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details api functions

	--> set all table keys to lower
	local temptable = {}
	function _detalhes:LowerizeKeys (_table)
		for key, value in _pairs (_table) do
			temptable [string.lower (key)] = value
		end
		temptable, _table = table.wipe (_table), temptable
		return _table
	end

	--> short numbers
	function _detalhes:ToK (numero)
		if (numero > 1000000) then
			return _string_format ("%.2f", numero/1000000) .."M"
		elseif (numero > 1000) then
			return _string_format ("%.1f", numero/1000) .."K"
		end
		return _string_format ("%.1f", numero)
	end
	--> short numbers no numbers after comma
	function _detalhes:ToK0 (numero)
		if (numero > 1000000) then
			return _string_format ("%.0f", numero/1000000) .."M"
		elseif (numero > 1000) then
			return _string_format ("%.0f", numero/1000) .."K"
		end
		return _string_format ("%.0f", numero)
	end

	--> remove a index from a hash table
	function _detalhes:tableRemove (tabela, indexName)
		local newtable = {}
		for hash, value in _pairs (tabela) do 
			if (hash ~= indexName) then
				newtable [hash] = value
			end
		end
		return newtable
	end

	--> return if the numeric table have an object
	function _detalhes:tableIN (tabela, objeto)
		for index, valor in _ipairs (tabela) do
			if (valor == objeto) then
				return index
			end
		end
		return false
	end

	--> unpack more than 1 table
	-- thanks http://www.dzone.com/snippets/lua-unpack-multiple-tables
	function _detalhes:unpacks (...)
		local values = {}
		for i = 1, select ('#', ...) do
			for _, value in _ipairs (select (i, ...)) do
				values[ #values + 1] = value
			end
		end
		return unpack (values)
	end

	--> put points in numbers
	-- thanks http://richard.warburton.it
	function _detalhes:comma_value(n) 
		local left,num,right = _string_match (n,'^([^%d]*%d)(%d*)(.-)$')
		return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
	end

	--> trim thanks from http://lua-users.org/wiki/StringTrim
	function _detalhes:trim (s)
		local from = s:match"^%s*()"
		return from > #s and "" or s:match(".*%S", from)
	end

	--> scale
	function _detalhes:Scale (rangeMin, rangeMax, scaleMin, scaleMax, x)
		return 1 + (x - rangeMin) * (scaleMax - scaleMin) / (rangeMax - rangeMin)
	end

	--> font size
	function _detalhes:SetFontSize (fontString, ...)
		local fonte, _, flags = fontString:GetFont()
		fontString:SetFont (fonte, _math_max (...), flags)
	end
	function _detalhes:GetFontSize (fontString)
		local _, size = fontString:GetFont()
		return size
	end

	--> font face
	function _detalhes:SetFontFace (fontString, fontface)
		local _, size, flags = fontString:GetFont()
		fontString:SetFont (fontface, size, flags)
	end
	function _detalhes:GetFontFace (fontString)
		local fontface = fontString:GetFont()
		return fontface
	end	
	
	--> font outline
	function _detalhes:SetFontOutline (fontString, outline)
		local fonte, size = fontString:GetFont()
		if (outline) then
			if (_type (outline) == "boolean" and outline) then
				outline = "OUTLINE"
			elseif (outline == 1) then
				outline = "OUTLINE"
			elseif (outline == 2) then
				outline = "THICKOUTLINE"
			end
		end
		fontString:SetFont (fonte, size, outline)
	end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internal functions

	local LastDamage = 0
	local LastDamageRecord = 0

	--> record raid/party/player damage every second
	function _detalhes:LogDps()

		LastDamageRecord = LastDamageRecord + 1

		if (LastDamageRecord > 1) then
			LastDamageRecord = 0
			
			local NowDamage = (_detalhes.tabela_vigente.totals_grupo[1] - LastDamage) /2
			
			_table_insert (_detalhes.tabela_vigente.DpsGraphic, NowDamage)
			if (NowDamage > _detalhes.tabela_vigente.DpsGraphic.max) then 
				_detalhes.tabela_vigente.DpsGraphic.max = NowDamage
			end
			
			LastDamage = _detalhes.tabela_vigente.totals_grupo[1]
		end
	end

	--> is in combat yet?
	function _detalhes:EstaEmCombate()

		_detalhes.tabela_vigente.TimeData:Record()

		if (_detalhes.zone_type == "pvp" or _InCombatLockdown()) then
			return true
		elseif (_UnitAffectingCombat("player")) then
			return true
		elseif (_IsInRaid()) then
			for i = 1, _GetNumGroupMembers(), 1 do
				if (_UnitAffectingCombat ("raid"..i)) then
					return true
				end
			end
		elseif (_IsInGroup()) then
			for i = 1, _GetNumGroupMembers()-1, 1 do
				if (_UnitAffectingCombat ("party"..i)) then
					return true
				end
			end
		end

		LastDps = 0
		_detalhes:SairDoCombate()
	end
	
	function _detalhes:FindGUIDFromName (name)
		if (_IsInRaid()) then
			for i = 1, _GetNumGroupMembers(), 1 do
				local this_name, _ = UnitName ("raid"..i)
				if (this_name == name) then
					return UnitGUID ("raid"..i)
				end
			end
		elseif (_IsInGroup()) then
			for i = 1, _GetNumGroupMembers()-1, 1 do
				local this_name, _ = UnitName ("party"..i)
				if (this_name == name) then
					return UnitGUID ("party"..i)
				end
			end
		end
		if (UnitName ("player") == name) then
			return UnitGUID ("player")
		end
		return nil
	end

	--> Armazena uma label recém criada - Store a new label on the pool
	function _detalhes.font_pool:add (_fontstring)
		self [#self+1] = _fontstring
	end

	local function frame_task (self, elapsed)

		self.FrameTime = self.FrameTime + elapsed

		if (self.HaveGradientEffect) then
			
			local done = false
			
			for index, ThisGradient in _ipairs (self.gradientes) do
			
				if (self.FrameTime >= ThisGradient.NextStepAt and not ThisGradient.done) then
				
					--> effects
					if (ThisGradient.ObjectType == "frame") then
						local r, g, b, a = ThisGradient.Object:GetBackdropColor()
						ThisGradient.Object:SetBackdropColor (r + ThisGradient.Colors.Red, g + ThisGradient.Colors.Green, b + ThisGradient.Colors.Blue, a + ThisGradient.Colors.Alpha)
					elseif (ThisGradient.ObjectType == "texture") then
						local r, g, b, a = ThisGradient.Object:GetVertexColor()
						ThisGradient.Object:SetVertexColor (r + ThisGradient.Colors.Red, g + ThisGradient.Colors.Green, b + ThisGradient.Colors.Blue, a + ThisGradient.Colors.Alpha)
					end
					
					ThisGradient.OnStep = ThisGradient.OnStep + 1
					if (ThisGradient.FinishStep == ThisGradient.OnStep) then
						if (ThisGradient.Func) then
							if (type (ThisGradient.Func) == "string") then
								local f = loadstring (ThisGradient.Func)
								f()
							else
								ThisGradient.Func()
							end
						end
						ThisGradient.done = true
						done = true
					else
						ThisGradient.NextStepAt = self.FrameTime + ThisGradient.SleepTime
					end
				end
			end
			
			if (done) then
				local _iter = {index = 1, data = self.gradientes [1]}
				while (_iter.data) do 
					if (_iter.data.done) then
						_iter.data.Object.HaveGradientEffect = false
						table.remove (self.gradientes, _iter.index)
						_iter.data = self.gradientes [_iter.index]
					else
						_iter.index = _iter.index + 1
						_iter.data = self.gradientes [_iter.index]
					end
				end
				
				if (#self.gradientes < 1) then
					self.HaveGradientEffect = false
				end
			end
		end
		
		if (not self.HaveGradientEffect) then
			self:SetScript ("OnUpdate", nil)
		end
		
	end

	--[[ test grayscale ]]
	function _detalhes:teste_grayscale()
		local instancia = _detalhes.tabela_instancias[1]
		for i = 1, instancia.barrasInfo.criadas, 1 do
			local barra = instancia.barras[i]
			local red, green, blue, alpha = barra.textura:GetVertexColor()
			local grayscale = (red*0.03+green+blue) / 3 --> grayscale lightness method
			gump:GradientEffect ( barra.textura, "texture", red, green, blue, alpha, grayscale, grayscale, grayscale, alpha, 1)
		end
	end

	function gump:GradientEffect ( Object, ObjectType, StartRed, StartGreen, StartBlue, StartAlpha, EndRed, EndGreen, EndBlue, EndAlpha, Duration, EndFunction, FuncParam)
		
		if (type (StartRed) == "table" and type (StartGreen) == "table") then
			Duration, EndFunction = StartBlue, StartAlpha
			EndRed, EndGreen, EndBlue, EndAlpha = unpack (StartGreen)
			StartRed, StartGreen, StartBlue, StartAlpha = unpack (StartRed)
			
		elseif (type (StartRed) == "table") then
			EndRed, EndGreen, EndBlue, EndAlpha, Duration, EndFunction = StartGreen, StartBlue, StartAlpha, EndRed, EndGreen, EndBlue
			StartRed, StartGreen, StartBlue, StartAlpha = unpack (StartRed)
			
		elseif (type (EndRed) == "table") then
			Duration, EndFunction = EndGreen, EndBlue
			EndRed, EndGreen, EndBlue, EndAlpha = unpack (EndRed)
		end
		
		if (not EndAlpha) then
			EndAlpha = 1.0
		end
		if (not StartAlpha) then
			StartAlpha = 1.0
		end
		
		if (EndRed > 1.0) then
			EndRed = 1.0
		end
		if (EndGreen > 1.0) then
			EndGreen = 1.0
		end
		if (EndBlue > 1.0) then
			EndBlue = 1.0
		end	
		
		local GradientFrameControl = _detalhes.listener
		GradientFrameControl.gradientes = GradientFrameControl.gradientes or {}
		
		for index = 1, #GradientFrameControl.gradientes do
			if (GradientFrameControl.gradientes[index].Object == Object) then
				GradientFrameControl.gradientes[index].done = true
			end
		end

		local MinFramesPerSecond = 10 --> at least 10 frames will be necessary
		local ExecTime = Duration * 1000 --> value in miliseconds
		local SleepTime = 100 --> 100 miliseconds
		
		local FrameAmount = _math_floor (ExecTime/100) --> amount of frames
		
		if (FrameAmount < MinFramesPerSecond) then
			FrameAmount = MinFramesPerSecond
			SleepTime = ExecTime/FrameAmount
		end
		
		local ColorStep = {}
		ColorStep.Red = (EndRed - StartRed) / FrameAmount
		ColorStep.Green = (EndGreen - StartGreen) / FrameAmount
		ColorStep.Blue = (EndBlue - StartBlue) / FrameAmount
		ColorStep.Alpha = (EndAlpha - StartAlpha) / FrameAmount

		GradientFrameControl.gradientes [#GradientFrameControl.gradientes+1] = {
			OnStep = 1,
			FinishStep = FrameAmount,
			SleepTime = SleepTime/1000,
			NextStepAt = GradientFrameControl.FrameTime + (SleepTime/1000),
			Object = Object,
			ObjectType = string.lower (ObjectType),
			Colors = ColorStep,
			Func = EndFunction,
			FuncParam = FuncParam}
		
		Object.HaveGradientEffect = true
		GradientFrameControl.HaveGradientEffect = true
		
		if (not GradientFrameControl:GetScript ("OnUpdate")) then
			GradientFrameControl:SetScript ("OnUpdate", frame_task)
		end

	end
	
	
	--> work around to solve the UI Frame Flashes
	
	local onFinish = function (self)
		if (self.showWhenDone) then
			self.frame:SetAlpha (1)
		else
			self.frame:SetAlpha (0)
			self.frame:Hide()
		end
	end
	
	local onLoop = function (self)
		if (self.finishAt < GetTime()) then
			self:Stop()
		end
	end

	local flash = function (self, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime)
		
		local FlashAnimation = self.FlashAnimation
		local fadeIn = FlashAnimation.fadeIn
		local fadeOut = FlashAnimation.fadeOut
	
		fadeIn:SetDuration (fadeInTime)
		fadeIn:SetEndDelay (flashInHoldTime or 0)
		
		fadeOut:SetDuration (fadeOutTime)
		fadeOut:SetEndDelay (flashOutHoldTime or 0)
		
		fadeIn:SetOrder (1)
		fadeOut:SetOrder (2)		
		
		fadeIn:SetChange (-1)
		fadeOut:SetChange (1)
		
		FlashAnimation.duration = flashDuration
		FlashAnimation.loopTime = FlashAnimation:GetDuration()
		FlashAnimation.finishAt = GetTime() + flashDuration
		FlashAnimation.showWhenDone = showWhenDone
		
		FlashAnimation:SetLooping ("REPEAT")
		
		FlashAnimation:Play()
	end
	
	function gump:CreateFlashAnimation (frame)
	
		local FlashAnimation = frame:CreateAnimationGroup() 
		
		FlashAnimation.fadeIn = FlashAnimation:CreateAnimation ("Alpha") --> fade in anime
		FlashAnimation.fadeOut = FlashAnimation:CreateAnimation ("Alpha") --> fade out anime
		
		frame.FlashAnimation = FlashAnimation
		FlashAnimation.frame = frame
		
		FlashAnimation:SetScript ("OnLoop", onLoop)
		FlashAnimation:SetScript ("OnFinished", onFinish)
		
		frame.Flash = flash
	
	end

	--> todo: remove the function creation everytime this function run.
	function gump:Fade (frame, tipo, velocidade, parametros)
		
		if (_type (frame) == "table") then 
			if (frame.meu_id) then --> ups, é uma instância
				if (parametros == "barras") then --> hida todas as barras da instância
					if (velocidade) then
						for i = 1, frame.barrasInfo.criadas, 1 do
							gump:Fade (frame.barras[i], tipo, velocidade)
						end
						return
					else
						velocidade = velocidade or 0.3
						for i = 1, frame.barrasInfo.criadas, 1 do
							gump:Fade (frame.barras[i], tipo, 0.3+(i/10))
						end
						return
					end
				elseif (parametros == "hide_barras") then --> hida todas as barras da instância
					for i = 1, frame.barrasInfo.criadas, 1 do
						local esta_barra = frame.barras[i]
						if (esta_barra.fading_in or esta_barra.fading_out) then
							esta_barra.fadeInfo.finishedFunc = nil
							_UIFrameFadeIn (esta_barra, 0.01, esta_barra:GetAlpha(), esta_barra:GetAlpha())
						end
						esta_barra.hidden = true
						esta_barra.faded = true
						esta_barra.fading_in = false
						esta_barra.fading_out = false
						esta_barra:Hide()
						esta_barra:SetAlpha(0)
					end
					return
				end
			elseif (frame.dframework) then
				frame = frame.widget
			end
		end
		
		velocidade = velocidade or 0.3
		
		--> esse ALL aqui pode dar merda com as instâncias não ativadas
		if (frame == "all") then --> todas as instâncias
			for _, instancia in _ipairs (_detalhes.tabela_instancias) do
				if (parametros == "barras") then --> hida todas as barras da instância
					for i = 1, instancia.barrasInfo.criadas, 1 do
						gump:Fade (instancia.barras[i], tipo, velocidade+(i/10))
					end
				end
			end
		
		elseif (_upper (tipo) == "IN") then

			if (frame:GetAlpha() == 0 and frame.hidden and not frame.fading_out) then --> ja esta escondida
				return
			elseif (frame.fading_in) then --> ja esta com uma animação, se for true
				return
			end
			
			if (frame.fading_out) then --> se tiver uma animação de aparecer em andamento se for true
				frame.fading_out = false
			end

			_UIFrameFadeIn (frame, velocidade, frame:GetAlpha(), 0)
			frame.fading_in = true
			frame.fadeInfo.finishedFunc = 
			function()
				frame.hidden = true
				frame.faded = true
				frame.fading_in = false
				frame:Hide()
			end
			
		elseif (_upper (tipo) == "OUT") then --> aparecer
			if (frame:GetAlpha() == 1 and not frame.hidden and not frame.fading_in) then --> ja esta na tela
				return
			elseif (frame.fading_out) then --> já ta com fading out
				return
			end
			
			if (frame.fading_in) then --> se tiver uma animação de hidar em andamento se for true
				frame.fading_in = false
			end
			
			frame:Show()
			_UIFrameFadeOut (frame, velocidade, frame:GetAlpha(), 1.0)
			frame.fading_out = true
			frame.fadeInfo.finishedFunc = 
				function() 
					frame.hidden = false
					frame.faded = false
					frame.fading_out = false
				end
				
		elseif (tipo == 0) then --> força o frame a ser mostrado
			frame.hidden = false
			frame.faded = false
			frame.fading_out = false
			frame.fading_in = false
			frame:Show()
			frame:SetAlpha(1)
			if (frame.fadeInfo) then --> limpa a função de fade se tiver alguma
				frame.fadeInfo.finishedFunc = nil
			end
			
		elseif (tipo == 1) then --> força o frame a ser hidado

			frame.hidden = true
			frame.faded = true
			frame.fading_out = false
			frame.fading_in = false
			frame:Hide()
			frame:SetAlpha(0)
			if (frame.fadeInfo) then --> limpa a função de fade se tiver alguma
				frame.fadeInfo.finishedFunc = nil
			end
			
		elseif (tipo == -1) then --> apenas da fade sem hidar
			if (frame:GetAlpha() == 0 and frame.hidden and not frame.fading_out) then --> ja esta escondida
				return
			elseif (frame.fading_in) then --> ja esta com uma animação, se for true
				return
			end
			
			if (frame.fading_out) then --> se tiver uma animação de aparecer em andamento se for true
				frame.fading_out = false
			end

			_UIFrameFadeIn (frame, velocidade, frame:GetAlpha(), 0)
			frame.fading_in = true
			frame.fadeInfo.finishedFunc = 
			function()
				frame.hidden = false
				frame.faded = true
				frame.fading_in = false
			end
			
		elseif (_upper (tipo) == "ALPHAANIM") then

			local value = velocidade
			local currentApha = frame:GetAlpha()
			frame:Show()
			
			if (currentApha < value) then
				if (frame.fading_in) then --> se tiver uma animação de hidar em andamento se for true
					frame.fading_in = false
					frame.fadeInfo.finishedFunc = nil
				end
				UIFrameFadeOut (frame, 0.3, currentApha, value)
				frame.fading_out = true
				frame.fadeInfo.finishedFunc = 
				function()
					frame.fading_out = false
				end
			else
				if (frame.fading_out) then --> se tiver uma animação de hidar em andamento se for true
					frame.fading_out = false
					frame.fadeInfo.finishedFunc = nil
				end
				UIFrameFadeIn (frame, 0.3, currentApha, value)
				frame.fading_in = true
				frame.fadeInfo.finishedFunc = 
				function()
					frame.fading_in = false
				end
			end

		elseif (_upper (tipo) == "ALPHA") then --> setando um alpha determinado
			if (frame.fading_in or frame.fading_out) then
				frame.fadeInfo.finishedFunc = nil
				_UIFrameFadeIn (frame, velocidade, frame:GetAlpha(), frame:GetAlpha())
			end
			frame.hidden = false
			frame.faded = false
			frame.fading_in = false
			frame.fading_out = false
			frame:Show()
			frame:SetAlpha (velocidade)
		end
	end

	function _detalhes:name_space (barra)
		--if (barra.icone_secundario_ativo) then
		--	local tamanho = barra:GetWidth()-barra.texto_direita:GetStringWidth()-16-barra:GetHeight()
		--	barra.texto_esquerdo:SetSize (tamanho-2, 15)
		--else
			barra.texto_esquerdo:SetSize (barra:GetWidth()-barra.texto_direita:GetStringWidth()-18, 15)
		--end
	end

	function _detalhes:name_space_info (barra)
		if (barra.icone_secundario_ativo) then
			local tamanho = barra:GetWidth()-barra.texto_direita:GetStringWidth()-16-barra:GetHeight()
			barra.texto_esquerdo:SetSize (tamanho-10, 15)
		else
			local tamanho = barra:GetWidth()-barra.texto_direita:GetStringWidth()-16
			barra.texto_esquerdo:SetSize (tamanho-10, 15)
		end
	end

	function _detalhes:name_space_generic (barra, separador)
		local texto_direita_tamanho = barra.texto_direita:GetStringWidth()
		local tamanho = barra:GetWidth()-texto_direita_tamanho-16
		if (separador) then 
			barra.texto_esquerdo:SetSize (tamanho+separador, 10)
			barra.texto_direita:SetSize (texto_direita_tamanho+15, 10)
		else
			barra.texto_esquerdo:SetSize (tamanho-10, 15)
			barra.texto_direita:SetSize (texto_direita_tamanho+5, 15)
		end
	end

