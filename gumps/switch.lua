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
		tile = true, tileSize = 16,
		insets = {left = 0, right = 0, top = 0, bottom = 0}}

	local frame = _CreateFrame ("frame", "DetailsSwitchPanel", _UIParent)
	frame:SetPoint ("center", _UIParent, "center", 500, -300)
	frame:SetWidth (250)
	frame:SetHeight (100)
	frame:SetBackdrop (gump_fundo_backdrop)
	frame:SetBackdropBorderColor (170/255, 170/255, 170/255)
	frame:SetBackdropColor (0, 0, 0, .7)
	
	frame:SetFrameStrata ("FULLSCREEN")
	frame:SetFrameLevel (16)
	
	frame.background = frame:CreateTexture (nil, "background")
	frame.background:SetTexture ([[Interface\Store\Store-Splash]])
	frame.background:SetTexCoord (16/1024, 561/1024, 8/1024, 263/1024)
	frame.background:SetAllPoints()
	frame.background:SetDesaturated (true)
	frame.background:SetVertexColor (.5, .5, .5, .85)
	
	frame.topbg = frame:CreateTexture (nil, "background")
	frame.topbg:SetTexture ([[Interface\Scenarios\ScenariosParts]])
	frame.topbg:SetTexCoord (100/512, 267/512, 143/512, 202/512)
	frame.topbg:SetPoint ("bottomleft", frame, "topleft")
	frame.topbg:SetPoint ("bottomright", frame, "topright")
	frame.topbg:SetHeight (20)
	frame.topbg:SetDesaturated (true)
	frame.topbg:SetVertexColor (.3, .3, .3, 1)
	
	frame.topbg_frame = CreateFrame ("frame", nil, frame)
	frame.topbg_frame:SetPoint ("bottomleft", frame, "topleft")
	frame.topbg_frame:SetPoint ("bottomright", frame, "topright")
	frame.topbg_frame:SetHeight (20)
	frame.topbg_frame:EnableMouse (true)
	frame.topbg_frame:SetScript ("OnMouseDown", function (self, button)
		if (button == "RightButton") then
			_detalhes.switch:CloseMe()
		end
	end)
	
	frame.star = frame:CreateTexture (nil, "overlay")
	frame.star:SetTexture ([[Interface\Glues\CharacterSelect\Glues-AddOn-Icons]])
	frame.star:SetTexCoord (0.75, 1, 0, 1)
	frame.star:SetSize (16, 16)
	frame.star:SetPoint ("bottomleft", frame, "topleft", 4, 0)
	
	frame.title_label = frame:CreateFontString (nil, "overlay", "GameFontNormal")
	frame.title_label:SetPoint ("left", frame.star, "right", 4, -1)
	frame.title_label:SetText ("Bookmark")

---------------------------------------------------------------------------------------------------------------------------

	frame.editing_window = nil
	local windowcolor_callback = function (button, r, g, b, a)
		local instance = frame.editing_window
	
		if (instance.menu_alpha.enabled and a ~= instance.color[4]) then
			_detalhes:Msg (Loc ["STRING_OPTIONS_MENU_ALPHAWARNING"])
			instance:InstanceColor (r, g, b, instance.menu_alpha.onleave, nil, true)
			
			if (_detalhes.options_group_edit) then
				for _, this_instance in ipairs (instance:GetInstanceGroup()) do
					if (this_instance ~= instance) then
						this_instance:InstanceColor (r, g, b, instance.menu_alpha.onleave, nil, true)
					end
				end
			end
			
			return
		end
		
		instance:InstanceColor (r, g, b, a, nil, true)
		if (_detalhes.options_group_edit) then
			for _, this_instance in ipairs (instance:GetInstanceGroup()) do
				if (this_instance ~= instance) then
					this_instance:InstanceColor (r, g, b, a, nil, true)
				end
			end
		end
	end
	
	local change_color = function()
		frame.editing_window = _detalhes.switch.current_instancia
		local r, g, b, a = unpack (frame.editing_window.color)
		_detalhes.gump:ColorPick (frame, r, g, b, a, windowcolor_callback)
		_detalhes.switch:CloseMe()
	end
	
	local window_color = gump:CreateButton (frame.topbg_frame, change_color, 14, 14)
	window_color:SetPoint ("bottomright", frame, "topright", -3, 2)
	
	local window_color_texture = gump:CreateImage (window_color, [[Interface\AddOns\Details\images\icons]], 14, 14, "artwork", {434/512, 466/512, 277/512, 307/512})
	window_color_texture:SetAlpha (0.35)
	window_color_texture:SetAllPoints()
	
	window_color:SetHook ("OnEnter", function()
		window_color_texture:SetAlpha (1)
		GameCooltip:Reset()
		_detalhes:CooltipPreset (1)
		GameCooltip:SetBackdrop (1, _detalhes.tooltip_backdrop, backgroundColor, _detalhes.tooltip_border_color)
		GameCooltip:AddLine (Loc ["STRING_OPTIONS_INSTANCE_COLOR"])
		GameCooltip:SetOwner (window_color.widget)
		GameCooltip:SetType ("tooltip")
		GameCooltip:Show()
	end)
	window_color:SetHook ("OnLeave", function()
		window_color_texture:SetAlpha (0.35)
		GameCooltip:Hide()
	end)
	
---------------------------------------------------------------------------------------------------------------------------

	local open_options = function()
		_detalhes:OpenOptionsWindow (_detalhes.switch.current_instancia)
		_detalhes.switch:CloseMe()
	end
	local options_button = gump:CreateButton (frame.topbg_frame, open_options, 14, 14, open_options)
	options_button:SetPoint ("right", window_color, "left", -2, 0)
	
	local options_button_texture = gump:CreateImage (options_button, [[Interface\AddOns\Details\images\modo_icones]], 14, 14, "artwork", {0.5, 0.625, 0, 1})
	options_button_texture:SetAlpha (0.35)
	options_button_texture:SetAllPoints()
	
	options_button:SetHook ("OnEnter", function()
		options_button_texture:SetAlpha (1)
		GameCooltip:Reset()
		_detalhes:CooltipPreset (1)
		GameCooltip:SetBackdrop (1, _detalhes.tooltip_backdrop, backgroundColor, _detalhes.tooltip_border_color)
		GameCooltip:AddLine (Loc ["STRING_INTERFACE_OPENOPTIONS"])
		GameCooltip:SetOwner (window_color.widget)
		GameCooltip:SetType ("tooltip")
		GameCooltip:Show()
	end)
	options_button:SetHook ("OnLeave", function()
		options_button_texture:SetAlpha (0.35)
		GameCooltip:Hide()
	end)
	
---------------------------------------------------------------------------------------------------------------------------
	
	function _detalhes.switch:CloseMe()
		_detalhes.switch.frame:Hide()
		GameCooltip:Hide()
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
	_detalhes.switch.button_height = 20
end

_detalhes.switch.buttons = {}
_detalhes.switch.slots = _detalhes.switch.slots or 6
_detalhes.switch.showing = 0
_detalhes.switch.table = _detalhes.switch.table or {}
_detalhes.switch.current_instancia = nil
_detalhes.switch.current_button = nil
_detalhes.switch.height_necessary = (_detalhes.switch.button_height * _detalhes.switch.slots) / 2

local right_click_text = {text = Loc ["STRING_SHORTCUT_RIGHTCLICK"], size = 9, color = {.9, .9, .9}}
local right_click_texture = {[[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 14, 14, 0.0019531, 0.1484375, 0.6269531, 0.8222656}

function _detalhes.switch:HideAllBookmarks()
	for _, bookmark in ipairs (_detalhes.switch.buttons) do
		bookmark:Hide()
	end
end

function _detalhes.switch:ShowMe (instancia)

	_detalhes.switch.current_instancia = instancia

	if (IsControlKeyDown()) then
		
		if (not _detalhes.tutorial.ctrl_click_close_tutorial) then
			if (not DetailsCtrlCloseWindowPanelTutorial) then
				local tutorial_frame = CreateFrame ("frame", "DetailsCtrlCloseWindowPanelTutorial", _detalhes.switch.frame)
				tutorial_frame:SetFrameStrata ("FULLSCREEN_DIALOG")
				tutorial_frame:SetAllPoints()
				tutorial_frame:EnableMouse (true)
				tutorial_frame:SetBackdrop ({bgFile = "Interface\\AddOns\\Details\\images\\background", tile = true, tileSize = 16 })
				tutorial_frame:SetBackdropColor (0.05, 0.05, 0.05, 0.95)

				tutorial_frame.info_label = tutorial_frame:CreateFontString (nil, "overlay", "GameFontNormal")
				tutorial_frame.info_label:SetPoint ("topleft", tutorial_frame, "topleft", 10, -10)
				tutorial_frame.info_label:SetText (Loc ["STRING_MINITUTORIAL_CLOSECTRL1"])
				tutorial_frame.info_label:SetJustifyH ("left")
				
				tutorial_frame.mouse = tutorial_frame:CreateTexture (nil, "overlay")
				tutorial_frame.mouse:SetTexture ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]])
				tutorial_frame.mouse:SetTexCoord (0.0019531, 0.1484375, 0.6269531, 0.8222656)
				tutorial_frame.mouse:SetSize (20, 22)
				tutorial_frame.mouse:SetPoint ("topleft", tutorial_frame.info_label, "bottomleft", -3, -10)

				tutorial_frame.close_label = tutorial_frame:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
				tutorial_frame.close_label:SetPoint ("left", tutorial_frame.mouse, "right", 4, 0)
				tutorial_frame.close_label:SetText (Loc ["STRING_MINITUTORIAL_CLOSECTRL2"])
				tutorial_frame.close_label:SetJustifyH ("left")
				
				local checkbox = CreateFrame ("CheckButton", "DetailsCtrlCloseWindowPanelTutorialCheckBox", tutorial_frame, "ChatConfigCheckButtonTemplate")
				checkbox:SetPoint ("topleft", tutorial_frame.mouse, "bottomleft", -1, -5)
				_G [checkbox:GetName().."Text"]:SetText (Loc ["STRING_MINITUTORIAL_BOOKMARK4"])
				
				tutorial_frame:SetScript ("OnMouseDown", function()
					if (checkbox:GetChecked()) then
						_detalhes.tutorial.ctrl_click_close_tutorial = true
					end
					
					tutorial_frame:Hide()
					
					if (instancia:IsEnabled()) then
						return instancia:ShutDown()
					end
				end)
			end
			
			DetailsCtrlCloseWindowPanelTutorial:Show()
			DetailsCtrlCloseWindowPanelTutorial.info_label:SetWidth (_detalhes.switch.frame:GetWidth()-30)
			DetailsCtrlCloseWindowPanelTutorial.close_label:SetWidth (_detalhes.switch.frame:GetWidth()-30)
			
			_detalhes.switch.frame:SetPoint ("topleft", instancia.baseframe, "topleft", 0, 1)
			_detalhes.switch.frame:SetPoint ("bottomright", instancia.baseframe, "bottomright", 0, 1)
			_detalhes.switch.frame:SetBackdropColor (0.094, 0.094, 0.094, .8)
			_detalhes.switch.frame:Show()
			
			return
		end
		
		return instancia:ShutDown()
		
	elseif (IsShiftKeyDown()) then
		
		if (not _detalhes.switch.segments_blocks) then
		
			local segment_switch = function (segment, _, _, button)
				if (button == "LeftButton") then
					_detalhes.switch.current_instancia:TrocaTabela (segment)
					_detalhes.switch.CloseMe()
				elseif (button == "RightButton") then
					_detalhes.switch.CloseMe()
				end
			end
			
			local hide_label = function (self)
				self.texture:Hide()
				self.button:Hide()
				self.background:Hide()
				self:Hide()
			end
			
			local show_label = function (self)
				self.texture:Show()
				self.button:Show()
				self.background:Show()
				self:Show()
			end
			
			local on_enter = function (self)
				self.MyObject.this_background:SetBlendMode ("ADD")
				self.MyObject.boss_texture:SetBlendMode ("ADD")
			end
			
			local on_leave = function (self)
				self.MyObject.this_background:SetBlendMode ("BLEND")
				self.MyObject.boss_texture:SetBlendMode ("BLEND")
			end
		
			function _detalhes.switch:CreateSegmentBlock()
				local s = gump:CreateLabel (_detalhes.switch.frame)
				_detalhes:SetFontSize (s, 9)
				
				local index = #_detalhes.switch.segments_blocks
				if (index == 1) then --overall button
					index = -1
				elseif (index >= 2) then
					index = index - 1
				end
				
				local button = gump:CreateButton (_detalhes.switch.frame, segment_switch, 100, 20, "", index)
				button:SetPoint ("topleft", s, "topleft", -17, 0)
				button:SetPoint ("bottomright", s, "bottomright", 0, 0)
				button:SetClickFunction (segment_switch, nil, nil, "right")

				local boss_texture = gump:CreateImage (button, nil, 16, 16)
				boss_texture:SetPoint ("right", s, "left", -2, 0)

				local background = button:CreateTexture (nil, "background")
				background:SetTexture ("Interface\\SPELLBOOK\\Spellbook-Parts")
				background:SetTexCoord (0.31250000, 0.96484375, 0.37109375, 0.52343750)
				background:SetWidth (85)
				background:SetPoint ("topleft", s.widget, "topleft", -16, 3)
				background:SetPoint ("bottomright", s.widget, "bottomright", -3, -5)
				
				button.this_background = background
				button.boss_texture = boss_texture.widget
				
				s.texture = boss_texture
				s.button = button
				s.background = background
				
				button:SetScript ("OnEnter", on_enter)
				button:SetScript ("OnLeave", on_leave)
				
				s.HideMe = hide_label
				s.ShowMe = show_label
				
				tinsert (_detalhes.switch.segments_blocks, s)
				return s
			end
			
			function _detalhes.switch:GetSegmentBlock (index)
				local block = _detalhes.switch.segments_blocks [index]
				if (not block) then
					return _detalhes.switch:CreateSegmentBlock()
				else
					return block
				end
			end
			
			function _detalhes.switch:ClearSegmentBlocks()
				for _, block in ipairs (_detalhes.switch.segments_blocks) do
					block:HideMe()
				end
			end
			
			function _detalhes.switch:ResizeSegmentBlocks()

				local x = 7
				local y = 5
				
				local window_width, window_height = _detalhes.switch.current_instancia:GetSize()
				
				local horizontal_amt = floor (math.max (window_width / 100, 2))
				local vertical_amt = floor ((window_height - y) / 20)
				local size = window_width / horizontal_amt
				
				local frame = _detalhes.switch.frame
				
				_detalhes.switch:ClearSegmentBlocks()
				
				local i = 1
				for vertical = 1, vertical_amt do
					x = 7
					for horizontal = 1, horizontal_amt do
						local button = _detalhes.switch:GetSegmentBlock (i)
						
						button:SetPoint ("topleft", frame, "topleft", x + 16, -y)
						button:SetSize (size - 22, 12)
						button:ShowMe()
						
						i = i + 1
						x = x + size
						if (i > 40) then
							break
						end
					end
					y = y + 20
				end
			end
		
			_detalhes.switch.segments_blocks = {}

			--> current and overall
			_detalhes.switch:CreateSegmentBlock()
			_detalhes.switch:CreateSegmentBlock()
			
			local block1 = _detalhes.switch:GetSegmentBlock (1)
			block1:SetText (Loc ["STRING_CURRENTFIGHT"])
			block1.texture:SetTexture ([[Interface\Scenarios\ScenariosParts]])
			block1.texture:SetTexCoord (55/512, 81/512, 368/512, 401/512)
			
			local block2 = _detalhes.switch:GetSegmentBlock (2)
			block2:SetText (Loc ["STRING_SEGMENT_OVERALL"])
			block2.texture:SetTexture ([[Interface\Scenarios\ScenariosParts]])
			block2.texture:SetTexCoord (55/512, 81/512, 368/512, 401/512)
		end
		
		_detalhes.switch:ClearSegmentBlocks()
		_detalhes.switch:HideAllBookmarks()
		
		local segment_index = 1
		for i = 3, #_detalhes.tabela_historico.tabelas + 2 do
		
			local combat = _detalhes.tabela_historico.tabelas [segment_index]
		
			local block = _detalhes.switch:GetSegmentBlock (i)
			local enemy, color, raid_type, killed, is_trash, portrait, background, background_coords = _detalhes:GetSegmentInfo (segment_index)

			block:SetText ("#" .. segment_index .. " " .. enemy)
			
			if (combat.is_boss and combat.instance_type == "raid") then
				local L, R, T, B, Texture = _detalhes:GetBossIcon (combat.is_boss.mapid, combat.is_boss.index)
				if (L) then
					block.texture:SetTexture (Texture)
					block.texture:SetTexCoord (L, R, T, B)
				else
					block.texture:SetTexture ([[Interface\Scenarios\ScenarioIcon-Boss]])
				end
			else
				block.texture:SetTexture ([[Interface\Scenarios\ScenarioIcon-Boss]])
			end
			
			block:ShowMe()
			segment_index = segment_index + 1
		end
		
		_detalhes.switch.frame:SetScale (instancia.window_scale)
		_detalhes.switch:ResizeSegmentBlocks()
		
		for i = segment_index+2, #_detalhes.switch.segments_blocks do
			_detalhes.switch.segments_blocks [i]:HideMe()
		end
		
		_detalhes.switch.frame:SetPoint ("topleft", instancia.baseframe, "topleft", 0, 1)
		_detalhes.switch.frame:SetPoint ("bottomright", instancia.baseframe, "bottomright", 0, 1)
		_detalhes.switch.frame:SetBackdropColor (0.094, 0.094, 0.094, .8)
		_detalhes.switch.frame:Show()
		
		return
		
	else
		if (_detalhes.switch.segments_blocks) then
			_detalhes.switch:ClearSegmentBlocks()
		end
	end

	--> check if there is some custom contidional
	if (instancia.atributo == 5) then
		local custom_object = instancia:GetCustomObject()
		if (custom_object and custom_object.OnSwitchShow) then
			local interrupt = custom_object.OnSwitchShow (instancia)
			if (interrupt) then
				return
			end
		end
	end
	
	_detalhes.switch.frame:SetPoint ("topleft", instancia.baseframe, "topleft", 0, 1)
	_detalhes.switch.frame:SetPoint ("bottomright", instancia.baseframe, "bottomright", 0, 1)
	_detalhes.switch.frame:SetBackdropColor (0.094, 0.094, 0.094, .8)
	
	local altura = instancia.baseframe:GetHeight()
	local mostrar_quantas = _math_floor (altura / _detalhes.switch.button_height) * 2
	
	local precisa_mostrar = 0
	for i = 1, #_detalhes.switch.table do
		local slot = _detalhes.switch.table [i]
		if (slot.atributo) then
			precisa_mostrar = precisa_mostrar + 1
		else
			break
		end
	end
	
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
		end
		
		_detalhes.switch.mostrar_quantas = mostrar_quantas
	end
	
	_detalhes.switch:Resize (precisa_mostrar)
	_detalhes.switch:Update()
	
	_detalhes.switch.frame:SetScale (instancia.window_scale)
	_detalhes.switch.frame:Show()
	
	if (not _detalhes.tutorial.bookmark_tutorial) then
	
		if (not SwitchPanelTutorial) then
			local tutorial_frame = CreateFrame ("frame", "SwitchPanelTutorial", _detalhes.switch.frame)
			tutorial_frame:SetFrameStrata ("FULLSCREEN_DIALOG")
			tutorial_frame:SetAllPoints()
			tutorial_frame:EnableMouse (true)
			tutorial_frame:SetBackdrop ({bgFile = "Interface\\AddOns\\Details\\images\\background", tile = true, tileSize = 16 })
			tutorial_frame:SetBackdropColor (0.05, 0.05, 0.05, 0.95)

			tutorial_frame.info_label = tutorial_frame:CreateFontString (nil, "overlay", "GameFontNormal")
			tutorial_frame.info_label:SetPoint ("topleft", tutorial_frame, "topleft", 10, -10)
			tutorial_frame.info_label:SetText (Loc ["STRING_MINITUTORIAL_BOOKMARK2"])
			tutorial_frame.info_label:SetJustifyH ("left")
			
			tutorial_frame.mouse = tutorial_frame:CreateTexture (nil, "overlay")
			tutorial_frame.mouse:SetTexture ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]])
			tutorial_frame.mouse:SetTexCoord (0.0019531, 0.1484375, 0.6269531, 0.8222656)
			tutorial_frame.mouse:SetSize (20, 22)
			tutorial_frame.mouse:SetPoint ("topleft", tutorial_frame.info_label, "bottomleft", -3, -10)

			tutorial_frame.close_label = tutorial_frame:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
			tutorial_frame.close_label:SetPoint ("left", tutorial_frame.mouse, "right", 4, 0)
			tutorial_frame.close_label:SetText (Loc ["STRING_MINITUTORIAL_BOOKMARK3"])
			tutorial_frame.close_label:SetJustifyH ("left")
			
			local checkbox = CreateFrame ("CheckButton", "SwitchPanelTutorialCheckBox", tutorial_frame, "ChatConfigCheckButtonTemplate")
			checkbox:SetPoint ("topleft", tutorial_frame.mouse, "bottomleft", -1, -5)
			_G [checkbox:GetName().."Text"]:SetText (Loc ["STRING_MINITUTORIAL_BOOKMARK4"])
			
			tutorial_frame:SetScript ("OnMouseDown", function()
				if (checkbox:GetChecked()) then
					_detalhes.tutorial.bookmark_tutorial = true
				end
				tutorial_frame:Hide()
			end)
		end
		
		SwitchPanelTutorial:Show()
		SwitchPanelTutorial.info_label:SetWidth (_detalhes.switch.frame:GetWidth()-30)
		SwitchPanelTutorial.close_label:SetWidth (_detalhes.switch.frame:GetWidth()-30)
	end
	
	_detalhes.switch:Resize (precisa_mostrar)
	--instancia:StatusBarAlert (right_click_text, right_click_texture) --icon, color, time
end

function _detalhes.switch:Config (_,_, atributo, sub_atributo)
	if (not sub_atributo) then 
		return
	end
	
	_detalhes.switch.table [_detalhes.switch.editing_bookmark].atributo = atributo
	_detalhes.switch.table [_detalhes.switch.editing_bookmark].sub_atributo = sub_atributo
	
	_detalhes.switch.editing_bookmark = nil
	
	_detalhes.switch:Update()
end

--[[global]] function DetailsChangeDisplayFromBookmark (number, instance)
	if (not instance) then
		local lower = _detalhes:GetLowerInstanceNumber()
		if (lower) then
			instance = _detalhes:GetInstance (lower)
		end
		if (not instance) then
			return _detalhes:Msg (Loc ["STRING_WINDOW_NOTFOUND"])
		end
	end
	
	local bookmark = _detalhes.switch.table [number]

	if (bookmark) then
		_detalhes.switch.current_instancia = instance
		
		if (not bookmark.atributo) then
			return _detalhes:Msg (string.format (Loc ["STRING_SWITCH_SELECTMSG"], number))
		end
		
		_detalhes:FastSwitch (nil, bookmark, number)
		
		--return _detalhes:FastSwitch (paramTable)
	end
		
end

function _detalhes:FastSwitch (button, bookmark, bookmark_number, select_new)
	if (select_new or not bookmark.atributo) then
		GameCooltip:Reset()
		GameCooltip:SetType (3)
		GameCooltip:SetFixedParameter (_detalhes.switch.current_instancia)

		GameCooltip:SetOwner (button)
		
		_detalhes.switch.editing_bookmark = bookmark_number
		
		_detalhes:MontaAtributosOption (_detalhes.switch.current_instancia, _detalhes.switch.Config)
		GameCooltip:SetColor (1, {.1, .1, .1, .3})
		GameCooltip:SetColor (2, {.1, .1, .1, .3})
		GameCooltip:SetOption ("HeightAnchorMod", -7)
		GameCooltip:SetBackdrop (1, _detalhes.tooltip_backdrop, backgroundColor, _detalhes.tooltip_border_color)
		GameCooltip:SetBackdrop (2, _detalhes.tooltip_backdrop, backgroundColor, _detalhes.tooltip_border_color)
		return GameCooltip:ShowCooltip()
	end

	if (IsShiftKeyDown()) then
		--> get a closed window or created a new one.
		local instance = _detalhes:CreateInstance()
		
		if (not instance) then
			_detalhes.switch.CloseMe()
			return _detalhes:Msg (Loc ["STRING_WINDOW_NOTFOUND"])
		end
		
		_detalhes.switch.current_instancia = instance
	end

	if (_detalhes.switch.current_instancia.modo == _detalhes._detalhes_props["MODO_ALONE"]) then
		_detalhes.switch.current_instancia:AlteraModo (_detalhes.switch.current_instancia, 2)
	elseif (_detalhes.switch.current_instancia.modo == _detalhes._detalhes_props["MODO_RAID"]) then
		_detalhes.switch.current_instancia:AlteraModo (_detalhes.switch.current_instancia, 2)
	end
	
	_detalhes.switch.current_instancia:TrocaTabela (_detalhes.switch.current_instancia, true, bookmark.atributo, bookmark.sub_atributo)
	_detalhes.switch.CloseMe()
end

-- nao tem suporte a solo mode tank mode
-- nao tem suporte a custom até agora, não sei como vai ficar

function _detalhes.switch:InitSwitch()
	local instancia = _detalhes.tabela_instancias [1]
	_detalhes.switch:ShowMe (instancia)
	_detalhes.switch:CloseMe()
	--return _detalhes.switch:Update()
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

local default_coords = {0, 1, 0, 1}
local unknown_coords = {157/512, 206/512, 39/512,  89/512}
local vertex_color_default = {1, 1, 1}
local vertex_color_unknown = {1, 1, 1}

function _detalhes.switch:Update()

	local slots = _detalhes.switch.slots
	local x = 10
	local y = 5
	local jump = false
	local hide_the_rest
	
	local offset = FauxScrollFrame_GetOffset (DetailsSwitchPanelScroll)
	local slots_shown = _detalhes.switch.slots
	
	for i = 1, slots_shown do

		--bookmark index
		local index = (offset * _detalhes.switch.vertical_amt) + i
	
		--button
		local button = _detalhes.switch.buttons [i]
		if (not button) then
			button = _detalhes.switch:NewSwitchButton (_detalhes.switch.frame, i, x, y, jump)
			button:SetFrameLevel (_detalhes.switch.frame:GetFrameLevel()+2)
			_detalhes.switch.showing = _detalhes.switch.showing + 1
		end

		local options = _detalhes.switch.table [index]
		if (not options and index <= 40) then 
			options = {}
			_detalhes.switch.table [index] = options
		end
		
		button.bookmark_number = index --button on icon
		button.button2.bookmark_number = index --button on text
		
		local icone
		local coords
		local name
		local vcolor
		
		if (options and options.sub_atributo) then
			if (options.atributo == 5) then --> custom
				local CustomObject = _detalhes.custom [options.sub_atributo]
				if (not CustomObject) then --> ele já foi deletado
					--icone = "Interface\\ICONS\\Ability_DualWield"
					icone = [[Interface\AddOns\Details\images\icons]]
					coords = unknown_coords
					name = Loc ["STRING_SWITCH_CLICKME"]
					vcolor = vertex_color_unknown
				else
					icone = CustomObject.icon
					coords = default_coords
					name = CustomObject.name
					vcolor = vertex_color_default
				end
			else
				icone = _detalhes.sub_atributos [options.atributo].icones [options.sub_atributo] [1]
				coords = _detalhes.sub_atributos [options.atributo].icones [options.sub_atributo] [2]
				name = _detalhes.sub_atributos [options.atributo].lista [options.sub_atributo]
				vcolor = vertex_color_default
			end
		else
			icone = [[Interface\AddOns\Details\images\icons]]
			icone = [[Interface\Buttons\UI-AttributeButton-Encourage-Up]]
			coords = unknown_coords
			coords = {0, 1, 0, 1}
			name = Loc ["STRING_SWITCH_CLICKME"]
			vcolor = vertex_color_unknown
		end

		button:Show()
		button.button2:Show()
		button.fundo:Show()
		
		button.button2.texto:SetText (name)
		
		button.textureNormal:SetTexture (icone, true)
		button.textureNormal:SetTexCoord (_unpack (coords))
		button.textureNormal:SetVertexColor (_unpack (vcolor))
		button.texturePushed:SetTexture (icone, true)
		button.texturePushed:SetTexCoord (_unpack (coords))
		button.texturePushed:SetVertexColor (_unpack (vcolor))
		button.textureH:SetTexture (icone, true)
		button.textureH:SetVertexColor (_unpack (vcolor))
		button.textureH:SetTexCoord (_unpack (coords))
		button:ChangeIcon (button.textureNormal, button.texturePushed, nil, button.textureH)

		if (name == Loc ["STRING_SWITCH_CLICKME"]) then
			--button.button2.texto:SetTextColor (.3, .3, .3, 1)
			button:SetAlpha (0.3)
		else
			--button.button2.texto:SetTextColor (.8, .8, .8, 1)
			button:SetAlpha (1)
		end
		
		if (jump) then 
			x = x - 125
			y = y + _detalhes.switch.button_height
			jump = false
		else
			x = x + 125
			jump = true
		end
		
	end
	
	FauxScrollFrame_Update (DetailsSwitchPanelScroll, ceil (40 / _detalhes.switch.vertical_amt) , _detalhes.switch.horizontal_amt, 20)
end

local scroll = CreateFrame ("scrollframe", "DetailsSwitchPanelScroll", DetailsSwitchPanel, "FauxScrollFrameTemplate")
scroll:SetAllPoints()
scroll:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (self, offset, 20, _detalhes.switch.Update) end) --altura
scroll.ScrollBar:Hide()
scroll.ScrollBar.ScrollUpButton:Hide()
scroll.ScrollBar.ScrollDownButton:Hide()

function _detalhes.switch:Resize (precisa_mostrar)

	local x = 7
	local y = 5
	local y_increment = 20
	
	local window_width, window_height = _detalhes.switch.current_instancia:GetSize()
	
	local horizontal_amt = floor (math.max (window_width / 100, 2))
	local vertical_amt = floor ((window_height - y) / y_increment)
	
	local total_amt = horizontal_amt * vertical_amt
	if (precisa_mostrar > total_amt) then
		--vertical_amt = floor ((window_height - y) / 15)
		--y_increment = 15
	end
	
	_detalhes.switch.y_increment = y_increment
	
	local size = window_width / horizontal_amt
	local frame = _detalhes.switch.frame
	
	for index, button in ipairs (_detalhes.switch.buttons) do
		button:Hide()
	end
	
	_detalhes.switch.vertical_amt = vertical_amt
	_detalhes.switch.horizontal_amt = horizontal_amt
	
	local i = 1
	for vertical = 1, vertical_amt do
		x = 7
		for horizontal = 1, horizontal_amt do
			local button = _detalhes.switch.buttons [i]
			
			local options = _detalhes.switch.table [i]
			if (not options) then 
				options = {atributo = nil, sub_atributo = nil}
				_detalhes.switch.table [i] = options
			end
			
			if (not button) then
				button = _detalhes.switch:NewSwitchButton (frame, i, x, y)
				button:SetFrameLevel (frame:GetFrameLevel()+2)
				_detalhes.switch.showing = _detalhes.switch.showing + 1
			end
			
			button:SetPoint ("topleft", frame, "topleft", x, -y)
			button.textureNormal:SetPoint ("topleft", frame, "topleft", x, -y)
			button.texturePushed:SetPoint ("topleft", frame, "topleft", x, -y)
			button.textureH:SetPoint ("topleft", frame, "topleft", x, -y)	
			button.button2.texto:SetSize (size - 30, 12)
			button.button2:SetPoint ("bottomright", button, "bottomright", size - 30, 0)
			button.line:SetWidth (size - 15)
			button.line2:SetWidth (size - 15)
			
			button:Show()
			
			i = i + 1
			x = x + size
			if (i > 40) then
				break
			end
		end
		y = y + y_increment
	end
	
	_detalhes.switch.slots = i-1
	
end

function _detalhes.switch:Resize2()

	local x = 7
	local y = 5
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
			y = y + _detalhes.switch.button_height
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

local onenter = function (self)
	if (not _detalhes.switch.table [self.id].atributo) then
		GameCooltip:Reset()
		_detalhes:CooltipPreset (1)
		GameCooltip:AddLine ("add bookmark")
		GameCooltip:AddIcon ([[Interface\Glues\CharacterSelect\Glues-AddOn-Icons]], 1, 1, 16, 16, 0.75, 1, 0, 1, {0, 1, 0})

		GameCooltip:SetOwner (self)
		GameCooltip:SetType ("tooltip")
		
		GameCooltip:SetOption ("TextSize", 10)
		GameCooltip:SetOption ("ButtonsYMod", 0)
		GameCooltip:SetOption ("YSpacingMod", 0)
		GameCooltip:SetOption ("IgnoreButtonAutoHeight", false)
		
		GameCooltip:SetBackdrop (1, _detalhes.tooltip_backdrop, backgroundColor, _detalhes.tooltip_border_color)
		GameCooltip:SetBackdrop (2, _detalhes.tooltip_backdrop, backgroundColor, _detalhes.tooltip_border_color)
		
		GameCooltip:Show()
	else
		GameCooltip:Hide()
	end
	
	self.texto:SetTextColor (1, 1, 1, 1)
	self.border:SetBlendMode ("ADD")
end

local onleave = function (self)
	if (GameCooltip:IsTooltip()) then
		GameCooltip:Hide()
	end
	self.texto:SetTextColor (.8, .8, .8, 1)
	self.border:SetBlendMode ("BLEND")
end

local oniconenter = function (self)

	if (GameCooltip:IsMenu()) then
		return
	end

	GameCooltip:Reset()
	_detalhes:CooltipPreset (1)
	GameCooltip:AddLine ("select bookmark")
	GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, 14, 0.0019531, 0.1484375, 0.6269531, 0.8222656)
	
	GameCooltip:SetOwner (self)
	GameCooltip:SetType ("tooltip")
	
	GameCooltip:SetOption ("TextSize", 10)
	GameCooltip:SetOption ("ButtonsYMod", 0)
	GameCooltip:SetOption ("YSpacingMod", 0)
	GameCooltip:SetOption ("IgnoreButtonAutoHeight", false)
	
	GameCooltip:SetBackdrop (1, _detalhes.tooltip_backdrop, backgroundColor, _detalhes.tooltip_border_color)
	
	GameCooltip:Show()
end

local oniconleave = function (self)
	if (GameCooltip:IsTooltip()) then
		GameCooltip:Hide()
	end
end

local left_box_on_click = function (self, button)
	if (button == "RightButton") then
		--select another bookmark
		_detalhes:FastSwitch (self, bookmark, self.bookmark_number, true)
	else
		--change the display
		local bookmark = _detalhes.switch.table [self.bookmark_number]
		if (bookmark.atributo) then
			_detalhes:FastSwitch (self, bookmark, self.bookmark_number)
		else
			--invalid bookmark, select another bookmark
			_detalhes:FastSwitch (self, bookmark, self.bookmark_number, true)
		end
	end
end

local right_box_on_click = function (self, button)
	if (button == "RightButton") then
		--close the bookmark menu
		_detalhes.switch:CloseMe()
	else
		--change the display
		local bookmark = _detalhes.switch.table [self.bookmark_number]
		if (bookmark.atributo) then
			_detalhes:FastSwitch (self, bookmark, self.bookmark_number)
		else
			--invalid bookmark, select another bookmark
			_detalhes:FastSwitch (self, bookmark, self.bookmark_number, true)
		end
	end
end

local change_icon = function (self, icon1, icon2, icon3, icon4)
	self:SetNormalTexture (icon1)
	self:SetPushedTexture (icon2)
	self:SetDisabledTexture (icon3)
	self:SetHighlightTexture (icon4, "ADD")
end
	
function _detalhes.switch:NewSwitchButton (frame, index, x, y, rightButton)

	local paramTable = {
			["instancia"] = _detalhes.switch.current_instancia, 
			["button"] = index, 
			["atributo"] = nil, 
			["sub_atributo"] = nil
		}

	--botao dentro da caixa
	local button = CreateFrame ("button", "DetailsSwitchPanelButton_1_"..index, frame)
	button:SetSize (15, 15) 
	button:SetPoint ("topleft", frame, "topleft", x, -y)
	button:SetScript ("OnMouseDown", left_box_on_click)
	button:SetScript ("OnEnter", oniconenter)
	button:SetScript ("OnLeave", oniconleave)
	button.ChangeIcon = change_icon
	button.id = index
	
	--borda
	button.fundo = button:CreateTexture (nil, "overlay")
	button.fundo:SetTexture ("Interface\\SPELLBOOK\\Spellbook-Parts")
	button.fundo:SetTexCoord (0.00390625, 0.27734375, 0.44140625,0.69531250)
	button.fundo:SetWidth (26)
	button.fundo:SetHeight (24)
	button.fundo:SetPoint ("topleft", button, "topleft", -5, 5)
	
	--fundo marrom
	local fundo_x = -3
	local fundo_y = -5
	button.line = button:CreateTexture (nil, "background")
	button.line:SetTexture ("Interface\\SPELLBOOK\\Spellbook-Parts")
	button.line:SetTexCoord (0.31250000, 0.96484375, 0.37109375, 0.52343750)
	button.line:SetWidth (85)
	button.line:SetPoint ("topleft", button, "topright", fundo_x, 0)
	button.line:SetPoint ("bottomleft", button, "bottomright", fundo_x, fundo_y)
	
	--fundo marrom 2
	button.line2 = button:CreateTexture (nil, "background")
	button.line2:SetTexture ("Interface\\SPELLBOOK\\Spellbook-Parts")
	button.line2:SetTexCoord (0.31250000, 0.96484375, 0.37109375, 0.52343750)
	button.line2:SetWidth (85)
	button.line2:SetPoint ("topleft", button, "topright", fundo_x, 0)
	button.line2:SetPoint ("bottomleft", button, "bottomright", fundo_x, fundo_y)
	
	--botao do fundo marrom
	local button2 = CreateFrame ("button", "DetailsSwitchPanelButton_2_"..index, button)
	button2:SetSize (1, 1)
	button2:SetPoint ("topleft", button, "topright", 1, 0)
	button2:SetPoint ("bottomright", button, "bottomright", 90, 0)
	button2:SetScript ("OnMouseDown", right_box_on_click)
	button2:SetScript ("OnEnter", onenter)
	button2:SetScript ("OnLeave", onleave)
	button2.id = index
	
	button.button2 = button2
	
	--icone
	button.textureNormal = button:CreateTexture (nil, "background")
	button.textureNormal:SetAllPoints (button)
	
	--icone pushed
	button.texturePushed = button:CreateTexture (nil, "background")
	button.texturePushed:SetAllPoints (button)
	
	--highlight
	button.textureH = button:CreateTexture (nil, "background")
	button.textureH:SetAllPoints (button)
	
	--texto do atributo
	gump:NewLabel (button2, button2, nil, "texto", "", "GameFontHighlightSmall")
	button2.texto:SetPoint ("left", button, "right", 5, -1)
	button2.texto:SetNonSpaceWrap (true)
	button2.texto:SetTextColor (.8, .8, .8, 1)
	
	button2.button1_icon = button.textureNormal
	button2.button1_icon2 = button.texturePushed
	button2.button1_icon3 = button.textureH
	button2.border = button.fundo
	
	button2.MouseOnEnterHook = onenter
	button2.MouseOnLeaveHook = onleave
	
	_detalhes.switch.buttons [index] = button
	
	return button
end
