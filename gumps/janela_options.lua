--[[ options panel file --]]

local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local LDB = LibStub ("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub ("LibDBIcon-1.0", true)

local g =	_detalhes.gump
local _
local preset_version = 2

function _detalhes:OpenOptionsWindow (instance)

	GameCooltip:Close()
	local window = _G.DetailsOptionsWindow

	if (not window) then
	
-- Details Overall -------------------------------------------------------------------------------------------------------------------------------------------------
	
		local SLIDER_WIDTH = 130
		local DROPDOWN_WIDTH = 120
		local COLOR_BUTTON_WIDTH = 55
		
	
		-- Most of details widgets have the same 6 first parameters: parent, container, global name, parent key, width, height
	
		window = g:NewPanel (UIParent, _, "DetailsOptionsWindow", _, 717, 434)
		window.instance = instance
		tinsert (UISpecialFrames, "DetailsOptionsWindow")
		window:SetPoint ("center", UIParent, "Center")
		window.locked = false
		window.close_with_right = true
		window.backdrop = nil
		
		local background = g:NewImage (window, _, "$parentBackground", "background", 717, 434, [[Interface\AddOns\Details\images\options_window]])
		background:SetPoint (0, 0)
		background:SetDrawLayer ("border")
		background:SetTexCoord (0, 0.699707, 0, 0.423828125)

		local bigdog = g:NewImage (window, _, "$parentBackgroundBigDog", "backgroundBigDog", 180, 200, [[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bigdog:SetPoint ("bottomright", window, "bottomright", -8, 36)
		bigdog:SetAlpha (.1)
		bigdog:SetTexCoord (1, 0, 0, 1)
		
		local window_icon = g:NewImage (window, _, "$parentWindowIcon", "windowicon", 58, 58, [[Interface\AddOns\Details\images\options_window]])
		window_icon:SetPoint (17, -17)
		window_icon:SetDrawLayer ("background")
		window_icon:SetTexCoord (0, 0.054199, 0.591308, 0.646972) --605 663

		--> title
		local title = g:NewLabel (window, nil, nil, "title", Loc ["STRING_OPTIONS_WINDOW"], "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
		title:SetPoint ("center", window, "center")
		title:SetPoint ("top", window, "top", 0, -28)
		
		--> edit what label
		local editing = g:NewLabel (window, nil, nil, "editing", Loc ["STRING_OPTIONS_GENERAL"], "QuestFont_Large", 20, "white")
		--editing:SetPoint ("topleft", window, "topleft", 90, -57)
		editing:SetPoint ("topright", window, "topright", -30, -62)
		editing.options = {Loc ["STRING_OPTIONS_GENERAL"], Loc ["STRING_OPTIONS_APPEARANCE"], Loc ["STRING_OPTIONS_PERFORMANCE"], Loc ["STRING_OPTIONS_PLUGINS"]}
		editing.shadow = 2
		
		--> edit anchors
		editing.apoio_icone_esquerdo = window:CreateTexture (nil, "ARTWORK")
		editing.apoio_icone_direito = window:CreateTexture (nil, "ARTWORK")
		editing.apoio_icone_esquerdo:SetTexture ("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
		editing.apoio_icone_direito:SetTexture ("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
		
		local apoio_altura = 13/256
		editing.apoio_icone_esquerdo:SetTexCoord (0, 1, 0, apoio_altura)
		editing.apoio_icone_direito:SetTexCoord (0, 1, apoio_altura+(1/256), apoio_altura+apoio_altura)
		
		editing.apoio_icone_esquerdo:SetPoint ("bottomright", editing.widget, "bottomleft",  42, 0)
		editing.apoio_icone_direito:SetPoint ("bottomleft", editing.widget, "bottomright",  -8, 0)
		
		editing.apoio_icone_esquerdo:SetWidth (64)
		editing.apoio_icone_esquerdo:SetHeight (13)
		editing.apoio_icone_direito:SetWidth (64)
		editing.apoio_icone_direito:SetHeight (13)		
		
		--> close button
		local close_button = CreateFrame ("button", nil, window.widget, "UIPanelCloseButton")
		close_button:SetWidth (32)
		close_button:SetHeight (32)
		close_button:SetPoint ("TOPRIGHT", window.widget, "TOPRIGHT", -3, -19)
		close_button:SetText ("X")
		close_button:SetFrameLevel (close_button:GetFrameLevel()+2)
		
		--> desc text (on the right)
		local info_text = g:NewLabel (window, nil, nil, "infotext", "", "GameFontNormal", 12)
		info_text:SetPoint ("topleft", window, "topleft", 470, -97)
		info_text.width = 200
		info_text.height = 280
		info_text.align = "<"
		info_text.valign = "^"
		info_text.active = false
		
		--> select instance dropbox
		local onSelectInstance = function (_, _, instance)
		
			local this_instance = _detalhes.tabela_instancias [instance]
			
			if (not this_instance.iniciada) then
				this_instance:RestauraJanela (instance)
				
			elseif (not this_instance:IsEnabled()) then
				_detalhes.CriarInstancia (_, _, this_instance.meu_id)
				
			end
			
			_detalhes:OpenOptionsWindow (this_instance)
		end

		local buildInstanceMenu = function()
			local InstanceList = {}
			for index = 1, #_detalhes.tabela_instancias, 1 do 
				local _this_instance = _detalhes.tabela_instancias [index]

				--> pegar o que ela ta mostrando
				local atributo = _this_instance.atributo
				local sub_atributo = _this_instance.sub_atributo
				
				if (atributo == 5) then --> custom
					local CustomObject = _detalhes.custom [sub_atributo]
					InstanceList [#InstanceList+1] = {value = index, label = _detalhes.atributos.lista [atributo] .. " - " .. CustomObject.name, onclick = onSelectInstance, icon = CustomObject.icon}
					
				else
					local modo = _this_instance.modo
					
					if (modo == 1) then --alone
						atributo = _detalhes.SoloTables.Mode or 1
						local SoloInfo = _detalhes.SoloTables.Menu [atributo]
						if (SoloInfo) then
							InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " " .. SoloInfo [1], onclick = onSelectInstance, icon = SoloInfo [2]}
						else
							InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " unknown", onclick = onSelectInstance, icon = ""}
						end
						
					elseif (modo == 4) then --raid
						atributo = _detalhes.RaidTables.Mode or 1
						local RaidInfo = _detalhes.RaidTables.Menu [atributo]
						if (RaidInfo) then
							InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " " .. RaidInfo [1], onclick = onSelectInstance, icon = RaidInfo [2]}
						else
							InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " unknown", onclick = onSelectInstance, icon = ""}
						end
					else
						InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " " .. _detalhes.atributos.lista [atributo] .. " - " .. _detalhes.sub_atributos [atributo].lista [sub_atributo], onclick = onSelectInstance, icon = _detalhes.sub_atributos [atributo].icones[sub_atributo] [1], texcoord = _detalhes.sub_atributos [atributo].icones[sub_atributo] [2]}
						
					end
				end
			end
			return InstanceList
		end

		local instances = g:NewDropDown (window, _, "$parentInstanceSelectDropdown", "instanceDropdown", 200, 18, buildInstanceMenu, nil)	
		instances:SetPoint ("bottomright", window, "bottomright", -17, 09)
		
		local instances_string = g:NewLabel (window, nil, nil, "instancetext", Loc ["STRING_OPTIONS_EDITINSTANCE"], "GameFontNormal", 12)
		instances_string:SetPoint ("right", instances, "left", -2)
		
		instances:Hide()
		instances_string:Hide()
		
		--> left panel buttons
		local select_options = function (options_type)
		
			window:hide_options (1)
			window:hide_options (2)
			window:hide_options (3)
			window:hide_options (4)
			
			window:un_hide_options (options_type)
			
			editing.text = editing.options [options_type]
			
			if (options_type == 1 or options_type == 2) then
				instances:Show()
				instances_string:Show()
			else
				instances:Hide()
				instances_string:Hide()			
			end
			
			-- ~altura
			
			if (options_type == 1) then
				window.options [1][1].slider:SetMinMaxValues (0, 200)
			elseif (options_type == 2) then
				window.options [2][1].slider:SetMinMaxValues (0, 1300)
				window.options [2][1].slider.scrollMax = 1300
			elseif (options_type == 3) then
				window.options [3][1].slider:SetMinMaxValues (0, 180)
			elseif (options_type == 4) then
				window.options [4][1].slider:SetMinMaxValues (0, 320)
				info_text.text = ""
			end
			
		end

		local mouse_over_texture = g:NewImage (window, _, "$parentButtonMouseOver", "buttonMouseOver", 156, 22, [[Interface\AddOns\Details\images\options_window]])
		mouse_over_texture:SetTexCoord (0.006347, 0.170410, 0.528808, 0.563964)
		mouse_over_texture:SetWidth (169)
		mouse_over_texture:SetHeight (37)
		mouse_over_texture:Hide()
		mouse_over_texture:SetBlendMode ("ADD")
		
		local g_settings_texture = {Normal = {0.006347, 0.150878, 0.406738, 0.436035}, Highlight = {0.006347, 0.150878, 0.437011, 0.467285}, Pushed = {0.006347, 0.150878, 0.469238, 0.499511}}
		local g_settings = g:NewButton (window, _, "$parentGeneralSettingsButton", "g_settings", 150, 18, select_options, 0x1, nil, nil, Loc ["STRING_OPTIONS_GENERAL"])
		g_settings:SetPoint ("topleft", window, "topleft", 35, -140)
		g_settings:SetHook ("OnEnter", function() 
			mouse_over_texture:SetPoint ("topleft", g_settings, "topleft", -10, 8)
			mouse_over_texture:Show()
		end)
		g_settings:SetHook ("OnLeave", function() 
			mouse_over_texture:Hide()
		end)
		--g_settings:InstallCustomTexture ()
		
		local g_appearance = g:NewButton (window, _, "$parentAppearanceButton", "g_appearance", 150, 18, select_options, 0x2, nil, nil, Loc ["STRING_OPTIONS_APPEARANCE"])
		g_appearance:SetPoint ("topleft", window, "topleft", 35, -200)
		g_appearance:SetHook ("OnEnter", function() 
			mouse_over_texture:SetPoint ("topleft", g_appearance, "topleft", -10, 8)
			mouse_over_texture:Show()
		end)		
		g_appearance:SetHook ("OnLeave", function() 
			mouse_over_texture:Hide()
		end)		
		--g_appearance:InstallCustomTexture ()
		
		local g_performance = g:NewButton (window, _, "$parentPerformanceButton", "g_appearance", 150, 18, select_options, 0x3, nil, nil, Loc ["STRING_OPTIONS_PERFORMANCE"])
		g_performance:SetPoint ("topleft", window, "topleft", 35, -260)
		g_performance:SetHook ("OnEnter", function() 
			mouse_over_texture:SetPoint ("topleft", g_performance, "topleft", -10, 8)
			mouse_over_texture:Show()
		end)		
		g_performance:SetHook ("OnLeave", function() 
			mouse_over_texture:Hide()
		end)		
		--g_performance:InstallCustomTexture ()
		
		local g_plugin = g:NewButton (window, _, "$parentPluginButton", "g_plugin", 150, 18, select_options, 0x4, nil, nil, Loc ["STRING_OPTIONS_PLUGINS"])
		g_plugin:SetPoint ("topleft", window, "topleft", 35, -320)
		g_plugin:SetHook ("OnEnter", function() 
			mouse_over_texture:SetPoint ("topleft", g_plugin, "topleft", -10, 8)
			mouse_over_texture:Show()
		end)		
		g_plugin:SetHook ("OnLeave", function() 
			mouse_over_texture:Hide()
		end)
		
		window.options = {
			[1] = {},
			[2] = {},
			[3] = {},
			[4] = {}
		} --> vai armazenar os frames das opções
		
		function window:create_box (n)
			local container_window = CreateFrame ("ScrollFrame", "Details_Options_ContainerScroll" .. n, window.widget)
			local container_slave = CreateFrame ("Frame", "DetailsOptionsWindow" .. n, container_window)

			container_slave:SetScript ("OnMouseDown", function()
				if (not window.widget.isMoving) then
					window.widget:StartMoving()
					window.widget.isMoving = true
				end
			end)
			container_slave:SetScript ("OnMouseUp", function()
				if (window.widget.isMoving) then
					window.widget:StopMovingOrSizing()
					window.widget.isMoving = false
				end
			end)
			
			container_window:SetBackdrop({
				edgeFile = "Interface\\DialogFrame\\UI-DialogBox-gold-Border", tile = true, tileSize = 16, edgeSize = 5,
				insets = {left = 1, right = 1, top = 0, bottom = 1},})		
			container_window:SetBackdropBorderColor (0, 0, 0, 0)
			container_window:SetBackdropColor (0, 0, 0, 0)
			
			container_slave:SetBackdrop({
				bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
				insets = {left = 1, right = 1, top = 0, bottom = 1},})		
			container_slave:SetBackdropColor (0, 0, 0, 0)

			container_slave:SetAllPoints (container_window)
			container_slave:SetWidth (480)
			container_slave:SetHeight (700)
			container_slave:EnableMouse (true)
			container_slave:SetResizable (false)
			container_slave:SetMovable (true)
			
			container_window:SetWidth (480)
			container_window:SetHeight (311)
			container_window:SetScrollChild (container_slave)
			container_window:SetPoint ("TOPLEFT", window.widget, "TOPLEFT", 198, -88)

			g:NewScrollBar (container_window, container_slave, 8, -10)
			container_window.slider:Altura (292)
			container_window.slider:cimaPoint (0, 1)
			container_window.slider:baixoPoint (0, -3)
			container_window.wheel_jump = 80

			container_window.ultimo = 0
			container_window.gump = container_slave
			container_window.container_slave = container_slave
			
			return container_window
		end
		
		table.insert (window.options [1], window:create_box (1))
		table.insert (window.options [2], window:create_box (2))
		table.insert (window.options [3], window:create_box (3))
		table.insert (window.options [4], window:create_box (4))

		function window:hide_options (options)
			for _, widget in ipairs (window.options [options]) do 
				widget:Hide()
			end
		end

		function window:un_hide_options (options)
			for _, widget in ipairs (window.options [options]) do 
				widget:Show()
			end
		end
		
		local background_on_enter = function (self)
			if (self.background_frame) then
				self = self.background_frame
			end
			
			if (self.parent and self.parent.info) then
				info_text.active = true
				info_text.text = self.parent.info
			end
		end
		local background_on_leave = function (self)
			if (self.background_frame) then
				self = self.background_frame
			end
			--self:SetBackdropColor (0, 0, 0, 0)
			if (info_text.active) then
				info_text.active = false
				--info_text.text = ""
			end
		end
		
		function window:create_line_background (frameX, label, parent)
			local f = CreateFrame ("frame", nil, frameX)
			f:SetPoint ("left", label.widget or label, "left", -2, 0)
			f:SetSize (260, 16)
			f:SetScript ("OnEnter", background_on_enter)
			f:SetScript ("OnLeave", background_on_leave)
			f:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}})		
			f:SetBackdropColor (0, 0, 0, 0)
			f.parent = parent
			if (parent.widget) then
				parent.widget.background_frame = f
			else
				parent.background_frame = f
			end
		end
		
		window:hide_options (2)
		window:hide_options (3)
		window:hide_options (4)
		
		--> general settings:
		local frame1 = window.options [1][1].gump
		
		--> nickname avatar
		local onPressEnter = function (_, _, text)
			local accepted, errortext = _detalhes:SetNickname (text)
			if (not accepted) then
				_detalhes:Msg (errortext)
			end
			--> we call again here, because if not accepted the box return the previous value and if successful accepted, update the value for formated string.
			frame1.nicknameEntry.text = _detalhes:GetNickname (UnitGUID ("player"), UnitName ("player"), true)
		end
		
		local titulo_persona = g:NewLabel (frame1, _, "$parentTituloPersona", "tituloPersonaLabel", Loc ["STRING_OPTIONS_SOCIAL"], "GameFontNormal", 16)
		titulo_persona:SetPoint (10, -10)
		local titulo_persona_desc = g:NewLabel (frame1, _, "$parentTituloPersona2", "tituloPersona2Label", Loc ["STRING_OPTIONS_SOCIAL_DESC"], "GameFontNormal", 9, "white")
		titulo_persona_desc.width = 250
		titulo_persona_desc:SetPoint (10, -30)
		
		--> persona
		g:NewLabel (frame1, _, "$parentNickNameLabel", "nicknameLabel", Loc ["STRING_OPTIONS_NICKNAME"])
		frame1.nicknameLabel:SetPoint (10, -70)
		
		g:NewTextEntry (frame1, _, "$parentNicknameEntry", "nicknameEntry", SLIDER_WIDTH, 20, onPressEnter)
		frame1.nicknameEntry:SetPoint ("left", frame1.nicknameLabel, "right", 2, 0)
		frame1.nicknameEntry.info = Loc ["STRING_OPTIONS_NICKNAME_DESC"]
		
		window:create_line_background (frame1, frame1.nicknameLabel, frame1.nicknameEntry)
		frame1.nicknameEntry:SetHook ("OnEnter", background_on_enter)
		frame1.nicknameEntry:SetHook ("OnLeave", background_on_leave)
		
		local avatarcallback = function (textureAvatar, textureAvatarTexCoord, textureBackground, textureBackgroundTexCoord, textureBackgroundColor)
			_detalhes:SetNicknameBackground (textureBackground, textureBackgroundTexCoord, textureBackgroundColor, true)
			_detalhes:SetNicknameAvatar (textureAvatar, textureAvatarTexCoord)
			_G.AvatarPickFrame.callback = nil
		end
		
		local openAtavarPickFrame = function()
			_G.AvatarPickFrame.callback = avatarcallback
			_G.AvatarPickFrame:Show()
		end
		
		g:NewButton (frame1, _, "$parentAvatarFrame", "chooseAvatarButton", frame1.nicknameLabel:GetStringWidth() + SLIDER_WIDTH + 2, 14, openAtavarPickFrame, nil, nil, nil, Loc ["STRING_OPTIONS_AVATAR"])
		frame1.chooseAvatarButton:InstallCustomTexture()
		frame1.chooseAvatarButton:SetPoint (11, -90)
		frame1.chooseAvatarButton.info = Loc ["STRING_OPTIONS_AVATAR_DESC"]
		
		window:create_line_background (frame1, frame1.chooseAvatarButton, frame1.chooseAvatarButton)
		frame1.chooseAvatarButton:SetHook ("OnEnter", background_on_enter)
		frame1.chooseAvatarButton:SetHook ("OnLeave", background_on_leave)
		
		--  realm name --------------------------------------------------------------------------------------------------------------------------------------------

		g:NewLabel (frame1, _, "$parentRealmNameLabel", "realmNameLabel", Loc ["STRING_OPTIONS_REALMNAME"])
		frame1.realmNameLabel:SetPoint (10, -110)
	
		g:NewSwitch (frame1, _, "$parentRealmNameSlider", "realmNameSlider", 60, 20, _, _, _detalhes.remove_realm_from_name)
		frame1.realmNameSlider:SetPoint ("left", frame1.realmNameLabel, "right", 2)
		--frame1.realmNameSlider.tooltip = Loc ["STRING_OPTIONS_SWITCHINFO"]
		frame1.realmNameSlider.info = Loc ["STRING_OPTIONS_REALMNAME_DESC"]
		frame1.realmNameSlider.OnSwitch = function (self, _, value)
			_detalhes.remove_realm_from_name = value
		end
		
		window:create_line_background (frame1, frame1.realmNameLabel, frame1.realmNameSlider)
		frame1.realmNameSlider:SetHook ("OnEnter", background_on_enter)
		frame1.realmNameSlider:SetHook ("OnLeave", background_on_leave)		
		
	------- Max Segments
		
		local titulo_display = g:NewLabel (frame1, _, "$parentTituloDisplay", "tituloDisplayLabel", "Display", "GameFontNormal", 16) --> localize-me
		titulo_display:SetPoint (10, -150)
		local titulo_display_desc = g:NewLabel (frame1, _, "$parentTituloDisplay2", "tituloDisplay2Label", "Preferencial adjustments of instances (windows).", "GameFontNormal", 9, "white") --> localize-me
		titulo_display_desc.width = 250
		titulo_display_desc:SetPoint (10, -170)
		
		g:NewLabel (frame1, _, "$parentSliderLabel", "segmentsLabel", Loc ["STRING_OPTIONS_MAXSEGMENTS"])
		frame1.segmentsLabel:SetPoint (10, -210)
		--
		g:NewSlider (frame1, _, "$parentSlider", "segmentsSlider", SLIDER_WIDTH, 20, 1, 25, 1, _detalhes.segments_amount)
		frame1.segmentsSlider:SetPoint ("left", frame1.segmentsLabel, "right", 2, 0)
		frame1.segmentsSlider:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.segments_amount = math.floor (amount)
		end)
		frame1.segmentsSlider.info = Loc ["STRING_OPTIONS_MAXSEGMENTS_DESC"]
		
		window:create_line_background (frame1, frame1.segmentsLabel, frame1.segmentsSlider)
		frame1.segmentsSlider:SetHook ("OnEnter", background_on_enter)
		frame1.segmentsSlider:SetHook ("OnLeave", background_on_leave)
		
	--------------- Use Scroll Bar
		g:NewLabel (frame1, _, "$parentUseScrollLabel", "scrollLabel", Loc ["STRING_OPTIONS_SCROLLBAR"])
		frame1.scrollLabel:SetPoint (10, -230)
		--
		g:NewSwitch (frame1, _, "$parentUseScrollSlider", "scrollSlider", 60, 20, _, _, _detalhes.use_scroll)
		frame1.scrollSlider:SetPoint ("left", frame1.scrollLabel, "right", 2, 0)
		frame1.scrollSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.use_scroll = value
			if (not value) then
				for index = 1, #_detalhes.tabela_instancias do
					local instance = _detalhes.tabela_instancias [index]
					if (instance.baseframe) then --fast check if instance already been initialized
						instance:EsconderScrollBar (true, true)
					end
				end
			end
			--hard instances reset
			_detalhes:InstanciaCallFunction (_detalhes.gump.Fade, "in", nil, "barras")
			_detalhes:InstanciaCallFunction (_detalhes.AtualizaSegmentos) -- atualiza o instancia.showing para as novas tabelas criadas
			_detalhes:InstanciaCallFunction (_detalhes.AtualizaSoloMode_AfertReset) -- verifica se precisa zerar as tabela da janela solo mode
			_detalhes:InstanciaCallFunction (_detalhes.ResetaGump) --_detalhes:ResetaGump ("de todas as instancias")
			_detalhes:AtualizaGumpPrincipal (-1, true) --atualiza todas as instancias
		end
		
		frame1.scrollSlider.info = Loc ["STRING_OPTIONS_SCROLLBAR_DESC"]
		window:create_line_background (frame1, frame1.scrollLabel, frame1.scrollSlider)		
		frame1.scrollSlider:SetHook ("OnEnter", background_on_enter)
		frame1.scrollSlider:SetHook ("OnLeave", background_on_leave)
		
	--------------- Max Instances
		g:NewLabel (frame1, _, "$parentLabelMaxInstances", "maxInstancesLabel", Loc ["STRING_OPTIONS_MAXINSTANCES"])
		frame1.maxInstancesLabel:SetPoint (10, -250)
		--
		g:NewSlider (frame1, _, "$parentSliderMaxInstances", "maxInstancesSlider", SLIDER_WIDTH, 20, 12, 30, 1, _detalhes.instances_amount) -- min, max, step, defaultv
		frame1.maxInstancesSlider:SetPoint ("left", frame1.maxInstancesLabel, "right", 2, 0)
		frame1.maxInstancesSlider:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.instances_amount = amount
		end)
		frame1.maxInstancesSlider.info = Loc ["STRING_OPTIONS_MAXINSTANCES_DESC"]
		
		window:create_line_background (frame1, frame1.maxInstancesLabel, frame1.maxInstancesSlider)
		frame1.maxInstancesSlider:SetHook ("OnEnter", background_on_enter)
		frame1.maxInstancesSlider:SetHook ("OnLeave", background_on_leave)
		
	--------------- Frags PVP Mode
		g:NewLabel (frame1, _, "$parentLabelFragsPvP", "fragsPvpLabel", Loc ["STRING_OPTIONS_PVPFRAGS"])
		frame1.fragsPvpLabel:SetPoint (10, -270)
		--
		g:NewSwitch (frame1, _, "$parentFragsPvpSlider", "fragsPvpSlider", 60, 20, _, _, _detalhes.only_pvp_frags)
		frame1.fragsPvpSlider:SetPoint ("left", frame1.fragsPvpLabel, "right", 2, 0)
		frame1.fragsPvpSlider.OnSwitch = function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.only_pvp_frags = amount
		end
		frame1.fragsPvpSlider.info = Loc ["STRING_OPTIONS_PVPFRAGS_DESC"]		
		
		window:create_line_background (frame1, frame1.fragsPvpLabel, frame1.fragsPvpSlider)
		frame1.fragsPvpSlider:SetHook ("OnEnter", background_on_enter)
		frame1.fragsPvpSlider:SetHook ("OnLeave", background_on_leave)
		
	--------------- Time Type
	
		--hide on combat
		g:NewSwitch (frame1, _, "$parentHideOnCombatSlider", "hideOnCombatSlider", 60, 20, _, _, window.instance.hide_in_combat)
		--mini map
		g:NewSwitch (frame1, _, "$parentMinimapSlider", "minimapSlider", 60, 20, _, _, not _detalhes.minimap.hide)
		
		--time type
		g:NewLabel (frame1, _, "$parentTimeTypeLabel", "timetypeLabel", Loc ["STRING_OPTIONS_TIMEMEASURE"])
		frame1.timetypeLabel:SetPoint (10, -290)
		--
		local onSelectTimeType = function (_, _, timetype)
			_detalhes.time_type = timetype
			_detalhes:AtualizaGumpPrincipal (-1, true)
		end
		local timetypeOptions = {
			{value = 1, label = "Activity Time", onclick = onSelectTimeType, icon = "Interface\\Icons\\INV_Misc_PocketWatch_01"}, --, desc = ""
			{value = 2, label = "Effective Time", onclick = onSelectTimeType, icon = "Interface\\Icons\\INV_Misc_Gear_03"} --, desc = ""
		}
		local buildTimeTypeMenu = function()
			return timetypeOptions
		end
		g:NewDropDown (frame1, _, "$parentTTDropdown", "timetypeDropdown", 160, 20, buildTimeTypeMenu, nil) -- func, default
		frame1.timetypeDropdown:SetPoint ("left", frame1.timetypeLabel, "right", 2, 0)		
		frame1.timetypeDropdown:SetFrameStrata ("DIALOG")
		
		frame1.timetypeDropdown.info = Loc ["STRING_OPTIONS_TIMEMEASURE_DESC"]

		window:create_line_background (frame1, frame1.timetypeLabel, frame1.timetypeDropdown)
		frame1.timetypeDropdown:SetHook ("OnEnter", background_on_enter)
		frame1.timetypeDropdown:SetHook ("OnLeave", background_on_leave)

	--------------- Minimap Icon
		g:NewLabel (frame1, _, "$parentMinimapLabel", "minimapLabel", Loc ["STRING_OPTIONS_MINIMAP"])
		frame1.minimapLabel:SetPoint (10, -310)
		--
		frame1.minimapSlider:SetPoint ("left", frame1.minimapLabel, "right", 2, 0)
		frame1.minimapSlider.OnSwitch = function (self, _, value)
			_detalhes.minimap.hide = not value
			
			LDBIcon:Refresh ("Details!", _detalhes.minimap)
			if (_detalhes.minimap.hide) then
				LDBIcon:Hide ("Details!")
			else
				LDBIcon:Show ("Details!")
			end
		end
		
		frame1.minimapSlider.info = Loc ["STRING_OPTIONS_MINIMAP_DESC"]
		
		window:create_line_background (frame1, frame1.minimapLabel, frame1.minimapSlider)
		frame1.minimapSlider:SetHook ("OnEnter", background_on_enter)
		frame1.minimapSlider:SetHook ("OnLeave", background_on_leave)
		
	--------------- hide in combat
		g:NewLabel (frame1, _, "$parentHideOnCombatLabel", "hideOnCombatLabel", Loc ["STRING_OPTIONS_HIDECOMBAT"])
		frame1.hideOnCombatLabel:SetPoint (10, -350)
		
		g:NewLabel (frame1, _, "$parentHideOnCombatAlphaLabel", "hideOnCombatAlphaLabel", Loc ["STRING_OPTIONS_HIDECOMBATALPHA"])
		frame1.hideOnCombatAlphaLabel:SetPoint (10, -370)

		frame1.hideOnCombatSlider:SetPoint ("left", frame1.hideOnCombatLabel, "right", 2, 0)
		frame1.hideOnCombatSlider.OnSwitch = function (self, instance, value)
			instance.hide_in_combat = value
		end
		
		g:NewSlider (frame1, _, "$parentHideOnCombatAlphaSlider", "hideOnCombatAlphaSlider", SLIDER_WIDTH, 20, 0, 100, 1, window.instance.hide_in_combat_alpha) -- min, max, step, defaultv
		frame1.hideOnCombatAlphaSlider:SetPoint ("left", frame1.hideOnCombatAlphaLabel, "right", 2, 0)
		frame1.hideOnCombatAlphaSlider:SetHook ("OnValueChange", function (self, instance, amount) --> slider, fixedValue, sliderValue
			instance.hide_in_combat_alpha = amount
		end)
		
		frame1.hideOnCombatSlider.info = Loc ["STRING_OPTIONS_HIDECOMBAT_DESC"]
		frame1.hideOnCombatAlphaSlider.info = Loc ["STRING_OPTIONS_HIDECOMBATALPHA_DESC"]
		
		window:create_line_background (frame1, frame1.hideOnCombatLabel, frame1.hideOnCombatSlider)
		frame1.hideOnCombatSlider:SetHook ("OnEnter", background_on_enter)
		frame1.hideOnCombatSlider:SetHook ("OnLeave", background_on_leave)
		
		window:create_line_background (frame1, frame1.hideOnCombatAlphaLabel, frame1.hideOnCombatAlphaSlider)
		frame1.hideOnCombatAlphaSlider:SetHook ("OnEnter", background_on_enter)
		frame1.hideOnCombatAlphaSlider:SetHook ("OnLeave", background_on_leave)
		
	--------------- abbreviation type
		g:NewLabel (frame1, _, "$parentDpsAbbreviateLabel", "dpsAbbreviateLabel", Loc ["STRING_OPTIONS_PS_ABBREVIATE"])
		frame1.dpsAbbreviateLabel:SetPoint (10, -410)
		--
		local onSelectTimeAbbreviation = function (_, _, abbreviationtype)
			_detalhes.ps_abbreviation = abbreviationtype
			_detalhes:AtualizaGumpPrincipal (-1, true)
		end
		local abbreviationOptions = {
			{value = 1, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_NONE"], onclick = onSelectTimeAbbreviation, icon = "Interface\\Icons\\Achievement_Guild_Challenge_1"}, --, desc = ""
			{value = 2, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK"], onclick = onSelectTimeAbbreviation, icon = "Interface\\Icons\\Achievement_Guild_Challenge_100"}, --, desc = ""
			{value = 3, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK2"], onclick = onSelectTimeAbbreviation, icon = "Interface\\Icons\\Achievement_Guild_Challenge_10"} --, desc = ""
		}
		local buildAbbreviationMenu = function()
			return abbreviationOptions
		end
		g:NewDropDown (frame1, _, "$parentAbbreviateDropdown", "dpsAbbreviateDropdown", 160, 20, buildAbbreviationMenu, _detalhes.ps_abbreviation) -- func, default
		frame1.dpsAbbreviateDropdown:SetPoint ("left", frame1.dpsAbbreviateLabel, "right", 2, 0)		
		frame1.dpsAbbreviateDropdown:SetFrameStrata ("DIALOG")
		
		frame1.dpsAbbreviateDropdown.info = Loc ["STRING_OPTIONS_PS_ABBREVIATE_DESC"]

		window:create_line_background (frame1, frame1.dpsAbbreviateLabel, frame1.dpsAbbreviateDropdown)
		frame1.dpsAbbreviateDropdown:SetHook ("OnEnter", background_on_enter)
		frame1.dpsAbbreviateDropdown:SetHook ("OnLeave", background_on_leave)
		
		
---------------- appearance
		local frame2 = window.options [2][1].gump

		--skin
		local titulo_skin = g:NewLabel (frame2, _, "$parentTituloSkin", "tituloSkinLabel", Loc ["STRING_OPTIONS_SKIN_A"], "GameFontNormal", 16)
		local titulo_skin_desc = g:NewLabel (frame2, _, "$parentTituloSkin2", "tituloSkin2Label", Loc ["STRING_OPTIONS_SKIN_A_DESC"], "GameFontNormal", 9, "white")
		titulo_skin_desc.width = 250
		
		--bars general
		local titulo_bars = g:NewLabel (frame2, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_BARS"], "GameFontNormal", 16)
		local titulo_bars_desc = g:NewLabel (frame2, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_BARS_DESC"], "GameFontNormal", 9, "white")
		titulo_bars_desc.width = 250

		--bars text
		local titulo_texts = g:NewLabel (frame2, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_TEXT"], "GameFontNormal", 16)
		local titulo_texts_desc = g:NewLabel (frame2, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_TEXT_DESC"], "GameFontNormal", 9, "white")
		titulo_texts_desc.width = 250
		
		--window
		local titulo_instance = g:NewLabel (frame2, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_INSTANCE"], "GameFontNormal", 16)
		local titulo_instance_desc = g:NewLabel (frame2, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_INSTANCE_DESC"], "GameFontNormal", 9, "white")
		titulo_instance_desc.width = 250
		
		--toolbar
		local titulo_toolbar = g:NewLabel (frame2, _, "$parentTituloToolbar", "tituloToolbarLabel", Loc ["STRING_OPTIONS_TOOLBAR_SETTINGS"], "GameFontNormal", 16)
		local titulo_toolbar_desc = g:NewLabel (frame2, _, "$parentTituloToolbar2", "tituloToolbar2Label", Loc ["STRING_OPTIONS_TOOLBAR_SETTINGS_DESC"], "GameFontNormal", 9, "white")
		titulo_toolbar_desc.width = 250
		
		--wallpaper
		local titulo_wallpaper = g:NewLabel (frame2, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_WP"], "GameFontNormal", 16)
		local titulo_wallpaper_desc = g:NewLabel (frame2, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_WP_DESC"], "GameFontNormal", 9, "white")
		titulo_wallpaper_desc.width = 250
		
		--save load
		local titulo_save = g:NewLabel (frame2, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_SAVELOAD"], "GameFontNormal", 16)
		local titulo_save_desc = g:NewLabel (frame2, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_SAVELOAD_DESC"], "GameFontNormal", 9, "white")
		titulo_save_desc.width = 250
	
	--> create functions and frames first:

		local function saveStyleFunc (temp)
			if ((not frame2.saveStyleName.text or frame2.saveStyleName.text == "") and not temp) then
				_detalhes:Msg (Loc ["STRING_OPTIONS_PRESETNONAME"])
				return
			end
			
			local savedObject = {
				version = 2,
				name = frame2.saveStyleName.text, --> preset name
			}
			
			for key, value in pairs (window.instance) do 
				if (_detalhes.instance_defaults [key]) then	
					if (type (value) == "table") then
						savedObject [key] = table_deepcopy (value)
					else
						savedObject [key] = value
					end
				end
			end
			
			if (temp) then
				return savedObject
			end
			
			_detalhes.savedStyles [#_detalhes.savedStyles+1] = savedObject
			frame2.saveStyleName.text = ""
		end	
	
		local loadStyle = function (_, instance, index)
		
			local style
		
			if (type (index) == "table") then
				style = index
			else
				style = _detalhes.savedStyles [index]
				if (not style.version or preset_version > style.version) then
					return _detalhes:Msg (Loc ["STRING_OPTIONS_PRESETTOOLD"])
				end
			end
			
			--> set skin preset
			local skin = style.skin
			instance.skin = ""
			instance:ChangeSkin (skin)
			
			--> overwrite all instance parameters with saved ones
			for key, value in pairs (style) do
				if (key ~= "skin") then
					if (type (value) == "table") then
						instance [key] = table_deepcopy (value)
					else
						instance [key] = value
					end
				end
			end
			
			--> apply all changed attributes
			instance:ChangeSkin()
			
			--> reload options panel
			_detalhes:OpenOptionsWindow (instance)
			
		end
	
		local resetToDefaults = function()
			loadStyle (nil, window.instance, _detalhes.instance_defaults)
		end
	
		------ apply to all button
		local applyToAll = function()
		
			local temp_preset = saveStyleFunc (true)
			local current_instance = window.instance
			
			for _, this_instance in ipairs (_detalhes.tabela_instancias) do 
				if (this_instance:IsAtiva() and this_instance.meu_id ~= window.instance.meu_id) then
					loadStyle (nil, this_instance, temp_preset)
				end
			end
			
			_detalhes:OpenOptionsWindow (current_instance)
			
		end

		--> save and load stuff
		g:NewTextEntry (frame2, _, "$parentSaveStyleName", "saveStyleName", nil, 20, _, _, _, 178) --width will be auto adjusted if space parameter is passed
		g:NewButton (frame2, _, "$parentSaveStyleButton", "saveStyle", 32, 19, saveStyleFunc, nil, nil, nil, Loc ["STRING_OPTIONS_SAVELOAD_SAVE"])
		g:NewButton (frame2, _, "$parentLoadStyleButton", "loadStyle", 32, 19, nil, nil, nil, nil, Loc ["STRING_OPTIONS_SAVELOAD_LOAD"])
		g:NewButton (frame2, _, "$parentRemoveStyleButton", "removeStyle", 12, 19, nil, nil, nil, nil, Loc ["STRING_OPTIONS_SAVELOAD_REMOVE"])
		g:NewButton (frame2, _, "$parentToAllStyleButton", "applyToAll", 140, 14, applyToAll, nil, nil, nil, Loc ["STRING_OPTIONS_SAVELOAD_APPLYTOALL"])
		g:NewButton (frame2, _, "$parentResetToDefaultButton", "resetToDefaults", 100, 14, resetToDefaults, nil, nil, nil, Loc ["STRING_OPTIONS_SAVELOAD_RESET"])
		
		--> text size
			g:NewSlider (frame2, _, "$parentSliderFontSize", "fonsizeSlider", SLIDER_WIDTH, 20, 8, 15, 1, tonumber (instance.row_info.font_size))

		--> instance color
			local selectedColor = function()
				local r, g, b = ColorPickerFrame:GetColorRGB()
				local a = OpacitySliderFrame:GetValue()
				
				frame2.instancecolortexture:SetTexture (r, g, b)
				frame2.instancecolortexture:SetAlpha (a)

				window.instance:InstanceColor (r, g, b, a)
			end
			
			local canceledColor = function()
				local c = ColorPickerFrame.previousValues
				frame2.instancecolortexture:SetTexture (c [1], c [2], c [3])
				frame2.instancecolortexture:SetAlpha (c [4])
				
				window.instance:InstanceColor (c [1], c [2], c [3], c [4])
				
				ColorPickerFrame.func = nil
				ColorPickerFrame.opacityFunc = nil
				ColorPickerFrame.cancelFunc = nil
			end
			
			local selectedAlpha = function()
				local r, g, b = ColorPickerFrame:GetColorRGB()
				local a = OpacitySliderFrame:GetValue()

				a = _detalhes:Scale (0, 1, 0.5, 1, a) - 0.5
				
				frame2.instancecolortexture:SetTexture (r, g, b)
				frame2.instancecolortexture:SetAlpha (a)
				
				window.instance:InstanceColor (r, g, b, a)

			end
			
			local colorpick = function()
				ColorPickerFrame.func = selectedColor
				ColorPickerFrame.opacityFunc = selectedAlpha
				ColorPickerFrame.cancelFunc = canceledColor
				ColorPickerFrame.hasOpacity = true --false
				ColorPickerFrame.opacity = window.instance.color[4] or 1
				ColorPickerFrame.previousValues = window.instance.color
				ColorPickerFrame:SetParent (window.widget)
				ColorPickerFrame:SetColorRGB (unpack (window.instance.color))
				ColorPickerFrame:Show()
			end

			g:NewImage (frame2, _, "$parentInstanceColorTexture", "instancecolortexture", COLOR_BUTTON_WIDTH, 12)
			g:NewButton (frame2, _, "$parentInstanceColorButton", "instancecolorbutton", COLOR_BUTTON_WIDTH, 14, colorpick, nil, nil, nil, Loc ["STRING_OPTIONS_PICKCOLOR"])
		
		--> bar background color
			local selectedRowBackgroundColor = function()
				local r, g, b = ColorPickerFrame:GetColorRGB()
				local a = OpacitySliderFrame:GetValue()
				frame2.rowBackgroundColorTexture:SetTexture (r, g, b, a)
				
				window.instance:SetBarSettings (nil, nil, nil, nil, nil, nil, {r, g, b, a})
			end
			
			local canceledRowBackgroundColor = function()
				frame2.rowBackgroundColorTexture:SetTexture (unpack (ColorPickerFrame.previousValues))
				window.instance:SetBarSettings (nil, nil, nil, nil, nil, nil, ColorPickerFrame.previousValues)
			
				ColorPickerFrame.func = nil
				ColorPickerFrame.opacityFunc = nil
				ColorPickerFrame.cancelFunc = nil
			end
			
			local selectedRowBackgroundAlpha = function()
				local r, g, b = ColorPickerFrame:GetColorRGB()
				local a = OpacitySliderFrame:GetValue()
				frame2.rowBackgroundColorTexture:SetTexture (r, g, b, a)
				window.instance:SetBarSettings (nil, nil, nil, nil, nil, nil, {r, g, b, a})
			end
			
			local colorpickRowBackground = function()
				ColorPickerFrame.func = selectedRowBackgroundColor
				ColorPickerFrame.opacityFunc = selectedRowBackgroundAlpha
				ColorPickerFrame.cancelFunc = canceledRowBackgroundColor
				ColorPickerFrame.hasOpacity = true --false
				ColorPickerFrame.opacity = window.instance.row_info.fixed_texture_background_color[4]
				ColorPickerFrame.previousValues = window.instance.row_info.fixed_texture_background_color
				ColorPickerFrame:SetParent (window.widget)
				ColorPickerFrame:SetColorRGB (unpack (window.instance.row_info.fixed_texture_background_color))
				ColorPickerFrame:Show()
			end

			g:NewImage (frame2, _, "$parentRowBackgroundColor", "rowBackgroundColorTexture", COLOR_BUTTON_WIDTH, 12)
			g:NewButton (frame2, _, "$parentRowBackgroundColorButton", "rowBackgroundColorButton", COLOR_BUTTON_WIDTH, 14, colorpickRowBackground, nil, nil, nil, Loc ["STRING_OPTIONS_PICKCOLOR"])
			
		--> background with class color
			g:NewSwitch (frame2, _, "$parentBackgroundClassColorSlider", "rowBackgroundColorByClassSlider", 60, 20, _, _, instance.row_info.texture_background_class_color)
		
		--> bar height
			g:NewSlider (frame2, _, "$parentSliderRowHeight", "rowHeightSlider", SLIDER_WIDTH, 20, 10, 30, 1, tonumber (instance.row_info.height))

		--> transparency
			g:NewSlider (frame2, _, "$parentAlphaSlider", "alphaSlider", SLIDER_WIDTH, 20, 0.02, 1, 0.02, instance.bg_alpha, true)
			
			local selectedBackgroundColor = function()
				local r, g, b = ColorPickerFrame:GetColorRGB()
				window.instance:SetBackgroundColor (r, g, b)
				frame2.backgroundColorTexture:SetTexture (r, g, b)
			end
			
			local canceledBackgroundColor = function()
				local c = ColorPickerFrame.previousValues
				window.instance:SetBackgroundColor (unpack (c))
				frame2.backgroundColorTexture:SetTexture (unpack (c))
				ColorPickerFrame.func = nil
				ColorPickerFrame.cancelFunc = nil
			end
			
			local colorpickBackgroundColor = function()
				ColorPickerFrame.func = selectedBackgroundColor
				ColorPickerFrame.cancelFunc = canceledBackgroundColor
				ColorPickerFrame.opacityFunc = nil
				ColorPickerFrame.hasOpacity = false
				ColorPickerFrame.previousValues = {window.instance.bg_r, window.instance.bg_g, window.instance.bg_b}
				ColorPickerFrame:SetParent (window.widget)
				ColorPickerFrame:SetColorRGB (window.instance.bg_r, window.instance.bg_g, window.instance.bg_b)
				ColorPickerFrame:Show()
			end

			g:NewImage (frame2, _, "$parentBackgroundColorTexture", "backgroundColorTexture", COLOR_BUTTON_WIDTH, 12)
			g:NewButton (frame2, _, "$parentBackgroundColorButton", "backgroundColorButton", COLOR_BUTTON_WIDTH, 14, colorpickBackgroundColor, nil, nil, nil, Loc ["STRING_OPTIONS_PICKCOLOR"])
		
		--> auto current segment
			g:NewSwitch (frame2, _, "$parentAutoCurrentSlider", "autoCurrentSlider", 60, 20, _, _, instance.auto_current)
			
		--> sidebars statusbar
			g:NewSwitch (frame2, _, "$parentSideBarsSlider", "sideBarsSlider", 60, 20, _, _, instance.show_sidebars)
			g:NewSwitch (frame2, _, "$parentStatusbarSlider", "statusbarSlider", 60, 20, _, _, instance.show_statusbar)
			
		--> desaturate
			g:NewSwitch (frame2, _, "$parentDesaturateMenuSlider", "desaturateMenuSlider", 60, 20, _, _, instance.desaturated_menu)
			
		--> hide icon
			g:NewSwitch (frame2, _, "$parentHideIconSlider", "hideIconSlider", 60, 20, _, _, instance.hide_icon)

		--> instance button anchor
			g:NewSlider (frame2, _, "$parentInstanceButtonAnchorXSlider", "instanceButtonAnchorXSlider", SLIDER_WIDTH, 20, -200, 20, 1, instance.instance_button_anchor[1])
			g:NewSlider (frame2, _, "$parentInstanceButtonAnchorYSlider", "instanceButtonAnchorYSlider", SLIDER_WIDTH, 20, -10, 10, 1, instance.instance_button_anchor[2])
			
		--> menu anchor
			g:NewSlider (frame2, _, "$parentMenuAnchorXSlider", "menuAnchorXSlider", SLIDER_WIDTH, 20, -20, 200, 1, instance.menu_anchor[1])
			g:NewSlider (frame2, _, "$parentMenuAnchorYSlider", "menuAnchorYSlider", SLIDER_WIDTH, 20, -10, 10, 1, instance.menu_anchor[2])
			
		--> close button
			--button overlay
			local close_overlay_color_callback = function (_, r, g, b, a)
				frame2.closeOverlayColorImage:SetTexture (r, g, b, a)
				window.instance:SetCloseButtonSettings ({r, g, b, a})
			end
			local close_overlay_color_onclick = function() 
				local color_table = window.instance.closebutton_info.color_overlay
				g:ColorPick (frame2.closeOverlayColorButton.widget, color_table[1], color_table[2], color_table[3], color_table[4], close_overlay_color_callback)
			end
			g:NewImage (frame2, nil, "$parentCloseOverlayColorImage", "closeOverlayColorImage", COLOR_BUTTON_WIDTH, 12, instance.closebutton_info.color_overlay)
			g:NewButton (frame2, nil, "$parentCloseOverlayColorButton", "closeOverlayColorButton", COLOR_BUTTON_WIDTH, 14, close_overlay_color_onclick, nil, nil, nil, "color")
			
		--> reset button
			--text color pick
			local reset_text_color_callback = function (_, r, g, b, a)
				frame2.resetTextColorImage:SetTexture (r, g, b, a)
				window.instance:SetDeleteButtonSettings (nil, nil, {r, g, b, a}, nil)
			end
			local reset_text_color_onclick = function() 
				local color_table = window.instance.resetbutton_info.text_color
				g:ColorPick (frame2.resetTextColorButton.widget, color_table[1], color_table[2], color_table[3], color_table[4], reset_text_color_callback)
			end
			g:NewImage (frame2, nil, "$parentResetTextColorImage", "resetTextColorImage", COLOR_BUTTON_WIDTH, 12, instance.resetbutton_info.text_color)
			g:NewButton (frame2, nil, "$parentResetTextColorButton", "resetTextColorButton", COLOR_BUTTON_WIDTH, 14, reset_text_color_onclick, nil, nil, nil, "color")
			
			--text size
			g:NewSlider (frame2, _, "$parentResetTextSizeSlider", "resetTextSizeSlider", SLIDER_WIDTH, 20, 8, 15, 1, tonumber (instance.resetbutton_info.text_size))
			frame2.resetTextSizeSlider:SetHook ("OnValueChange", function (self, instance, amount) 
				instance:SetDeleteButtonSettings (nil, amount)
			end)
			
			--button overlay
			local reset_overlay_color_callback = function (_, r, g, b, a)
				frame2.resetOverlayColorImage:SetTexture (r, g, b, a)
				window.instance:SetDeleteButtonSettings (nil, nil, nil, {r, g, b, a})
			end
			local reset_overlay_color_onclick = function() 
				local color_table = window.instance.resetbutton_info.color_overlay
				g:ColorPick (frame2.resetOverlayColorButton.widget, color_table[1], color_table[2], color_table[3], color_table[4], reset_overlay_color_callback)
			end
			g:NewImage (frame2, nil, "$parentResetOverlayColorImage", "resetOverlayColorImage", COLOR_BUTTON_WIDTH, 12, instance.resetbutton_info.color_overlay)
			g:NewButton (frame2, nil, "$parentResetOverlayColorButton", "resetOverlayColorButton", COLOR_BUTTON_WIDTH, 14, reset_overlay_color_onclick, nil, nil, nil, "color")
			--reset always small
			g:NewSwitch (frame2, _, "$parentResetAlwaysSmallSlider", "resetAlwaysSmallSlider", 60, 20, _, _, instance.resetbutton_info.always_small)
			
			--text face
			local reset_text_color_onselectfont = function (_, instance, fontName)
				window.instance:SetDeleteButtonSettings (fontName)
			end
			local  reset_text_color_build_font_menu = function() 
				local fontObjects = SharedMedia:HashTable ("font")
				local fontTable = {}
				for name, fontPath in pairs (fontObjects) do 
					fontTable[#fontTable+1] = {value = name, label = name, onclick = reset_text_color_onselectfont, font = fontPath}
				end
				return fontTable 
			end
			g:NewDropDown (frame2, _, "$parentResetTextFontDropdown", "resetTextFontDropdown", DROPDOWN_WIDTH, 20, reset_text_color_build_font_menu, nil)
			
		--> stretch button anchor
			g:NewSwitch (frame2, _, "$parentStretchAnchorSlider", "stretchAnchorSlider", 80, 20, Loc ["STRING_TOP"], Loc ["STRING_BOTTOM"], instance.stretch_button_side, true)
			
		--> plugins icons grow direction
			g:NewSwitch (frame2, _, "$parentPluginIconsDirectionSlider", "pluginIconsDirectionSlider", 80, 20, Loc ["STRING_LEFT"], Loc ["STRING_RIGHT"], instance.plugins_grow_direction)
			
		--> instance toolbar side
			g:NewSwitch (frame2, _, "$parentInstanceToolbarSideSlider", "instanceToolbarSideSlider", 80, 20, Loc ["STRING_TOP"], Loc ["STRING_BOTTOM"], instance.toolbar_side, true)
			
		--> bars grow direction
			g:NewSwitch (frame2, _, "$parentBarGrowDirectionSlider", "barGrowDirectionSlider", 80, 20, Loc ["STRING_TOP"], Loc ["STRING_BOTTOM"], instance.bars_grow_direction, true)

		--> bars sort direction
			g:NewSwitch (frame2, _, "$parentBarSortDirectionSlider", "barSortDirectionSlider", 80, 20, Loc ["STRING_TOP"], Loc ["STRING_BOTTOM"], instance.bars_sort_direction, true)
			
		--> instance button
			--text color pick
			local instance_text_color_callback = function (_, r, g, b, a)
				frame2.instanceTextColorImage:SetTexture (r, g, b, a)
				window.instance:SetInstanceButtonSettings (nil, nil, {r, g, b, a})
			end
			local instance_text_color_onclick = function() 
				local color_table = window.instance.instancebutton_info.text_color
				g:ColorPick (frame2.instanceTextColorButton.widget, color_table[1], color_table[2], color_table[3], color_table[4], instance_text_color_callback)
			end
			g:NewImage (frame2, nil, "$parentInstanceTextColorImage", "instanceTextColorImage", COLOR_BUTTON_WIDTH, 12, instance.instancebutton_info.text_color)
			g:NewButton (frame2, nil, "$parentInstanceTextColorButton", "instanceTextColorButton", COLOR_BUTTON_WIDTH, 14, instance_text_color_onclick, nil, nil, nil, "color")
			--text size
			g:NewSlider (frame2, _, "$parentInstanceTextSizeSlider", "instanceTextSizeSlider", SLIDER_WIDTH, 20, 8, 15, 1, tonumber (instance.instancebutton_info.text_size))
			frame2.instanceTextSizeSlider:SetHook ("OnValueChange", function (self, instance, amount) 
				instance:SetInstanceButtonSettings (nil, amount)
			end)
			--button overlay
			local instance_overlay_color_callback = function (_, r, g, b, a)
				frame2.instanceOverlayColorImage:SetTexture (r, g, b, a)
				window.instance:SetInstanceButtonSettings (nil, nil, nil, {r, g, b, a})
			end
			local instance_overlay_color_onclick = function() 
				local color_table = window.instance.instancebutton_info.color_overlay
				g:ColorPick (frame2.instanceOverlayColorButton.widget, color_table[1], color_table[2], color_table[3], color_table[4], instance_overlay_color_callback)
			end
			g:NewImage (frame2, nil, "$parentInstanceOverlayColorImage", "instanceOverlayColorImage", COLOR_BUTTON_WIDTH, 12, instance.instancebutton_info.color_overlay)
			g:NewButton (frame2, nil, "$parentInstanceOverlayColorButton", "instanceOverlayColorButton", COLOR_BUTTON_WIDTH, 14, instance_overlay_color_onclick, nil, nil, nil, "color")		
			--text face
			local instance_text_color_onselectfont = function (_, instance, fontName)
				instance:SetInstanceButtonSettings (fontName)
			end
			local  instance_text_color_build_font_menu = function() 
				local fontObjects = SharedMedia:HashTable ("font")
				local fontTable = {}
				for name, fontPath in pairs (fontObjects) do 
					fontTable[#fontTable+1] = {value = name, label = name, onclick = instance_text_color_onselectfont, font = fontPath}
				end
				return fontTable 
			end
			g:NewDropDown (frame2, _, "$parentInstanceTextFontDropdown", "instanceTextFontDropdown", DROPDOWN_WIDTH, 20, instance_text_color_build_font_menu, nil)

		--> bar texture by class color
			g:NewSwitch (frame2, _, "$parentClassColorSlider", "classColorSlider", 60, 20, _, _, instance.row_info.texture_class_colors)
		--> left text and right class color
			g:NewSwitch (frame2, _, "$parentUseClassColorsLeftTextSlider", "classColorsLeftTextSlider", 60, 20, _, _, instance.row_info.textL_class_colors)
			g:NewSwitch (frame2, _, "$parentUseClassColorsRightTextSlider", "classColorsRightTextSlider", 60, 20, _, _, instance.row_info.textR_class_colors)
		
		--> row texture color
			local selectedColorClass = function()
				local r, g, b = ColorPickerFrame:GetColorRGB()
				frame2.fixedRowColorTexture:SetTexture (r, g, b)
				
				window.instance:SetBarSettings (nil, nil, nil, {r, g, b, 1})
			end
			
			local canceledColorClass = function()
				local c = ColorPickerFrame.previousValues
				frame2.fixedRowColorTexture:SetTexture (c[1], c[2], c[3])
				
				window.instance:SetBarSettings (nil, nil, nil, {c[1], c[2], c[3], 1})

				ColorPickerFrame.func = nil
				ColorPickerFrame.cancelFunc = nil
			end
			
			local colorpickClass = function()
				ColorPickerFrame.func = selectedColorClass
				ColorPickerFrame.cancelFunc = canceledColorClass
				ColorPickerFrame.opacityFunc = nil
				ColorPickerFrame.hasOpacity = false
				ColorPickerFrame.previousValues = window.instance.row_info.fixed_texture_color
				ColorPickerFrame:SetParent (window.widget)
				ColorPickerFrame:SetColorRGB (unpack (window.instance.row_info.fixed_texture_color))
				ColorPickerFrame:Show()
			end

			g:NewImage (frame2, _, "$parentFixedRowColorTexture", "fixedRowColorTexture", COLOR_BUTTON_WIDTH, 12)
			g:NewButton (frame2, _, "$parentFixedRowColorButton", "fixedRowColorButton", COLOR_BUTTON_WIDTH, 14, colorpickClass, nil, nil, nil, Loc ["STRING_OPTIONS_PICKCOLOR"])	

		--> text color
			local selectedTextColor = function()
				local r, g, b = ColorPickerFrame:GetColorRGB()
				frame2.fixedRowColorText:SetTexture (r, g, b)
				window.instance:SetBarTextSettings (nil, nil, {r, g, b, 1})
			end
			
			local canceledTextColor = function()
				local c = ColorPickerFrame.previousValues
				frame2.fixedRowColorText:SetTexture (c [1], c [2], c [3])
				window.instance:SetBarTextSettings (nil, nil, {c [1], c [2], c [3], 1})
				
				ColorPickerFrame.func = nil
				ColorPickerFrame.cancelFunc = nil
			end
			
			local colorpickTextColor = function()
				ColorPickerFrame.func = selectedTextColor
				ColorPickerFrame.cancelFunc = canceledTextColor
				ColorPickerFrame.opacityFunc = nil
				ColorPickerFrame.hasOpacity = false
				ColorPickerFrame.previousValues = window.instance.row_info.fixed_text_color
				ColorPickerFrame:SetParent (window.widget)
				ColorPickerFrame:SetColorRGB (unpack (window.instance.row_info.fixed_text_color))
				ColorPickerFrame:Show()
			end

			g:NewImage (frame2, _, "$parentFixedRowColorTTexture", "fixedRowColorText", COLOR_BUTTON_WIDTH, 12)
			g:NewButton (frame2, _, "$parentFixedRowColorTButton", "fixedRowColorTButton", COLOR_BUTTON_WIDTH, 14, colorpickTextColor, nil, nil, nil, Loc ["STRING_OPTIONS_PICKCOLOR"])
			
		--> outline
			g:NewSwitch (frame2, _, "$parentTextLeftOutlineSlider", "textLeftOutlineSlider", 60, 20, _, _, instance.row_info.textL_outline)
			g:NewSwitch (frame2, _, "$parentTextRightOutlineSlider", "textRightOutlineSlider", 60, 20, _, _, instance.row_info.textR_outline)
			
		--> wallpaper
		
			--> primeiro o botão de editar a imagem
			local callmeback = function (width, height, overlayColor, alpha, texCoords)
				local tinstance = _G ["DetailsOptionsWindow"].MyObject.instance
				tinstance:InstanceWallpaper (nil, nil, alpha, texCoords, width, height, overlayColor)
			end
			
			local startImageEdit = function()
				local tinstance = _G ["DetailsOptionsWindow"].MyObject.instance
				
				if (tinstance.wallpaper.texture:find ("TALENTFRAME")) then
					g:ImageEditor (callmeback, tinstance.wallpaper.texture, tinstance.wallpaper.texcoord, tinstance.wallpaper.overlay, window.instance.baseframe.wallpaper:GetWidth(), window.instance.baseframe.wallpaper:GetHeight())
				else
					tinstance.wallpaper.overlay [4] = 0.5
					g:ImageEditor (callmeback, tinstance.wallpaper.texture, tinstance.wallpaper.texcoord, tinstance.wallpaper.overlay, window.instance.baseframe.wallpaper:GetWidth(), window.instance.baseframe.wallpaper:GetHeight())
				end
			end
			g:NewButton (frame2, _, "$parentEditImage", "editImage", 200, 18, startImageEdit, nil, nil, nil, Loc ["STRING_OPTIONS_EDITIMAGE"])
			
			--> agora o dropdown do alinhamento
			local onSelectAnchor = function (_, instance, anchor)
				instance:InstanceWallpaper (nil, anchor)
			end
			local anchorMenu = {
				{value = "all", label = "Fill", onclick = onSelectAnchor},
				{value = "center", label = "Center", onclick = onSelectAnchor},
				{value = "stretchLR", label = "Stretch Left-Right", onclick = onSelectAnchor},
				{value = "stretchTB", label = "Stretch Top-Bottom", onclick = onSelectAnchor},
				{value = "topleft", label = "Top Left", onclick = onSelectAnchor},
				{value = "bottomleft", label = "Bottom Left", onclick = onSelectAnchor},
				{value = "topright", label = "Top Right", onclick = onSelectAnchor},
				{value = "bottomright", label = "Bottom Right", onclick = onSelectAnchor},
			}
			local buildAnchorMenu = function()
				return anchorMenu
			end

			g:NewDropDown (frame2, _, "$parentAnchorDropdown", "anchorDropdown", DROPDOWN_WIDTH, 20, buildAnchorMenu, nil)			
			
			--> agora cria os 2 dropdown da categoria e wallpaper
			
			local onSelectSecTexture = function (self, instance, texturePath) 
				
				if (texturePath:find ("TALENTFRAME")) then
					instance:InstanceWallpaper (texturePath, nil, nil, {0, 1, 0, 0.703125})
				else
					instance:InstanceWallpaper (texturePath, nil, nil, {0, 1, 0, 1})
				end
			end
		
			local subMenu = {
				
				["ARCHEOLOGY"] = {
					{value = [[Interface\ARCHEOLOGY\Arch-BookCompletedLeft]], label = "Book Wallpaper", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-BookCompletedLeft]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-BookItemLeft]], label = "Book Wallpaper 2", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-BookItemLeft]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-DraeneiBIG]], label = "Draenei", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-DraeneiBIG]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-DwarfBIG]], label = "Dwarf", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-DwarfBIG]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-NightElfBIG]], label = "Night Elf", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-NightElfBIG]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-OrcBIG]], label = "Orc", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-OrcBIG]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-PandarenBIG]], label = "Pandaren", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-PandarenBIG]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-TrollBIG]], label = "Troll", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-TrollBIG]], texcoord = nil},

					{value = [[Interface\ARCHEOLOGY\ArchRare-AncientShamanHeaddress]], label = "Ancient Shaman", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-AncientShamanHeaddress]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-BabyPterrodax]], label = "Baby Pterrodax", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-BabyPterrodax]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-ChaliceMountainKings]], label = "Chalice Mountain Kings", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ChaliceMountainKings]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-ClockworkGnome]], label = "Clockwork Gnomes", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ClockworkGnome]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-QueenAzsharaGown]], label = "Queen Azshara Gown", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-QueenAzsharaGown]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-QuilinStatue]], label = "Quilin Statue", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-QuilinStatue]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-TempRareSketch]], label = "Rare Sketch", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-TempRareSketch]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-ScepterofAzAqir]], label = "Scepter of Az Aqir", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ScepterofAzAqir]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-ShriveledMonkeyPaw]], label = "Shriveled Monkey Paw", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ShriveledMonkeyPaw]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-StaffofAmmunrae]], label = "Staff of Ammunrae", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-StaffofAmmunrae]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-TinyDinosaurSkeleton]], label = "Tiny Dinosaur", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-TinyDinosaurSkeleton]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-TyrandesFavoriteDoll]], label = "Tyrandes Favorite Doll", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-TyrandesFavoriteDoll]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-ZinRokhDestroyer]], label = "ZinRokh Destroyer", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ZinRokhDestroyer]], texcoord = nil},
				},
			
				["CREDITS"] = {
					{value = [[Interface\Glues\CREDITS\Arakkoa2]], label = "Arakkoa", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Arakkoa2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Arcane_Golem2]], label = "Arcane Golem", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Arcane_Golem2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Badlands3]], label = "Badlands", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Badlands3]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\BD6]], label = "Draenei", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\BD6]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Draenei_Character1]], label = "Draenei 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_Character1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Draenei_Character2]], label = "Draenei 3", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_Character2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Draenei_Crest2]], label = "Draenei Crest", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_Crest2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Draenei_Female2]], label = "Draenei 4", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_Female2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Draenei2]], label = "Draenei 5", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Blood_Elf_One1]], label = "Kael'thas", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Blood_Elf_One1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\BD2]], label = "Blood Elf", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\BD2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\BloodElf_Priestess_Master2]], label = "Blood elf 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\BloodElf_Priestess_Master2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Female_BloodElf2]], label = "Blood Elf 3", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Female_BloodElf2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\CinSnow01TGA3]], label = "Cin Snow", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\CinSnow01TGA3]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\DalaranDomeTGA3]], label = "Dalaran", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\DalaranDomeTGA3]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Darnasis5]], label = "Darnasus", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Darnasis5]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Draenei_CityInt5]], label = "Exodar", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_CityInt5]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Shattrath6]], label = "Shattrath", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Shattrath6]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Demon_Chamber2]], label = "Demon Chamber", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Demon_Chamber2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Demon_Chamber6]], label = "Demon Chamber 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Demon_Chamber6]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Dwarfhunter1]], label = "Dwarf Hunter", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Dwarfhunter1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Fellwood5]], label = "Fellwood", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Fellwood5]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\HordeBanner1]], label = "Horde Banner", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\HordeBanner1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Illidan_Concept1]], label = "Illidan", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Illidan_Concept1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Illidan1]], label = "Illidan 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Illidan1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Naaru_CrashSite2]], label = "Naaru Crash", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Naaru_CrashSite2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\NightElves1]], label = "Night Elves", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\NightElves1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Ocean2]], label = "Mountain", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Ocean2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Tempest_Keep2]], label = "Tempest Keep", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Tempest_Keep2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Tempest_Keep6]], label = "Tempest Keep 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Tempest_Keep6]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Terrokkar6]], label = "Terrokkar", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Terrokkar6]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\ThousandNeedles2]], label = "Thousand Needles", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\ThousandNeedles2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Troll2]], label = "Troll", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Troll2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\LESSERELEMENTAL_FIRE_03B1]], label = "Fire Elemental", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\LESSERELEMENTAL_FIRE_03B1]], texcoord = nil},
				},
			
				["DEATHKNIGHT"] = {
					{value = [[Interface\TALENTFRAME\bg-deathknight-blood]], label = "Blood", onclick = onSelectSecTexture, icon = [[Interface\ICONS\Spell_Deathknight_BloodPresence]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-deathknight-frost]], label = "Frost", onclick = onSelectSecTexture, icon = [[Interface\ICONS\Spell_Deathknight_FrostPresence]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-deathknight-unholy]], label = "Unholy", onclick = onSelectSecTexture, icon = [[Interface\ICONS\Spell_Deathknight_UnholyPresence]], texcoord = nil}
				},
				
				["DRESSUP"] = {
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-BloodElf1]], label = "Blood Elf", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.5, 0.625, 0.75, 1}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-DeathKnight1]], label = "Death Knight", onclick = onSelectSecTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["DEATHKNIGHT"]},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Draenei1]], label = "Draenei", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.5, 0.625, 0.5, 0.75}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Dwarf1]], label = "Dwarf", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.125, 0.25, 0, 0.25}},
					{value = [[Interface\DRESSUPFRAME\DRESSUPBACKGROUND-GNOME1]], label = "Gnome", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.25, 0.375, 0, 0.25}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Goblin1]], label = "Goblin", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.625, 0.75, 0.75, 1}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Human1]], label = "Human", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0, 0.125, 0.5, 0.75}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-NightElf1]], label = "Night Elf", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.375, 0.5, 0, 0.25}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Orc1]], label = "Orc", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.375, 0.5, 0.25, 0.5}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Pandaren1]], label = "Pandaren", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.75, 0.875, 0.5, 0.75}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Tauren1]], label = "Tauren", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0, 0.125, 0.25, 0.5}},
					{value = [[Interface\DRESSUPFRAME\DRESSUPBACKGROUND-TROLL1]], label = "Troll", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.25, 0.375, 0.75, 1}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Scourge1]], label = "Undead", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.125, 0.25, 0.75, 1}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Worgen1]], label = "Worgen", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.625, 0.75, 0, 0.25}},
				},
				
				["DRUID"] = {
					{value = [[Interface\TALENTFRAME\bg-druid-bear]], label = "Guardian", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_racial_bearform]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-druid-restoration]], label = "Restoration", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_healingtouch]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-druid-cat]], label = "Feral", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_vampiricaura]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-druid-balance]], label = "Balance", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_starfall]], texcoord = nil}
				},
				
				["HUNTER"] = {
					{value = [[Interface\TALENTFRAME\bg-hunter-beastmaster]], label = "Beast Mastery", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_hunter_bestialdiscipline]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-hunter-marksman]], label = "Marksmanship", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_hunter_focusedaim]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-hunter-survival]], label = "Survival", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_hunter_camouflage]], texcoord = nil}
				},
				
				["MAGE"] = {
					{value = [[Interface\TALENTFRAME\bg-mage-arcane]], label = "Arcane", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_magicalsentry]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-mage-fire]], label = "Fire", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_fire_firebolt02]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-mage-frost]], label = "Frost", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_frost_frostbolt02]], texcoord = nil}
				},

				["MONK"] = {
					{value = [[Interface\TALENTFRAME\bg-monk-brewmaster]], label = "Brewmaster", onclick = onSelectSecTexture, icon = [[Interface\ICONS\monk_stance_drunkenox]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-monk-mistweaver]], label = "Mistweaver", onclick = onSelectSecTexture, icon = [[Interface\ICONS\monk_stance_wiseserpent]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-monk-battledancer]], label = "Windwalker", onclick = onSelectSecTexture, icon = [[Interface\ICONS\monk_stance_whitetiger]], texcoord = nil}
				},

				["PALADIN"] = {
					{value = [[Interface\TALENTFRAME\bg-paladin-holy]], label = "Holy", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_holybolt]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-paladin-protection]], label = "Protection", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_paladin_shieldofthetemplar]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-paladin-retribution]], label = "Retribution", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_auraoflight]], texcoord = nil}
				},
				
				["PRIEST"] = {
					{value = [[Interface\TALENTFRAME\bg-priest-discipline]], label = "Discipline", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_powerwordshield]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-priest-holy]], label = "Holy", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_guardianspirit]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-priest-shadow]], label = "Shadow", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_shadowwordpain]], texcoord = nil}
				},

				["ROGUE"] = {
					{value = [[Interface\TALENTFRAME\bg-rogue-assassination]], label = "Assassination", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_rogue_eviscerate]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-rogue-combat]], label = "Combat", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_backstab]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-rogue-subtlety]], label = "Subtlety", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_stealth]], texcoord = nil}
				},

				["SHAMAN"] = {
					{value = [[Interface\TALENTFRAME\bg-shaman-elemental]], label = "Elemental", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_lightning]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-shaman-enhancement]], label = "Enhancement", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_lightningshield]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-shaman-restoration]], label = "Restoration", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_magicimmunity]], texcoord = nil}	
				},
				
				["WARLOCK"] = {
					{value = [[Interface\TALENTFRAME\bg-warlock-affliction]], label = "Affliction", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_deathcoil]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-warlock-demonology]], label = "Demonology", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_metamorphosis]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-warlock-destruction]], label = "Destruction", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_rainoffire]], texcoord = nil}
				},
				["WARRIOR"] = {
					{value = [[Interface\TALENTFRAME\bg-warrior-arms]], label = "Arms", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_warrior_savageblow]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-warrior-fury]], label = "Fury", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_warrior_innerrage]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-warrior-protection]], label = "Protection", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_warrior_defensivestance]], texcoord = nil}
				},
			}
		
			local buildBackgroundMenu2 = function() 
				return  subMenu [frame2.backgroundDropdown.value] or {label = "-- -- --", value = 0}
			end
		
			local onSelectMainTexture = function (_, instance, choose)
				frame2.backgroundDropdown2:Select (choose)
			end
		
			local backgroundTable = {
				{value = "ARCHEOLOGY", label = "Archeology", onclick = onSelectMainTexture, icon = [[Interface\ARCHEOLOGY\Arch-Icon-Marker]]},
				{value = "CREDITS", label = "Burning Crusade", onclick = onSelectMainTexture, icon = [[Interface\ICONS\TEMP]]},
				{value = "DEATHKNIGHT", label = "Death Knight", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["DEATHKNIGHT"]},
				{value = "DRESSUP", label = "Class Background", onclick = onSelectMainTexture, icon = [[Interface\ICONS\INV_Chest_Cloth_17]]},
				{value = "DRUID", label = "Druid", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["DRUID"]},
				{value = "HUNTER", label = "Hunter", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["HUNTER"]},
				{value = "MAGE", label = "Mage", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["MAGE"]},
				{value = "MONK", label = "Monk", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["MONK"]},
				{value = "PALADIN", label = "Paladin", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["PALADIN"]},
				{value = "PRIEST", label = "Priest", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["PRIEST"]},
				{value = "ROGUE", label = "Rogue", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["ROGUE"]},
				{value = "SHAMAN", label = "Shaman", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["SHAMAN"]},
				{value = "WARLOCK", label = "Warlock", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["WARLOCK"]},
				{value = "WARRIOR", label = "Warrior", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["WARRIOR"]},
			}
			local buildBackgroundMenu = function() return backgroundTable end		
			
			g:NewSwitch (frame2, _, "$parentUseBackgroundSlider", "useBackgroundSlider", 60, 20, _, _, window.instance.wallpaper.enabled)
			g:NewDropDown (frame2, _, "$parentBackgroundDropdown", "backgroundDropdown", DROPDOWN_WIDTH, 20, buildBackgroundMenu, nil)
			g:NewDropDown (frame2, _, "$parentBackgroundDropdown2", "backgroundDropdown2", DROPDOWN_WIDTH, 20, buildBackgroundMenu2, nil)


			
		--> text font
			local onSelectFont = function (_, instance, fontName)
				instance:SetBarTextSettings (nil, fontName)
			end
			local fontObjects = SharedMedia:HashTable ("font")
			local fontTable = {}
			for name, fontPath in pairs (fontObjects) do 
				fontTable[#fontTable+1] = {value = name, label = name, onclick = onSelectFont, font = fontPath}
			end
			local buildFontMenu = function() return fontTable end
			g:NewDropDown (frame2, _, "$parentFontDropdown", "fontDropdown", DROPDOWN_WIDTH, 20, buildFontMenu, nil)			
			
		--> bar background
			local onSelectTextureBackground = function (_, instance, textureName)
				instance:SetBarSettings (nil, nil, nil, nil, textureName)
			end
			
			local textures2 = SharedMedia:HashTable ("statusbar")
			local texTable2 = {}
			for name, texturePath in pairs (textures2) do 
				texTable2[#texTable2+1] = {value = name, label = name, statusbar = texturePath,  onclick = onSelectTextureBackground}
			end
			local buildTextureMenu2 = function() return texTable2 end
			
			g:NewDropDown (frame2, _, "$parentRowBackgroundTextureDropdown", "rowBackgroundDropdown", DROPDOWN_WIDTH, 20, buildTextureMenu2, nil)			
		
		--> bar texture
			local onSelectTexture = function (_, instance, textureName)
				instance:SetBarSettings (nil, textureName)
			end
			
			local textures = SharedMedia:HashTable ("statusbar")
			local texTable = {}
			for name, texturePath in pairs (textures) do 
				texTable[#texTable+1] = {value = name, label = name, statusbar = texturePath,  onclick = onSelectTexture}
			end
			
			local buildTextureMenu = function() return texTable end
			g:NewDropDown (frame2, _, "$parentTextureDropdown", "textureDropdown", DROPDOWN_WIDTH, 20, buildTextureMenu, nil)
		
		--> select skin
			local onSelectSkin = function (_, instance, skin_name)
				instance:ChangeSkin (skin_name)
			end

			local buildSkinMenu = function()
				local skinOptions = {}
				for skin_name, skin_table in pairs (_detalhes.skins) do
					skinOptions [#skinOptions+1] = {value = skin_name, label = skin_name, onclick = onSelectSkin, icon = "Interface\\GossipFrame\\TabardGossipIcon", desc = skin_table.desc}
				end
				return skinOptions
			end
			
			g:NewDropDown (frame2, _, "$parentSkinDropdown", "skinDropdown", DROPDOWN_WIDTH, 20, buildSkinMenu, 1)
			
--==============================================================================================================================================================

	-- Bar Settings
	
		-- texture
		g:NewLabel (frame2, _, "$parentTextureLabel", "textureLabel", Loc ["STRING_OPTIONS_BAR_TEXTURE"])
		--
		frame2.textureDropdown:SetPoint ("left", frame2.textureLabel, "right", 2)
		
		frame2.textureDropdown.info = Loc ["STRING_OPTIONS_BAR_TEXTURE_DESC"]
		window:create_line_background (frame2, frame2.textureLabel, frame2.textureDropdown)
		frame2.textureDropdown:SetHook ("OnEnter", background_on_enter)
		frame2.textureDropdown:SetHook ("OnLeave", background_on_leave)
		
		-- background texture
		g:NewLabel (frame2, _, "$parentRowBackgroundTextureLabel", "rowBackgroundLabel", Loc ["STRING_OPTIONS_BAR_BTEXTURE"])
		--
		frame2.rowBackgroundDropdown:SetPoint ("left", frame2.rowBackgroundLabel, "right", 2)

		frame2.rowBackgroundDropdown.info = Loc ["STRING_OPTIONS_BAR_BTEXTURE_DESC"]
		window:create_line_background (frame2, frame2.rowBackgroundLabel, frame2.rowBackgroundDropdown)
		frame2.rowBackgroundDropdown:SetHook ("OnEnter", background_on_enter)
		frame2.rowBackgroundDropdown:SetHook ("OnLeave", background_on_leave)
	
		-- background color
		g:NewLabel (frame2, _, "$parentRowBackgroundColorLabel", "rowBackgroundColorLabel", Loc ["STRING_OPTIONS_BAR_BCOLOR"])

		--frame2.rowBackgroundColorTexture:SetPoint ("left", frame2.rowBackgroundColorLabel, "right", 2)
		frame2.rowBackgroundColorTexture:SetTexture (1, 1, 1)
		
		frame2.rowBackgroundColorButton:SetPoint ("left", frame2.rowBackgroundColorTexture, "left")
		frame2.rowBackgroundColorButton:InstallCustomTexture()
			
		frame2.rowBackgroundColorButton.info = Loc ["STRING_OPTIONS_BAR_BCOLOR_DESC"]
		window:create_line_background (frame2, frame2.rowBackgroundColorLabel, frame2.rowBackgroundColorButton)
		frame2.rowBackgroundColorButton:SetHook ("OnEnter", background_on_enter)
		frame2.rowBackgroundColorButton:SetHook ("OnLeave", background_on_leave)
	
		-- back background with class color
		g:NewLabel (frame2, _, "$parentRowBackgroundClassColorLabel", "rowBackgroundColorByClassLabel", Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2"])

		frame2.rowBackgroundColorByClassSlider:SetPoint ("left", frame2.rowBackgroundColorByClassLabel, "right", 2)
		frame2.rowBackgroundColorByClassSlider.OnSwitch = function (self, instance, value)
			instance:SetBarSettings (nil, nil, nil, nil, nil, value)
		end

		frame2.rowBackgroundColorByClassSlider.info = Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2_DESC"]
		window:create_line_background (frame2, frame2.rowBackgroundColorByClassLabel, frame2.rowBackgroundColorByClassSlider)
		frame2.rowBackgroundColorByClassSlider:SetHook ("OnEnter", background_on_enter)
		frame2.rowBackgroundColorByClassSlider:SetHook ("OnLeave", background_on_leave)
	
		-- height
		g:NewLabel (frame2, _, "$parentRowHeightLabel", "rowHeightLabel", Loc ["STRING_OPTIONS_BAR_HEIGHT"])
		--
		frame2.rowHeightSlider:SetPoint ("left", frame2.rowHeightLabel, "right", 2)
		frame2.rowHeightSlider:SetThumbSize (50)
		frame2.rowHeightSlider:SetHook ("OnValueChange", function (self, instance, amount) 
			instance.row_info.height = amount
			instance.row_height = instance.row_info.height+instance.row_info.space.between
			instance:RefreshBars()
			instance:InstanceReset()
			instance:ReajustaGump()
		end)	
		
		frame2.rowHeightSlider.info = Loc ["STRING_OPTIONS_BAR_HEIGHT_DESC"]
		window:create_line_background (frame2, frame2.rowHeightLabel, frame2.rowHeightSlider)
		frame2.rowHeightSlider:SetHook ("OnEnter", background_on_enter)
		frame2.rowHeightSlider:SetHook ("OnLeave", background_on_leave)
	
		-- texture color by class color
		g:NewLabel (frame2, _, "$parentUseClassColorsLabel", "classColorsLabel", Loc ["STRING_OPTIONS_BAR_COLORBYCLASS"])
		frame2.classColorSlider:SetPoint ("left", frame2.classColorsLabel, "right", 2)
		frame2.classColorSlider.OnSwitch = function (self, instance, value)
			instance:SetBarSettings (nil, nil, value)
		end

		frame2.classColorSlider.info = Loc ["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"]
		window:create_line_background (frame2, frame2.classColorsLabel, frame2.classColorSlider)
		frame2.classColorSlider:SetHook ("OnEnter", background_on_enter)
		frame2.classColorSlider:SetHook ("OnLeave", background_on_leave)		
	
		-- ROW TEXTURE COLOR -- é aquele quadrado grande pra escolher a cor
		
		frame2.fixedRowColorTexture:SetPoint ("left", frame2.classColorSlider, "right", 5)
		frame2.fixedRowColorTexture:SetTexture (1, 1, 1)

		frame2.fixedRowColorButton:SetPoint ("left", frame2.fixedRowColorTexture, "left")
		frame2.fixedRowColorButton:InstallCustomTexture()
	
	-- Text Settings
	
		-- Text Sizes
		g:NewLabel (frame2, _, "$parentFontSizeLabel", "fonsizeLabel", Loc ["STRING_OPTIONS_TEXT_SIZE"])
		frame2.fonsizeSlider:SetPoint ("left", frame2.fonsizeLabel, "right", 2)
		frame2.fonsizeSlider:SetThumbSize (50)
		frame2.fonsizeSlider:SetHook ("OnValueChange", function (self, instance, amount)
			instance:SetBarTextSettings (amount)
		end)
		frame2.fonsizeSlider.info = Loc ["STRING_OPTIONS_TEXT_SIZE_DESC"]
		window:create_line_background (frame2, frame2.fonsizeLabel, frame2.fonsizeSlider)
		frame2.fonsizeSlider:SetHook ("OnEnter", background_on_enter)
		frame2.fonsizeSlider:SetHook ("OnLeave", background_on_leave)
		
		-- Text Fonts
		g:NewLabel (frame2, _, "$parentFontLabel", "fontLabel", Loc ["STRING_OPTIONS_TEXT_FONT"])
		frame2.fontDropdown:SetPoint ("left", frame2.fontLabel, "right", 2)
		
		frame2.fontDropdown.info = Loc ["STRING_OPTIONS_TEXT_FONT_DESC"]
		window:create_line_background (frame2, frame2.fontLabel, frame2.fontDropdown)
		frame2.fontDropdown:SetHook ("OnEnter", background_on_enter)
		frame2.fontDropdown:SetHook ("OnLeave", background_on_leave)		

		-- left text by class color
		g:NewLabel (frame2, _, "$parentUseClassColorsLeftText", "classColorsLeftTextLabel", Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR"])

		frame2.classColorsLeftTextSlider:SetPoint ("left", frame2.classColorsLeftTextLabel, "right", 2)
		frame2.classColorsLeftTextSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, value)
		end
		
		frame2.classColorsLeftTextSlider.info = Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR_DESC"]
		window:create_line_background (frame2, frame2.classColorsLeftTextLabel, frame2.classColorsLeftTextSlider)
		frame2.classColorsLeftTextSlider:SetHook ("OnEnter", background_on_enter)
		frame2.classColorsLeftTextSlider:SetHook ("OnLeave", background_on_leave)
		
		-- right text by class color
		g:NewLabel (frame2, _, "$parentUseClassColorsRightText", "classColorsRightTextLabel", Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR"])

		frame2.classColorsRightTextSlider:SetPoint ("left", frame2.classColorsRightTextLabel, "right", 2)
		frame2.classColorsRightTextSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, nil, value)
		end
		
		frame2.classColorsRightTextSlider.info = Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR_DESC"]
		window:create_line_background (frame2, frame2.classColorsRightTextLabel, frame2.classColorsRightTextSlider)
		frame2.classColorsRightTextSlider:SetHook ("OnEnter", background_on_enter)
		frame2.classColorsRightTextSlider:SetHook ("OnLeave", background_on_leave)
		
		-- TEXT COLOR???????
		frame2.fixedRowColorText:SetPoint ("topleft", frame2.classColorsLeftTextSlider, "topright", 10, -5)
		frame2.fixedRowColorText:SetPoint ("bottomleft", frame2.classColorsRightTextSlider, "bottomright", 10, 5)
		frame2.fixedRowColorText:SetTexture (1, 1, 1)

		frame2.fixedRowColorTButton:SetPoint ("topleft", frame2.classColorsLeftTextSlider, "topright", 10, -5)
		frame2.fixedRowColorTButton:SetPoint ("bottomleft", frame2.classColorsRightTextSlider, "bottomright", 10, 5)
		frame2.fixedRowColorTButton:InstallCustomTexture()	

		-- left outline
		g:NewLabel (frame2, _, "$parentTextLeftOutlineLabel", "textLeftOutlineLabel", Loc ["STRING_OPTIONS_TEXT_LOUTILINE"])
		
		frame2.textLeftOutlineSlider:SetPoint ("left", frame2.textLeftOutlineLabel, "right", 2)
		frame2.textLeftOutlineSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, nil, nil, value)
		end

		frame2.textLeftOutlineSlider.info = Loc ["STRING_OPTIONS_TEXT_LOUTILINE_DESC"]
		window:create_line_background (frame2, frame2.textLeftOutlineLabel, frame2.textLeftOutlineSlider)
		frame2.textLeftOutlineSlider:SetHook ("OnEnter", background_on_enter)
		frame2.textLeftOutlineSlider:SetHook ("OnLeave", background_on_leave)
		
		-- right outline
		g:NewLabel (frame2, _, "$parentTextRightOutlineLabel", "textRightOutlineLabel", Loc ["STRING_OPTIONS_TEXT_ROUTILINE"])
		
		frame2.textRightOutlineSlider:SetPoint ("left", frame2.textRightOutlineLabel, "right", 2)
		frame2.textRightOutlineSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, nil, nil, nil, value)
		end
		
		frame2.textRightOutlineSlider.info = Loc ["STRING_OPTIONS_TEXT_ROUTILINE_DESC"]
		window:create_line_background (frame2, frame2.textRightOutlineLabel, frame2.textRightOutlineSlider)
		frame2.textRightOutlineSlider:SetHook ("OnEnter", background_on_enter)
		frame2.textRightOutlineSlider:SetHook ("OnLeave", background_on_leave)
		
	-- Instance Settings
	
		-- Instance Color
		g:NewLabel (frame2, _, "$parentInstanceColorLabel", "instancecolor", Loc ["STRING_OPTIONS_INSTANCE_COLOR"])

		frame2.instancecolortexture:SetPoint ("left", frame2.instancecolor, "right", 2)
		frame2.instancecolortexture:SetTexture (1, 1, 1)
		
		frame2.instancecolorbutton:SetPoint ("left", frame2.instancecolor, "right", 2)
		frame2.instancecolorbutton:InstallCustomTexture()
		
		frame2.instancecolorbutton.info = Loc ["STRING_OPTIONS_INSTANCE_COLOR_DESC"]
		window:create_line_background (frame2, frame2.instancecolor, frame2.instancecolorbutton)
		frame2.instancecolorbutton:SetHook ("OnEnter", background_on_enter)
		frame2.instancecolorbutton:SetHook ("OnLeave", background_on_leave)
		
		-- Color and Alpha
		g:NewLabel (frame2, _, "$parentAlphaLabel", "alphaLabel", Loc ["STRING_OPTIONS_INSTANCE_ALPHA"])
		g:NewLabel (frame2, _, "$parentBackgroundColorLabel", "backgroundColorLabel", Loc ["STRING_OPTIONS_INSTANCE_ALPHA2"])
		--
		frame2.alphaSlider:SetPoint ("left", frame2.alphaLabel, "right", 2, 0)
		frame2.alphaSlider.useDecimals = true
		frame2.alphaSlider:SetHook ("OnValueChange", function (self, instance, amount) --> slider, fixedValue, sliderValue
			self.amt:SetText (string.format ("%.2f", amount))
			instance:SetBackgroundAlpha (amount)
			return true
		end)
		frame2.alphaSlider.thumb:SetSize (30+(120*0.2)+2, 20*1.2)

		frame2.backgroundColorTexture:SetPoint ("left", frame2.backgroundColorLabel, "right", 2)
		frame2.backgroundColorTexture:SetTexture (1, 1, 1)
		
		frame2.backgroundColorButton:SetPoint ("left", frame2.backgroundColorLabel, "right", 2)
		frame2.backgroundColorButton:InstallCustomTexture()		
		
		-- alpha background COLOR????
		
		frame2.alphaSlider.info = Loc ["STRING_OPTIONS_INSTANCE_ALPHA_DESC"]
		window:create_line_background (frame2, frame2.alphaLabel, frame2.alphaSlider)
		frame2.alphaSlider:SetHook ("OnEnter", background_on_enter)
		frame2.alphaSlider:SetHook ("OnLeave", background_on_leave)

		-- Auto Current Segment
	
		g:NewLabel (frame2, _, "$parentAutoCurrentLabel", "autoCurrentLabel", Loc ["STRING_OPTIONS_INSTANCE_CURRENT"])

		frame2.autoCurrentSlider:SetPoint ("left", frame2.autoCurrentLabel, "right", 2)
		frame2.autoCurrentSlider.OnSwitch = function (self, instance, value)
			instance.auto_current = value
		end
		
		frame2.autoCurrentSlider.info = Loc ["STRING_OPTIONS_INSTANCE_CURRENT_DESC"]
		window:create_line_background (frame2, frame2.autoCurrentLabel, frame2.autoCurrentSlider)
		frame2.autoCurrentSlider:SetHook ("OnEnter", background_on_enter)
		frame2.autoCurrentSlider:SetHook ("OnLeave", background_on_leave)
		
		-- show side bars
		
		g:NewLabel (frame2, _, "$parentSideBarsLabel", "sideBarsLabel", Loc ["STRING_OPTIONS_SHOW_SIDEBARS"])

		frame2.sideBarsSlider:SetPoint ("left", frame2.sideBarsLabel, "right", 2)
		frame2.sideBarsSlider.OnSwitch = function (self, instance, value)
			if (value) then
				instance:ShowSideBars()
			else
				instance:HideSideBars()
			end
		end
		
		frame2.sideBarsSlider.info = Loc ["STRING_OPTIONS_SHOW_SIDEBARS_DESC"]
		window:create_line_background (frame2, frame2.sideBarsLabel, frame2.sideBarsSlider)
		frame2.sideBarsSlider:SetHook ("OnEnter", background_on_enter)
		frame2.sideBarsSlider:SetHook ("OnLeave", background_on_leave)		
		
		-- show statusbar
		
		g:NewLabel (frame2, _, "$parentStatusbarLabel", "statusbarLabel", Loc ["STRING_OPTIONS_SHOW_STATUSBAR"])

		frame2.statusbarSlider:SetPoint ("left", frame2.statusbarLabel, "right", 2)
		frame2.statusbarSlider.OnSwitch = function (self, instance, value)
			if (value) then
				instance:ShowStatusBar()
			else
				instance:HideStatusBar()
			end
		end
		
		frame2.statusbarSlider.info = Loc ["STRING_OPTIONS_SHOW_STATUSBAR_DESC"]
		window:create_line_background (frame2, frame2.statusbarLabel, frame2.statusbarSlider)
		frame2.statusbarSlider:SetHook ("OnEnter", background_on_enter)
		frame2.statusbarSlider:SetHook ("OnLeave", background_on_leave)
		
		--[[



		--]]
		
		-- desaturate
			g:NewLabel (frame2, _, "$parentDesaturateMenuLabel", "desaturateMenuLabel", Loc ["STRING_OPTIONS_DESATURATE_MENU"])

			frame2.desaturateMenuSlider:SetPoint ("left", frame2.desaturateMenuLabel, "right", 2)
			frame2.desaturateMenuSlider.OnSwitch = function (self, instance, value)
				instance:DesaturateMenu (value)
			end
			
			frame2.desaturateMenuSlider.info = Loc ["STRING_OPTIONS_DESATURATE_MENU_DESC"]
			window:create_line_background (frame2, frame2.desaturateMenuLabel, frame2.desaturateMenuSlider)
			frame2.desaturateMenuSlider:SetHook ("OnEnter", background_on_enter)
			frame2.desaturateMenuSlider:SetHook ("OnLeave", background_on_leave)

		-- hide icon
			g:NewLabel (frame2, _, "$parentHideIconLabel", "hideIconLabel", Loc ["STRING_OPTIONS_HIDE_ICON"])

			frame2.hideIconSlider:SetPoint ("left", frame2.hideIconLabel, "right", 2)
			frame2.hideIconSlider.OnSwitch = function (self, instance, value)
				instance:HideMainIcon (value)
			end
			
			frame2.hideIconSlider.info = Loc ["STRING_OPTIONS_HIDE_ICON_DESC"]
			window:create_line_background (frame2, frame2.hideIconLabel, frame2.hideIconSlider)
			frame2.hideIconSlider:SetHook ("OnEnter", background_on_enter)
			frame2.hideIconSlider:SetHook ("OnLeave", background_on_leave)
			
		-- menu anchors
			g:NewLabel (frame2, _, "$parentMenuAnchorXLabel", "menuAnchorXLabel", Loc ["STRING_OPTIONS_MENU_X"])
			frame2.menuAnchorXSlider:SetPoint ("left", frame2.menuAnchorXLabel, "right", 2)
			frame2.menuAnchorXSlider:SetThumbSize (50)
			frame2.menuAnchorXSlider:SetHook ("OnValueChange", function (self, instance, x) 
				instance:MenuAnchor (x, nil)
			end)
			
			frame2.menuAnchorXSlider.info = Loc ["STRING_OPTIONS_MENU_X_DESC"]
			window:create_line_background (frame2, frame2.menuAnchorXLabel, frame2.menuAnchorXSlider)
			frame2.menuAnchorXSlider:SetHook ("OnEnter", background_on_enter)
			frame2.menuAnchorXSlider:SetHook ("OnLeave", background_on_leave)
			
			g:NewLabel (frame2, _, "$parentMenuAnchorYLabel", "menuAnchorYLabel", Loc ["STRING_OPTIONS_MENU_Y"])
			frame2.menuAnchorYSlider:SetPoint ("left", frame2.menuAnchorYLabel, "right", 2)
			frame2.menuAnchorYSlider:SetThumbSize (50)
			frame2.menuAnchorYSlider:SetHook ("OnValueChange", function (self, instance, y)
				instance:MenuAnchor (nil, y)
			end)
			
			frame2.menuAnchorYSlider.info = Loc ["STRING_OPTIONS_MENU_Y_DESC"]
			window:create_line_background (frame2, frame2.menuAnchorYLabel, frame2.menuAnchorYSlider)
			frame2.menuAnchorYSlider:SetHook ("OnEnter", background_on_enter)
			frame2.menuAnchorYSlider:SetHook ("OnLeave", background_on_leave)
			
		-- instance button anchors
			g:NewLabel (frame2, _, "$parentInstanceButtonAnchorXLabel", "instanceButtonAnchorXLabel", Loc ["STRING_OPTIONS_INSBUTTON_X"])
			frame2.instanceButtonAnchorXSlider:SetPoint ("left", frame2.instanceButtonAnchorXLabel, "right", 2)
			frame2.instanceButtonAnchorXSlider:SetThumbSize (50)
			frame2.instanceButtonAnchorXSlider:SetHook ("OnValueChange", function (self, instance, x)
				instance:InstanceButtonAnchor (x, nil)
			end)
			
			frame2.instanceButtonAnchorXSlider.info = Loc ["STRING_OPTIONS_INSBUTTON_X_DESC"]
			window:create_line_background (frame2, frame2.instanceButtonAnchorXLabel, frame2.instanceButtonAnchorXSlider)
			frame2.instanceButtonAnchorXSlider:SetHook ("OnEnter", background_on_enter)
			frame2.instanceButtonAnchorXSlider:SetHook ("OnLeave", background_on_leave)
			
			g:NewLabel (frame2, _, "$parentInstanceButtonAnchorYLabel", "instanceButtonAnchorYLabel", Loc ["STRING_OPTIONS_INSBUTTON_Y"])
			frame2.instanceButtonAnchorYSlider:SetPoint ("left", frame2.instanceButtonAnchorYLabel, "right", 2)
			frame2.instanceButtonAnchorYSlider:SetThumbSize (50)
			frame2.instanceButtonAnchorYSlider:SetHook ("OnValueChange", function (self, instance, y)
				instance:InstanceButtonAnchor (nil, y)
			end)

			frame2.instanceButtonAnchorYSlider.info =Loc ["STRING_OPTIONS_INSBUTTON_Y_DESC"]
			window:create_line_background (frame2, frame2.instanceButtonAnchorYLabel, frame2.instanceButtonAnchorYSlider)
			frame2.instanceButtonAnchorYSlider:SetHook ("OnEnter", background_on_enter)
			frame2.instanceButtonAnchorYSlider:SetHook ("OnLeave", background_on_leave)
		
		-- reset button
			-- text color
			g:NewLabel (frame2, _, "$parentResetTextColorLabel", "resetTextColorLabel", Loc ["STRING_OPTIONS_RESET_TEXTCOLOR"])

			frame2.resetTextColorImage:SetPoint ("left", frame2.resetTextColorLabel, "right", 2)
			
			frame2.resetTextColorButton:SetPoint ("left", frame2.resetTextColorLabel, "right", 2)
			frame2.resetTextColorButton:InstallCustomTexture()
			
			frame2.resetTextColorButton.info = Loc ["STRING_OPTIONS_RESET_TEXTCOLOR_DESC"]
			window:create_line_background (frame2, frame2.resetTextColorLabel, frame2.resetTextColorButton)
			frame2.resetTextColorButton:SetHook ("OnEnter", background_on_enter)
			frame2.resetTextColorButton:SetHook ("OnLeave", background_on_leave)
			
			-- text font
			g:NewLabel (frame2, _, "$parentResetTextFontLabel", "resetTextFontLabel", Loc ["STRING_OPTIONS_RESET_TEXTFONT"])
			frame2.resetTextFontDropdown:SetPoint ("left", frame2.resetTextFontLabel, "right", 2)
			
			frame2.resetTextFontDropdown.info = Loc ["STRING_OPTIONS_RESET_TEXTFONT_DESC"]
			window:create_line_background (frame2, frame2.resetTextFontLabel, frame2.resetTextFontDropdown)
			frame2.resetTextFontDropdown:SetHook ("OnEnter", background_on_enter)
			frame2.resetTextFontDropdown:SetHook ("OnLeave", background_on_leave)
			
			-- text size
			g:NewLabel (frame2, _, "$parentResetTextSizeLabel", "resetTextSizeLabel", Loc ["STRING_OPTIONS_RESET_TEXTSIZE"])
			frame2.resetTextSizeSlider:SetPoint ("left", frame2.resetTextSizeLabel, "right", 2)
			
			frame2.resetTextSizeSlider.info = Loc ["STRING_OPTIONS_RESET_TEXTSIZE_DESC"]
			window:create_line_background (frame2, frame2.resetTextSizeLabel, frame2.resetTextSizeSlider)
			frame2.resetTextSizeSlider:SetHook ("OnEnter", background_on_enter)
			frame2.resetTextSizeSlider:SetHook ("OnLeave", background_on_leave)

			-- color overlay
			g:NewLabel (frame2, _, "$parentResetOverlayColorLabel", "resetOverlayColorLabel", Loc ["STRING_OPTIONS_RESET_OVERLAY"])

			frame2.resetOverlayColorImage:SetPoint ("left", frame2.resetOverlayColorLabel, "right", 2)
			
			frame2.resetOverlayColorButton:SetPoint ("left", frame2.resetOverlayColorLabel, "right", 2)
			frame2.resetOverlayColorButton:InstallCustomTexture()
			
			frame2.resetOverlayColorButton.info = Loc ["STRING_OPTIONS_RESET_OVERLAY_DESC"]
			window:create_line_background (frame2, frame2.resetOverlayColorLabel, frame2.resetOverlayColorButton)
			frame2.resetOverlayColorButton:SetHook ("OnEnter", background_on_enter)
			frame2.resetOverlayColorButton:SetHook ("OnLeave", background_on_leave)
			
		-- reset always small
			g:NewLabel (frame2, _, "$parentResetAlwaysSmallLabel", "resetAlwaysSmallLabel", Loc ["STRING_OPTIONS_RESET_SMALL"])
			
			frame2.resetAlwaysSmallSlider:SetPoint ("left", frame2.resetAlwaysSmallLabel, "right", 2)
			frame2.resetAlwaysSmallSlider.OnSwitch = function (self, instance, value)
				instance:SetDeleteButtonSettings (nil, nil, nil, nil, value)
			end
			
			frame2.resetAlwaysSmallSlider.info = Loc ["STRING_OPTIONS_RESET_SMALL_DESC"]
			window:create_line_background (frame2, frame2.resetAlwaysSmallLabel, frame2.resetAlwaysSmallSlider)
			frame2.resetAlwaysSmallSlider:SetHook ("OnEnter", background_on_enter)
			frame2.resetAlwaysSmallSlider:SetHook ("OnLeave", background_on_leave)
			
		-- stretch button anchor
			g:NewLabel (frame2, _, "$parentStretchAnchorLabel", "stretchAnchorLabel", Loc ["STRING_OPTIONS_STRETCH"])

			frame2.stretchAnchorSlider:SetPoint ("left", frame2.stretchAnchorLabel, "right", 2)
			frame2.stretchAnchorSlider.OnSwitch = function (self, instance, value)
				instance:StretchButtonAnchor (value and 2 or 1)
			end
			frame2.stretchAnchorSlider.thumb:SetSize (40, 12)
			
			frame2.stretchAnchorSlider.info = Loc ["STRING_OPTIONS_STRETCH_DESC"]
			window:create_line_background (frame2, frame2.stretchAnchorLabel, frame2.stretchAnchorSlider)
			frame2.stretchAnchorSlider:SetHook ("OnEnter", background_on_enter)
			frame2.stretchAnchorSlider:SetHook ("OnLeave", background_on_leave)

		-- plugin icons direction
			g:NewLabel (frame2, _, "$parentPluginIconsDirectionLabel", "pluginIconsDirectionLabel", Loc ["STRING_OPTIONS_PICONS_DIRECTION"])

			frame2.pluginIconsDirectionSlider:SetPoint ("left", frame2.pluginIconsDirectionLabel, "right", 2)
			frame2.pluginIconsDirectionSlider.OnSwitch = function (self, instance, value)
				instance.plugins_grow_direction = value and 2 or 1
				instance:DefaultIcons()
			end
			frame2.pluginIconsDirectionSlider.thumb:SetSize (40, 12)
			
			frame2.pluginIconsDirectionSlider.info = Loc ["STRING_OPTIONS_PICONS_DIRECTION_DESC"]
			window:create_line_background (frame2, frame2.pluginIconsDirectionLabel, frame2.pluginIconsDirectionSlider)
			frame2.pluginIconsDirectionSlider:SetHook ("OnEnter", background_on_enter)
			frame2.pluginIconsDirectionSlider:SetHook ("OnLeave", background_on_leave)
			
		-- instance toolbar side
			g:NewLabel (frame2, _, "$parentInstanceToolbarSideLabel", "instanceToolbarSideLabel", Loc ["STRING_OPTIONS_TOOLBARSIDE"])

			frame2.instanceToolbarSideSlider:SetPoint ("left", frame2.instanceToolbarSideLabel, "right", 2)
			frame2.instanceToolbarSideSlider.OnSwitch = function (self, instance, value)
				instance.toolbar_side = value and 2 or 1
				instance:ToolbarSide (side)
				
			end
			frame2.instanceToolbarSideSlider.thumb:SetSize (50, 12)
			
			frame2.instanceToolbarSideSlider.info = Loc ["STRING_OPTIONS_TOOLBARSIDE_DESC"]
			window:create_line_background (frame2, frame2.instanceToolbarSideLabel, frame2.instanceToolbarSideSlider)
			frame2.instanceToolbarSideSlider:SetHook ("OnEnter", background_on_enter)
			frame2.instanceToolbarSideSlider:SetHook ("OnLeave", background_on_leave)
			
		-- bar grow direction
			g:NewLabel (frame2, _, "$parentBarGrowDirectionLabel", "barGrowDirectionLabel", Loc ["STRING_OPTIONS_BARGROW_DIRECTION"])

			frame2.barGrowDirectionSlider:SetPoint ("left", frame2.barGrowDirectionLabel, "right", 2)
			frame2.barGrowDirectionSlider.OnSwitch = function (self, instance, value)
				instance:SetBarGrowDirection (value and 2 or 1)
			end
			frame2.barGrowDirectionSlider.thumb:SetSize (50, 12)
			
			frame2.barGrowDirectionSlider.info = Loc ["STRING_OPTIONS_BARGROW_DIRECTION_DESC"]
			window:create_line_background (frame2, frame2.barGrowDirectionLabel, frame2.barGrowDirectionSlider)
			frame2.barGrowDirectionSlider:SetHook ("OnEnter", background_on_enter)
			frame2.barGrowDirectionSlider:SetHook ("OnLeave", background_on_leave)
			
		-- bar sort direction
			g:NewLabel (frame2, _, "$parentBarSortDirectionLabel", "barSortDirectionLabel", Loc ["STRING_OPTIONS_BARSORT_DIRECTION"])

			frame2.barSortDirectionSlider:SetPoint ("left", frame2.barSortDirectionLabel, "right", 2)
			frame2.barSortDirectionSlider.OnSwitch = function (self, instance, value)
				instance.bars_sort_direction = value and 2 or 1
				_detalhes:AtualizaGumpPrincipal (-1, true)
			end
			frame2.barSortDirectionSlider.thumb:SetSize (50, 12)
			
			frame2.barSortDirectionSlider.info = Loc ["STRING_OPTIONS_BARSORT_DIRECTION_DESC"]
			window:create_line_background (frame2, frame2.barSortDirectionLabel, frame2.barSortDirectionSlider)
			frame2.barSortDirectionSlider:SetHook ("OnEnter", background_on_enter)
			frame2.barSortDirectionSlider:SetHook ("OnLeave", background_on_leave)
		
		-- instance button
			-- text color
			g:NewLabel (frame2, _, "$parentInstanceTextColorLabel", "instanceTextColorLabel", Loc ["STRING_OPTIONS_INSTANCE_TEXTCOLOR"])

			frame2.instanceTextColorImage:SetPoint ("left", frame2.instanceTextColorLabel, "right", 2)
			
			frame2.instanceTextColorButton:SetPoint ("left", frame2.instanceTextColorLabel, "right", 2)
			frame2.instanceTextColorButton:InstallCustomTexture()
			
			frame2.instanceTextColorButton.info = Loc ["STRING_OPTIONS_INSTANCE_TEXTCOLOR_DESC"]
			window:create_line_background (frame2, frame2.instanceTextColorLabel, frame2.instanceTextColorButton)
			frame2.instanceTextColorButton:SetHook ("OnEnter", background_on_enter)
			frame2.instanceTextColorButton:SetHook ("OnLeave", background_on_leave)
			
			-- text font
			g:NewLabel (frame2, _, "$parentInstanceTextFontLabel", "instanceTextFontLabel", Loc ["STRING_OPTIONS_INSTANCE_TEXTFONT"])
			frame2.instanceTextFontDropdown:SetPoint ("left", frame2.instanceTextFontLabel, "right", 2)
			
			frame2.instanceTextFontDropdown.info = Loc ["STRING_OPTIONS_INSTANCE_TEXTFONT_DESC"]
			window:create_line_background (frame2, frame2.instanceTextFontLabel, frame2.instanceTextFontDropdown)
			frame2.instanceTextFontDropdown:SetHook ("OnEnter", background_on_enter)
			frame2.instanceTextFontDropdown:SetHook ("OnLeave", background_on_leave)
			
			-- text size
			g:NewLabel (frame2, _, "$parentInstanceTextSizeLabel", "instanceTextSizeLabel", Loc ["STRING_OPTIONS_INSTANCE_TEXTSIZE"])
			frame2.instanceTextSizeSlider:SetPoint ("left", frame2.instanceTextSizeLabel, "right", 2)
			
			frame2.instanceTextSizeSlider.info = Loc ["STRING_OPTIONS_INSTANCE_TEXTSIZE_DESC"]
			window:create_line_background (frame2, frame2.instanceTextSizeLabel, frame2.instanceTextSizeSlider)
			frame2.instanceTextSizeSlider:SetHook ("OnEnter", background_on_enter)
			frame2.instanceTextSizeSlider:SetHook ("OnLeave", background_on_leave)

			-- color overlay
			g:NewLabel (frame2, _, "$parentInstanceOverlayColorLabel", "instanceOverlayColorLabel", Loc ["STRING_OPTIONS_INSTANCE_OVERLAY"])

			frame2.instanceOverlayColorImage:SetPoint ("left", frame2.instanceOverlayColorLabel, "right", 2)
			
			frame2.instanceOverlayColorButton:SetPoint ("left", frame2.instanceOverlayColorLabel, "right", 2)
			frame2.instanceOverlayColorButton:InstallCustomTexture()
			
			frame2.instanceOverlayColorButton.info = Loc ["STRING_OPTIONS_INSTANCE_OVERLAY_DESC"]
			window:create_line_background (frame2, frame2.instanceOverlayColorLabel, frame2.instanceOverlayColorButton)
			frame2.instanceOverlayColorButton:SetHook ("OnEnter", background_on_enter)
			frame2.instanceOverlayColorButton:SetHook ("OnLeave", background_on_leave)
			
		-- close button
			-- color overlay
			g:NewLabel (frame2, _, "$parentCloseOverlayColorLabel", "closeOverlayColorLabel", Loc ["STRING_OPTIONS_CLOSE_OVERLAY"])

			frame2.closeOverlayColorImage:SetPoint ("left", frame2.closeOverlayColorLabel, "right", 2)
			
			frame2.closeOverlayColorButton:SetPoint ("left", frame2.closeOverlayColorLabel, "right", 2)
			frame2.closeOverlayColorButton:InstallCustomTexture()
			
			frame2.closeOverlayColorButton.info = Loc ["STRING_OPTIONS_CLOSE_OVERLAY_DESC"]
			window:create_line_background (frame2, frame2.closeOverlayColorLabel, frame2.closeOverlayColorButton)
			frame2.closeOverlayColorButton:SetHook ("OnEnter", background_on_enter)
			frame2.closeOverlayColorButton:SetHook ("OnLeave", background_on_leave)
			
			
		-- skin
		g:NewLabel (frame2, _, "$parentSkinLabel", "skinLabel", Loc ["STRING_OPTIONS_INSTANCE_SKIN"])
		frame2.skinDropdown:SetPoint ("left", frame2.skinLabel, "right", 2)
		
		frame2.skinDropdown.info = Loc ["STRING_OPTIONS_INSTANCE_SKIN_DESC"]
		window:create_line_background (frame2, frame2.skinLabel, frame2.skinDropdown)
		frame2.skinDropdown:SetHook ("OnEnter", background_on_enter)
		frame2.skinDropdown:SetHook ("OnLeave", background_on_leave)
		
	-- Wallpaper Settings	

		-- wallpaper

		g:NewLabel (frame2, _, "$parentBackgroundLabel", "enablewallpaperLabel", Loc ["STRING_OPTIONS_WP_ENABLE"])
		--
		frame2.useBackgroundSlider:SetPoint ("left", frame2.enablewallpaperLabel, "right", 2, 0) --> slider ativar ou desativar
		frame2.useBackgroundSlider.OnSwitch = function (self, instance, value)
			instance.wallpaper.enabled = value
			if (value) then
				--> primeira vez que roda:
				if (not instance.wallpaper.texture) then
					local spec = GetSpecialization()
					if (spec) then
						local id, name, description, icon, _background, role = GetSpecializationInfo (spec)
						if (_background) then
							instance.wallpaper.texture = "Interface\\TALENTFRAME\\".._background
						end
					end
					instance.wallpaper.texcoord = {0, 1, 0, 0.703125}
				end
				
				instance:InstanceWallpaper (true)
				_G.DetailsOptionsWindow2BackgroundDropdown.MyObject:Enable()
				_G.DetailsOptionsWindow2BackgroundDropdown2.MyObject:Enable()
				
			else
				instance:InstanceWallpaper (false)
				_G.DetailsOptionsWindow2BackgroundDropdown.MyObject:Disable()
				_G.DetailsOptionsWindow2BackgroundDropdown2.MyObject:Disable()
			end
		end
		
		g:NewLabel (frame2, _, "$parentBackgroundLabel", "wallpapergroupLabel", Loc ["STRING_OPTIONS_WP_GROUP"])
		g:NewLabel (frame2, _, "$parentBackgroundLabel", "selectwallpaperLabel", Loc ["STRING_OPTIONS_WP_GROUP2"])
		g:NewLabel (frame2, _, "$parentAnchorLabel", "anchorLabel", Loc ["STRING_OPTIONS_WP_ALIGN"])
		--
		frame2.anchorDropdown:SetPoint ("left", frame2.anchorLabel, "right", 2)
		--
		frame2.editImage:InstallCustomTexture()
		
		frame2.useBackgroundSlider.info = Loc ["STRING_OPTIONS_WP_ENABLE_DESC"]
		window:create_line_background (frame2, frame2.enablewallpaperLabel, frame2.useBackgroundSlider)
		frame2.useBackgroundSlider:SetHook ("OnEnter", background_on_enter)
		frame2.useBackgroundSlider:SetHook ("OnLeave", background_on_leave)
		
		frame2.anchorDropdown.info = Loc ["STRING_OPTIONS_WP_ALIGN_DESC"]
		window:create_line_background (frame2, frame2.anchorLabel, frame2.anchorDropdown)
		frame2.anchorDropdown:SetHook ("OnEnter", background_on_enter)
		frame2.anchorDropdown:SetHook ("OnLeave", background_on_leave)
		
		frame2.editImage.info = Loc ["STRING_OPTIONS_WP_EDIT_DESC"]
		window:create_line_background (frame2, frame2.editImage, frame2.editImage)
		frame2.editImage:SetHook ("OnEnter", background_on_enter)
		frame2.editImage:SetHook ("OnLeave", background_on_leave)
		
		frame2.backgroundDropdown.info = Loc ["STRING_OPTIONS_WP_GROUP_DESC"]
		window:create_line_background (frame2, frame2.wallpapergroupLabel, frame2.backgroundDropdown)
		frame2.backgroundDropdown:SetHook ("OnEnter", background_on_enter)
		frame2.backgroundDropdown:SetHook ("OnLeave", background_on_leave)
		
		frame2.backgroundDropdown2.info = Loc ["STRING_OPTIONS_WP_GROUP2_DESC"]
		window:create_line_background (frame2, frame2.selectwallpaperLabel, frame2.backgroundDropdown2)
		frame2.backgroundDropdown2:SetHook ("OnEnter", background_on_enter)
		frame2.backgroundDropdown2:SetHook ("OnLeave", background_on_leave)

----------------------- Save Style Text Entry and Button -----------------------------------------
	
		----- style name
		
		frame2.saveStyleName:SetLabelText (Loc ["STRING_OPTIONS_SAVELOAD_PNAME"] .. ":")

		----- add style button
		
		frame2.saveStyle:InstallCustomTexture()
		frame2.saveStyle:SetPoint ("left", frame2.saveStyleName, "right", 2)
		
		----- load style button
		
		frame2.loadStyle:InstallCustomTexture()
		frame2.loadStyle:SetPoint ("left", frame2.saveStyle, "right", 2)

		local createLoadMenu = function()
			for index, _table in ipairs (_detalhes.savedStyles) do 
				GameCooltip:AddLine (_table.name)
				GameCooltip:AddMenu (1, loadStyle, index)
			end
		end
		frame2.loadStyle.CoolTip = {Type = "menu", BuildFunc = createLoadMenu, FixedValue = instance}
		GameCooltip:CoolTipInject (frame2.loadStyle)
		
		------ remove style button

		frame2.removeStyle:InstallCustomTexture()
		frame2.removeStyle:SetPoint ("left", frame2.loadStyle, "right", 2)
		
		local removeStyle = function (_, _, index)
			table.remove (_detalhes.savedStyles, index)
			if (#_detalhes.savedStyles > 0) then 
				GameCooltip:ExecFunc (frame2.removeStyle)
			else
				GameCooltip:Close()
			end
		end
		
		local createRemoveMenu = function()
			for index, _table in ipairs (_detalhes.savedStyles) do 
				GameCooltip:AddLine (_table.name)
				GameCooltip:AddMenu (1, removeStyle, index)
			end
		end
		frame2.removeStyle.CoolTip = {Type = "menu", BuildFunc = createRemoveMenu}
		GameCooltip:CoolTipInject (frame2.removeStyle)
		
		frame2.applyToAll:InstallCustomTexture()
		frame2.applyToAll:SetPoint ("bottomright", frame2.removeStyle, "topright", 1, 3)

		frame2.resetToDefaults:InstallCustomTexture()
		frame2.resetToDefaults:SetPoint ("right", frame2.applyToAll, "left", -5, 0)
		
		
-- Anchors --------------------------------------------------------------------------------------------------------------------------------------------

	--> skin settings
		--title
		titulo_skin:SetPoint (10, -10)
		titulo_skin_desc:SetPoint (10, -30)
		--skin select
		frame2.skinLabel:SetPoint (10, -70)
		
	--> general bar settings
		titulo_bars:SetPoint (10, -110)
		titulo_bars_desc:SetPoint (10, -130)

		frame2.rowHeightLabel:SetPoint (10, -170) --bar height
		frame2.barGrowDirectionLabel:SetPoint (10, -190) --grow direction
		frame2.barSortDirectionLabel:SetPoint (10, -210) --sort direction
		
		frame2.textureLabel:SetPoint (10, -250) --bar texture
		frame2.classColorsLabel:SetPoint (10, -270) --class color
		frame2.rowBackgroundLabel:SetPoint (10, -290) --select background
		frame2.rowBackgroundColorByClassLabel:SetPoint (10, -310) --class color background
		frame2.rowBackgroundColorTexture:SetPoint ("left", frame2.rowBackgroundColorByClassSlider, "right", 2) --bar color background
		
	--> text bar settings
		titulo_texts:SetPoint (10, -350)
		titulo_texts_desc:SetPoint (10, -370)
		
		frame2.fonsizeLabel:SetPoint (10, -410) --text size
		frame2.fontLabel:SetPoint (10, -430) --text fontface
		frame2.textLeftOutlineLabel:SetPoint (10, -450) --left outline
		frame2.textRightOutlineLabel:SetPoint (10, -470) --right outline
		frame2.classColorsLeftTextLabel:SetPoint (10, -490) --left color by class
		frame2.classColorsRightTextLabel:SetPoint (10, -510) --right color by class
		
	--> window settings
		titulo_instance:SetPoint (10, -550)
		titulo_instance_desc:SetPoint (10, -570)
		
		frame2.instancecolor:SetPoint (10, -610) --window color
		frame2.alphaLabel:SetPoint (10, -630) --background alpha
		frame2.backgroundColorLabel:SetPoint (10, -650) --background color
		
		frame2.autoCurrentLabel:SetPoint (10, -670) --auto current
		frame2.instanceToolbarSideLabel:SetPoint (10, -690)
		frame2.sideBarsLabel:SetPoint (10, -710) --borders
		frame2.statusbarLabel:SetPoint (10, -730) --statusbar
		frame2.stretchAnchorLabel:SetPoint (10, -750) --stretch direction

	--> toolbar settings
		titulo_toolbar:SetPoint (10, -790)
		titulo_toolbar_desc:SetPoint (10, -810)

		frame2.menuAnchorXLabel:SetPoint (10, -850)
		frame2.menuAnchorYLabel:SetPoint (10, -870)
		frame2.desaturateMenuLabel:SetPoint (10, -890)
		frame2.hideIconLabel:SetPoint (10, -910)
		frame2.pluginIconsDirectionLabel:SetPoint (10, -930)

		frame2.instanceButtonAnchorXLabel:SetPoint (10, -970)
		frame2.instanceButtonAnchorYLabel:SetPoint (10, -990)
		frame2.instanceTextColorLabel:SetPoint (10, -1010)
		frame2.instanceTextFontLabel:SetPoint (10, -1030)
		frame2.instanceTextSizeLabel:SetPoint (10, -1050)
		frame2.instanceOverlayColorLabel:SetPoint (10, -1070)		

		frame2.resetTextColorLabel:SetPoint (10, -1110)
		frame2.resetTextFontLabel:SetPoint (10, -1130)
		frame2.resetTextSizeLabel:SetPoint (10, -1150)
		frame2.resetOverlayColorLabel:SetPoint (10, -1170)
		frame2.resetAlwaysSmallLabel:SetPoint (10, -1190)

		frame2.closeOverlayColorLabel:SetPoint (10, -1230)
		
	--> wallpaper settings
		titulo_wallpaper:SetPoint (10, -1270)
		titulo_wallpaper_desc:SetPoint (10, -1290)
		
		frame2.enablewallpaperLabel:SetPoint (10, -1330)
		
		frame2.wallpapergroupLabel:SetPoint (10, -1350)
		frame2.selectwallpaperLabel:SetPoint (135, -1350)
		
		frame2.backgroundDropdown:SetPoint ("topleft", frame2.wallpapergroupLabel, "bottomleft")
		frame2.backgroundDropdown2:SetPoint ("topleft", frame2.selectwallpaperLabel, "bottomleft")
		
		frame2.anchorLabel:SetPoint (10, -1390)
		frame2.editImage:SetPoint (10, -1410)
		
	--> save and load
		
		titulo_save:SetPoint (10, -1450)
		titulo_save_desc:SetPoint (10, -1470)
		
		frame2.saveStyleName:SetPoint (10, -1510)
		
---------------- performance
		local frame3 = window.options [3][1].gump
		
		local titulo_performance_general = g:NewLabel (frame3, _, "$parentTituloPerformance1", "tituloPerformance1Label", Loc ["STRING_OPTIONS_PERFORMANCE1"], "GameFontNormal", 16)
		titulo_performance_general:SetPoint (10, -10)
		local titulo_performance_general_desc = g:NewLabel (frame3, _, "$parentTituloPersona2", "tituloPersona2Label", Loc ["STRING_OPTIONS_PERFORMANCE1_DESC"], "GameFontNormal", 9, "white")
		titulo_performance_general_desc.width = 250
		titulo_performance_general_desc:SetPoint (10, -30)
		
	--------------- Memory		
		g:NewSlider (frame3, _, "$parentSliderSegmentsSave", "segmentsSliderToSave", SLIDER_WIDTH, 20, 1, 5, 1, _detalhes.segments_amount_to_save)
		g:NewSlider (frame3, _, "$parentSliderUpdateSpeed", "updatespeedSlider", SLIDER_WIDTH, 20, 0.3, 3, 0.1, _detalhes.update_speed, true)
	
		g:NewLabel (frame3, _, "$parentLabelMemory", "memoryLabel", Loc ["STRING_OPTIONS_MEMORYT"])
		frame3.memoryLabel:SetPoint (10, -70)
		
		g:NewSlider (frame3, _, "$parentSliderMemory", "memorySlider", SLIDER_WIDTH, 20, 1, 4, 1, _detalhes.memory_threshold)
		frame3.memorySlider:SetPoint ("left", frame3.memoryLabel, "right", 2, 0)
		frame3.memorySlider:SetHook ("OnValueChange", function (slider, _, amount)
			
			amount = math.floor (amount)
			
			if (amount == 1) then
				slider.amt:SetText ("<= 1gb")
				_detalhes.memory_ram = 16
				
			elseif (amount == 2) then
				slider.amt:SetText ("2gb")
				_detalhes.memory_ram = 32
				
			elseif (amount == 3) then
				slider.amt:SetText ("4gb")
				_detalhes.memory_ram = 64
				
			elseif (amount == 4) then
				slider.amt:SetText (">= 6gb")
				_detalhes.memory_ram = 128
				
			end
			
			_detalhes.memory_threshold = amount
			
			return true
		end)
		frame3.memorySlider.info = Loc ["STRING_OPTIONS_MEMORYT_DESC"]
		frame3.memorySlider.thumb:SetSize (40, 12)
		frame3.memorySlider.thumb:SetTexture ([[Interface\Buttons\UI-Listbox-Highlight2]])
		frame3.memorySlider.thumb:SetVertexColor (.2, .2, .2, .9)
		local t = _detalhes.memory_threshold
		frame3.memorySlider:SetValue (1)
		frame3.memorySlider:SetValue (2)
		frame3.memorySlider:SetValue (t)
		
		window:create_line_background (frame3, frame3.memoryLabel, frame3.memorySlider)
		frame3.memorySlider:SetHook ("OnEnter", background_on_enter)
		frame3.memorySlider:SetHook ("OnLeave", background_on_leave)
		
	--------------- Max Segments Saved
		g:NewLabel (frame3, _, "$parentLabelSegmentsSave", "segmentsSaveLabel", Loc ["STRING_OPTIONS_SEGMENTSSAVE"])
		frame3.segmentsSaveLabel:SetPoint (10, -90)
		--
		
		frame3.segmentsSliderToSave:SetPoint ("left", frame3.segmentsSaveLabel, "right", 2, 0)
		frame3.segmentsSliderToSave:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.segments_amount_to_save = math.floor (amount)
		end)
		frame3.segmentsSliderToSave.info = Loc ["STRING_OPTIONS_SEGMENTSSAVE_DESC"]
	
		window:create_line_background (frame3, frame3.segmentsSaveLabel, frame3.segmentsSliderToSave)
		frame3.segmentsSliderToSave:SetHook ("OnEnter", background_on_enter)
		frame3.segmentsSliderToSave:SetHook ("OnLeave", background_on_leave)
	
	--------------- Panic Mode
		g:NewLabel (frame3, _, "$parentPanicModeLabel", "panicModeLabel", Loc ["STRING_OPTIONS_PANIMODE"])
		frame3.panicModeLabel:SetPoint (10, -110)
		--
		g:NewSwitch (frame3, _, "$parentPanicModeSlider", "panicModeSlider", 60, 20, _, _, _detalhes.segments_panic_mode)
		frame3.panicModeSlider:SetPoint ("left", frame3.panicModeLabel, "right", 2, 0)
		frame3.panicModeSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.segments_panic_mode = value
		end
		frame3.panicModeSlider.info = Loc ["STRING_OPTIONS_PANIMODE_DESC"]
		
		window:create_line_background (frame3, frame3.panicModeLabel, frame3.panicModeSlider)
		frame3.panicModeSlider:SetHook ("OnEnter", background_on_enter)
		frame3.panicModeSlider:SetHook ("OnLeave", background_on_leave)		
		
	--------------- Animate Rows
		g:NewLabel (frame3, _, "$parentAnimateLabel", "animateLabel", Loc ["STRING_OPTIONS_ANIMATEBARS"])
		frame3.animateLabel:SetPoint (10, -130)
		--
		g:NewSwitch (frame3, _, "$parentAnimateSlider", "animateSlider", 60, 20, _, _, _detalhes.use_row_animations) -- ltext, rtext, defaultv
		frame3.animateSlider:SetPoint ("left",frame3.animateLabel, "right", 2, 0)
		frame3.animateSlider.info = Loc ["STRING_OPTIONS_ANIMATEBARS_DESC"]
		frame3.animateSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue (false, true)
			_detalhes.use_row_animations = value
		end
		
		window:create_line_background (frame3, frame3.animateLabel, frame3.animateSlider)
		frame3.animateSlider:SetHook ("OnEnter", background_on_enter)
		frame3.animateSlider:SetHook ("OnLeave", background_on_leave)
		
	--------------- Animate scroll bar
		g:NewLabel (frame3, _, "$parentAnimateScrollLabel", "animatescrollLabel", Loc ["STRING_OPTIONS_ANIMATESCROLL"])
		frame3.animatescrollLabel:SetPoint (10, -150)
		--
		g:NewSwitch (frame3, _, "$parentClearAnimateScrollSlider", "animatescrollSlider", 60, 20, _, _, _detalhes.animate_scroll) -- ltext, rtext, defaultv
		frame3.animatescrollSlider:SetPoint ("left", frame3.animatescrollLabel, "right", 2, 0)
		frame3.animatescrollSlider.info = Loc ["STRING_OPTIONS_ANIMATESCROLL_DESC"]
		frame3.animatescrollSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.animate_scroll = value
		end
		
		window:create_line_background (frame3, frame3.animatescrollLabel, frame3.animatescrollSlider)
		frame3.animatescrollSlider:SetHook ("OnEnter", background_on_enter)
		frame3.animatescrollSlider:SetHook ("OnLeave", background_on_leave)		
		
	--------------- Update Speed
		g:NewLabel (frame3, _, "$parentUpdateSpeedLabel", "updatespeedLabel", Loc ["STRING_OPTIONS_WINDOWSPEED"])
		frame3.updatespeedLabel:SetPoint (10, -170)
		--
		frame3.updatespeedSlider:SetPoint ("left", frame3.updatespeedLabel, "right", 2, 0)
		frame3.updatespeedSlider:SetThumbSize (50)
		frame3.updatespeedSlider.useDecimals = true
		local updateColor = function (slider, value)
			if (value < 1) then
				slider.amt:SetTextColor (1, value, 0)
			elseif (value > 1) then
				slider.amt:SetTextColor (-(value-3), 1, 0)
			else
				slider.amt:SetTextColor (1, 1, 0)
			end
		end
		frame3.updatespeedSlider:SetHook ("OnValueChange", function (self, _, amount) 
			_detalhes:CancelTimer (_detalhes.atualizador)
			_detalhes.update_speed = amount
			_detalhes.atualizador = _detalhes:ScheduleRepeatingTimer ("AtualizaGumpPrincipal", _detalhes.update_speed, -1)
			updateColor (self, amount)
		end)
		updateColor (frame3.updatespeedSlider, _detalhes.update_speed)
		
		frame3.updatespeedSlider.info = Loc ["STRING_OPTIONS_WINDOWSPEED_DESC"]

		window:create_line_background (frame3, frame3.updatespeedLabel, frame3.updatespeedSlider)
		frame3.updatespeedSlider:SetHook ("OnEnter", background_on_enter)
		frame3.updatespeedSlider:SetHook ("OnLeave", background_on_leave)		
		
	--------------- Erase Trash
		g:NewLabel (frame3, _, "$parentEraseTrash", "eraseTrashLabel", Loc ["STRING_OPTIONS_CLEANUP"])
		frame3.eraseTrashLabel:SetPoint (10, -190)
		--
		g:NewSwitch (frame3, _, "$parentRemoveTrashSlider", "removeTrashSlider", 60, 20, _, _, _detalhes.trash_auto_remove)
		frame3.removeTrashSlider:SetPoint ("left", frame3.eraseTrashLabel, "right")
		frame3.removeTrashSlider.OnSwitch = function (self, _, amount)
			_detalhes.trash_auto_remove = amount
		end
		frame3.removeTrashSlider.info = Loc ["STRING_OPTIONS_CLEANUP_DESC"]
		
		window:create_line_background (frame3, frame3.eraseTrashLabel, frame3.removeTrashSlider)
		frame3.removeTrashSlider:SetHook ("OnEnter", background_on_enter)
		frame3.removeTrashSlider:SetHook ("OnLeave", background_on_leave)			
		
		local titulo_performance_captures = g:NewLabel (frame3, _, "$parentTituloPerformanceCaptures", "tituloPerformanceCaptures", Loc ["STRING_OPTIONS_PERFORMANCECAPTURES"], "GameFontNormal", 16)
		titulo_performance_captures:SetPoint (10, -230)
		local titulo_performance_captures_desc = g:NewLabel (frame3, _, "$parentTituloPersonaCaptures2", "tituloPersonaCaptures2Label", Loc ["STRING_OPTIONS_PERFORMANCECAPTURES_DESC"], "GameFontNormal", 9, "white")
		titulo_performance_captures_desc.width = 250
		titulo_performance_captures_desc:SetPoint (10, -250)
		
	--------------- Captures
		g:NewImage (frame3, _, "$parentCaptureDamage", "damageCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		frame3.damageCaptureImage:SetPoint (10, -290)
		frame3.damageCaptureImage:SetTexCoord (0, 0.125, 0, 1)
		
		g:NewImage (frame3, _, "$parentCaptureHeal", "healCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		frame3.healCaptureImage:SetPoint (10, -310)
		frame3.healCaptureImage:SetTexCoord (0.125, 0.25, 0, 1)
		
		g:NewImage (frame3, _, "$parentCaptureEnergy", "energyCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		frame3.energyCaptureImage:SetPoint (10, -330)
		frame3.energyCaptureImage:SetTexCoord (0.25, 0.375, 0, 1)
		
		g:NewImage (frame3, _, "$parentCaptureMisc", "miscCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		frame3.miscCaptureImage:SetPoint (10, -350)
		frame3.miscCaptureImage:SetTexCoord (0.375, 0.5, 0, 1)
		
		g:NewImage (frame3, _, "$parentCaptureAura", "auraCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		frame3.auraCaptureImage:SetPoint (10, -370)
		frame3.auraCaptureImage:SetTexCoord (0.5, 0.625, 0, 1)
		
		g:NewLabel (frame3, _, "$parentCaptureDamageLabel", "damageCaptureLabel", Loc ["STRING_OPTIONS_CDAMAGE"])
		frame3.damageCaptureLabel:SetPoint ("left", frame3.damageCaptureImage, "right", 2)
		
		g:NewLabel (frame3, _, "$parentCaptureDamageLabel", "healCaptureLabel", Loc ["STRING_OPTIONS_CHEAL"])
		frame3.healCaptureLabel:SetPoint ("left", frame3.healCaptureImage, "right", 2)
		
		g:NewLabel (frame3, _, "$parentCaptureDamageLabel", "energyCaptureLabel", Loc ["STRING_OPTIONS_CENERGY"])
		frame3.energyCaptureLabel:SetPoint ("left", frame3.energyCaptureImage, "right", 2)
		
		g:NewLabel (frame3, _, "$parentCaptureDamageLabel", "miscCaptureLabel", Loc ["STRING_OPTIONS_CMISC"])
		frame3.miscCaptureLabel:SetPoint ("left", frame3.miscCaptureImage, "right", 2)
		
		g:NewLabel (frame3, _, "$parentCaptureDamageLabel", "auraCaptureLabel", Loc ["STRING_OPTIONS_CAURAS"])
		frame3.auraCaptureLabel:SetPoint ("left", frame3.auraCaptureImage, "right", 2)
		
		local switch_icon_color = function (icon, on_off)
			icon:SetDesaturated (not on_off)
		end
		
		g:NewSwitch (frame3, _, "$parentCaptureDamageSlider", "damageCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["damage"])
		frame3.damageCaptureSlider:SetPoint ("left", frame3.damageCaptureLabel, "right", 2)
		frame3.damageCaptureSlider.info = Loc ["STRING_OPTIONS_CDAMAGE_DESC"]
		frame3.damageCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "damage", true)
			switch_icon_color (frame3.damageCaptureImage, value)
		end
		switch_icon_color (frame3.damageCaptureImage, _detalhes.capture_real ["damage"])
		
		window:create_line_background (frame3, frame3.damageCaptureLabel, frame3.damageCaptureSlider)
		frame3.damageCaptureSlider:SetHook ("OnEnter", background_on_enter)
		frame3.damageCaptureSlider:SetHook ("OnLeave", background_on_leave)
		
		g:NewSwitch (frame3, _, "$parentCaptureHealSlider", "healCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["heal"])
		frame3.healCaptureSlider:SetPoint ("left", frame3.healCaptureLabel, "right", 2)
		frame3.healCaptureSlider.info = Loc ["STRING_OPTIONS_CHEAL_DESC"]
		frame3.healCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "heal", true)
			switch_icon_color (frame3.healCaptureImage, value)
		end
		switch_icon_color (frame3.healCaptureImage, _detalhes.capture_real ["heal"])
		
		window:create_line_background (frame3, frame3.healCaptureLabel, frame3.healCaptureSlider)
		frame3.healCaptureSlider:SetHook ("OnEnter", background_on_enter)
		frame3.healCaptureSlider:SetHook ("OnLeave", background_on_leave)	
		
		g:NewSwitch (frame3, _, "$parentCaptureEnergySlider", "energyCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["energy"])
		frame3.energyCaptureSlider:SetPoint ("left", frame3.energyCaptureLabel, "right", 2)
		frame3.energyCaptureSlider.info = Loc ["STRING_OPTIONS_CENERGY_DESC"]
		frame3.energyCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "energy", true)
			switch_icon_color (frame3.energyCaptureImage, value)
		end
		switch_icon_color (frame3.energyCaptureImage, _detalhes.capture_real ["energy"])
		
		window:create_line_background (frame3, frame3.energyCaptureLabel, frame3.energyCaptureSlider)
		frame3.energyCaptureSlider:SetHook ("OnEnter", background_on_enter)
		frame3.energyCaptureSlider:SetHook ("OnLeave", background_on_leave)	
		
		g:NewSwitch (frame3, _, "$parentCaptureMiscSlider", "miscCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["miscdata"])
		frame3.miscCaptureSlider:SetPoint ("left", frame3.miscCaptureLabel, "right", 2)
		frame3.miscCaptureSlider.info = Loc ["STRING_OPTIONS_CMISC_DESC"]
		frame3.miscCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "miscdata", true)
			switch_icon_color (frame3.miscCaptureImage, value)
		end
		switch_icon_color (frame3.miscCaptureImage, _detalhes.capture_real ["miscdata"])
		
		window:create_line_background (frame3, frame3.miscCaptureLabel, frame3.miscCaptureSlider)
		frame3.miscCaptureSlider:SetHook ("OnEnter", background_on_enter)
		frame3.miscCaptureSlider:SetHook ("OnLeave", background_on_leave)		
		
		g:NewSwitch (frame3, _, "$parentCaptureAuraSlider", "auraCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["aura"])
		frame3.auraCaptureSlider:SetPoint ("left", frame3.auraCaptureLabel, "right", 2)
		frame3.auraCaptureSlider.info = Loc ["STRING_OPTIONS_CAURAS_DESC"]
		frame3.auraCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "aura", true)
			switch_icon_color (frame3.auraCaptureImage, value)
		end
		switch_icon_color (frame3.auraCaptureImage, _detalhes.capture_real ["aura"])
		
		window:create_line_background (frame3, frame3.auraCaptureLabel, frame3.auraCaptureSlider)
		frame3.auraCaptureSlider:SetHook ("OnEnter", background_on_enter)
		frame3.auraCaptureSlider:SetHook ("OnLeave", background_on_leave)		
		
	--------------- Cloud Capture
	
		g:NewLabel (frame3, _, "$parentCloudCaptureLabel", "cloudCaptureLabel", Loc ["STRING_OPTIONS_CLOUD"])
		frame3.cloudCaptureLabel:SetPoint (10, -400)
	
		g:NewSwitch (frame3, _, "$parentCloudAuraSlider", "cloudCaptureSlider", 60, 20, _, _, _detalhes.cloud_capture)
		frame3.cloudCaptureSlider:SetPoint ("left", frame3.cloudCaptureLabel, "right", 2)
		frame3.cloudCaptureSlider.info = Loc ["STRING_OPTIONS_CLOUD_DESC"] 
		frame3.cloudCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes.cloud_capture = value
		end
		
		window:create_line_background (frame3, frame3.cloudCaptureLabel, frame3.cloudCaptureSlider)
		frame3.cloudCaptureSlider:SetHook ("OnEnter", background_on_enter)
		frame3.cloudCaptureSlider:SetHook ("OnLeave", background_on_leave)		

	--------------- Concatenate Trash
	--[[
		g:NewLabel (frame3, _, "$parentConcatenateTrash", "concatenateTrashLabel", "concatenate clean up segments")
		frame3.concatenateTrashLabel:SetPoint (10, -344)
		--
		g:NewSwitch (frame3, _, "$parentConcatenateTrashSlider", "concatenateTrashSlider", 60, 20, _, _, _detalhes.trash_concatenate)
		frame3.concatenateTrashSlider:SetPoint ("left", frame3.concatenateTrashLabel, "right")
		frame3.concatenateTrashSlider.OnSwitch = function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.trash_concatenate = amount
		end
		frame3.concatenateTrashSlider.tooltip = "Concatenate the next boss segments into only one."
		--]]
		

	
-------- plugins
	local frame4 = window.options [4][1].gump
	
	local on_enter = function (self)
		self:SetBackdropColor (.3, .3, .3, .8)
	end
	
	local on_leave = function (self)
		self:SetBackdropColor (.3, .3, .3, .3)
	end
	
	local y = -20
	
	--toolbar
	g:NewLabel (frame4, _, "$parentToolbarPluginsLabel", "toolbarLabel", "Toolbar Plugins", "GameFontNormal", 16)
	frame4.toolbarLabel:SetPoint ("topleft", frame4, "topleft", 10, y)
	
	y = y - 30
	
	do
		local descbar = frame4:CreateTexture (nil, "artwork")
		descbar:SetTexture (.3, .3, .3, .8)
		descbar:SetPoint ("topleft", frame4, "topleft", 5, y+3)
		descbar:SetSize (480, 20)
		g:NewLabel (frame4, _, "$parentDescNameLabel", "descNameLabel", "Name", "GameFontNormal", 12)
		frame4.descNameLabel:SetPoint ("topleft", frame4, "topleft", 15, y)
		g:NewLabel (frame4, _, "$parentDescAuthorLabel", "descAuthorLabel", "Author", "GameFontNormal", 12)
		frame4.descAuthorLabel:SetPoint ("topleft", frame4, "topleft", 180, y)
		g:NewLabel (frame4, _, "$parentDescVersionLabel", "descVersionLabel", "Version", "GameFontNormal", 12)
		frame4.descVersionLabel:SetPoint ("topleft", frame4, "topleft", 290, y)
		g:NewLabel (frame4, _, "$parentDescEnabledLabel", "descEnabledLabel", "Enabled", "GameFontNormal", 12)
		frame4.descEnabledLabel:SetPoint ("topleft", frame4, "topleft", 400, y)
	end
	
	y = y - 30
	
	local i = 1
	local allplugins_toolbar = _detalhes.ToolBar.NameTable
	for absName, pluginObject in pairs (allplugins_toolbar) do 
	
		local bframe = CreateFrame ("frame", "OptionsPluginToolbarBG", frame4)
		bframe:SetSize (480, 20)
		bframe:SetPoint ("topleft", frame4, "topleft", 10, y)
		bframe:SetBackdrop ({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, insets = {left = 1, right = 1, top = 0, bottom = 1}})
		bframe:SetBackdropColor (.3, .3, .3, .3)
		bframe:SetScript ("OnEnter", on_enter)
		bframe:SetScript ("OnLeave", on_leave)
	
		g:NewImage (bframe, _, "$parentToolbarPluginsIcon"..i, "toolbarPluginsIcon"..i, 18, 18, pluginObject.__icon)
		bframe ["toolbarPluginsIcon"..i]:SetPoint ("topleft", frame4, "topleft", 10, y)
	
		g:NewLabel (bframe, _, "$parentToolbarPluginsLabel"..i, "toolbarPluginsLabel"..i, pluginObject.__name)
		bframe ["toolbarPluginsLabel"..i]:SetPoint ("left", bframe ["toolbarPluginsIcon"..i], "right", 2, 0)
		
		g:NewLabel (bframe, _, "$parentToolbarPluginsLabel2"..i, "toolbarPluginsLabel2"..i, pluginObject.__author)
		bframe ["toolbarPluginsLabel2"..i]:SetPoint ("topleft", frame4, "topleft", 180, y-4)
		
		g:NewLabel (bframe, _, "$parentToolbarPluginsLabel3"..i, "toolbarPluginsLabel3"..i, pluginObject.__version)
		bframe ["toolbarPluginsLabel3"..i]:SetPoint ("topleft", frame4, "topleft", 290, y-4)
		
		local plugin_stable = _detalhes:GetPluginSavedTable (absName)
		local plugin = _detalhes:GetPlugin (absName)
		g:NewSwitch (bframe, _, "$parentToolbarSlider"..i, "toolbarPluginsSlider"..i, 60, 20, _, _, plugin_stable.enabled)
		bframe ["toolbarPluginsSlider"..i]:SetPoint ("topleft", frame4, "topleft", 400, y+1)
		bframe ["toolbarPluginsSlider"..i].OnSwitch = function (self, _, value)
			plugin_stable.enabled = value
			plugin.__enabled = value
			if (value) then
				_detalhes:SendEvent ("PLUGIN_ENABLED", plugin)
			else
				_detalhes:SendEvent ("PLUGIN_DISABLED", plugin)
			end
		end
		
		i = i + 1
		y = y - 20
	end
	
	y = y - 10
	
	--raid
	g:NewLabel (frame4, _, "$parentRaidPluginsLabel", "raidLabel", "Raid Plugins", "GameFontNormal", 16)
	frame4.raidLabel:SetPoint ("topleft", frame4, "topleft", 10, y)
	
	y = y - 30
	
	do
		local descbar = frame4:CreateTexture (nil, "artwork")
		descbar:SetTexture (.3, .3, .3, .8)
		descbar:SetPoint ("topleft", frame4, "topleft", 5, y+3)
		descbar:SetSize (480, 20)
		g:NewLabel (frame4, _, "$parentDescNameLabel2", "descNameLabel", "Name", "GameFontNormal", 12)
		frame4.descNameLabel:SetPoint ("topleft", frame4, "topleft", 15, y)
		g:NewLabel (frame4, _, "$parentDescAuthorLabel2", "descAuthorLabel", "Author", "GameFontNormal", 12)
		frame4.descAuthorLabel:SetPoint ("topleft", frame4, "topleft", 180, y)
		g:NewLabel (frame4, _, "$parentDescVersionLabel2", "descVersionLabel", "Version", "GameFontNormal", 12)
		frame4.descVersionLabel:SetPoint ("topleft", frame4, "topleft", 290, y)
		g:NewLabel (frame4, _, "$parentDescEnabledLabel2", "descEnabledLabel", "Enabled", "GameFontNormal", 12)
		frame4.descEnabledLabel:SetPoint ("topleft", frame4, "topleft", 400, y)
	end
	
	y = y - 30
	
	local i = 1
	local allplugins_raid = _detalhes.RaidTables.NameTable
	for absName, pluginObject in pairs (allplugins_raid) do 

		local bframe = CreateFrame ("frame", "OptionsPluginRaidBG", frame4)
		bframe:SetSize (480, 20)
		bframe:SetPoint ("topleft", frame4, "topleft", 10, y)
		bframe:SetBackdrop ({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, insets = {left = 1, right = 1, top = 0, bottom = 1}})
		bframe:SetBackdropColor (.3, .3, .3, .3)
		bframe:SetScript ("OnEnter", on_enter)
		bframe:SetScript ("OnLeave", on_leave)
	
		g:NewImage (bframe, _, "$parentRaidPluginsIcon"..i, "raidPluginsIcon"..i, 18, 18, pluginObject.__icon)
		bframe ["raidPluginsIcon"..i]:SetPoint ("topleft", frame4, "topleft", 10, y)
	
		g:NewLabel (bframe, _, "$parentRaidPluginsLabel"..i, "raidPluginsLabel"..i, pluginObject.__name)
		bframe ["raidPluginsLabel"..i]:SetPoint ("left", bframe ["raidPluginsIcon"..i], "right", 2, 0)
		
		g:NewLabel (bframe, _, "$parentRaidPluginsLabel2"..i, "raidPluginsLabel2"..i, pluginObject.__author)
		bframe ["raidPluginsLabel2"..i]:SetPoint ("topleft", frame4, "topleft", 180, y-4)
		
		g:NewLabel (bframe, _, "$parentRaidPluginsLabel3"..i, "raidPluginsLabel3"..i, pluginObject.__version)
		bframe ["raidPluginsLabel3"..i]:SetPoint ("topleft", frame4, "topleft", 290, y-4)
		
		local plugin_stable = _detalhes:GetPluginSavedTable (absName)
		local plugin = _detalhes:GetPlugin (absName)
		g:NewSwitch (bframe, _, "$parentRaidSlider"..i, "raidPluginsSlider"..i, 60, 20, _, _, plugin_stable.enabled)
		bframe ["raidPluginsSlider"..i]:SetPoint ("topleft", frame4, "topleft", 400, y+1)
		bframe ["raidPluginsSlider"..i].OnSwitch = function (self, _, value)
			plugin_stable.enabled = value
			plugin.__enabled = value
			if (not value) then
				for index, instancia in ipairs (_detalhes.tabela_instancias) do
					if (instancia.modo == 4) then -- 4 = raid
						_detalhes:TrocaTabela (instancia, 0, 1, 1, nil, 2)
					end
				end
			end
		end
		
		i = i + 1
		y = y - 20
	end
	
	y = y - 10

	-- solo
	g:NewLabel (frame4, _, "$parentSoloPluginsLabel", "soloLabel", "Solo Plugins", "GameFontNormal", 16)
	frame4.soloLabel:SetPoint ("topleft", frame4, "topleft", 10, y)
	
	y = y - 30
	
	do
		local descbar = frame4:CreateTexture (nil, "artwork")
		descbar:SetTexture (.3, .3, .3, .8)
		descbar:SetPoint ("topleft", frame4, "topleft", 5, y+3)
		descbar:SetSize (480, 20)
		g:NewLabel (frame4, _, "$parentDescNameLabel3", "descNameLabel", "Name", "GameFontNormal", 12)
		frame4.descNameLabel:SetPoint ("topleft", frame4, "topleft", 15, y)
		g:NewLabel (frame4, _, "$parentDescAuthorLabel3", "descAuthorLabel", "Author", "GameFontNormal", 12)
		frame4.descAuthorLabel:SetPoint ("topleft", frame4, "topleft", 180, y)
		g:NewLabel (frame4, _, "$parentDescVersionLabel3", "descVersionLabel", "Version", "GameFontNormal", 12)
		frame4.descVersionLabel:SetPoint ("topleft", frame4, "topleft", 290, y)
		g:NewLabel (frame4, _, "$parentDescEnabledLabel3", "descEnabledLabel", "Enabled", "GameFontNormal", 12)
		frame4.descEnabledLabel:SetPoint ("topleft", frame4, "topleft", 400, y)
	end
	
	y = y - 30
	
	local i = 1
	local allplugins_solo = _detalhes.SoloTables.NameTable
	for absName, pluginObject in pairs (allplugins_solo) do 
	
		local bframe = CreateFrame ("frame", "OptionsPluginSoloBG", frame4)
		bframe:SetSize (480, 20)
		bframe:SetPoint ("topleft", frame4, "topleft", 10, y)
		bframe:SetBackdrop ({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, insets = {left = 1, right = 1, top = 0, bottom = 1}})
		bframe:SetBackdropColor (.3, .3, .3, .3)
		bframe:SetScript ("OnEnter", on_enter)
		bframe:SetScript ("OnLeave", on_leave)
	
		g:NewImage (bframe, _, "$parentSoloPluginsIcon"..i, "soloPluginsIcon"..i, 18, 18, pluginObject.__icon)
		bframe ["soloPluginsIcon"..i]:SetPoint ("topleft", frame4, "topleft", 10, y)
	
		g:NewLabel (bframe, _, "$parentSoloPluginsLabel"..i, "soloPluginsLabel"..i, pluginObject.__name)
		bframe ["soloPluginsLabel"..i]:SetPoint ("left", bframe ["soloPluginsIcon"..i], "right", 2, 0)
		
		g:NewLabel (bframe, _, "$parentSoloPluginsLabel2"..i, "soloPluginsLabel2"..i, pluginObject.__author)
		bframe ["soloPluginsLabel2"..i]:SetPoint ("topleft", frame4, "topleft", 180, y-4)
		
		g:NewLabel (bframe, _, "$parentSoloPluginsLabel3"..i, "soloPluginsLabel3"..i, pluginObject.__version)
		bframe ["soloPluginsLabel3"..i]:SetPoint ("topleft", frame4, "topleft", 290, y-4)
		
		local plugin_stable = _detalhes:GetPluginSavedTable (absName)
		local plugin = _detalhes:GetPlugin (absName)
		g:NewSwitch (bframe, _, "$parentSoloSlider"..i, "soloPluginsSlider"..i, 60, 20, _, _, plugin_stable.enabled)
		bframe ["soloPluginsSlider"..i]:SetPoint ("topleft", frame4, "topleft", 400, y+1)
		bframe ["soloPluginsSlider"..i].OnSwitch = function (self, _, value)
			plugin_stable.enabled = value
			plugin.__enabled = value
			if (not value) then
				for index, instancia in ipairs (_detalhes.tabela_instancias) do
					if (instancia.modo == 1) then -- 1 = solo
						_detalhes:TrocaTabela (instancia, 0, 1, 1, nil, 2)
					end
				end
			end
		end
		
		i = i + 1
		y = y - 20
	end
	
	
	select_options (1)
		
end
----------------------------------------------------------------------------------------
--> Show

	_G.DetailsOptionsWindow2ResetTextColorImage.MyObject:SetTexture (unpack (instance.resetbutton_info.text_color))
	_G.DetailsOptionsWindow2ResetTextSizeSlider.MyObject:SetValue (instance.resetbutton_info.text_size)
	_G.DetailsOptionsWindow2ResetTextFontDropdown.MyObject:Select (instance.resetbutton_info.text_face)
	_G.DetailsOptionsWindow2ResetOverlayColorImage.MyObject:SetTexture (unpack (instance.resetbutton_info.color_overlay))

	_G.DetailsOptionsWindow2InstanceTextColorImage.MyObject:SetTexture (unpack (instance.instancebutton_info.text_color))
	_G.DetailsOptionsWindow2InstanceTextSizeSlider.MyObject:SetValue (instance.instancebutton_info.text_size)
	_G.DetailsOptionsWindow2InstanceTextFontDropdown.MyObject:Select (instance.instancebutton_info.text_face)
	_G.DetailsOptionsWindow2InstanceOverlayColorImage.MyObject:SetTexture (unpack (instance.instancebutton_info.color_overlay))

	_G.DetailsOptionsWindow2CloseOverlayColorImage.MyObject:SetTexture (unpack (instance.closebutton_info.color_overlay))

	_G.DetailsOptionsWindow1HideOnCombatSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow1HideOnCombatAlphaSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow1HideOnCombatSlider.MyObject:SetValue (instance.hide_in_combat)
	_G.DetailsOptionsWindow1HideOnCombatAlphaSlider.MyObject:SetValue (instance.hide_in_combat_alpha)
	
	_G.DetailsOptionsWindow2SideBarsSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2SideBarsSlider.MyObject:SetValue (instance.show_sidebars)
	
	_G.DetailsOptionsWindow2StatusbarSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2StatusbarSlider.MyObject:SetValue (instance.show_statusbar)
	
	_G.DetailsOptionsWindow2StretchAnchorSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2StretchAnchorSlider.MyObject:SetValue (instance.stretch_button_side)
	
	_G.DetailsOptionsWindow2PluginIconsDirectionSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2PluginIconsDirectionSlider.MyObject:SetValue (instance.plugins_grow_direction)
	
	_G.DetailsOptionsWindow2InstanceToolbarSideSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2InstanceToolbarSideSlider.MyObject:SetValue (instance.toolbar_side)
	
	_G.DetailsOptionsWindow2BarSortDirectionSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2BarSortDirectionSlider.MyObject:SetValue (instance.bars_sort_direction)
	
	_G.DetailsOptionsWindow2BarGrowDirectionSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2BarGrowDirectionSlider.MyObject:SetValue (instance.bars_grow_direction)
	

	_G.DetailsOptionsWindow2DesaturateMenuSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2DesaturateMenuSlider.MyObject:SetValue (instance.desaturated_menu)
	
	_G.DetailsOptionsWindow2HideIconSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2HideIconSlider.MyObject:SetValue (instance.hide_icon)
	
	_G.DetailsOptionsWindow2MenuAnchorXSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2MenuAnchorXSlider.MyObject:SetValue (instance.menu_anchor[1])
	
	_G.DetailsOptionsWindow2MenuAnchorYSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2MenuAnchorYSlider.MyObject:SetValue (instance.menu_anchor[2])
	
	_G.DetailsOptionsWindow2InstanceButtonAnchorXSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2InstanceButtonAnchorXSlider.MyObject:SetValue (instance.instance_button_anchor[1])
	
	_G.DetailsOptionsWindow2InstanceButtonAnchorYSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2InstanceButtonAnchorYSlider.MyObject:SetValue (instance.instance_button_anchor[2])

----------------------------------------------------------------	
	
	--resetTextColor
	_G.DetailsOptionsWindow2ResetTextFontDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2ResetTextSizeSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2ResetAlwaysSmallSlider.MyObject:SetFixedParameter (instance)
	--resetOverlayColorLabel

	--instanceTextColorLabel
	_G.DetailsOptionsWindow2InstanceTextFontDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2InstanceTextSizeSlider.MyObject:SetFixedParameter (instance)
	--instanceOverlayColorLabel

	--closeOverlayColorLabel
	
	_G.DetailsOptionsWindow2SkinDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2SkinDropdown.MyObject:Select (instance.skin)
	_G.DetailsOptionsWindow2TextureDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2RowBackgroundTextureDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2TextureDropdown.MyObject:Select (instance.row_info.texture)
	_G.DetailsOptionsWindow2RowBackgroundTextureDropdown.MyObject:Select (instance.row_info.texture_background)
	_G.DetailsOptionsWindow2RowBackgroundColor.MyObject:SetTexture (unpack (instance.row_info.fixed_texture_background_color))
	
	_G.DetailsOptionsWindow2BackgroundClassColorSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2BackgroundClassColorSlider.MyObject:SetValue (instance.row_info.texture_background_class_color)
	
	_G.DetailsOptionsWindow2FontDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2FontDropdown.MyObject:Select (instance.row_info.font_face)
	--
	_G.DetailsOptionsWindow2SliderRowHeight.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2SliderRowHeight.MyObject:SetValue (instance.row_info.height)
	--
	_G.DetailsOptionsWindow2SliderFontSize.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2SliderFontSize.MyObject:SetValue (instance.row_info.font_size)
	--
	_G.DetailsOptionsWindow2AutoCurrentSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2AutoCurrentSlider.MyObject:SetValue (instance.auto_current)
	--
	_G.DetailsOptionsWindow2ClassColorSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2ClassColorSlider.MyObject:SetValue (instance.row_info.texture_class_colors)
	
	_G.DetailsOptionsWindow2UseClassColorsLeftTextSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2UseClassColorsLeftTextSlider.MyObject:SetValue (instance.row_info.textL_class_colors)
	_G.DetailsOptionsWindow2UseClassColorsRightTextSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2UseClassColorsRightTextSlider.MyObject:SetValue (instance.row_info.textR_class_colors)
	
	_G.DetailsOptionsWindow2TextLeftOutlineSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2TextLeftOutlineSlider.MyObject:SetValue (instance.row_info.textL_outline)
	_G.DetailsOptionsWindow2TextRightOutlineSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2TextRightOutlineSlider.MyObject:SetValue (instance.row_info.textR_outline)
	--
	_G.DetailsOptionsWindow2AlphaSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2AlphaSlider.MyObject:SetValue (instance.bg_alpha)
	--
	_G.DetailsOptionsWindow2UseBackgroundSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2BackgroundDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2BackgroundDropdown2.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2AnchorDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2BackgroundDropdown.MyObject:Select (instance.wallpaper.texture)
	
	if (instance.wallpaper.enabled) then
		_G.DetailsOptionsWindow2BackgroundDropdown.MyObject:Enable()
		_G.DetailsOptionsWindow2BackgroundDropdown2.MyObject:Enable()
		_G.DetailsOptionsWindow2UseBackgroundSlider.MyObject:SetValue (2)
	else
		_G.DetailsOptionsWindow2BackgroundDropdown.MyObject:Disable()
		_G.DetailsOptionsWindow2BackgroundDropdown2.MyObject:Disable()
		_G.DetailsOptionsWindow2UseBackgroundSlider.MyObject:SetValue (1)
	end

	_G.DetailsOptionsWindow2InstanceColorTexture.MyObject:SetTexture (unpack (instance.color))
	_G.DetailsOptionsWindow2BackgroundColorTexture.MyObject:SetTexture (instance.bg_r, instance.bg_g, instance.bg_b)
	_G.DetailsOptionsWindow2FixedRowColorTexture.MyObject:SetTexture (unpack (instance.row_info.fixed_texture_color))
	_G.DetailsOptionsWindow2FixedRowColorTTexture.MyObject:SetTexture (unpack (instance.row_info.fixed_text_color))
	
	GameCooltip:SetFixedParameter (_G.DetailsOptionsWindow2LoadStyleButton, instance)
	
	_G.DetailsOptionsWindow1NicknameEntry.MyObject.text = _detalhes:GetNickname (UnitGUID ("player"), UnitName ("player"), true)
	_G.DetailsOptionsWindow1TTDropdown.MyObject:Select (_detalhes.time_type, true)
	
	_G.DetailsOptionsWindow.MyObject.instance = instance
	
	_G.DetailsOptionsWindowInstanceSelectDropdown.MyObject:Select (instance.meu_id, true)
	
	window:Show()

end

