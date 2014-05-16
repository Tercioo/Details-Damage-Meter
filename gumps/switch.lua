local _detalhes = 		_G._detalhes
local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ( "Details" )

local gump = 			_detalhes.gump
local _
--lua locals
local _unpack = unpack
local _math_floor = math.floor

--api locals
do
	local _CreateFrame = CreateFrame
	local _UIParent = UIParent

	local gump_fundo_backdrop = {
		bgFile = "Interface\\AddOns\\Details\\images\\background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true, tileSize = 16, edgeSize = 4,
		insets = {left = 0, right = 0, top = 0, bottom = 0}}

	local frame = _CreateFrame ("frame", "DetailsSwitchPanel", _UIParent)
	frame:SetPoint ("center", _UIParent, "center", 500, -300)
	frame:SetWidth (250)
	frame:SetHeight (100)
	frame:SetBackdrop (gump_fundo_backdrop)
	frame:SetBackdropBorderColor (170/255, 170/255, 170/255)
	frame:SetBackdropColor (24/255, 24/255, 24/255, .8)
	
	frame:SetFrameStrata ("FULLSCREEN")
	frame:SetFrameLevel (16)
	
	function _detalhes.switch:CloseMe()
		_detalhes.switch.frame:Hide()
		_detalhes.switch.frame:SetBackdropColor (24/255, 24/255, 24/255, .8)
		_detalhes.switch.current_instancia:StatusBarAlert (nil)
		_detalhes.switch.current_instancia = nil
	end
	
	--> limitação: não tenho como pegar o base frame da instância por aqui
	frame.close = gump:NewDetailsButton (frame, frame, _, function() end, nil, nil, 1, 1, "", "", "", "", {rightFunc = {func = _detalhes.switch.CloseMe, param1 = nil, param2 = nil}}, "DetailsSwitchPanelClose")
	frame.close:SetPoint ("topleft", frame, "topleft")
	frame.close:SetPoint ("bottomright", frame, "bottomright")
	frame.close:SetFrameLevel (9)
	frame:Hide()
	
	_detalhes.switch.frame = frame
end

_detalhes.switch.buttons = {}
_detalhes.switch.slots = _detalhes.switch.slots or 6
_detalhes.switch.showing = 0
_detalhes.switch.table = _detalhes.switch.table or {}
_detalhes.switch.current_instancia = nil
_detalhes.switch.current_button = nil
_detalhes.switch.height_necessary = (30*_detalhes.switch.slots)/2

local right_click_text = {text = Loc ["STRING_SHORTCUT_RIGHTCLICK"], size = 9, color = {.9, .9, .9}}
local right_click_texture = {[[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 14, 14, 0.0019531, 0.1484375, 0.6269531, 0.8222656}

function _detalhes.switch:ShowMe (instancia)

	if (_detalhes.switch.current_instancia) then
		_detalhes.switch.current_instancia:StatusBarAlert (nil)
	end

	_detalhes.switch.current_instancia = instancia
	
	--_detalhes.switch.frame:SetFrameLevel (instancia.baseframe:GetFrameLevel() + 5)
	_detalhes.switch.frame:SetPoint ("topleft", instancia.baseframe, "topleft", 2, 0)
	_detalhes.switch.frame:SetPoint ("bottomright", instancia.baseframe, "bottomright", -2, 0)
	
	_detalhes.switch.frame:SetBackdropColor (0.094, 0.094, 0.094, .8)
	local _r, _g, _b, _a = _detalhes.switch.frame:GetBackdropColor()
	gump:GradientEffect (_detalhes.switch.frame, "frame", _r, _g, _b, _a, _r, _g, _b, 1, 1)
	
	local altura = instancia.baseframe:GetHeight()
	local mostrar_quantas = _math_floor (altura / 30) * 2
	
	if (_detalhes.switch.mostrar_quantas ~= mostrar_quantas) then 
		for i = 1, #_detalhes.switch.buttons do
			if (i <= mostrar_quantas) then 
				_detalhes.switch.buttons [i]:Show()
			else
				_detalhes.switch.buttons [i]:Hide()
			end
		end
		
		if (#_detalhes.switch.buttons < mostrar_quantas) then
			_detalhes.switch.slots = mostrar_quantas
			_detalhes.switch:Update()
		end
		
		_detalhes.switch.mostrar_quantas = mostrar_quantas
	end
	
	_detalhes.switch:Resize()
	
	_detalhes.switch.frame:Show()
	instancia:StatusBarAlert (right_click_text, right_click_texture) --icon, color, time
end

function _detalhes.switch:Config (_,_, atributo, sub_atributo)
	if (not sub_atributo) then 
		return
	end
	
	_detalhes.switch.table [_detalhes.switch.current_button].atributo = atributo
	_detalhes.switch.table [_detalhes.switch.current_button].sub_atributo = sub_atributo
	_detalhes.switch:Update()
end

function _detalhes:FastSwitch (_this)
	_detalhes.switch.current_button = _this.button
	
	if (not _this.atributo) then --> botão direito
	
		GameCooltip:Reset()
		GameCooltip:SetType (3)
		GameCooltip:SetFixedParameter (_detalhes.switch.current_instancia)
		GameCooltip:SetOwner (_detalhes.switch.buttons [_this.button])
		_detalhes:MontaAtributosOption (_detalhes.switch.current_instancia, _detalhes.switch.Config)
		GameCooltip:SetColor (1, {.1, .1, .1, .3})
		GameCooltip:SetColor (2, {.1, .1, .1, .3})
		GameCooltip:ShowCooltip()

	else --> botão esquerdo
		if (_detalhes.switch.current_instancia.modo == _detalhes._detalhes_props["MODO_ALONE"]) then
			_detalhes.switch.current_instancia:AlteraModo (_detalhes.switch.current_instancia, _detalhes.switch.current_instancia.LastModo)
			
		elseif (_detalhes.switch.current_instancia.modo == _detalhes._detalhes_props["MODO_RAID"]) then
			_detalhes.switch.current_instancia:AlteraModo (_detalhes.switch.current_instancia, _detalhes.switch.current_instancia.LastModo)
			
		end
		
		_detalhes.switch.current_instancia:TrocaTabela (_detalhes.switch.current_instancia, true, _this.atributo, _this.sub_atributo)
		_detalhes.switch.CloseMe()
		
	end
end

-- nao tem suporte a solo mode tank mode
-- nao tem suporte a custom até agora, não sei como vai ficar

function _detalhes.switch:InitSwitch()
	return _detalhes.switch:Update()
end

function _detalhes.switch:OnRemoveCustom (CustomIndex)
	for i = 1, _detalhes.switch.slots do
		local options = _detalhes.switch.table [i]
		if (options and options.atributo == 5 and options.sub_atributo == CustomIndex) then 
			--> precisa resetar esse aqui
			options.atributo = nil
			options.sub_atributo = nil
			_detalhes.switch:Update()
		end
	end
end

function _detalhes.switch:Update()

	local slots = _detalhes.switch.slots
	local x = 10
	local y = 10
	local jump = false

	for i = 1, slots do

		local options = _detalhes.switch.table [i]
		if (not options) then 
			options = {atributo = nil, sub_atributo = nil}
			_detalhes.switch.table [i] = options
		end

		local button = _detalhes.switch.buttons [i]
		if (not button) then
			button = _detalhes.switch:NewSwitchButton (_detalhes.switch.frame, i, x, y, jump)
			button:SetFrameLevel (_detalhes.switch.frame:GetFrameLevel()+2)
			_detalhes.switch.showing = _detalhes.switch.showing + 1
		end
		
		local param2Table = {
			["instancia"] = _detalhes.switch.current_instancia, 
			["button"] = i, 
			["atributo"] = options.atributo, 
			["sub_atributo"] = options.sub_atributo
		}
		
		button.funcParam2 = param2Table
		button.button2.funcParam2 = param2Table
		
		local icone
		local coords
		local name
		
		if (options.sub_atributo) then
			if (options.atributo == 5) then --> custom
				local CustomObject = _detalhes.custom [options.sub_atributo]
				if (not CustomObject) then --> ele já foi deletado
					icone = "Interface\\ICONS\\Ability_DualWield"
					coords = {0, 1, 0, 1}
					name = Loc ["STRING_SWITCH_CLICKME"]
				else
					icone = CustomObject.icon
					coords = {0, 1, 0, 1}
					name = CustomObject.name
				end
			else
				icone = _detalhes.sub_atributos [options.atributo].icones [options.sub_atributo] [1]
				coords = _detalhes.sub_atributos [options.atributo].icones [options.sub_atributo] [2]
				name = _detalhes.sub_atributos [options.atributo].lista [options.sub_atributo]
			end
		else
			icone = "Interface\\ICONS\\Ability_DualWield"
			coords = {0, 1, 0, 1}
			name = Loc ["STRING_SWITCH_CLICKME"]
		end
		
		button.button2.texto:SetText (name)
		
		button.textureNormal:SetTexture (icone, true)
		button.textureNormal:SetTexCoord (_unpack (coords))
		button.texturePushed:SetTexture (icone, true)
		button.texturePushed:SetTexCoord (_unpack (coords))
		button.textureH:SetTexture (icone, true)
		button.textureH:SetTexCoord (_unpack (coords))
		button:ChangeIcon (button.textureNormal, button.texturePushed, _, button.textureH)

		if (jump) then 
			x = x - 125
			y = y + 30
			jump = false
		else
			x = x + 125
			jump = true
		end

	end
end

function _detalhes.switch:Resize()

	local x = 10
	local y = 10
	local xPlus = (_detalhes.switch.current_instancia:GetSize()/2)-5
	local frame = _detalhes.switch.frame
	
	for index, button in ipairs (_detalhes.switch.buttons) do
		
		if (button.rightButton) then
			button:SetPoint ("topleft", frame, "topleft", x, -y)
			button.textureNormal:SetPoint ("topleft", frame, "topleft", x, -y)
			button.texturePushed:SetPoint ("topleft", frame, "topleft", x, -y)
			button.textureH:SetPoint ("topleft", frame, "topleft", x, -y)	
			button.button2.texto:SetSize (xPlus - 30, 12)
			button.button2:SetPoint ("bottomright", button, "bottomright", xPlus - 30, 0)
			button.line:SetWidth (xPlus - 15)
			button.line2:SetWidth (xPlus - 15)
			x = x - xPlus
			y = y + 30
			jump = false
		else
			button:SetPoint ("topleft", frame, "topleft", x, -y)
			button.textureNormal:SetPoint ("topleft", frame, "topleft", x, -y)
			button.texturePushed:SetPoint ("topleft", frame, "topleft", x, -y)
			button.textureH:SetPoint ("topleft", frame, "topleft", x, -y)	
			button.button2.texto:SetSize (xPlus - 30, 12)
			button.button2:SetPoint ("topleft", button, "topright", 1, 0)
			button.button2:SetPoint ("bottomright", button, "bottomright", xPlus - 30, 0)
			button.line:SetWidth (xPlus - 20)
			button.line2:SetWidth (xPlus - 20)
			x = x + xPlus
			jump = true			
		end
		
	end
end

function _detalhes.switch:NewSwitchButton (frame, index, x, y, rightButton)

	local paramTable = {
			["instancia"] = _detalhes.switch.current_instancia, 
			["button"] = index, 
			["atributo"] = nil, 
			["sub_atributo"] = nil
		}

	local button = gump:NewDetailsButton (frame, frame, _, _detalhes.FastSwitch, nil, paramTable, 15, 15, "", "", "", "", 
	{rightFunc = {func = _detalhes.FastSwitch, param1 = nil, param2 = {atributo = nil, button = index}}, OnGrab = "PassClick"}, "DetailsSwitchPanelButton_1_"..index)
	button:SetPoint ("topleft", frame, "topleft", x, -y)
	button.rightButton = rightButton
	
	button.fundo = button:CreateTexture (nil, "background")
	button.fundo:SetTexture ("Interface\\SPELLBOOK\\Spellbook-Parts")
	button.fundo:SetTexCoord (0.00390625, 0.27734375, 0.44140625,0.69531250)
	button.fundo:SetWidth (34)
	button.fundo:SetHeight (32)
	button.fundo:SetPoint ("topleft", button, "topleft", -9, 9)
	
	button.line = button:CreateTexture (nil, "background")
	button.line:SetTexture ("Interface\\SPELLBOOK\\Spellbook-Parts")
	button.line:SetTexCoord (0.31250000, 0.96484375, 0.37109375, 0.52343750)
	button.line:SetWidth (85)
	button.line:SetHeight (25)
	button.line:SetPoint ("left", button, "right", 0, -3)
	
	button.line2 = button:CreateTexture (nil, "background")
	button.line2:SetTexture ("Interface\\SPELLBOOK\\Spellbook-Parts")
	button.line2:SetTexCoord (0.31250000, 0.96484375, 0.37109375, 0.52343750)
	button.line2:SetWidth (85)
	button.line2:SetHeight (25)
	button.line2:SetPoint ("left", button, "right", 0, -3)
	
	local button2 = gump:NewDetailsButton (button, button, _, _detalhes.FastSwitch, nil, paramTable, 1, 1, button.line, "", "", button.line2, 
	{rightFunc = {func = _detalhes.switch.CloseMe, param1 = nil, param2 = nil}, OnGrab = "PassClick"}, "DetailsSwitchPanelButton_2_"..index)
	button2:SetPoint ("topleft", button, "topright", 1, 0)
	button2:SetPoint ("bottomright", button, "bottomright", 90, 0)
	button.button2 = button2
	
	button.textureNormal = frame:CreateTexture (nil, "overlay")
	button.textureNormal:SetWidth (15)
	button.textureNormal:SetHeight (15)
	button.textureNormal:SetPoint ("topleft", frame, "topleft", x, -y)
	
	button.texturePushed = frame:CreateTexture (nil, "overlay")
	button.texturePushed:SetWidth (15)
	button.texturePushed:SetHeight (15)
	button.texturePushed:SetPoint ("topleft", frame, "topleft", x, -y)

	button.textureH = frame:CreateTexture (nil, "overlay")
	button.textureH:SetWidth (15)
	button.textureH:SetHeight (15)
	button.textureH:SetPoint ("topleft", frame, "topleft", x, -y)	
	
	gump:NewLabel (button2, button2, nil, "texto", "", "GameFontHighlightSmall")
	button2.texto:SetPoint ("left", button, "right", 4, -1)
	button2.texto:SetNonSpaceWrap (true)
	
	_detalhes.switch.buttons [index] = button
	
	return button
end
