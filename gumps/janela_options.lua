--[[ options panel file --]]

local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local LDB = LibStub ("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub ("LibDBIcon-1.0", true)

local g =	_detalhes.gump
local _
local preset_version = 3

function _detalhes:OpenOptionsWindow (instance)

	GameCooltip:Close()
	local window = _G.DetailsOptionsWindow

	if (not window) then
	
-- Details Overall -------------------------------------------------------------------------------------------------------------------------------------------------
	
		local SLIDER_WIDTH = 130
		local DROPDOWN_WIDTH = 160
		local COLOR_BUTTON_WIDTH = 160
		
	
		-- Most of details widgets have the same 6 first parameters: parent, container, global name, parent key, width, height
	
		window = g:NewPanel (UIParent, _, "DetailsOptionsWindow", _, 897, 592)
		window.instance = instance
		tinsert (UISpecialFrames, "DetailsOptionsWindow")
		window:SetFrameStrata ("HIGH")
		window:SetPoint ("center", UIParent, "Center")
		window.locked = false
		window.close_with_right = true
		window.backdrop = nil
		
		--x 9 897 y 9 592
		
		local background = g:NewImage (window, _, "$parentBackground", "background", 897, 592, [[Interface\AddOns\Details\images\options_window]])
		background:SetPoint (0, 0)
		background:SetDrawLayer ("border")
		--background:SetTexCoord (0.0087890625, 0.8759765625, 0.0087890625, 0.578125)
		background:SetTexCoord (0, 0.8759765625, 0, 0.578125)

		local bigdog = g:NewImage (window, _, "$parentBackgroundBigDog", "backgroundBigDog", 180, 200, [[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bigdog:SetPoint ("bottomright", window, "bottomright", -8, 31)
		bigdog:SetAlpha (.15)
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
		close_button:SetPoint ("TOPRIGHT", window.widget, "TOPRIGHT", 0, -19)
		close_button:SetText ("X")
		close_button:SetFrameLevel (close_button:GetFrameLevel()+2)
		
		--> desc text (on the right)
		local info_text = g:NewLabel (window, nil, nil, "infotext", "", "GameFontNormal", 12)
		info_text:SetPoint ("topleft", window, "topleft", 560, -109)
		info_text.width = 300
		info_text.height = 280
		info_text.align = "<"
		info_text.valign = "^"
		info_text.active = false
		info_text.color = "white"
		
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
		
		--instances:Hide()
		--instances_string:Hide()
		
		--> left panel buttons
		local select_options = function (options_type)
			
			window:hide_all_options()
			
			window:un_hide_options (options_type)
			
			editing.text = editing.options [options_type]
			
			-- ~altura
			if (options_type == 12) then
				window.options [12][1].slider:SetMinMaxValues (0, 320)
				info_text.text = ""
			end
			
		end

		local mouse_over_texture = g:NewImage (window, _, "$parentButtonMouseOver", "buttonMouseOver", 156, 22, [[Interface\AddOns\Details\images\options_window]])
		--mouse_over_texture:SetTexCoord (0.006347, 0.170410, 0.528808, 0.563964)
		mouse_over_texture:SetTexCoord (0.1044921875, 0.26953125, 0.6259765625, 0.662109375)
		mouse_over_texture:SetWidth (169)
		mouse_over_texture:SetHeight (37)
		mouse_over_texture:Hide()
		mouse_over_texture:SetBlendMode ("ADD")

		--> menu anchor textures
		
		--general settings
			local g_settings = g:NewButton (window, _, "$parentGeneralSettingsButton", "g_settings", 150, 33, function() end, 0x1)
			
			g:NewLabel (window, _, "$parentgeneral_settings_text", "GeneralSettingsLabel", Loc ["STRING_OPTIONS_GENERAL"], "GameFontNormal", 12)
			window.GeneralSettingsLabel:SetPoint ("topleft", g_settings, "topleft", 35, -11)
		
			local g_settings_texture = g:NewImage (window, _, "$parentGeneralSettingsTexture", "GeneralSettingsTexture", 160, 33, [[Interface\AddOns\Details\images\options_window]])
			g_settings_texture:SetTexCoord (0, 0.15625, 0.685546875, 0.7177734375)
			g_settings_texture:SetPoint ("topleft", g_settings, "topleft", 0, 0)

		--apparance
			local g_appearance = g:NewButton (window, _, "$parentAppearanceButton", "g_appearance", 150, 33, function() end, 0x2)

			g:NewLabel (window, _, "$parentappearance_settings_text", "AppearanceSettingsLabel", Loc ["STRING_OPTIONS_APPEARANCE"], "GameFontNormal", 12)
			window.AppearanceSettingsLabel:SetPoint ("topleft", g_appearance, "topleft", 35, -11)
		
			local g_appearance_texture = g:NewImage (window, _, "$parentAppearanceSettingsTexture", "AppearanceSettingsTexture", 160, 33, [[Interface\AddOns\Details\images\options_window]])
			g_appearance_texture:SetTexCoord (0, 0.15625, 0.71875, 0.7509765625)
			g_appearance_texture:SetPoint ("topleft", g_appearance, "topleft", 0, 0)
		
		--performance
			local g_performance = g:NewButton (window, _, "$parentPerformanceButton", "g_appearance", 150, 33, function() end, 0x3)

			g:NewLabel (window, _, "$parentperformance_settings_text", "PerformanceSettingsLabel", Loc ["STRING_OPTIONS_PERFORMANCE"], "GameFontNormal", 12)
			window.PerformanceSettingsLabel:SetPoint ("topleft", g_performance, "topleft", 35, -11)
		
			local g_performance_texture = g:NewImage (window, _, "$parentPerformanceSettingsTexture", "PerformanceSettingsTexture", 160, 33, [[Interface\AddOns\Details\images\options_window]])
			g_performance_texture:SetTexCoord (0, 0.15625, 0.751953125, 0.7841796875)
			g_performance_texture:SetPoint ("topleft", g_performance, "topleft", 0, 0)
			
		--plugins
			local g_plugin = g:NewButton (window, _, "$parentPluginButton", "g_plugin", 150, 33, function() end, 0x4)
			
			g:NewLabel (window, _, "$parentperplugins_settings_text", "PluginsSettingsLabel", Loc ["STRING_OPTIONS_PLUGINS"], "GameFontNormal", 12)
			window.PluginsSettingsLabel:SetPoint ("topleft", g_plugin, "topleft", 35, -11)
		
			local g_performance_texture = g:NewImage (window, _, "$parentPluginsSettingsTexture", "PluginsSettingsTexture", 160, 33, [[Interface\AddOns\Details\images\options_window]])
			g_performance_texture:SetTexCoord (0, 0.15625, 0.78515625, 0.8173828125)
			g_performance_texture:SetPoint ("topleft", g_plugin, "topleft", 0, 0)
		
		local menus = {
			{"Display", "Combat"},
			{"Skin", "Row", "Row Texts", "Window Settings", "Top Menu Bar", "Reset/Instance/Close", "Wallpaper"},
			{"Performance Tweaks", "Data Collector"},
			{"Plugins Management"}
		}
		
		--> create menus
		local anchors = {g_settings, g_appearance, g_performance, g_plugin}
		local y = -110
		local sub_menu_index = 1
		
		local textcolor = {.8, .8, .8, 1}
		
		local button_onenter = function (self)
			self.MyObject.my_bg_texture:SetVertexColor (1, 1, 1, 1)
			self.MyObject.textcolor = "yellow"
		end
		local button_onleave = function (self)
			self.MyObject.my_bg_texture:SetVertexColor (1, 1, 1, .5)
			self.MyObject.textcolor = textcolor
		end
		
		local true_index = 1
		
		for index, menulist in ipairs (menus) do 
			
			anchors [index]:SetPoint (23, y)
			local amount = #menulist
			
			y = y - 37
			
			for i = 1, amount do 
			
				local texture = g:NewImage (window, _, "$parentButton_" .. index .. "_" .. i .. "_texture", nil, 130, 14, [[Interface\ARCHEOLOGY\ArchaeologyParts]])
				texture:SetTexCoord (0.146484375, 0.591796875, 0.0546875, 0.26171875)
				texture:SetPoint (38, y-2)
				texture:SetVertexColor (1, 1, 1, .5)
				
				local button = g:NewButton (window, _, "$parentButton_" .. index .. "_" .. i, nil, 150, 18, select_options, true_index, nil, "", menus [index] [i])
				button:SetPoint (40, y)
				button.textalign = "<"
				button.textcolor = textcolor
				button.textsize = 11
				button.my_bg_texture = texture
				y = y - 16
				
				button:SetHook ("OnEnter", button_onenter)
				button:SetHook ("OnLeave", button_onleave)
				
				true_index = true_index + 1
			
			end
			
			y = y - 10
			
		end
		
		window.options = {
			[1] = {},
			[2] = {},
			[3] = {},
			[4] = {},
			[5] = {},
			[6] = {},
			[7] = {},
			[8] = {},
			[9] = {},
			[10] = {},
			[11] = {},
			[12] = {},
		} --> vai armazenar os frames das opções
		
		
		function window:create_box_no_scroll (n)
			local container = CreateFrame ("Frame", "DetailsOptionsWindow" .. n, window.widget)

			container:SetScript ("OnMouseDown", function()
				if (not window.widget.isMoving) then
					window.widget:StartMoving()
					window.widget.isMoving = true
				end
			end)
			container:SetScript ("OnMouseUp", function()
				if (window.widget.isMoving) then
					window.widget:StopMovingOrSizing()
					window.widget.isMoving = false
				end
			end)
			
			container:SetBackdrop({
				edgeFile = "Interface\\DialogFrame\\UI-DialogBox-gold-Border", tile = true, tileSize = 16, edgeSize = 5,
				insets = {left = 1, right = 1, top = 0, bottom = 1},})		
			container:SetBackdropBorderColor (0, 0, 0, 0)
			container:SetBackdropColor (0, 0, 0, 0)
			
			container:SetWidth (663)
			container:SetHeight (500)
			container:SetPoint ("TOPLEFT", window.widget, "TOPLEFT", 198, -88)
			
			g:NewScrollBar (container, container, 8, -10)
			container.slider:Altura (449)
			container.slider:cimaPoint (0, 1)
			container.slider:baixoPoint (0, -3)
			container.wheel_jump = 80
			
			container.slider:Disable()
			container.baixo:Disable()
			container.cima:Disable()
			container:EnableMouseWheel (false)
			
			return container
		end
		
		
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
			
			container_window:SetWidth (663)
			container_window:SetHeight (500)
			container_window:SetScrollChild (container_slave)
			container_window:SetPoint ("TOPLEFT", window.widget, "TOPLEFT", 198, -88)

			g:NewScrollBar (container_window, container_slave, 8, -10)
			container_window.slider:Altura (449)
			container_window.slider:cimaPoint (0, 1)
			container_window.slider:baixoPoint (0, -3)
			container_window.wheel_jump = 80

			container_window.ultimo = 0
			container_window.gump = container_slave
			container_window.container_slave = container_slave
			
			return container_window
		end
		
		table.insert (window.options [1], window:create_box_no_scroll (1))
		table.insert (window.options [2], window:create_box_no_scroll (2))
		table.insert (window.options [3], window:create_box_no_scroll (3))
		table.insert (window.options [4], window:create_box_no_scroll (4))
		table.insert (window.options [5], window:create_box_no_scroll (5))
		table.insert (window.options [6], window:create_box_no_scroll (6))
		table.insert (window.options [7], window:create_box_no_scroll (7))
		table.insert (window.options [8], window:create_box_no_scroll (8))
		table.insert (window.options [9], window:create_box_no_scroll (9))
		table.insert (window.options [10], window:create_box_no_scroll (10))
		table.insert (window.options [11], window:create_box_no_scroll (11))
		table.insert (window.options [12], window:create_box (12))

		function window:hide_all_options()
			for _, frame in ipairs (window.options) do 
				for _, widget in ipairs (frame) do 
					widget:Hide()
				end
			end
		end
		
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
		
		select_options (1)
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- General Settings - Display
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--> general settings:
		local frame1 = window.options [1][1]

	--> nickname avatar
		local onPressEnter = function (_, _, text)
			local accepted, errortext = _detalhes:SetNickname (text)
			if (not accepted) then
				_detalhes:Msg (errortext)
			end
			--> we call again here, because if not accepted the box return the previous value and if successful accepted, update the value for formated string.
			local nick = _detalhes:GetNickname (UnitGUID ("player"), UnitName ("player"), true)
			frame1.nicknameEntry.text = nick
			_G.DetailsOptionsWindow1AvatarNicknameLabel:SetText (nick)
		end
		
		local titulo_persona = g:NewLabel (frame1, _, "$parentTituloPersona", "tituloPersonaLabel", Loc ["STRING_OPTIONS_SOCIAL"], "GameFontNormal", 16)
		local titulo_persona_desc = g:NewLabel (frame1, _, "$parentTituloPersona2", "tituloPersona2Label", Loc ["STRING_OPTIONS_SOCIAL_DESC"], "GameFontNormal", 9, "white")
		titulo_persona_desc.width = 350
		
	--> persona
		
		g:NewLabel (frame1, _, "$parentNickNameLabel", "nicknameLabel", Loc ["STRING_OPTIONS_NICKNAME"], "GameFontHighlightLeft")
		
		g:NewTextEntry (frame1, _, "$parentNicknameEntry", "nicknameEntry", SLIDER_WIDTH, 20, onPressEnter)
		frame1.nicknameEntry:SetPoint ("left", frame1.nicknameLabel, "right", 2, 0)
		frame1.nicknameEntry.info = Loc ["STRING_OPTIONS_NICKNAME_DESC"]
		
		window:create_line_background (frame1, frame1.nicknameLabel, frame1.nicknameEntry)
		frame1.nicknameEntry:SetHook ("OnEnter", background_on_enter)
		frame1.nicknameEntry:SetHook ("OnLeave", background_on_leave)
		
		local avatarcallback = function (textureAvatar, textureAvatarTexCoord, textureBackground, textureBackgroundTexCoord, textureBackgroundColor)
			_detalhes:SetNicknameBackground (textureBackground, textureBackgroundTexCoord, textureBackgroundColor, true)
			_detalhes:SetNicknameAvatar (textureAvatar, textureAvatarTexCoord)

			_G.DetailsOptionsWindow1AvatarPreviewTexture.MyObject.texture = textureAvatar
			_G.DetailsOptionsWindow1AvatarPreviewTexture2.MyObject.texture = textureBackground
			_G.DetailsOptionsWindow1AvatarPreviewTexture2.MyObject.texcoord =  textureBackgroundTexCoord
			_G.DetailsOptionsWindow1AvatarPreviewTexture2.MyObject:SetVertexColor (unpack (textureBackgroundColor))
			
			_G.AvatarPickFrame.callback = nil
		end
		
		local openAtavarPickFrame = function()
			_G.AvatarPickFrame.callback = avatarcallback
			_G.AvatarPickFrame:Show()
		end
		
		g:NewButton (frame1, _, "$parentAvatarFrame", "chooseAvatarButton", frame1.nicknameLabel:GetStringWidth() + SLIDER_WIDTH + 2, 14, openAtavarPickFrame, nil, nil, nil, Loc ["STRING_OPTIONS_AVATAR"])
		frame1.chooseAvatarButton:InstallCustomTexture()
		frame1.chooseAvatarButton.info = Loc ["STRING_OPTIONS_AVATAR_DESC"]
		
		window:create_line_background (frame1, frame1.chooseAvatarButton, frame1.chooseAvatarButton)
		frame1.chooseAvatarButton:SetHook ("OnEnter", background_on_enter)
		frame1.chooseAvatarButton:SetHook ("OnLeave", background_on_leave)
		
	--> avatar preview
		g:NewImage (frame1, _, "$parentAvatarPreviewTexture", "avatarPreview", 128, 64)
		g:NewImage (frame1, _, "$parentAvatarPreviewTexture2", "avatarPreview2", 275, 60)
		g:NewLabel (frame1, _, "$parentAvatarNicknameLabel", "avatarNickname", UnitName ("player"), "GameFontHighlightSmall")

		_detalhes:SetFontSize (frame1.avatarNickname.widget, 18)
		
		frame1.avatarPreview:SetDrawLayer ("overlay", 3)
		frame1.avatarNickname:SetDrawLayer ("overlay", 3)
		frame1.avatarPreview2:SetDrawLayer ("overlay", 2)
		
	-->  realm name --------------------------------------------------------------------------------------------------------------------------------------------

		g:NewLabel (frame1, _, "$parentRealmNameLabel", "realmNameLabel", Loc ["STRING_OPTIONS_REALMNAME"], "GameFontHighlightLeft")
		g:NewSwitch (frame1, _, "$parentRealmNameSlider", "realmNameSlider", 60, 20, _, _, _detalhes.remove_realm_from_name)
		frame1.realmNameSlider:SetPoint ("left", frame1.realmNameLabel, "right", 2)
		frame1.realmNameSlider.info = Loc ["STRING_OPTIONS_REALMNAME_DESC"]
		frame1.realmNameSlider.OnSwitch = function (self, _, value)
			_detalhes.remove_realm_from_name = value
		end
		
		window:create_line_background (frame1, frame1.realmNameLabel, frame1.realmNameSlider)
		frame1.realmNameSlider:SetHook ("OnEnter", background_on_enter)
		frame1.realmNameSlider:SetHook ("OnLeave", background_on_leave)		

	--> Max Segments
	
		local titulo_display = g:NewLabel (frame1, _, "$parentTituloDisplay", "tituloDisplayLabel", "Display", "GameFontNormal", 16) --> localize-me
		local titulo_display_desc = g:NewLabel (frame1, _, "$parentTituloDisplay2", "tituloDisplay2Label", "Preferencial adjustments of instances (windows).", "GameFontNormal", 9, "white") --> localize-me
		titulo_display_desc.width = 320
		
		g:NewLabel (frame1, _, "$parentSliderLabel", "segmentsLabel", Loc ["STRING_OPTIONS_MAXSEGMENTS"], "GameFontHighlightLeft")
		g:NewSlider (frame1, _, "$parentSlider", "segmentsSlider", SLIDER_WIDTH, 20, 1, 25, 1, _detalhes.segments_amount)
		frame1.segmentsSlider:SetPoint ("left", frame1.segmentsLabel, "right", 2, 0)
		frame1.segmentsSlider:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.segments_amount = math.floor (amount)
		end)
		frame1.segmentsSlider.info = Loc ["STRING_OPTIONS_MAXSEGMENTS_DESC"]
		
		window:create_line_background (frame1, frame1.segmentsLabel, frame1.segmentsSlider)
		frame1.segmentsSlider:SetHook ("OnEnter", background_on_enter)
		frame1.segmentsSlider:SetHook ("OnLeave", background_on_leave)
		
	--> Use Scroll Bar
		g:NewLabel (frame1, _, "$parentUseScrollLabel", "scrollLabel", Loc ["STRING_OPTIONS_SCROLLBAR"], "GameFontHighlightLeft")
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
		
	--> Max Instances
		g:NewLabel (frame1, _, "$parentLabelMaxInstances", "maxInstancesLabel", Loc ["STRING_OPTIONS_MAXINSTANCES"], "GameFontHighlightLeft")
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
		
	--> Minimap Icon
		g:NewSwitch (frame1, _, "$parentMinimapSlider", "minimapSlider", 60, 20, _, _, not _detalhes.minimap.hide)
		g:NewLabel (frame1, _, "$parentMinimapLabel", "minimapLabel", Loc ["STRING_OPTIONS_MINIMAP"], "GameFontHighlightLeft")
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
		
	---> Abbreviation Type
		g:NewLabel (frame1, _, "$parentDpsAbbreviateLabel", "dpsAbbreviateLabel", Loc ["STRING_OPTIONS_PS_ABBREVIATE"], "GameFontHighlightLeft")
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
		
		frame1.dpsAbbreviateDropdown.info = Loc ["STRING_OPTIONS_PS_ABBREVIATE_DESC"]

		window:create_line_background (frame1, frame1.dpsAbbreviateLabel, frame1.dpsAbbreviateDropdown)
		frame1.dpsAbbreviateDropdown:SetHook ("OnEnter", background_on_enter)
		frame1.dpsAbbreviateDropdown:SetHook ("OnLeave", background_on_leave)

		titulo_persona:SetPoint (10, -10)
		titulo_persona_desc:SetPoint (10, -30)
		frame1.nicknameLabel:SetPoint (10, -70)
		frame1.chooseAvatarButton:SetPoint (11, -90)
		
		frame1.avatarPreview:SetPoint (-8, -107)
		frame1.avatarPreview2:SetPoint (-8, -107)
		frame1.avatarNickname:SetPoint (100, -142)

		local avatar = NickTag:GetNicknameAvatar (UnitGUID ("player"), NICKTAG_DEFAULT_AVATAR, true)
		local background, cords, color = NickTag:GetNicknameBackground (UnitGUID ("player"), NICKTAG_DEFAULT_BACKGROUND, NICKTAG_DEFAULT_BACKGROUND_CORDS, {1, 1, 1, 1}, true)
		
		frame1.avatarPreview.texture = avatar
		frame1.avatarPreview2.texture = background
		frame1.avatarPreview2.texcoord = cords
		frame1.avatarPreview2:SetVertexColor (unpack (color))

		titulo_display:SetPoint (10, -200)
		titulo_display_desc:SetPoint (10, -220)
		
		frame1.segmentsLabel:SetPoint (10, -260)
		frame1.scrollLabel:SetPoint (10, -285)
		frame1.maxInstancesLabel:SetPoint (10, -310)
		frame1.minimapLabel:SetPoint (10, -335)
		frame1.dpsAbbreviateLabel:SetPoint (10, -360)
		frame1.realmNameLabel:SetPoint (10, -385)
		
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- General Settings - Combat
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
	--> general settings:
		local frame2 = window.options [2][1]
		
	--> titles
		local titulo_combattweeks = g:NewLabel (frame2, _, "$parentTituloCombatTweeks", "tituloCombatTweeksLabel", Loc ["STRING_OPTIONS_COMBATTWEEKS"], "GameFontNormal", 16)
		titulo_combattweeks:SetPoint (10, -10)
		local titulo_combattweeks_desc = g:NewLabel (frame2, _, "$parentCombatTweeks2", "tituloCombatTweeks2Label", Loc ["STRING_OPTIONS_COMBATTWEEKS_DESC"], "GameFontNormal", 9, "white")
		titulo_combattweeks_desc.width = 320
		titulo_combattweeks_desc:SetPoint (10, -30)
		
	--> Frags PVP Mode
		g:NewLabel (frame2, _, "$parentLabelFragsPvP", "fragsPvpLabel", Loc ["STRING_OPTIONS_PVPFRAGS"], "GameFontHighlightLeft")
		--
		g:NewSwitch (frame2, _, "$parentFragsPvpSlider", "fragsPvpSlider", 60, 20, _, _, _detalhes.only_pvp_frags)
		frame2.fragsPvpSlider:SetPoint ("left", frame2.fragsPvpLabel, "right", 2, 0)
		frame2.fragsPvpSlider.OnSwitch = function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.only_pvp_frags = amount
		end
		frame2.fragsPvpSlider.info = Loc ["STRING_OPTIONS_PVPFRAGS_DESC"]		
		
		window:create_line_background (frame2, frame2.fragsPvpLabel, frame2.fragsPvpSlider)
		frame2.fragsPvpSlider:SetHook ("OnEnter", background_on_enter)
		frame2.fragsPvpSlider:SetHook ("OnLeave", background_on_leave)
		
	--> Time Type
		g:NewLabel (frame2, _, "$parentTimeTypeLabel", "timetypeLabel", Loc ["STRING_OPTIONS_TIMEMEASURE"], "GameFontHighlightLeft")
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
		g:NewDropDown (frame2, _, "$parentTTDropdown", "timetypeDropdown", 160, 20, buildTimeTypeMenu, nil) -- func, default
		frame2.timetypeDropdown:SetPoint ("left", frame2.timetypeLabel, "right", 2, 0)		
		
		frame2.timetypeDropdown.info = Loc ["STRING_OPTIONS_TIMEMEASURE_DESC"]

		window:create_line_background (frame2, frame2.timetypeLabel, frame2.timetypeDropdown)
		frame2.timetypeDropdown:SetHook ("OnEnter", background_on_enter)
		frame2.timetypeDropdown:SetHook ("OnLeave", background_on_leave)

	--> hide in combat
		g:NewLabel (frame2, _, "$parentHideOnCombatLabel", "hideOnCombatLabel", Loc ["STRING_OPTIONS_HIDECOMBAT"], "GameFontHighlightLeft")
		g:NewLabel (frame2, _, "$parentHideOnCombatAlphaLabel", "hideOnCombatAlphaLabel", Loc ["STRING_OPTIONS_HIDECOMBATALPHA"], "GameFontHighlightLeft")
		
		g:NewSwitch (frame2, _, "$parentHideOnCombatSlider", "hideOnCombatSlider", 60, 20, _, _, window.instance.hide_in_combat)
		frame2.hideOnCombatSlider:SetPoint ("left", frame2.hideOnCombatLabel, "right", 2, 0)
		frame2.hideOnCombatSlider.OnSwitch = function (self, instance, value)
			instance.hide_in_combat = value
		end
		
		g:NewSlider (frame2, _, "$parentHideOnCombatAlphaSlider", "hideOnCombatAlphaSlider", SLIDER_WIDTH, 20, 0, 100, 1, window.instance.hide_in_combat_alpha) -- min, max, step, defaultv
		frame2.hideOnCombatAlphaSlider:SetPoint ("left", frame2.hideOnCombatAlphaLabel, "right", 2, 0)
		frame2.hideOnCombatAlphaSlider:SetHook ("OnValueChange", function (self, instance, amount) --> slider, fixedValue, sliderValue
			instance.hide_in_combat_alpha = amount
		end)
		
		frame2.hideOnCombatSlider.info = Loc ["STRING_OPTIONS_HIDECOMBAT_DESC"]
		frame2.hideOnCombatAlphaSlider.info = Loc ["STRING_OPTIONS_HIDECOMBATALPHA_DESC"]
		
		window:create_line_background (frame2, frame2.hideOnCombatLabel, frame2.hideOnCombatSlider)
		frame2.hideOnCombatSlider:SetHook ("OnEnter", background_on_enter)
		frame2.hideOnCombatSlider:SetHook ("OnLeave", background_on_leave)
		
		window:create_line_background (frame2, frame2.hideOnCombatAlphaLabel, frame2.hideOnCombatAlphaSlider)
		frame2.hideOnCombatAlphaSlider:SetHook ("OnEnter", background_on_enter)
		frame2.hideOnCombatAlphaSlider:SetHook ("OnLeave", background_on_leave)

	--> auto switch
		g:NewLabel (frame2, _, "$parentAutoSwitchLabel", "autoSwitchLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH"], "GameFontHighlightLeft")
		--
		local onSelectAutoSwitch = function (_, _, switch_to)
			if (switch_to == 0) then
				window.instance.auto_switch_to = nil
				return
			end
			
			local selected = window.lastSwitchList [switch_to]
			
			if (selected [1] == "raid") then
				local name = _detalhes.RaidTables.Menu [selected [2]] [1]
				selected [2] = name
				window.instance.auto_switch_to = selected
			else
				window.instance.auto_switch_to = selected
			end

		end
		
		local buildSwitchMenu = function()
		
			window.lastSwitchList = {}
			local t = {{value = 0, label = "NONE", onclick = onSelectAutoSwitch, icon = [[Interface\COMMON\VOICECHAT-MUTED]]}}
			
			local attributes = _detalhes.sub_atributos
			local i = 1
			
			for atributo, sub_atributo in ipairs (attributes) do
				local icones = sub_atributo.icones
				for index, att_name in ipairs (sub_atributo.lista) do
					local texture, texcoord = unpack (icones [index])
					tinsert (t, {value = i, label = att_name, onclick = onSelectAutoSwitch, icon = texture, texcoord = texcoord})
					window.lastSwitchList [i] = {atributo, index, i}
					i = i + 1
				end
			end
			
			for index, ptable in ipairs (_detalhes.RaidTables.Menu) do
				tinsert (t, {value = i, label = ptable [1], onclick = onSelectAutoSwitch, icon = ptable [2]})
				window.lastSwitchList [i] = {"raid", index, i}
				i = i + 1
			end
		
			return t
		end
		
		g:NewDropDown (frame2, _, "$parentAutoSwitchDropdown", "autoSwitchDropdown", 160, 20, buildSwitchMenu, 1) -- func, default
		frame2.autoSwitchDropdown:SetPoint ("left", frame2.autoSwitchLabel, "right", 2, 0)		
		
		frame2.autoSwitchDropdown.info = Loc ["STRING_OPTIONS_AUTO_SWITCH_DESC"]

		window:create_line_background (frame2, frame2.autoSwitchLabel, frame2.autoSwitchDropdown)
		frame2.autoSwitchDropdown:SetHook ("OnEnter", background_on_enter)
		frame2.autoSwitchDropdown:SetHook ("OnLeave", background_on_leave)
		
		--> auto current segment
		g:NewSwitch (frame2, _, "$parentAutoCurrentSlider", "autoCurrentSlider", 60, 20, _, _, instance.auto_current)
		
		-- Auto Current Segment
	
		g:NewLabel (frame2, _, "$parentAutoCurrentLabel", "autoCurrentLabel", Loc ["STRING_OPTIONS_INSTANCE_CURRENT"], "GameFontHighlightLeft")

		frame2.autoCurrentSlider:SetPoint ("left", frame2.autoCurrentLabel, "right", 2)
		frame2.autoCurrentSlider.OnSwitch = function (self, instance, value)
			instance.auto_current = value
		end
		
		frame2.autoCurrentSlider.info = Loc ["STRING_OPTIONS_INSTANCE_CURRENT_DESC"]
		window:create_line_background (frame2, frame2.autoCurrentLabel, frame2.autoCurrentSlider)
		frame2.autoCurrentSlider:SetHook ("OnEnter", background_on_enter)
		frame2.autoCurrentSlider:SetHook ("OnLeave", background_on_leave)

		frame2.fragsPvpLabel:SetPoint (10, -75)
		frame2.timetypeLabel:SetPoint (10, -100)
		frame2.hideOnCombatLabel:SetPoint (10, -135)
		frame2.hideOnCombatAlphaLabel:SetPoint (10, -160)
		frame2.autoSwitchLabel:SetPoint (10, -195)
		frame2.autoCurrentLabel:SetPoint (10, -220) --auto current
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Skin
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	local frame3 = window.options [3][1]

	--> Skin
		local titulo_skin = g:NewLabel (frame3, _, "$parentTituloSkin", "tituloSkinLabel", Loc ["STRING_OPTIONS_SKIN_A"], "GameFontNormal", 16)
		local titulo_skin_desc = g:NewLabel (frame3, _, "$parentTituloSkin2", "tituloSkin2Label", Loc ["STRING_OPTIONS_SKIN_A_DESC"], "GameFontNormal", 9, "white")
		titulo_skin_desc.width = 320
	
	--> Save Load
		local titulo_save = g:NewLabel (frame3, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_SAVELOAD"], "GameFontNormal", 16)
		local titulo_save_desc = g:NewLabel (frame3, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_SAVELOAD_DESC"], "GameFontNormal", 9, "white")
		titulo_save_desc.width = 320
		
	--> create functions and frames first:

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
		_detalhes.loadStyleFunc = loadStyle 
	
		local resetToDefaults = function()
			loadStyle (nil, window.instance, _detalhes.instance_defaults)
		end

		--g:NewButton (frame3, _, "$parentResetToDefaultButton", "resetToDefaults", 160, 16, resetToDefaults, nil, nil, nil, Loc ["STRING_OPTIONS_SAVELOAD_RESET"])
		--frame3.resetToDefaults:InstallCustomTexture()

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
		
		-- skin
		g:NewDropDown (frame3, _, "$parentSkinDropdown", "skinDropdown", 160, 20, buildSkinMenu, 1)	
		g:NewLabel (frame3, _, "$parentSkinLabel", "skinLabel", Loc ["STRING_OPTIONS_INSTANCE_SKIN"], "GameFontHighlightLeft")
	
		frame3.skinDropdown.info = Loc ["STRING_OPTIONS_INSTANCE_SKIN_DESC"]
		window:create_line_background (frame3, frame3.skinLabel, frame3.skinDropdown)
		frame3.skinDropdown:SetHook ("OnEnter", background_on_enter)
		frame3.skinDropdown:SetHook ("OnLeave", background_on_leave)
		frame3.skinDropdown:SetPoint ("left", frame3.skinLabel, "right", 2)

	--> Create New Skin
	
		local function saveStyleFunc (temp)
			if ((not frame3.saveStyleName.text or frame3.saveStyleName.text == "") and not temp) then
				_detalhes:Msg (Loc ["STRING_OPTIONS_PRESETNONAME"])
				return
			end
			
			local savedObject = {
				version = preset_version,
				name = frame3.saveStyleName.text, --> preset name
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
			frame3.saveStyleName.text = ""
			
			_detalhes:Msg (Loc ["STRING_OPTIONS_SAVELOAD_SKINCREATED"])
			
		end	
	
		g:NewTextEntry (frame3, _, "$parentSaveStyleName", "saveStyleName", 120, 20)
		g:NewLabel (frame3, _, "$parentSaveSkinLabel", "saveSkinLabel", Loc ["STRING_OPTIONS_SAVELOAD_PNAME"], "GameFontHighlightLeft")
		frame3.saveStyleName:SetPoint ("left", frame3.saveSkinLabel, "right", 2)
		g:NewButton (frame3, _, "$parentSaveStyleButton", "saveStyle", 50, 19, saveStyleFunc, nil, nil, nil, Loc ["STRING_OPTIONS_SAVELOAD_SAVE"])
		frame3.saveStyle:InstallCustomTexture()
		
		frame3.saveStyleName.info = Loc ["STRING_OPTIONS_SAVELOAD_CREATE_DESC"]
		window:create_line_background (frame3, frame3.saveSkinLabel, frame3.saveStyleName)
		frame3.saveStyleName:SetHook ("OnEnter", background_on_enter)
		frame3.saveStyleName:SetHook ("OnLeave", background_on_leave)

	--> apply to all button
		local applyToAll = function()
		
			local temp_preset = saveStyleFunc (true)
			local current_instance = window.instance
			
			for _, this_instance in ipairs (_detalhes.tabela_instancias) do 
				if (this_instance.meu_id ~= window.instance.meu_id) then
					if (not this_instance.iniciada) then
						this_instance:RestauraJanela()
						loadStyle (nil, this_instance, temp_preset)
						this_instance:DesativarInstancia()
					else
						loadStyle (nil, this_instance, temp_preset)
					end
				end
			end
			
			_detalhes:OpenOptionsWindow (current_instance)
			
			_detalhes:Msg (Loc ["STRING_OPTIONS_SAVELOAD_APPLYALL"])
			
		end
		
		local makeDefault = function()
			local temp_preset = saveStyleFunc (true)
			_detalhes.standard_skin = temp_preset
			_detalhes:Msg (Loc ["STRING_OPTIONS_SAVELOAD_STDSAVE"])
		end

		g:NewButton (frame3, _, "$parentToAllStyleButton", "applyToAll", 160, 18, applyToAll, nil, nil, nil, Loc ["STRING_OPTIONS_SAVELOAD_APPLYTOALL"])
		frame3.applyToAll:InstallCustomTexture()
		g:NewButton (frame3, _, "$parentMakeDefaultButton", "makeDefault", 160, 18, makeDefault, nil, nil, nil, Loc ["STRING_OPTIONS_SAVELOAD_MAKEDEFAULT"])
		frame3.makeDefault:InstallCustomTexture()
		
		g:NewLabel (frame3, _, "$parentToAllStyleLabel", "toAllStyleLabel", "", "GameFontHighlightLeft")
		g:NewLabel (frame3, _, "$parentmakeDefaultLabel", "makeDefaultLabel", "", "GameFontHighlightLeft")
		
		frame3.toAllStyleLabel:SetPoint ("left", frame3.applyToAll, "left")
		frame3.makeDefaultLabel:SetPoint ("left", frame3.makeDefault, "left")
		
		frame3.applyToAll.info = Loc ["STRING_OPTIONS_SAVELOAD_APPLYALL_DESC"]
		window:create_line_background (frame3, frame3.toAllStyleLabel, frame3.applyToAll)
		frame3.applyToAll:SetHook ("OnEnter", background_on_enter)
		frame3.applyToAll:SetHook ("OnLeave", background_on_leave)
		
		frame3.makeDefault.info = Loc ["STRING_OPTIONS_SAVELOAD_STD_DESC"]
		window:create_line_background (frame3, frame3.makeDefaultLabel, frame3.makeDefault)
		frame3.makeDefault:SetHook ("OnEnter", background_on_enter)
		frame3.makeDefault:SetHook ("OnLeave", background_on_leave)
		
	--> Load Custom Skin
		g:NewLabel (frame3, _, "$parentLoadCustomSkinLabel", "loadCustomSkinLabel", Loc ["STRING_OPTIONS_SAVELOAD_LOAD"], "GameFontHighlightLeft")
		--
		local onSelectCustomSkin = function (_, _, index)
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
			_detalhes:OpenOptionsWindow (window.instance)
		end

		local loadtable = {}
		local buildCustomSkinMenu = function()
			table.wipe (loadtable)
			for index, _table in ipairs (_detalhes.savedStyles) do
				tinsert (loadtable, {value = index, label = _table.name, onclick = onSelectCustomSkin, icon = "Interface\\GossipFrame\\TabardGossipIcon", iconcolor = {.7, .7, .5, 1}})
			end
			return loadtable
		end
		
		g:NewDropDown (frame3, _, "$parentCustomSkinLoadDropdown", "customSkinSelectDropdown", 160, 20, buildCustomSkinMenu, nil) -- func, default
		frame3.customSkinSelectDropdown:SetPoint ("left", frame3.loadCustomSkinLabel, "right", 2, 0)
		
		frame3.customSkinSelectDropdown.info = Loc ["STRING_OPTIONS_SAVELOAD_LOAD_DESC"]
		window:create_line_background (frame3, frame3.loadCustomSkinLabel, frame3.customSkinSelectDropdown)
		frame3.customSkinSelectDropdown:SetHook ("OnEnter", background_on_enter)
		frame3.customSkinSelectDropdown:SetHook ("OnLeave", background_on_leave)
		
	--> Remove Custom Skin
		g:NewLabel (frame3, _, "$parentRemoveCustomSkinLabel", "removeCustomSkinLabel", Loc ["STRING_OPTIONS_SAVELOAD_REMOVE"], "GameFontHighlightLeft")
		--
		local onSelectCustomSkinToErase = function (_, _, index)
			table.remove (_detalhes.savedStyles, index)
			frame3.customSkinSelectToRemoveDropdown:Select (1)
		end

		local loadtable2 = {}
		local buildCustomSkinToEraseMenu = function()
			table.wipe (loadtable2)
			for index, _table in ipairs (_detalhes.savedStyles) do
				tinsert (loadtable2, {value = index, label = _table.name, onclick = onSelectCustomSkinToErase, icon = [[Interface\COMMON\VOICECHAT-MUTED]], iconcolor = {.7, .7, .5, 1}})
			end
			return loadtable2
		end
		
		g:NewDropDown (frame3, _, "$parentCustomSkinRemoveDropdown", "customSkinSelectToRemoveDropdown", 160, 20, buildCustomSkinToEraseMenu, nil) -- func, default
		frame3.customSkinSelectToRemoveDropdown:SetPoint ("left", frame3.removeCustomSkinLabel, "right", 2, 0)
		frame3.customSkinSelectToRemoveDropdown.info = Loc ["STRING_OPTIONS_SAVELOAD_LOAD_DESC"]

		frame3.customSkinSelectToRemoveDropdown.info = Loc ["STRING_OPTIONS_SAVELOAD_ERASE_DESC"]
		
		window:create_line_background (frame3, frame3.removeCustomSkinLabel, frame3.customSkinSelectToRemoveDropdown)
		frame3.customSkinSelectToRemoveDropdown:SetHook ("OnEnter", background_on_enter)
		frame3.customSkinSelectToRemoveDropdown:SetHook ("OnLeave", background_on_leave)

		
	--title
		titulo_skin:SetPoint (10, -10)
		titulo_skin_desc:SetPoint (10, -30)
	--skin select
		frame3.skinLabel:SetPoint (10, -70)
	--title
		titulo_save:SetPoint (10, -105)
		titulo_save_desc:SetPoint (10, -125)

	--saving
		frame3.saveSkinLabel:SetPoint (10, -160)
		frame3.saveStyle:SetPoint ("left", frame3.saveStyleName, "right", 2)
		
	--loading
		frame3.loadCustomSkinLabel:SetPoint (10, -185)
	
	--removing
		frame3.removeCustomSkinLabel:SetPoint (10, -210)
		
		frame3.makeDefault:SetPoint (10, -245)
		--frame3.resetToDefaults:SetPoint (10, -270)
		frame3.applyToAll:SetPoint (10, -270)
		
		
	
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Row
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local frame4 = window.options [4][1]

	--> bars general
		local titulo_bars = g:NewLabel (frame4, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_BARS"], "GameFontNormal", 16)
		local titulo_bars_desc = g:NewLabel (frame4, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_BARS_DESC"], "GameFontNormal", 9, "white")
		titulo_bars_desc.width = 320
	
	--> bar background color
	
		local rowcolorbackground_callback = function (button, r, g, b, a)
			window.instance:SetBarSettings (nil, nil, nil, nil, nil, nil, {r, g, b, a})
		end
		g:NewColorPickButton (frame4, "$parentRowBackgroundColorPick", "rowBackgroundColorPick", rowcolorbackground_callback)
		g:NewLabel (frame4, _, "$parentRowBackgroundColorPickLabel", "rowBackgroundPickLabel", Loc ["STRING_OPTIONS_TEXT_ROWCOLOR"], "GameFontHighlightLeft")
		frame4.rowBackgroundColorPick:SetPoint ("left", frame4.rowBackgroundPickLabel, "right", 2, 0)

		frame4.rowBackgroundColorPick.info = Loc ["STRING_OPTIONS_BAR_BCOLOR_DESC"]
		window:create_line_background (frame4, frame4.rowBackgroundPickLabel, frame4.rowBackgroundColorPick)
		frame4.rowBackgroundColorPick:SetHook ("OnEnter", background_on_enter)
		frame4.rowBackgroundColorPick:SetHook ("OnLeave", background_on_leave)

	--> bar texture by class color
		g:NewSwitch (frame4, _, "$parentClassColorSlider", "classColorSlider", 60, 20, _, _, instance.row_info.texture_class_colors)

		
	--> background with class color
		g:NewSwitch (frame4, _, "$parentBackgroundClassColorSlider", "rowBackgroundColorByClassSlider", 60, 20, _, _, instance.row_info.texture_background_class_color)
	
	--> bar height
		g:NewSlider (frame4, _, "$parentSliderRowHeight", "rowHeightSlider", SLIDER_WIDTH, 20, 10, 30, 1, tonumber (instance.row_info.height))

	--> bars grow direction
		g:NewSwitch (frame4, _, "$parentBarGrowDirectionSlider", "barGrowDirectionSlider", 80, 20, Loc ["STRING_TOP"], Loc ["STRING_BOTTOM"], instance.bars_grow_direction, true)

	--> bars sort direction
		g:NewSwitch (frame4, _, "$parentBarSortDirectionSlider", "barSortDirectionSlider", 80, 20, Loc ["STRING_TOP"], Loc ["STRING_BOTTOM"], instance.bars_sort_direction, true)

	--> row texture color
	
		local rowcolor_callback = function (button, r, g, b, a)
			window.instance:SetBarSettings (nil, nil, nil, {r, g, b})
			window.instance.row_info.alpha = a
			window.instance:SetBarSettings (nil, nil, nil, nil, nil, nil, nil, a)
		end
		g:NewColorPickButton (frame4, "$parentRowColorPick", "rowColorPick", rowcolor_callback)
		g:NewLabel (frame4, _, "$parentRowColorPickLabel", "rowPickColorLabel", Loc ["STRING_OPTIONS_TEXT_ROWCOLOR2"], "GameFontHighlightLeft")
		frame4.rowColorPick:SetPoint ("left", frame4.rowPickColorLabel, "right", 2, 0)

		frame4.rowColorPick.info = Loc ["STRING_OPTIONS_BAR_COLOR_DESC"]
		window:create_line_background (frame4, frame4.rowPickColorLabel, frame4.rowColorPick)
		frame4.rowColorPick:SetHook ("OnEnter", background_on_enter)
		frame4.rowColorPick:SetHook ("OnLeave", background_on_leave)
	
	
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
			
			g:NewDropDown (frame4, _, "$parentRowBackgroundTextureDropdown", "rowBackgroundDropdown", DROPDOWN_WIDTH, 20, buildTextureMenu2, nil)			
		
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
			g:NewDropDown (frame4, _, "$parentTextureDropdown", "textureDropdown", DROPDOWN_WIDTH, 20, buildTextureMenu, nil)			
		
		-- bar grow direction
			g:NewLabel (frame4, _, "$parentBarGrowDirectionLabel", "barGrowDirectionLabel", Loc ["STRING_OPTIONS_BARGROW_DIRECTION"], "GameFontHighlightLeft")

			frame4.barGrowDirectionSlider:SetPoint ("left", frame4.barGrowDirectionLabel, "right", 2)
			frame4.barGrowDirectionSlider.OnSwitch = function (self, instance, value)
				instance:SetBarGrowDirection (value and 2 or 1)
			end
			frame4.barGrowDirectionSlider.thumb:SetSize (50, 12)
			
			frame4.barGrowDirectionSlider.info = Loc ["STRING_OPTIONS_BARGROW_DIRECTION_DESC"]
			window:create_line_background (frame4, frame4.barGrowDirectionLabel, frame4.barGrowDirectionSlider)
			frame4.barGrowDirectionSlider:SetHook ("OnEnter", background_on_enter)
			frame4.barGrowDirectionSlider:SetHook ("OnLeave", background_on_leave)
			
		-- bar sort direction
			g:NewLabel (frame4, _, "$parentBarSortDirectionLabel", "barSortDirectionLabel", Loc ["STRING_OPTIONS_BARSORT_DIRECTION"], "GameFontHighlightLeft")

			frame4.barSortDirectionSlider:SetPoint ("left", frame4.barSortDirectionLabel, "right", 2)
			frame4.barSortDirectionSlider.OnSwitch = function (self, instance, value)
				instance.bars_sort_direction = value and 2 or 1
				_detalhes:AtualizaGumpPrincipal (-1, true)
			end
			frame4.barSortDirectionSlider.thumb:SetSize (50, 12)
			
			frame4.barSortDirectionSlider.info = Loc ["STRING_OPTIONS_BARSORT_DIRECTION_DESC"]
			window:create_line_background (frame4, frame4.barSortDirectionLabel, frame4.barSortDirectionSlider)
			frame4.barSortDirectionSlider:SetHook ("OnEnter", background_on_enter)
			frame4.barSortDirectionSlider:SetHook ("OnLeave", background_on_leave)

	-- Bar Settings
	
		g:NewLabel (frame4, _, "$parentRowUpperTextureAnchor", "rowUpperTextureLabel", "Top Texture", "GameFontNormal")
		g:NewLabel (frame4, _, "$parentRowLowerTextureAnchor", "rowLowerTextureLabel", "Bottom Texture (background)", "GameFontNormal")
	
		--alpha
		g:NewLabel (frame4, _, "$parentRowAlphaLabel", "rowAlphaLabel", "Alpha", "GameFontHighlightLeft")
		g:NewSlider (frame4, _, "$parentRowAlphaSlider", "rowAlphaSlider", SLIDER_WIDTH, 20, 0.02, 1, 0.02, instance.row_info.alpha, true)
		frame4.rowAlphaSlider:SetPoint ("left", frame4.rowAlphaLabel, "right", 2, 0)
		frame4.rowAlphaSlider.useDecimals = true
		frame4.rowAlphaSlider:SetHook ("OnValueChange", function (self, instance, amount)
			self.amt:SetText (string.format ("%.2f", amount))
			instance.row_info.alpha = amount --precisa atualizar a barra
			instance:SetBarSettings (nil, nil, nil, nil, nil, nil, nil, amount)
			return true
		end)
		frame4.rowAlphaSlider.thumb:SetSize (30+(120*0.2)+2, 20*1.2)

		frame4.rowAlphaSlider.info = "Change the alpha of the row"
		window:create_line_background (frame4, frame4.rowAlphaLabel, frame4.rowAlphaSlider)
		frame4.rowAlphaSlider:SetHook ("OnEnter", background_on_enter)
		frame4.rowAlphaSlider:SetHook ("OnLeave", background_on_leave)
	
		-- texture
		g:NewLabel (frame4, _, "$parentTextureLabel", "textureLabel", Loc ["STRING_OPTIONS_BAR_TEXTURE"], "GameFontHighlightLeft")
		--
		frame4.textureDropdown:SetPoint ("left", frame4.textureLabel, "right", 2)
		
		frame4.textureDropdown.info = Loc ["STRING_OPTIONS_BAR_TEXTURE_DESC"]
		window:create_line_background (frame4, frame4.textureLabel, frame4.textureDropdown)
		frame4.textureDropdown:SetHook ("OnEnter", background_on_enter)
		frame4.textureDropdown:SetHook ("OnLeave", background_on_leave)
		
		-- background texture
		g:NewLabel (frame4, _, "$parentRowBackgroundTextureLabel", "rowBackgroundLabel", Loc ["STRING_OPTIONS_BAR_TEXTURE"], "GameFontHighlightLeft")
		--
		frame4.rowBackgroundDropdown:SetPoint ("left", frame4.rowBackgroundLabel, "right", 2)

		frame4.rowBackgroundDropdown.info = Loc ["STRING_OPTIONS_BAR_BTEXTURE_DESC"]
		window:create_line_background (frame4, frame4.rowBackgroundLabel, frame4.rowBackgroundDropdown)
		frame4.rowBackgroundDropdown:SetHook ("OnEnter", background_on_enter)
		frame4.rowBackgroundDropdown:SetHook ("OnLeave", background_on_leave)
	
		-- background color
		g:NewLabel (frame4, _, "$parentRowBackgroundColorLabel", "rowBackgroundColorLabel", Loc ["STRING_OPTIONS_BAR_BCOLOR"], "GameFontHighlightLeft")

		-- back background with class color
		g:NewLabel (frame4, _, "$parentRowBackgroundClassColorLabel", "rowBackgroundColorByClassLabel", Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2"], "GameFontHighlightLeft")

		frame4.rowBackgroundColorByClassSlider:SetPoint ("left", frame4.rowBackgroundColorByClassLabel, "right", 2)
		frame4.rowBackgroundColorByClassSlider.OnSwitch = function (self, instance, value)
			instance:SetBarSettings (nil, nil, nil, nil, nil, value)
		end

		frame4.rowBackgroundColorByClassSlider.info = Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2_DESC"]
		window:create_line_background (frame4, frame4.rowBackgroundColorByClassLabel, frame4.rowBackgroundColorByClassSlider)
		frame4.rowBackgroundColorByClassSlider:SetHook ("OnEnter", background_on_enter)
		frame4.rowBackgroundColorByClassSlider:SetHook ("OnLeave", background_on_leave)
	
		-- height
		g:NewLabel (frame4, _, "$parentRowHeightLabel", "rowHeightLabel", Loc ["STRING_OPTIONS_BAR_HEIGHT"], "GameFontHighlightLeft")
		--
		frame4.rowHeightSlider:SetPoint ("left", frame4.rowHeightLabel, "right", 2)
		frame4.rowHeightSlider:SetThumbSize (50)
		frame4.rowHeightSlider:SetHook ("OnValueChange", function (self, instance, amount) 
			instance.row_info.height = amount
			instance.row_height = instance.row_info.height+instance.row_info.space.between
			instance:RefreshBars()
			instance:InstanceReset()
			instance:ReajustaGump()
		end)	
		
		frame4.rowHeightSlider.info = Loc ["STRING_OPTIONS_BAR_HEIGHT_DESC"]
		window:create_line_background (frame4, frame4.rowHeightLabel, frame4.rowHeightSlider)
		frame4.rowHeightSlider:SetHook ("OnEnter", background_on_enter)
		frame4.rowHeightSlider:SetHook ("OnLeave", background_on_leave)
	
		-- texture color by class color
		g:NewLabel (frame4, _, "$parentUseClassColorsLabel", "classColorsLabel", Loc ["STRING_OPTIONS_BAR_COLORBYCLASS"], "GameFontHighlightLeft")
		frame4.classColorSlider:SetPoint ("left", frame4.classColorsLabel, "right", 2)
		frame4.classColorSlider.OnSwitch = function (self, instance, value)
			instance:SetBarSettings (nil, nil, value)
		end

		frame4.classColorSlider.info = Loc ["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"]
		window:create_line_background (frame4, frame4.classColorsLabel, frame4.classColorSlider)
		frame4.classColorSlider:SetHook ("OnEnter", background_on_enter)
		frame4.classColorSlider:SetHook ("OnLeave", background_on_leave)		

		--icon file
		g:NewLabel (frame4, _, "$parentIconFileLabel", "iconFileLabel", Loc ["STRING_OPTIONS_BAR_ICONFILE"], "GameFontHighlightLeft")
		g:NewTextEntry (frame4, _, "$parentIconFileEntry", "iconFileEntry", 260, 20)
		frame4.iconFileEntry:SetPoint ("left", frame4.iconFileLabel, "right", 2, 0)

		frame4.iconFileEntry.tooltip = "press escape to restore default value"
		frame4.iconFileEntry:SetHook ("OnEnterPressed", function()
			instance:SetBarSettings (nil, nil, nil, nil, nil, nil, nil, nil, frame4.iconFileEntry.text)
		end)
		frame4.iconFileEntry:SetHook ("OnEscapePressed", function()
			frame4.iconFileEntry:SetText ([[Interface\AddOns\Details\images\classes_small]])
			frame4.iconFileEntry:ClearFocus()
			instance:SetBarSettings (nil, nil, nil, nil, nil, nil, nil, nil, [[Interface\AddOns\Details\images\classes_small]])
			return true
		end)
		
		frame4.iconFileEntry.info = Loc ["STRING_OPTIONS_BAR_ICONFILE_DESC"]
		window:create_line_background (frame4, frame4.iconFileLabel, frame4.iconFileEntry)
		frame4.iconFileEntry:SetHook ("OnEnter", background_on_enter)
		frame4.iconFileEntry:SetHook ("OnLeave", background_on_leave)

		frame4.iconFileEntry.text = instance.row_info.icon_file

		--anchors:
		titulo_bars:SetPoint (10, -10)
		titulo_bars_desc:SetPoint (10, -30)

		frame4.rowHeightLabel:SetPoint (10, -70) --bar height
		frame4.barGrowDirectionLabel:SetPoint (10, -95) --grow direction
		frame4.barSortDirectionLabel:SetPoint (10, -120) --sort direction
		
		frame4.rowUpperTextureLabel:SetPoint (10, -155) --anchor
		
		frame4.textureLabel:SetPoint (10, -180) --bar texture
		frame4.rowAlphaLabel:SetPoint (10, -205) --bar alpha slider
		frame4.classColorsLabel:SetPoint (10, -230) --class color
		
		frame4.rowPickColorLabel:SetPoint (10, -255)
		
		frame4.rowLowerTextureLabel:SetPoint (10, -290)
		
		frame4.rowBackgroundLabel:SetPoint (10, -315) --select background
		frame4.rowBackgroundColorByClassLabel:SetPoint (10, -340) --class color background
		frame4.rowBackgroundPickLabel:SetPoint (10, -365) --bar color background		
		
		frame4.iconFileLabel:SetPoint (10, -405)
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Texts
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local frame5 = window.options [5][1]
	
	--> bars text
		local titulo_texts = g:NewLabel (frame5, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_TEXT"], "GameFontNormal", 16)
		local titulo_texts_desc = g:NewLabel (frame5, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_TEXT_DESC"], "GameFontNormal", 9, "white")
		titulo_texts_desc.width = 320
	
	--> text color
		local textcolor_callback = function (button, r, g, b, a)
			window.instance:SetBarTextSettings (nil, nil, {r, g, b, 1})
		end
		g:NewColorPickButton (frame5, "$parentFixedTextColor", "fixedTextColor", textcolor_callback, false)
		local fixedColorText = g:NewLabel (frame5, _, "$parentFixedTextColorLabel", "fixedTextColorLabel", Loc ["STRING_OPTIONS_TEXT_FIXEDCOLOR"], "GameFontHighlightLeft")
		frame5.fixedTextColor:SetPoint ("left", fixedColorText, "right", 2, 0)
	
		--> text size
			g:NewSlider (frame5, _, "$parentSliderFontSize", "fonsizeSlider", SLIDER_WIDTH, 20, 8, 15, 1, tonumber (instance.row_info.font_size))

		--> outline
			g:NewSwitch (frame5, _, "$parentTextLeftOutlineSlider", "textLeftOutlineSlider", 60, 20, _, _, instance.row_info.textL_outline)
			g:NewSwitch (frame5, _, "$parentTextRightOutlineSlider", "textRightOutlineSlider", 60, 20, _, _, instance.row_info.textR_outline)

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
			g:NewDropDown (frame5, _, "$parentFontDropdown", "fontDropdown", DROPDOWN_WIDTH, 20, buildFontMenu, nil)		

	-- Text Settings
	
		-- Text Sizes
		g:NewLabel (frame5, _, "$parentFontSizeLabel", "fonsizeLabel", Loc ["STRING_OPTIONS_TEXT_SIZE"], "GameFontHighlightLeft")
		frame5.fonsizeSlider:SetPoint ("left", frame5.fonsizeLabel, "right", 2)
		frame5.fonsizeSlider:SetThumbSize (50)
		frame5.fonsizeSlider:SetHook ("OnValueChange", function (self, instance, amount)
			instance:SetBarTextSettings (amount)
		end)
		frame5.fonsizeSlider.info = Loc ["STRING_OPTIONS_TEXT_SIZE_DESC"]
		window:create_line_background (frame5, frame5.fonsizeLabel, frame5.fonsizeSlider)
		frame5.fonsizeSlider:SetHook ("OnEnter", background_on_enter)
		frame5.fonsizeSlider:SetHook ("OnLeave", background_on_leave)
		
		-- Text Fonts
		g:NewLabel (frame5, _, "$parentFontLabel", "fontLabel", Loc ["STRING_OPTIONS_TEXT_FONT"], "GameFontHighlightLeft")
		frame5.fontDropdown:SetPoint ("left", frame5.fontLabel, "right", 2)
		
		frame5.fontDropdown.info = Loc ["STRING_OPTIONS_TEXT_FONT_DESC"]
		window:create_line_background (frame5, frame5.fontLabel, frame5.fontDropdown)
		frame5.fontDropdown:SetHook ("OnEnter", background_on_enter)
		frame5.fontDropdown:SetHook ("OnLeave", background_on_leave)		

		-- left text by class color
		--> left text and right class color
		g:NewSwitch (frame5, _, "$parentUseClassColorsLeftTextSlider", "classColorsLeftTextSlider", 60, 20, _, _, instance.row_info.textL_class_colors)
		g:NewSwitch (frame5, _, "$parentUseClassColorsRightTextSlider", "classColorsRightTextSlider", 60, 20, _, _, instance.row_info.textR_class_colors)
		g:NewLabel (frame5, _, "$parentUseClassColorsLeftText", "classColorsLeftTextLabel", Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR"], "GameFontHighlightLeft")

		frame5.classColorsLeftTextSlider:SetPoint ("left", frame5.classColorsLeftTextLabel, "right", 2)
		frame5.classColorsLeftTextSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, value)
		end
		
		frame5.classColorsLeftTextSlider.info = Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR_DESC"]
		window:create_line_background (frame5, frame5.classColorsLeftTextLabel, frame5.classColorsLeftTextSlider)
		frame5.classColorsLeftTextSlider:SetHook ("OnEnter", background_on_enter)
		frame5.classColorsLeftTextSlider:SetHook ("OnLeave", background_on_leave)
		
		-- right text by class color
		g:NewLabel (frame5, _, "$parentUseClassColorsRightText", "classColorsRightTextLabel", Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR"], "GameFontHighlightLeft")

		frame5.classColorsRightTextSlider:SetPoint ("left", frame5.classColorsRightTextLabel, "right", 2)
		frame5.classColorsRightTextSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, nil, value)
		end
		
		frame5.classColorsRightTextSlider.info = Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR_DESC"]
		window:create_line_background (frame5, frame5.classColorsRightTextLabel, frame5.classColorsRightTextSlider)
		frame5.classColorsRightTextSlider:SetHook ("OnEnter", background_on_enter)
		frame5.classColorsRightTextSlider:SetHook ("OnLeave", background_on_leave)
		
		-- left outline
		g:NewLabel (frame5, _, "$parentTextLeftOutlineLabel", "textLeftOutlineLabel", Loc ["STRING_OPTIONS_TEXT_LOUTILINE"], "GameFontHighlightLeft")
		
		frame5.textLeftOutlineSlider:SetPoint ("left", frame5.textLeftOutlineLabel, "right", 2)
		frame5.textLeftOutlineSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, nil, nil, value)
		end

		frame5.textLeftOutlineSlider.info = Loc ["STRING_OPTIONS_TEXT_LOUTILINE_DESC"]
		window:create_line_background (frame5, frame5.textLeftOutlineLabel, frame5.textLeftOutlineSlider)
		frame5.textLeftOutlineSlider:SetHook ("OnEnter", background_on_enter)
		frame5.textLeftOutlineSlider:SetHook ("OnLeave", background_on_leave)
		
		-- right outline
		g:NewLabel (frame5, _, "$parentTextRightOutlineLabel", "textRightOutlineLabel", Loc ["STRING_OPTIONS_TEXT_ROUTILINE"], "GameFontHighlightLeft")
		
		frame5.textRightOutlineSlider:SetPoint ("left", frame5.textRightOutlineLabel, "right", 2)
		frame5.textRightOutlineSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, nil, nil, nil, value)
		end
		
		frame5.textRightOutlineSlider.info = Loc ["STRING_OPTIONS_TEXT_ROUTILINE_DESC"]
		window:create_line_background (frame5, frame5.textRightOutlineLabel, frame5.textRightOutlineSlider)
		frame5.textRightOutlineSlider:SetHook ("OnEnter", background_on_enter)
		frame5.textRightOutlineSlider:SetHook ("OnLeave", background_on_leave)
			
		titulo_texts:SetPoint (10, -10)
		titulo_texts_desc:SetPoint (10, -30)
		
		frame5.fonsizeLabel:SetPoint (10, -70) --text size
		frame5.fontLabel:SetPoint (10, -95) --text fontface
		frame5.textLeftOutlineLabel:SetPoint (10, -120) --left outline
		frame5.textRightOutlineLabel:SetPoint (10, -145) --right outline
		frame5.classColorsLeftTextLabel:SetPoint (10, -170) --left color by class
		frame5.classColorsRightTextLabel:SetPoint (10, -195) --right color by class
		
		frame5.fixedTextColorLabel:SetPoint (10, -220)
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Window Settings
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local frame6 = window.options [6][1]

	--> window
		local titulo_instance = g:NewLabel (frame6, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_INSTANCE"], "GameFontNormal", 16)
		local titulo_instance_desc = g:NewLabel (frame6, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_INSTANCE_DESC"], "GameFontNormal", 9, "white")
		titulo_instance_desc.width = 320

	--> window color
		local windowcolor_callback = function (button, r, g, b, a)
			window.instance:InstanceColor (r, g, b, a)
		end
		g:NewColorPickButton (frame6, "$parentWindowColorPick", "windowColorPick", windowcolor_callback)
		g:NewLabel (frame6, _, "$parentWindowColorPickLabel", "windowPickColorLabel", Loc ["STRING_OPTIONS_INSTANCE_COLOR"], "GameFontHighlightLeft")
		frame6.windowColorPick:SetPoint ("left", frame6.windowPickColorLabel, "right", 2, 0)

		frame6.windowColorPick.info = Loc ["STRING_OPTIONS_INSTANCE_COLOR_DESC"]
		window:create_line_background (frame6, frame6.windowPickColorLabel, frame6.windowColorPick)
		frame6.windowColorPick:SetHook ("OnEnter", background_on_enter)
		frame6.windowColorPick:SetHook ("OnLeave", background_on_leave)

	--> Transparency
		g:NewSlider (frame6, _, "$parentAlphaSlider", "alphaSlider", SLIDER_WIDTH, 20, 0.02, 1, 0.02, instance.bg_alpha, true)
	
	--> background color
	
		local windowbackgroundcolor_callback = function (button, r, g, b, a)
			window.instance:SetBackgroundColor (r, g, b)
			window.instance:SetBackgroundAlpha (a)
			frame6.alphaSlider:SetValue (a)
		end
		g:NewColorPickButton (frame6, "$parentWindowBackgroundColorPick", "windowBackgroundColorPick", windowbackgroundcolor_callback)
		g:NewLabel (frame6, _, "$parentWindowBackgroundColorPickLabel", "windowBackgroundPickColorLabel", Loc ["STRING_OPTIONS_INSTANCE_ALPHA2"], "GameFontHighlightLeft")
		frame6.windowBackgroundColorPick:SetPoint ("left", frame6.windowBackgroundPickColorLabel, "right", 2, 0)

		frame6.windowBackgroundColorPick.info = Loc ["STRING_OPTIONS_INSTANCE_ALPHA2_DESC"]
		window:create_line_background (frame6, frame6.windowBackgroundPickColorLabel, frame6.windowBackgroundColorPick)
		frame6.windowBackgroundColorPick:SetHook ("OnEnter", background_on_enter)
		frame6.windowBackgroundColorPick:SetHook ("OnLeave", background_on_leave)

	--> sidebars statusbar
		g:NewSwitch (frame6, _, "$parentSideBarsSlider", "sideBarsSlider", 60, 20, _, _, instance.show_sidebars)
		g:NewSwitch (frame6, _, "$parentStatusbarSlider", "statusbarSlider", 60, 20, _, _, instance.show_statusbar)

	--> stretch button anchor
		g:NewSwitch (frame6, _, "$parentStretchAnchorSlider", "stretchAnchorSlider", 80, 20, Loc ["STRING_TOP"], Loc ["STRING_BOTTOM"], instance.stretch_button_side, true)
		
	-- Instance Settings
	
		-- Color and Alpha
		g:NewLabel (frame6, _, "$parentAlphaLabel", "alphaLabel", Loc ["STRING_OPTIONS_INSTANCE_ALPHA"], "GameFontHighlightLeft")
		g:NewLabel (frame6, _, "$parentBackgroundColorLabel", "backgroundColorLabel", Loc ["STRING_OPTIONS_INSTANCE_ALPHA2"], "GameFontHighlightLeft")
		
		-- alpha background
		frame6.alphaSlider:SetPoint ("left", frame6.alphaLabel, "right", 2, 0)
		frame6.alphaSlider.useDecimals = true
		frame6.alphaSlider:SetHook ("OnValueChange", function (self, instance, amount) --> slider, fixedValue, sliderValue
			self.amt:SetText (string.format ("%.2f", amount))
			instance:SetBackgroundAlpha (amount)
			return true
		end)
		frame6.alphaSlider.thumb:SetSize (30+(120*0.2)+2, 20*1.2)

		frame6.alphaSlider.info = Loc ["STRING_OPTIONS_INSTANCE_ALPHA_DESC"]
		window:create_line_background (frame6, frame6.alphaLabel, frame6.alphaSlider)
		frame6.alphaSlider:SetHook ("OnEnter", background_on_enter)
		frame6.alphaSlider:SetHook ("OnLeave", background_on_leave)		
		
		-- stretch button anchor
			g:NewLabel (frame6, _, "$parentStretchAnchorLabel", "stretchAnchorLabel", Loc ["STRING_OPTIONS_STRETCH"], "GameFontHighlightLeft")

			frame6.stretchAnchorSlider:SetPoint ("left", frame6.stretchAnchorLabel, "right", 2)
			frame6.stretchAnchorSlider.OnSwitch = function (self, instance, value)
				instance:StretchButtonAnchor (value and 2 or 1)
			end
			frame6.stretchAnchorSlider.thumb:SetSize (40, 12)
			
			frame6.stretchAnchorSlider.info = Loc ["STRING_OPTIONS_STRETCH_DESC"]
			window:create_line_background (frame6, frame6.stretchAnchorLabel, frame6.stretchAnchorSlider)
			frame6.stretchAnchorSlider:SetHook ("OnEnter", background_on_enter)
			frame6.stretchAnchorSlider:SetHook ("OnLeave", background_on_leave)		
		
		-- instance toolbar side
			g:NewLabel (frame6, _, "$parentInstanceToolbarSideLabel", "instanceToolbarSideLabel", Loc ["STRING_OPTIONS_TOOLBARSIDE"], "GameFontHighlightLeft")
			g:NewSwitch (frame6, _, "$parentInstanceToolbarSideSlider", "instanceToolbarSideSlider", 80, 20, Loc ["STRING_TOP"], Loc ["STRING_BOTTOM"], instance.toolbar_side, true)
			frame6.instanceToolbarSideSlider:SetPoint ("left", frame6.instanceToolbarSideLabel, "right", 2)
			frame6.instanceToolbarSideSlider.OnSwitch = function (self, instance, value)
				instance.toolbar_side = value and 2 or 1
				instance:ToolbarSide (side)
				
			end
			frame6.instanceToolbarSideSlider.thumb:SetSize (50, 12)
			
			frame6.instanceToolbarSideSlider.info = Loc ["STRING_OPTIONS_TOOLBARSIDE_DESC"]
			window:create_line_background (frame6, frame6.instanceToolbarSideLabel, frame6.instanceToolbarSideSlider)
			frame6.instanceToolbarSideSlider:SetHook ("OnEnter", background_on_enter)
			frame6.instanceToolbarSideSlider:SetHook ("OnLeave", background_on_leave)		
		
		-- show side bars
		
		g:NewLabel (frame6, _, "$parentSideBarsLabel", "sideBarsLabel", Loc ["STRING_OPTIONS_SHOW_SIDEBARS"], "GameFontHighlightLeft")

		frame6.sideBarsSlider:SetPoint ("left", frame6.sideBarsLabel, "right", 2)
		frame6.sideBarsSlider.OnSwitch = function (self, instance, value)
			if (value) then
				instance:ShowSideBars()
			else
				instance:HideSideBars()
			end
		end
		
		frame6.sideBarsSlider.info = Loc ["STRING_OPTIONS_SHOW_SIDEBARS_DESC"]
		window:create_line_background (frame6, frame6.sideBarsLabel, frame6.sideBarsSlider)
		frame6.sideBarsSlider:SetHook ("OnEnter", background_on_enter)
		frame6.sideBarsSlider:SetHook ("OnLeave", background_on_leave)		
		
		-- show statusbar
		
		g:NewLabel (frame6, _, "$parentStatusbarLabel", "statusbarLabel", Loc ["STRING_OPTIONS_SHOW_STATUSBAR"], "GameFontHighlightLeft")

		frame6.statusbarSlider:SetPoint ("left", frame6.statusbarLabel, "right", 2)
		frame6.statusbarSlider.OnSwitch = function (self, instance, value)
			if (value) then
				instance:ShowStatusBar()
			else
				instance:HideStatusBar()
			end
		end
		
		frame6.statusbarSlider.info = Loc ["STRING_OPTIONS_SHOW_STATUSBAR_DESC"]
		window:create_line_background (frame6, frame6.statusbarLabel, frame6.statusbarSlider)
		frame6.statusbarSlider:SetHook ("OnEnter", background_on_enter)
		frame6.statusbarSlider:SetHook ("OnLeave", background_on_leave)
		
		--show total bar
		
		g:NewLabel (frame6, _, "$parentTotalBarLabel", "totalBarLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR"], "GameFontHighlightLeft")
		g:NewSwitch (frame6, _, "$parentTotalBarSlider", "totalBarSlider", 60, 20, _, _, instance.total_bar.enabled)

		frame6.totalBarSlider:SetPoint ("left", frame6.totalBarLabel, "right", 2)
		frame6.totalBarSlider.OnSwitch = function (self, instance, value)
			instance.total_bar.enabled = value
			instance:InstanceReset()
		end
		
		frame6.totalBarSlider.info = Loc ["STRING_OPTIONS_SHOW_TOTALBAR_DESC"]
		window:create_line_background (frame6, frame6.totalBarLabel, frame6.totalBarSlider)
		frame6.totalBarSlider:SetHook ("OnEnter", background_on_enter)
		frame6.totalBarSlider:SetHook ("OnLeave", background_on_leave)
		
		--total bar color
			local totalbarcolor_callback = function (button, r, g, b, a)
				window.instance.total_bar.color[1] = r
				window.instance.total_bar.color[2] = g
				window.instance.total_bar.color[3] = b
				window.instance:InstanceReset()
			end
			g:NewColorPickButton (frame6, "$parentTotalBarColorPick", "totalBarColorPick", totalbarcolor_callback)
			g:NewLabel (frame6, _, "$parentTotalBarColorPickLabel", "totalBarPickColorLabel", Loc ["STRING_OPTIONS_COLOR"], "GameFontHighlightLeft")
			frame6.totalBarColorPick:SetPoint ("left", frame6.totalBarPickColorLabel, "right", 2, 0)

			frame6.totalBarColorPick.info = Loc ["STRING_OPTIONS_SHOW_TOTALBAR_COLOR_DESC"]
			window:create_line_background (frame6, frame6.totalBarPickColorLabel, frame6.totalBarColorPick)
			frame6.totalBarColorPick:SetHook ("OnEnter", background_on_enter)
			frame6.totalBarColorPick:SetHook ("OnLeave", background_on_leave)
		
		--total bar only in group
		g:NewLabel (frame6, _, "$parentTotalBarOnlyInGroupLabel", "totalBarOnlyInGroupLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR_INGROUP"], "GameFontHighlightLeft")
		g:NewSwitch (frame6, _, "$parentTotalBarOnlyInGroupSlider", "totalBarOnlyInGroupSlider", 60, 20, _, _, instance.total_bar.only_in_group)

		frame6.totalBarOnlyInGroupSlider:SetPoint ("left", frame6.totalBarOnlyInGroupLabel, "right", 2)
		frame6.totalBarOnlyInGroupSlider.OnSwitch = function (self, instance, value)
			instance.total_bar.only_in_group = value
			instance:InstanceReset()
		end
		
		frame6.totalBarOnlyInGroupSlider.info = Loc ["STRING_OPTIONS_SHOW_TOTALBAR_INGROUP_DESC"]
		window:create_line_background (frame6, frame6.totalBarOnlyInGroupLabel, frame6.totalBarOnlyInGroupSlider)
		frame6.totalBarOnlyInGroupSlider:SetHook ("OnEnter", background_on_enter)
		frame6.totalBarOnlyInGroupSlider:SetHook ("OnLeave", background_on_leave)
		
		--total bar icon
		local totalbar_pickicon_callback = function (texture)
			instance.total_bar.icon = texture
			frame6.totalBarIconTexture:SetTexture (texture)
			instance:InstanceReset()
		end
		local totalbar_pickicon = function()
			g:IconPick (totalbar_pickicon_callback)
		end
		g:NewLabel (frame6, _, "$parentTotalBarIconLabel", "totalBarIconLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR_ICON"], "GameFontHighlightLeft")
		g:NewImage (frame6, _, "$parentTotalBarIconTexture", "totalBarIconTexture", 20, 20)
		g:NewButton (frame6, _, "$parentTotalBarIconButton", "totalBarIconButton", 20, 20, totalbar_pickicon)
		frame6.totalBarIconButton:InstallCustomTexture()
		frame6.totalBarIconButton:SetPoint ("left", frame6.totalBarIconLabel, "right", 2, 0)
		frame6.totalBarIconTexture:SetPoint ("left", frame6.totalBarIconLabel, "right", 2, 0)
		
		frame6.totalBarIconButton.info = Loc ["STRING_OPTIONS_SHOW_TOTALBAR_ICON_DESC"]
		window:create_line_background (frame6, frame6.totalBarIconLabel, frame6.totalBarIconButton)
		frame6.totalBarIconButton:SetHook ("OnEnter", background_on_enter)
		frame6.totalBarIconButton:SetHook ("OnLeave", background_on_leave)
		
		--anchors
		titulo_instance:SetPoint (10, -10)
		titulo_instance_desc:SetPoint (10, -30)
		
		frame6.windowPickColorLabel:SetPoint (10, -70) --window color
		--frame6.alphaLabel:SetPoint (10, -95) --background alpha
		frame6.windowBackgroundPickColorLabel:SetPoint (10, -95) --background color
		
		frame6.instanceToolbarSideLabel:SetPoint (10, -145)
		frame6.sideBarsLabel:SetPoint (10, -170) --borders
		frame6.statusbarLabel:SetPoint (10, -195) --statusbar
		frame6.stretchAnchorLabel:SetPoint (10, -220) --stretch direction		
		
		g:NewLabel (frame6, _, "$parentTotalBarAnchor", "totalBarAnchorLabel", "Total Bar", "GameFontNormal")
		frame6.totalBarAnchorLabel:SetPoint (10, -255)
		frame6.totalBarIconLabel:SetPoint (10, -280)
		frame6.totalBarPickColorLabel:SetPoint (10, -305)
		frame6.totalBarLabel:SetPoint (10, -355)
		frame6.totalBarOnlyInGroupLabel:SetPoint (10, -330)
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Top Menu Bar
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local frame7 = window.options [7][1]
	
		local titulo_toolbar = g:NewLabel (frame7, _, "$parentTituloToolbar", "tituloToolbarLabel", Loc ["STRING_OPTIONS_TOOLBAR_SETTINGS"], "GameFontNormal", 16)
		local titulo_toolbar_desc = g:NewLabel (frame7, _, "$parentTituloToolbar2", "tituloToolbar2Label", Loc ["STRING_OPTIONS_TOOLBAR_SETTINGS_DESC"], "GameFontNormal", 9, "white")
		titulo_toolbar_desc.width = 320

		--> instance button anchor
			g:NewSlider (frame7, _, "$parentInstanceButtonAnchorXSlider", "instanceButtonAnchorXSlider", SLIDER_WIDTH, 20, -200, 20, 1, instance.instance_button_anchor[1])
			g:NewSlider (frame7, _, "$parentInstanceButtonAnchorYSlider", "instanceButtonAnchorYSlider", SLIDER_WIDTH, 20, -10, 10, 1, instance.instance_button_anchor[2])
			
		--> desaturate
			g:NewSwitch (frame7, _, "$parentDesaturateMenuSlider", "desaturateMenuSlider", 60, 20, _, _, instance.desaturated_menu)
			
		--> hide icon
			g:NewSwitch (frame7, _, "$parentHideIconSlider", "hideIconSlider", 60, 20, _, _, instance.hide_icon)			
			
		--> menu anchor
			g:NewSlider (frame7, _, "$parentMenuAnchorXSlider", "menuAnchorXSlider", SLIDER_WIDTH, 20, -20, 200, 1, instance.menu_anchor[1])
			g:NewSlider (frame7, _, "$parentMenuAnchorYSlider", "menuAnchorYSlider", SLIDER_WIDTH, 20, -10, 10, 1, instance.menu_anchor[2])
		
	--> plugins icons grow direction
		g:NewSwitch (frame7, _, "$parentPluginIconsDirectionSlider", "pluginIconsDirectionSlider", 80, 20, Loc ["STRING_LEFT"], Loc ["STRING_RIGHT"], instance.plugins_grow_direction)
		
		
		-- menu anchors
			g:NewLabel (frame7, _, "$parentMenuAnchorXLabel", "menuAnchorXLabel", Loc ["STRING_OPTIONS_MENU_X"], "GameFontHighlightLeft")
			frame7.menuAnchorXSlider:SetPoint ("left", frame7.menuAnchorXLabel, "right", 2)
			frame7.menuAnchorXSlider:SetThumbSize (50)
			frame7.menuAnchorXSlider:SetHook ("OnValueChange", function (self, instance, x) 
				instance:MenuAnchor (x, nil)
			end)
			
			frame7.menuAnchorXSlider.info = Loc ["STRING_OPTIONS_MENU_X_DESC"]
			window:create_line_background (frame7, frame7.menuAnchorXLabel, frame7.menuAnchorXSlider)
			frame7.menuAnchorXSlider:SetHook ("OnEnter", background_on_enter)
			frame7.menuAnchorXSlider:SetHook ("OnLeave", background_on_leave)
			
			g:NewLabel (frame7, _, "$parentMenuAnchorYLabel", "menuAnchorYLabel", Loc ["STRING_OPTIONS_MENU_Y"], "GameFontHighlightLeft")
			frame7.menuAnchorYSlider:SetPoint ("left", frame7.menuAnchorYLabel, "right", 2)
			frame7.menuAnchorYSlider:SetThumbSize (50)
			frame7.menuAnchorYSlider:SetHook ("OnValueChange", function (self, instance, y)
				instance:MenuAnchor (nil, y)
			end)
			
			frame7.menuAnchorYSlider.info = Loc ["STRING_OPTIONS_MENU_Y_DESC"]
			window:create_line_background (frame7, frame7.menuAnchorYLabel, frame7.menuAnchorYSlider)
			frame7.menuAnchorYSlider:SetHook ("OnEnter", background_on_enter)
			frame7.menuAnchorYSlider:SetHook ("OnLeave", background_on_leave)
			
		-- instance button anchors
			g:NewLabel (frame7, _, "$parentInstanceButtonAnchorXLabel", "instanceButtonAnchorXLabel", Loc ["STRING_OPTIONS_INSBUTTON_X"], "GameFontHighlightLeft")
			frame7.instanceButtonAnchorXSlider:SetPoint ("left", frame7.instanceButtonAnchorXLabel, "right", 2)
			frame7.instanceButtonAnchorXSlider:SetThumbSize (50)
			frame7.instanceButtonAnchorXSlider:SetHook ("OnValueChange", function (self, instance, x)
				instance:InstanceButtonAnchor (x, nil)
			end)
			
			frame7.instanceButtonAnchorXSlider.info = Loc ["STRING_OPTIONS_INSBUTTON_X_DESC"]
			window:create_line_background (frame7, frame7.instanceButtonAnchorXLabel, frame7.instanceButtonAnchorXSlider)
			frame7.instanceButtonAnchorXSlider:SetHook ("OnEnter", background_on_enter)
			frame7.instanceButtonAnchorXSlider:SetHook ("OnLeave", background_on_leave)
			
			g:NewLabel (frame7, _, "$parentInstanceButtonAnchorYLabel", "instanceButtonAnchorYLabel", Loc ["STRING_OPTIONS_INSBUTTON_Y"], "GameFontHighlightLeft")
			frame7.instanceButtonAnchorYSlider:SetPoint ("left", frame7.instanceButtonAnchorYLabel, "right", 2)
			frame7.instanceButtonAnchorYSlider:SetThumbSize (50)
			frame7.instanceButtonAnchorYSlider:SetHook ("OnValueChange", function (self, instance, y)
				instance:InstanceButtonAnchor (nil, y)
			end)

			frame7.instanceButtonAnchorYSlider.info =Loc ["STRING_OPTIONS_INSBUTTON_Y_DESC"]
			window:create_line_background (frame7, frame7.instanceButtonAnchorYLabel, frame7.instanceButtonAnchorYSlider)
			frame7.instanceButtonAnchorYSlider:SetHook ("OnEnter", background_on_enter)
			frame7.instanceButtonAnchorYSlider:SetHook ("OnLeave", background_on_leave)

	--> instance toolbar side

		-- desaturate
			g:NewLabel (frame7, _, "$parentDesaturateMenuLabel", "desaturateMenuLabel", Loc ["STRING_OPTIONS_DESATURATE_MENU"], "GameFontHighlightLeft")

			frame7.desaturateMenuSlider:SetPoint ("left", frame7.desaturateMenuLabel, "right", 2)
			frame7.desaturateMenuSlider.OnSwitch = function (self, instance, value)
				instance:DesaturateMenu (value)
			end
			
			frame7.desaturateMenuSlider.info = Loc ["STRING_OPTIONS_DESATURATE_MENU_DESC"]
			window:create_line_background (frame7, frame7.desaturateMenuLabel, frame7.desaturateMenuSlider)
			frame7.desaturateMenuSlider:SetHook ("OnEnter", background_on_enter)
			frame7.desaturateMenuSlider:SetHook ("OnLeave", background_on_leave)

		-- hide icon
			g:NewLabel (frame7, _, "$parentHideIconLabel", "hideIconLabel", Loc ["STRING_OPTIONS_HIDE_ICON"], "GameFontHighlightLeft")

			frame7.hideIconSlider:SetPoint ("left", frame7.hideIconLabel, "right", 2)
			frame7.hideIconSlider.OnSwitch = function (self, instance, value)
				instance:HideMainIcon (value)
			end
			
			frame7.hideIconSlider.info = Loc ["STRING_OPTIONS_HIDE_ICON_DESC"]
			window:create_line_background (frame7, frame7.hideIconLabel, frame7.hideIconSlider)
			frame7.hideIconSlider:SetHook ("OnEnter", background_on_enter)
			frame7.hideIconSlider:SetHook ("OnLeave", background_on_leave)
			
		-- plugin icons direction
			g:NewLabel (frame7, _, "$parentPluginIconsDirectionLabel", "pluginIconsDirectionLabel", Loc ["STRING_OPTIONS_PICONS_DIRECTION"], "GameFontHighlightLeft")

			frame7.pluginIconsDirectionSlider:SetPoint ("left", frame7.pluginIconsDirectionLabel, "right", 2)
			frame7.pluginIconsDirectionSlider.OnSwitch = function (self, instance, value)
				instance.plugins_grow_direction = value and 2 or 1
				instance:DefaultIcons()
			end
			frame7.pluginIconsDirectionSlider.thumb:SetSize (40, 12)
			
			frame7.pluginIconsDirectionSlider.info = Loc ["STRING_OPTIONS_PICONS_DIRECTION_DESC"]
			window:create_line_background (frame7, frame7.pluginIconsDirectionLabel, frame7.pluginIconsDirectionSlider)
			frame7.pluginIconsDirectionSlider:SetHook ("OnEnter", background_on_enter)
			frame7.pluginIconsDirectionSlider:SetHook ("OnLeave", background_on_leave)
			
		titulo_toolbar:SetPoint (10, -10)
		titulo_toolbar_desc:SetPoint (10, -30)
		frame7.instanceButtonAnchorXLabel:SetPoint (10, -70)
		frame7.instanceButtonAnchorYLabel:SetPoint (10, -95)
		frame7.menuAnchorXLabel:SetPoint (10, -120)
		frame7.menuAnchorYLabel:SetPoint (10, -145)
		frame7.desaturateMenuLabel:SetPoint (10, -170)
		frame7.hideIconLabel:SetPoint (10, -195)
		frame7.pluginIconsDirectionLabel:SetPoint (10, -220)
			
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Reset Instance Close
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		local frame8 = window.options [8][1]

		local titulo_toolbar2 = g:NewLabel (frame8, _, "$parentTituloToolbar_buttons", "tituloToolbarLabel", Loc ["STRING_OPTIONS_TOOLBAR2_SETTINGS"], "GameFontNormal", 16)
		local titulo_toolbar2_desc = g:NewLabel (frame8, _, "$parentTituloToolbar_buttons", "tituloToolbar2Label", Loc ["STRING_OPTIONS_TOOLBAR2_SETTINGS_DESC"], "GameFontNormal", 9, "white")
		titulo_toolbar2_desc.width = 320
		
		--> close button
			--button overlay
			local close_overlay_callback = function (button, r, g, b, a)
				window.instance:SetCloseButtonSettings ({r, g, b, a})
			end
			g:NewColorPickButton (frame8, "$parentCloseButtonColorPick", "closeButtonColorPick", close_overlay_callback)
			g:NewLabel (frame8, _, "$parentWindowCloseButtonLabel", "closeButtonColorLabel", Loc ["STRING_OPTIONS_CLOSE_OVERLAY"], "GameFontHighlightLeft")
			frame8.closeButtonColorPick:SetPoint ("left", frame8.closeButtonColorLabel, "right", 2, 0)

			frame8.closeButtonColorPick.info = Loc ["STRING_OPTIONS_CLOSE_OVERLAY_DESC"]
			window:create_line_background (frame8, frame8.closeButtonColorLabel, frame8.closeButtonColorPick)
			frame8.closeButtonColorPick:SetHook ("OnEnter", background_on_enter)
			frame8.closeButtonColorPick:SetHook ("OnLeave", background_on_leave)
			
		--> reset button
			--text color pick
		
			local reset_textcolor_callback = function (button, r, g, b, a)
				window.instance:SetDeleteButtonSettings (nil, nil, {r, g, b, a}, nil)
			end
			g:NewColorPickButton (frame8, "$parentResetTextColorPick", "resetTextColorPick", reset_textcolor_callback)
			g:NewLabel (frame8, _, "$parentResetTextLabel", "resetTextColorPickLabel", Loc ["STRING_OPTIONS_RESET_TEXTCOLOR"], "GameFontHighlightLeft")
			frame8.resetTextColorPick:SetPoint ("left", frame8.resetTextColorPickLabel, "right", 2, 0)

			frame8.resetTextColorPick.info = Loc ["STRING_OPTIONS_RESET_TEXTCOLOR_DESC"]
			window:create_line_background (frame8, frame8.resetTextColorPickLabel, frame8.resetTextColorPick)
			frame8.resetTextColorPick:SetHook ("OnEnter", background_on_enter)
			frame8.resetTextColorPick:SetHook ("OnLeave", background_on_leave)
			
			--text size
			g:NewSlider (frame8, _, "$parentResetTextSizeSlider", "resetTextSizeSlider", SLIDER_WIDTH, 20, 8, 15, 1, tonumber (instance.resetbutton_info.text_size))
			frame8.resetTextSizeSlider:SetHook ("OnValueChange", function (self, instance, amount) 
				instance:SetDeleteButtonSettings (nil, amount)
			end)
			
			--reset always small
			g:NewSwitch (frame8, _, "$parentResetAlwaysSmallSlider", "resetAlwaysSmallSlider", 60, 20, _, _, instance.resetbutton_info.always_small)
			
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
			g:NewDropDown (frame8, _, "$parentResetTextFontDropdown", "resetTextFontDropdown", DROPDOWN_WIDTH, 20, reset_text_color_build_font_menu, nil)
			
		--> instance button
			--text color pick
			--text size
			g:NewSlider (frame8, _, "$parentInstanceTextSizeSlider", "instanceTextSizeSlider", SLIDER_WIDTH, 20, 8, 15, 1, tonumber (instance.instancebutton_info.text_size))
			frame8.instanceTextSizeSlider:SetHook ("OnValueChange", function (self, instance, amount) 
				instance:SetInstanceButtonSettings (nil, amount)
			end)
			--button overlay

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
			g:NewDropDown (frame8, _, "$parentInstanceTextFontDropdown", "instanceTextFontDropdown", DROPDOWN_WIDTH, 20, instance_text_color_build_font_menu, nil)
			

		
		-- reset button

			-- text font
			g:NewLabel (frame8, _, "$parentResetTextFontLabel", "resetTextFontLabel", Loc ["STRING_OPTIONS_RESET_TEXTFONT"], "GameFontHighlightLeft")
			frame8.resetTextFontDropdown:SetPoint ("left", frame8.resetTextFontLabel, "right", 2)
			
			frame8.resetTextFontDropdown.info = Loc ["STRING_OPTIONS_RESET_TEXTFONT_DESC"]
			window:create_line_background (frame8, frame8.resetTextFontLabel, frame8.resetTextFontDropdown)
			frame8.resetTextFontDropdown:SetHook ("OnEnter", background_on_enter)
			frame8.resetTextFontDropdown:SetHook ("OnLeave", background_on_leave)
			
			-- text size
			g:NewLabel (frame8, _, "$parentResetTextSizeLabel", "resetTextSizeLabel", Loc ["STRING_OPTIONS_RESET_TEXTSIZE"], "GameFontHighlightLeft")
			frame8.resetTextSizeSlider:SetPoint ("left", frame8.resetTextSizeLabel, "right", 2)
			
			frame8.resetTextSizeSlider.info = Loc ["STRING_OPTIONS_RESET_TEXTSIZE_DESC"]
			window:create_line_background (frame8, frame8.resetTextSizeLabel, frame8.resetTextSizeSlider)
			frame8.resetTextSizeSlider:SetHook ("OnEnter", background_on_enter)
			frame8.resetTextSizeSlider:SetHook ("OnLeave", background_on_leave)

			-- color overlay
			local reset_overlaycolor_callback = function (button, r, g, b, a)
				window.instance:SetDeleteButtonSettings (nil, nil, nil, {r, g, b, a})
			end
			g:NewColorPickButton (frame8, "$parentResetOverlayColorPick", "resetOverlayColorPick", reset_overlaycolor_callback)
			g:NewLabel (frame8, _, "$parentResetOverlayLabel", "resetOverlayColorPickLabel", Loc ["STRING_OPTIONS_RESET_OVERLAY"], "GameFontHighlightLeft")
			frame8.resetOverlayColorPick:SetPoint ("left", frame8.resetOverlayColorPickLabel, "right", 2, 0)

			frame8.resetOverlayColorPick.info = Loc ["STRING_OPTIONS_RESET_OVERLAY_DESC"]
			window:create_line_background (frame8, frame8.resetOverlayColorPickLabel, frame8.resetOverlayColorPick)
			frame8.resetOverlayColorPick:SetHook ("OnEnter", background_on_enter)
			frame8.resetOverlayColorPick:SetHook ("OnLeave", background_on_leave)

		-- reset always small
			g:NewLabel (frame8, _, "$parentResetAlwaysSmallLabel", "resetAlwaysSmallLabel", Loc ["STRING_OPTIONS_RESET_SMALL"], "GameFontHighlightLeft")
			
			frame8.resetAlwaysSmallSlider:SetPoint ("left", frame8.resetAlwaysSmallLabel, "right", 2)
			frame8.resetAlwaysSmallSlider.OnSwitch = function (self, instance, value)
				instance:SetDeleteButtonSettings (nil, nil, nil, nil, value)
			end
			
			frame8.resetAlwaysSmallSlider.info = Loc ["STRING_OPTIONS_RESET_SMALL_DESC"]
			window:create_line_background (frame8, frame8.resetAlwaysSmallLabel, frame8.resetAlwaysSmallSlider)
			frame8.resetAlwaysSmallSlider:SetHook ("OnEnter", background_on_enter)
			frame8.resetAlwaysSmallSlider:SetHook ("OnLeave", background_on_leave)			
		
		-- instance button
			-- text color
			
			local instance_textcolor_callback = function (button, r, g, b, a)
				window.instance:SetInstanceButtonSettings (nil, nil, {r, g, b, a})
			end
			g:NewColorPickButton (frame8, "$parentInstanceTextColorPick", "instanceTextColorPick", instance_textcolor_callback)
			g:NewLabel (frame8, _, "$parentInstanceTextLabel", "instanceTextColorPickLabel", Loc ["STRING_OPTIONS_INSTANCE_TEXTCOLOR"], "GameFontHighlightLeft")
			frame8.instanceTextColorPick:SetPoint ("left", frame8.instanceTextColorPickLabel, "right", 2, 0)

			frame8.instanceTextColorPick.info = Loc ["STRING_OPTIONS_RESET_OVERLAY_DESC"]
			window:create_line_background (frame8, frame8.instanceTextColorPickLabel, frame8.instanceTextColorPick)
			frame8.instanceTextColorPick:SetHook ("OnEnter", background_on_enter)
			frame8.instanceTextColorPick:SetHook ("OnLeave", background_on_leave)
			
			-- text font
			g:NewLabel (frame8, _, "$parentInstanceTextFontLabel", "instanceTextFontLabel", Loc ["STRING_OPTIONS_INSTANCE_TEXTFONT"], "GameFontHighlightLeft")
			frame8.instanceTextFontDropdown:SetPoint ("left", frame8.instanceTextFontLabel, "right", 2)
			
			frame8.instanceTextFontDropdown.info = Loc ["STRING_OPTIONS_INSTANCE_TEXTCOLOR_DESC"]
			window:create_line_background (frame8, frame8.instanceTextFontLabel, frame8.instanceTextFontDropdown)
			frame8.instanceTextFontDropdown:SetHook ("OnEnter", background_on_enter)
			frame8.instanceTextFontDropdown:SetHook ("OnLeave", background_on_leave)
			
			-- text size
			g:NewLabel (frame8, _, "$parentInstanceTextSizeLabel", "instanceTextSizeLabel", Loc ["STRING_OPTIONS_INSTANCE_TEXTSIZE"], "GameFontHighlightLeft")
			frame8.instanceTextSizeSlider:SetPoint ("left", frame8.instanceTextSizeLabel, "right", 2)
			
			frame8.instanceTextSizeSlider.info = Loc ["STRING_OPTIONS_INSTANCE_TEXTSIZE_DESC"]
			window:create_line_background (frame8, frame8.instanceTextSizeLabel, frame8.instanceTextSizeSlider)
			frame8.instanceTextSizeSlider:SetHook ("OnEnter", background_on_enter)
			frame8.instanceTextSizeSlider:SetHook ("OnLeave", background_on_leave)

			-- color overlay

			local instance_overlaycolor_callback = function (button, r, g, b, a)
				window.instance:SetInstanceButtonSettings (nil, nil, nil, {r, g, b, a})
			end
			g:NewColorPickButton (frame8, "$parentInstanceOverlayColorPick", "instanceOverlayColorPick", instance_overlaycolor_callback)
			g:NewLabel (frame8, _, "$parentInstanceOverlayLabel", "instanceOverlayColorPickLabel", Loc ["STRING_OPTIONS_INSTANCE_OVERLAY"], "GameFontHighlightLeft")
			frame8.instanceOverlayColorPick:SetPoint ("left", frame8.instanceOverlayColorPickLabel, "right", 2, 0)

			frame8.instanceOverlayColorPick.info = Loc ["STRING_OPTIONS_INSTANCE_OVERLAY_DESC"]
			window:create_line_background (frame8, frame8.instanceOverlayColorPickLabel, frame8.instanceOverlayColorPick)
			frame8.instanceOverlayColorPick:SetHook ("OnEnter", background_on_enter)
			frame8.instanceOverlayColorPick:SetHook ("OnLeave", background_on_leave)			
			
		-- close button
			-- color overlay

		
		titulo_toolbar2:SetPoint (10, -10)
		titulo_toolbar2_desc:SetPoint (10, -30)

		g:NewLabel (frame8, _, "$parentInstanceButtonAnchor", "instanceAnchorLabel", Loc ["STRING_OPTIONS_INSTANCE_BUTTON_ANCHOR"], "GameFontNormal")
		g:NewLabel (frame8, _, "$parentResetButtonAnchor", "resetAnchorLabel", Loc ["STRING_OPTIONS_RESET_BUTTON_ANCHOR"], "GameFontNormal")
		g:NewLabel (frame8, _, "$parentCloseButtonAnchor", "closeAnchorLabel", Loc ["STRING_OPTIONS_CLOSE_BUTTON_ANCHOR"], "GameFontNormal")
		
		frame8.instanceAnchorLabel:SetPoint (10, -75)
		
		frame8.instanceTextColorPickLabel:SetPoint (10, -100)
		frame8.instanceTextFontLabel:SetPoint (10, -125)
		frame8.instanceTextSizeLabel:SetPoint (10, -150)
		frame8.instanceOverlayColorPickLabel:SetPoint (10, -175)

		frame8.resetAnchorLabel:SetPoint (10, -210)
		
		frame8.resetTextColorPickLabel:SetPoint (10, -235)
		frame8.resetTextFontLabel:SetPoint (10, -260)
		frame8.resetTextSizeLabel:SetPoint (10, -285)
		frame8.resetOverlayColorPickLabel:SetPoint (10, -310)
		frame8.resetAlwaysSmallLabel:SetPoint (10, -335)

		frame8.closeAnchorLabel:SetPoint (10, -370)
		
		frame8.closeButtonColorLabel:SetPoint (10, -395)
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Wallpaper
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local frame9 = window.options [9][1]

		local titulo_wallpaper = g:NewLabel (frame9, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_WP"], "GameFontNormal", 16)
		local titulo_wallpaper_desc = g:NewLabel (frame9, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_WP_DESC"], "GameFontNormal", 9, "white")
		titulo_wallpaper_desc.width = 320
		
		--> wallpaper
		
			--> primeiro o botão de editar a imagem
			local callmeback = function (width, height, overlayColor, alpha, texCoords)
				local tinstance = _G ["DetailsOptionsWindow"].MyObject.instance
				tinstance:InstanceWallpaper (nil, nil, alpha, texCoords, width, height, overlayColor)
				window:update_wallpaper_info()
			end
			
			local startImageEdit = function()
				local tinstance = _G ["DetailsOptionsWindow"].MyObject.instance
				
				if (not tinstance.wallpaper.texture) then
					return
				end
				
				if (tinstance.wallpaper.texture:find ("TALENTFRAME")) then
					g:ImageEditor (callmeback, tinstance.wallpaper.texture, tinstance.wallpaper.texcoord, tinstance.wallpaper.overlay, window.instance.baseframe.wallpaper:GetWidth(), window.instance.baseframe.wallpaper:GetHeight())
				else
					tinstance.wallpaper.overlay [4] = 0.5
					g:ImageEditor (callmeback, tinstance.wallpaper.texture, tinstance.wallpaper.texcoord, tinstance.wallpaper.overlay, window.instance.baseframe.wallpaper:GetWidth(), window.instance.baseframe.wallpaper:GetHeight())
				end
			end
			g:NewButton (frame9, _, "$parentEditImage", "editImage", 200, 18, startImageEdit, nil, nil, nil, Loc ["STRING_OPTIONS_EDITIMAGE"])
			
			--> agora o dropdown do alinhamento
			local onSelectAnchor = function (_, instance, anchor)
				instance:InstanceWallpaper (nil, anchor)
				window:update_wallpaper_info()
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

			g:NewDropDown (frame9, _, "$parentAnchorDropdown", "anchorDropdown", DROPDOWN_WIDTH, 20, buildAnchorMenu, nil)			
			
			--> agora cria os 2 dropdown da categoria e wallpaper
			
			local onSelectSecTexture = function (self, instance, texturePath) 
				
				if (texturePath:find ("TALENTFRAME")) then
					instance:InstanceWallpaper (texturePath, nil, nil, {0, 1, 0, 0.703125})
				else
					instance:InstanceWallpaper (texturePath, nil, nil, {0, 1, 0, 1})
				end
				
				window:update_wallpaper_info()
				
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
				return  subMenu [frame9.backgroundDropdown.value] or {label = "-- -- --", value = 0}
			end
		
			local onSelectMainTexture = function (_, instance, choose)
				frame9.backgroundDropdown2:Select (choose)
				window:update_wallpaper_info()
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
			
			g:NewSwitch (frame9, _, "$parentUseBackgroundSlider", "useBackgroundSlider", 60, 20, _, _, window.instance.wallpaper.enabled)
			g:NewDropDown (frame9, _, "$parentBackgroundDropdown", "backgroundDropdown", DROPDOWN_WIDTH, 20, buildBackgroundMenu, nil)
			g:NewDropDown (frame9, _, "$parentBackgroundDropdown2", "backgroundDropdown2", DROPDOWN_WIDTH, 20, buildBackgroundMenu2, nil)

	-- Wallpaper Settings	

		-- wallpaper

		g:NewLabel (frame9, _, "$parentBackgroundLabel", "enablewallpaperLabel", Loc ["STRING_OPTIONS_WP_ENABLE"], "GameFontHighlightLeft")
		--
		frame9.useBackgroundSlider:SetPoint ("left", frame9.enablewallpaperLabel, "right", 2, 0) --> slider ativar ou desativar
		frame9.useBackgroundSlider.OnSwitch = function (self, instance, value)
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
				_G.DetailsOptionsWindow9BackgroundDropdown.MyObject:Enable()
				_G.DetailsOptionsWindow9BackgroundDropdown2.MyObject:Enable()
				
			else
				instance:InstanceWallpaper (false)
				_G.DetailsOptionsWindow9BackgroundDropdown.MyObject:Disable()
				_G.DetailsOptionsWindow9BackgroundDropdown2.MyObject:Disable()
			end
			
			window:update_wallpaper_info()
			
		end
		
		g:NewLabel (frame9, _, "$parentBackgroundLabel", "wallpapergroupLabel", Loc ["STRING_OPTIONS_WP_GROUP"], "GameFontHighlightLeft")
		g:NewLabel (frame9, _, "$parentBackgroundLabel", "selectwallpaperLabel", Loc ["STRING_OPTIONS_WP_GROUP2"], "GameFontHighlightLeft")
		g:NewLabel (frame9, _, "$parentAnchorLabel", "anchorLabel", Loc ["STRING_OPTIONS_WP_ALIGN"], "GameFontHighlightLeft")
		--
		frame9.anchorDropdown:SetPoint ("left", frame9.anchorLabel, "right", 2)
		--
		frame9.editImage:InstallCustomTexture()
		
		frame9.useBackgroundSlider.info = Loc ["STRING_OPTIONS_WP_ENABLE_DESC"]
		window:create_line_background (frame9, frame9.enablewallpaperLabel, frame9.useBackgroundSlider)
		frame9.useBackgroundSlider:SetHook ("OnEnter", background_on_enter)
		frame9.useBackgroundSlider:SetHook ("OnLeave", background_on_leave)
		
		frame9.anchorDropdown.info = Loc ["STRING_OPTIONS_WP_ALIGN_DESC"]
		window:create_line_background (frame9, frame9.anchorLabel, frame9.anchorDropdown)
		frame9.anchorDropdown:SetHook ("OnEnter", background_on_enter)
		frame9.anchorDropdown:SetHook ("OnLeave", background_on_leave)
		
		frame9.editImage.info = Loc ["STRING_OPTIONS_WP_EDIT_DESC"]
		window:create_line_background (frame9, frame9.editImage, frame9.editImage)
		frame9.editImage:SetHook ("OnEnter", background_on_enter)
		frame9.editImage:SetHook ("OnLeave", background_on_leave)
		
		frame9.backgroundDropdown.info = Loc ["STRING_OPTIONS_WP_GROUP_DESC"]
		window:create_line_background (frame9, frame9.wallpapergroupLabel, frame9.backgroundDropdown)
		frame9.backgroundDropdown:SetHook ("OnEnter", background_on_enter)
		frame9.backgroundDropdown:SetHook ("OnLeave", background_on_leave)
		
		frame9.backgroundDropdown2.info = Loc ["STRING_OPTIONS_WP_GROUP2_DESC"]
		window:create_line_background (frame9, frame9.selectwallpaperLabel, frame9.backgroundDropdown2)
		frame9.backgroundDropdown2:SetHook ("OnEnter", background_on_enter)
		frame9.backgroundDropdown2:SetHook ("OnLeave", background_on_leave)			

		function window:update_wallpaper_info()
			local w = window.instance.wallpaper
			
			local a = w.alpha or 0
			a = a * 100
			a = string.format ("%.1f", a) .. "%"

			local t = w.texcoord [1] or 0
			t = t * 100
			t = string.format ("%.3f", t) .. "%"
			local b = w.texcoord [2] or 1
			b = b * 100
			b = string.format ("%.3f", b) .. "%"
			local l = w.texcoord [3] or 0
			l = l * 100
			l = string.format ("%.3f", l) .. "%"
			local r = w.texcoord [4] or 1
			r = r * 100
			r = string.format ("%.3f", r) .. "%"
			
			local red = w.overlay[1] or 0
			red = math.ceil (red * 255)
			local green = w.overlay[2] or "0"
			green = math.ceil (green * 255)
			local blue = w.overlay[3] or "0"
			blue = math.ceil (blue * 255)
			
			frame9.wallpaperCurrentLabel.text = "Texture File: " .. (w.texture or "-- -- --") .. "\nAlpha: " .. a .. "\nOverlay red: " .. red .. " green: " .. green .. " blue: " .. blue .. "\nCut (top): " .. t .. "\nCut (bottom): " .. b .. "\nCut (left): " .. l .. "\nCut (right): " .. r
		end
		
	--current settings
		g:NewLabel (frame9, _, "$parentWallpaperCurrentAnchor", "wallpaperCurrentAnchorLabel", "Current:", "GameFontNormal")
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel", "wallpaperCurrentLabel", "", "GameFontHighlightSmall")
		
	--anchors
	
		titulo_wallpaper:SetPoint (10, -10)
		titulo_wallpaper_desc:SetPoint (10, -30)
		
		frame9.enablewallpaperLabel:SetPoint (10, -70)
		
		frame9.wallpapergroupLabel:SetPoint (10, -95)
		frame9.selectwallpaperLabel:SetPoint (10, -120)
		
		frame9.backgroundDropdown:SetPoint ("left", frame9.wallpapergroupLabel, "right", 2, 0)
		frame9.backgroundDropdown2:SetPoint ("left", frame9.selectwallpaperLabel, "right", 2, 0)
		
		frame9.anchorLabel:SetPoint (10, -145)
		frame9.editImage:SetPoint (10, -170)
		
		frame9.wallpaperCurrentAnchorLabel:SetPoint (10, -380)
		frame9.wallpaperCurrentLabel:SetPoint (10, -400)

		
	--> wallpaper settings

		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Performance - Tweaks
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		local frame10 = window.options [10][1]
		local frame11 = window.options [11][1]
		
		local titulo_performance_general = g:NewLabel (frame10, _, "$parentTituloPerformance1", "tituloPerformance1Label", Loc ["STRING_OPTIONS_PERFORMANCE1"], "GameFontNormal", 16)
		local titulo_performance_general_desc = g:NewLabel (frame10, _, "$parentTituloPersona2", "tituloPersona2Label", Loc ["STRING_OPTIONS_PERFORMANCE1_DESC"], "GameFontNormal", 9, "white")
		titulo_performance_general_desc.width = 320
		
	--------------- Memory		
		g:NewSlider (frame10, _, "$parentSliderSegmentsSave", "segmentsSliderToSave", SLIDER_WIDTH, 20, 1, 5, 1, _detalhes.segments_amount_to_save)
		g:NewSlider (frame10, _, "$parentSliderUpdateSpeed", "updatespeedSlider", SLIDER_WIDTH, 20, 0.3, 3, 0.1, _detalhes.update_speed, true)
	
		g:NewLabel (frame10, _, "$parentLabelMemory", "memoryLabel", Loc ["STRING_OPTIONS_MEMORYT"], "GameFontHighlightLeft")

		g:NewSlider (frame10, _, "$parentSliderMemory", "memorySlider", SLIDER_WIDTH, 20, 1, 4, 1, _detalhes.memory_threshold)
		frame10.memorySlider:SetPoint ("left", frame10.memoryLabel, "right", 2, 0)
		frame10.memorySlider:SetHook ("OnValueChange", function (slider, _, amount)
			
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
		frame10.memorySlider.info = Loc ["STRING_OPTIONS_MEMORYT_DESC"]
		frame10.memorySlider.thumb:SetSize (40, 12)
		frame10.memorySlider.thumb:SetTexture ([[Interface\Buttons\UI-Listbox-Highlight2]])
		frame10.memorySlider.thumb:SetVertexColor (.2, .2, .2, .9)
		local t = _detalhes.memory_threshold
		frame10.memorySlider:SetValue (1)
		frame10.memorySlider:SetValue (2)
		frame10.memorySlider:SetValue (t)
		
		window:create_line_background (frame10, frame10.memoryLabel, frame10.memorySlider)
		frame10.memorySlider:SetHook ("OnEnter", background_on_enter)
		frame10.memorySlider:SetHook ("OnLeave", background_on_leave)
		
	--------------- Max Segments Saved
		g:NewLabel (frame10, _, "$parentLabelSegmentsSave", "segmentsSaveLabel", Loc ["STRING_OPTIONS_SEGMENTSSAVE"], "GameFontHighlightLeft")
		--
		
		frame10.segmentsSliderToSave:SetPoint ("left", frame10.segmentsSaveLabel, "right", 2, 0)
		frame10.segmentsSliderToSave:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.segments_amount_to_save = math.floor (amount)
		end)
		frame10.segmentsSliderToSave.info = Loc ["STRING_OPTIONS_SEGMENTSSAVE_DESC"]
	
		window:create_line_background (frame10, frame10.segmentsSaveLabel, frame10.segmentsSliderToSave)
		frame10.segmentsSliderToSave:SetHook ("OnEnter", background_on_enter)
		frame10.segmentsSliderToSave:SetHook ("OnLeave", background_on_leave)
	
	--------------- Panic Mode
		g:NewLabel (frame10, _, "$parentPanicModeLabel", "panicModeLabel", Loc ["STRING_OPTIONS_PANIMODE"], "GameFontHighlightLeft")
		--
		g:NewSwitch (frame10, _, "$parentPanicModeSlider", "panicModeSlider", 60, 20, _, _, _detalhes.segments_panic_mode)
		frame10.panicModeSlider:SetPoint ("left", frame10.panicModeLabel, "right", 2, 0)
		frame10.panicModeSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.segments_panic_mode = value
		end
		frame10.panicModeSlider.info = Loc ["STRING_OPTIONS_PANIMODE_DESC"]
		
		window:create_line_background (frame10, frame10.panicModeLabel, frame10.panicModeSlider)
		frame10.panicModeSlider:SetHook ("OnEnter", background_on_enter)
		frame10.panicModeSlider:SetHook ("OnLeave", background_on_leave)		
		
	--------------- Animate Rows
		g:NewLabel (frame10, _, "$parentAnimateLabel", "animateLabel", Loc ["STRING_OPTIONS_ANIMATEBARS"], "GameFontHighlightLeft")

		g:NewSwitch (frame10, _, "$parentAnimateSlider", "animateSlider", 60, 20, _, _, _detalhes.use_row_animations) -- ltext, rtext, defaultv
		frame10.animateSlider:SetPoint ("left",frame10.animateLabel, "right", 2, 0)
		frame10.animateSlider.info = Loc ["STRING_OPTIONS_ANIMATEBARS_DESC"]
		frame10.animateSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue (false, true)
			_detalhes.use_row_animations = value
		end
		
		window:create_line_background (frame10, frame10.animateLabel, frame10.animateSlider)
		frame10.animateSlider:SetHook ("OnEnter", background_on_enter)
		frame10.animateSlider:SetHook ("OnLeave", background_on_leave)
		
	--------------- Animate scroll bar
		g:NewLabel (frame10, _, "$parentAnimateScrollLabel", "animatescrollLabel", Loc ["STRING_OPTIONS_ANIMATESCROLL"], "GameFontHighlightLeft")
		
		--
		g:NewSwitch (frame10, _, "$parentClearAnimateScrollSlider", "animatescrollSlider", 60, 20, _, _, _detalhes.animate_scroll) -- ltext, rtext, defaultv
		frame10.animatescrollSlider:SetPoint ("left", frame10.animatescrollLabel, "right", 2, 0)
		frame10.animatescrollSlider.info = Loc ["STRING_OPTIONS_ANIMATESCROLL_DESC"]
		frame10.animatescrollSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.animate_scroll = value
		end
		
		window:create_line_background (frame10, frame10.animatescrollLabel, frame10.animatescrollSlider)
		frame10.animatescrollSlider:SetHook ("OnEnter", background_on_enter)
		frame10.animatescrollSlider:SetHook ("OnLeave", background_on_leave)		
		
	--------------- Update Speed
		g:NewLabel (frame10, _, "$parentUpdateSpeedLabel", "updatespeedLabel", Loc ["STRING_OPTIONS_WINDOWSPEED"], "GameFontHighlightLeft")
		
		--
		frame10.updatespeedSlider:SetPoint ("left", frame10.updatespeedLabel, "right", 2, 0)
		frame10.updatespeedSlider:SetThumbSize (50)
		frame10.updatespeedSlider.useDecimals = true
		local updateColor = function (slider, value)
			if (value < 1) then
				slider.amt:SetTextColor (1, value, 0)
			elseif (value > 1) then
				slider.amt:SetTextColor (-(value-3), 1, 0)
			else
				slider.amt:SetTextColor (1, 1, 0)
			end
		end
		frame10.updatespeedSlider:SetHook ("OnValueChange", function (self, _, amount) 
			_detalhes:CancelTimer (_detalhes.atualizador)
			_detalhes.update_speed = amount
			_detalhes.atualizador = _detalhes:ScheduleRepeatingTimer ("AtualizaGumpPrincipal", _detalhes.update_speed, -1)
			updateColor (self, amount)
		end)
		updateColor (frame10.updatespeedSlider, _detalhes.update_speed)
		
		frame10.updatespeedSlider.info = Loc ["STRING_OPTIONS_WINDOWSPEED_DESC"]

		window:create_line_background (frame10, frame10.updatespeedLabel, frame10.updatespeedSlider)
		frame10.updatespeedSlider:SetHook ("OnEnter", background_on_enter)
		frame10.updatespeedSlider:SetHook ("OnLeave", background_on_leave)		
		
	--------------- Erase Trash
		g:NewLabel (frame10, _, "$parentEraseTrash", "eraseTrashLabel", Loc ["STRING_OPTIONS_CLEANUP"], "GameFontHighlightLeft")
		
		--
		g:NewSwitch (frame10, _, "$parentRemoveTrashSlider", "removeTrashSlider", 60, 20, _, _, _detalhes.trash_auto_remove)
		frame10.removeTrashSlider:SetPoint ("left", frame10.eraseTrashLabel, "right")
		frame10.removeTrashSlider.OnSwitch = function (self, _, amount)
			_detalhes.trash_auto_remove = amount
		end
		frame10.removeTrashSlider.info = Loc ["STRING_OPTIONS_CLEANUP_DESC"]
		
		window:create_line_background (frame10, frame10.eraseTrashLabel, frame10.removeTrashSlider)
		frame10.removeTrashSlider:SetHook ("OnEnter", background_on_enter)
		frame10.removeTrashSlider:SetHook ("OnLeave", background_on_leave)			

		titulo_performance_general:SetPoint (10, -10)
		titulo_performance_general_desc:SetPoint (10, -30)
		frame10.memoryLabel:SetPoint (10, -70)
		frame10.segmentsSaveLabel:SetPoint (10, -95)
		frame10.panicModeLabel:SetPoint (10, -120)
		frame10.animateLabel:SetPoint (10, -145)
		--frame10.animatescrollLabel:SetPoint (10, -170)
		frame10.updatespeedLabel:SetPoint (10, -170)
		frame10.eraseTrashLabel:SetPoint (10, -195)
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Performance - Captures
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		local titulo_performance_captures = g:NewLabel (frame11, _, "$parentTituloPerformanceCaptures", "tituloPerformanceCaptures", Loc ["STRING_OPTIONS_PERFORMANCECAPTURES"], "GameFontNormal", 16)
		local titulo_performance_captures_desc = g:NewLabel (frame11, _, "$parentTituloPersonaCaptures2", "tituloPersonaCaptures2Label", Loc ["STRING_OPTIONS_PERFORMANCECAPTURES_DESC"], "GameFontNormal", 9, "white")
		titulo_performance_captures_desc.width = 320
		
	--------------- Captures
		g:NewImage (frame11, _, "$parentCaptureDamage", "damageCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		
		frame11.damageCaptureImage:SetTexCoord (0, 0.125, 0, 1)
		
		g:NewImage (frame11, _, "$parentCaptureHeal", "healCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		frame11.healCaptureImage:SetTexCoord (0.125, 0.25, 0, 1)
		
		g:NewImage (frame11, _, "$parentCaptureEnergy", "energyCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		frame11.energyCaptureImage:SetTexCoord (0.25, 0.375, 0, 1)
		
		g:NewImage (frame11, _, "$parentCaptureMisc", "miscCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		frame11.miscCaptureImage:SetTexCoord (0.375, 0.5, 0, 1)
		
		g:NewImage (frame11, _, "$parentCaptureAura", "auraCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		frame11.auraCaptureImage:SetTexCoord (0.5, 0.625, 0, 1)
		
		g:NewLabel (frame11, _, "$parentCaptureDamageLabel", "damageCaptureLabel", Loc ["STRING_OPTIONS_CDAMAGE"], "GameFontHighlightLeft")
		frame11.damageCaptureLabel:SetPoint ("left", frame11.damageCaptureImage, "right", 2)
		
		g:NewLabel (frame11, _, "$parentCaptureDamageLabel", "healCaptureLabel", Loc ["STRING_OPTIONS_CHEAL"], "GameFontHighlightLeft")
		frame11.healCaptureLabel:SetPoint ("left", frame11.healCaptureImage, "right", 2)
		
		g:NewLabel (frame11, _, "$parentCaptureDamageLabel", "energyCaptureLabel", Loc ["STRING_OPTIONS_CENERGY"], "GameFontHighlightLeft")
		frame11.energyCaptureLabel:SetPoint ("left", frame11.energyCaptureImage, "right", 2)
		
		g:NewLabel (frame11, _, "$parentCaptureDamageLabel", "miscCaptureLabel", Loc ["STRING_OPTIONS_CMISC"], "GameFontHighlightLeft")
		frame11.miscCaptureLabel:SetPoint ("left", frame11.miscCaptureImage, "right", 2)
		
		g:NewLabel (frame11, _, "$parentCaptureDamageLabel", "auraCaptureLabel", Loc ["STRING_OPTIONS_CAURAS"], "GameFontHighlightLeft")
		frame11.auraCaptureLabel:SetPoint ("left", frame11.auraCaptureImage, "right", 2)
		
		local switch_icon_color = function (icon, on_off)
			icon:SetDesaturated (not on_off)
		end
		
		g:NewSwitch (frame11, _, "$parentCaptureDamageSlider", "damageCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["damage"])
		frame11.damageCaptureSlider:SetPoint ("left", frame11.damageCaptureLabel, "right", 2)
		frame11.damageCaptureSlider.info = Loc ["STRING_OPTIONS_CDAMAGE_DESC"]
		frame11.damageCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "damage", true)
			switch_icon_color (frame11.damageCaptureImage, value)
		end
		switch_icon_color (frame11.damageCaptureImage, _detalhes.capture_real ["damage"])
		
		window:create_line_background (frame11, frame11.damageCaptureLabel, frame11.damageCaptureSlider)
		frame11.damageCaptureSlider:SetHook ("OnEnter", background_on_enter)
		frame11.damageCaptureSlider:SetHook ("OnLeave", background_on_leave)
		
		g:NewSwitch (frame11, _, "$parentCaptureHealSlider", "healCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["heal"])
		frame11.healCaptureSlider:SetPoint ("left", frame11.healCaptureLabel, "right", 2)
		frame11.healCaptureSlider.info = Loc ["STRING_OPTIONS_CHEAL_DESC"]
		frame11.healCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "heal", true)
			switch_icon_color (frame11.healCaptureImage, value)
		end
		switch_icon_color (frame11.healCaptureImage, _detalhes.capture_real ["heal"])
		
		window:create_line_background (frame11, frame11.healCaptureLabel, frame11.healCaptureSlider)
		frame11.healCaptureSlider:SetHook ("OnEnter", background_on_enter)
		frame11.healCaptureSlider:SetHook ("OnLeave", background_on_leave)	
		
		g:NewSwitch (frame11, _, "$parentCaptureEnergySlider", "energyCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["energy"])
		frame11.energyCaptureSlider:SetPoint ("left", frame11.energyCaptureLabel, "right", 2)
		frame11.energyCaptureSlider.info = Loc ["STRING_OPTIONS_CENERGY_DESC"]
		frame11.energyCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "energy", true)
			switch_icon_color (frame11.energyCaptureImage, value)
		end
		switch_icon_color (frame11.energyCaptureImage, _detalhes.capture_real ["energy"])
		
		window:create_line_background (frame11, frame11.energyCaptureLabel, frame11.energyCaptureSlider)
		frame11.energyCaptureSlider:SetHook ("OnEnter", background_on_enter)
		frame11.energyCaptureSlider:SetHook ("OnLeave", background_on_leave)	
		
		g:NewSwitch (frame11, _, "$parentCaptureMiscSlider", "miscCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["miscdata"])
		frame11.miscCaptureSlider:SetPoint ("left", frame11.miscCaptureLabel, "right", 2)
		frame11.miscCaptureSlider.info = Loc ["STRING_OPTIONS_CMISC_DESC"]
		frame11.miscCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "miscdata", true)
			switch_icon_color (frame11.miscCaptureImage, value)
		end
		switch_icon_color (frame11.miscCaptureImage, _detalhes.capture_real ["miscdata"])
		
		window:create_line_background (frame11, frame11.miscCaptureLabel, frame11.miscCaptureSlider)
		frame11.miscCaptureSlider:SetHook ("OnEnter", background_on_enter)
		frame11.miscCaptureSlider:SetHook ("OnLeave", background_on_leave)		
		
		g:NewSwitch (frame11, _, "$parentCaptureAuraSlider", "auraCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["aura"])
		frame11.auraCaptureSlider:SetPoint ("left", frame11.auraCaptureLabel, "right", 2)
		frame11.auraCaptureSlider.info = Loc ["STRING_OPTIONS_CAURAS_DESC"]
		frame11.auraCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "aura", true)
			switch_icon_color (frame11.auraCaptureImage, value)
		end
		switch_icon_color (frame11.auraCaptureImage, _detalhes.capture_real ["aura"])
		
		window:create_line_background (frame11, frame11.auraCaptureLabel, frame11.auraCaptureSlider)
		frame11.auraCaptureSlider:SetHook ("OnEnter", background_on_enter)
		frame11.auraCaptureSlider:SetHook ("OnLeave", background_on_leave)		
		
	--------------- Cloud Capture
	
		g:NewLabel (frame11, _, "$parentCloudCaptureLabel", "cloudCaptureLabel", Loc ["STRING_OPTIONS_CLOUD"], "GameFontHighlightLeft")

		g:NewSwitch (frame11, _, "$parentCloudAuraSlider", "cloudCaptureSlider", 60, 20, _, _, _detalhes.cloud_capture)
		frame11.cloudCaptureSlider:SetPoint ("left", frame11.cloudCaptureLabel, "right", 2)
		frame11.cloudCaptureSlider.info = Loc ["STRING_OPTIONS_CLOUD_DESC"] 
		frame11.cloudCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes.cloud_capture = value
		end
		
		window:create_line_background (frame11, frame11.cloudCaptureLabel, frame11.cloudCaptureSlider)
		frame11.cloudCaptureSlider:SetHook ("OnEnter", background_on_enter)
		frame11.cloudCaptureSlider:SetHook ("OnLeave", background_on_leave)		

		titulo_performance_captures:SetPoint (10, -10)
		titulo_performance_captures_desc:SetPoint (10, -30)
		frame11.damageCaptureImage:SetPoint (10, -70)
		frame11.healCaptureImage:SetPoint (10, -95)
		frame11.energyCaptureImage:SetPoint (10, -120)
		frame11.miscCaptureImage:SetPoint (10, -145)
		frame11.auraCaptureImage:SetPoint (10, -170)
		frame11.cloudCaptureLabel:SetPoint (10, -200)
		
		
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
	local frame4 = window.options [12][1].gump
	
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

	_G.DetailsOptionsWindow8ResetTextColorPick.MyObject:SetColor (unpack (instance.resetbutton_info.text_color))
	_G.DetailsOptionsWindow8ResetTextSizeSlider.MyObject:SetValue (instance.resetbutton_info.text_size)
	_G.DetailsOptionsWindow8ResetTextFontDropdown.MyObject:Select (instance.resetbutton_info.text_face)
	_G.DetailsOptionsWindow8ResetOverlayColorPick.MyObject:SetColor (unpack (instance.resetbutton_info.color_overlay))

	_G.DetailsOptionsWindow8InstanceTextColorPick.MyObject:SetColor (unpack (instance.instancebutton_info.text_color))
	_G.DetailsOptionsWindow8InstanceTextSizeSlider.MyObject:SetValue (instance.instancebutton_info.text_size)
	_G.DetailsOptionsWindow8InstanceTextFontDropdown.MyObject:Select (instance.instancebutton_info.text_face)
	_G.DetailsOptionsWindow8InstanceOverlayColorPick.MyObject:SetColor (unpack (instance.instancebutton_info.color_overlay))

	_G.DetailsOptionsWindow8CloseButtonColorPick.MyObject:SetColor (unpack (instance.closebutton_info.color_overlay))

	_G.DetailsOptionsWindow2HideOnCombatSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2HideOnCombatAlphaSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2HideOnCombatSlider.MyObject:SetValue (instance.hide_in_combat)
	_G.DetailsOptionsWindow2HideOnCombatAlphaSlider.MyObject:SetValue (instance.hide_in_combat_alpha)
	
	_G.DetailsOptionsWindow6SideBarsSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow6SideBarsSlider.MyObject:SetValue (instance.show_sidebars)
	
	_G.DetailsOptionsWindow6TotalBarSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow6TotalBarSlider.MyObject:SetValue (instance.total_bar.enabled)
	
	_G.DetailsOptionsWindow6TotalBarColorPick.MyObject:SetColor (unpack (instance.total_bar.color))
	
	_G.DetailsOptionsWindow6TotalBarOnlyInGroupSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow6TotalBarOnlyInGroupSlider.MyObject:SetValue (instance.total_bar.only_in_group)
	_G.DetailsOptionsWindow6TotalBarIconTexture.MyObject:SetTexture (instance.total_bar.icon)
	
	_G.DetailsOptionsWindow6StatusbarSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow6StatusbarSlider.MyObject:SetValue (instance.show_statusbar)
	
	_G.DetailsOptionsWindow6StretchAnchorSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow6StretchAnchorSlider.MyObject:SetValue (instance.stretch_button_side)
	
	_G.DetailsOptionsWindow7PluginIconsDirectionSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow7PluginIconsDirectionSlider.MyObject:SetValue (instance.plugins_grow_direction)
	
	_G.DetailsOptionsWindow6InstanceToolbarSideSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow6InstanceToolbarSideSlider.MyObject:SetValue (instance.toolbar_side)
	
	_G.DetailsOptionsWindow4BarSortDirectionSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow4BarSortDirectionSlider.MyObject:SetValue (instance.bars_sort_direction)
	
	_G.DetailsOptionsWindow4BarGrowDirectionSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow4BarGrowDirectionSlider.MyObject:SetValue (instance.bars_grow_direction)

	_G.DetailsOptionsWindow7DesaturateMenuSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow7DesaturateMenuSlider.MyObject:SetValue (instance.desaturated_menu)
	
	_G.DetailsOptionsWindow7HideIconSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow7HideIconSlider.MyObject:SetValue (instance.hide_icon)
	
	_G.DetailsOptionsWindow7MenuAnchorXSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow7MenuAnchorXSlider.MyObject:SetValue (instance.menu_anchor[1])
	
	_G.DetailsOptionsWindow7MenuAnchorYSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow7MenuAnchorYSlider.MyObject:SetValue (instance.menu_anchor[2])
	
	_G.DetailsOptionsWindow7InstanceButtonAnchorXSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow7InstanceButtonAnchorXSlider.MyObject:SetValue (instance.instance_button_anchor[1])
	
	_G.DetailsOptionsWindow7InstanceButtonAnchorYSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow7InstanceButtonAnchorYSlider.MyObject:SetValue (instance.instance_button_anchor[2])

----------------------------------------------------------------	

	--auto switch
	local autoswitch = instance.auto_switch_to
	if (autoswitch) then
		if (autoswitch [1] == "raid") then
			_G.DetailsOptionsWindow2AutoSwitchDropdown.MyObject:Select (autoswitch[2])
		else
			_G.DetailsOptionsWindow2AutoSwitchDropdown.MyObject:Select (autoswitch[3]+1, true)
		end
	else
		_G.DetailsOptionsWindow2AutoSwitchDropdown.MyObject:Select (1, true)
	end
	
	--resetTextColor
	_G.DetailsOptionsWindow8ResetTextFontDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow8ResetTextSizeSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow8ResetAlwaysSmallSlider.MyObject:SetFixedParameter (instance)
	--resetOverlayColorLabel

	--instanceTextColorLabel
	_G.DetailsOptionsWindow8InstanceTextFontDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow8InstanceTextSizeSlider.MyObject:SetFixedParameter (instance)
	--instanceOverlayColorLabel

	--closeOverlayColorLabel
	
	_G.DetailsOptionsWindow3SkinDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow3SkinDropdown.MyObject:Select (instance.skin)
	_G.DetailsOptionsWindow4TextureDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow4RowBackgroundTextureDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow4TextureDropdown.MyObject:Select (instance.row_info.texture)
	_G.DetailsOptionsWindow4RowBackgroundTextureDropdown.MyObject:Select (instance.row_info.texture_background)
	
	_G.DetailsOptionsWindow4RowBackgroundColorPick.MyObject:SetColor (unpack (instance.row_info.fixed_texture_background_color))
	
	_G.DetailsOptionsWindow4BackgroundClassColorSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow4BackgroundClassColorSlider.MyObject:SetValue (instance.row_info.texture_background_class_color)
	
	_G.DetailsOptionsWindow5FontDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow5FontDropdown.MyObject:Select (instance.row_info.font_face)
	--
	_G.DetailsOptionsWindow4SliderRowHeight.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow4SliderRowHeight.MyObject:SetValue (instance.row_info.height)
	--
	_G.DetailsOptionsWindow5SliderFontSize.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow5SliderFontSize.MyObject:SetValue (instance.row_info.font_size)
	--
	_G.DetailsOptionsWindow2AutoCurrentSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow2AutoCurrentSlider.MyObject:SetValue (instance.auto_current)
	--
	_G.DetailsOptionsWindow4ClassColorSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow4ClassColorSlider.MyObject:SetValue (instance.row_info.texture_class_colors)
	
	_G.DetailsOptionsWindow5UseClassColorsLeftTextSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow5UseClassColorsLeftTextSlider.MyObject:SetValue (instance.row_info.textL_class_colors)
	_G.DetailsOptionsWindow5UseClassColorsRightTextSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow5UseClassColorsRightTextSlider.MyObject:SetValue (instance.row_info.textR_class_colors)
	
	_G.DetailsOptionsWindow5TextLeftOutlineSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow5TextLeftOutlineSlider.MyObject:SetValue (instance.row_info.textL_outline)
	_G.DetailsOptionsWindow5TextRightOutlineSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow5TextRightOutlineSlider.MyObject:SetValue (instance.row_info.textR_outline)
	--
	_G.DetailsOptionsWindow4RowAlphaSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow4RowAlphaSlider.MyObject:SetValue (instance.row_info.alpha)
	
	_G.DetailsOptionsWindow6AlphaSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow6AlphaSlider.MyObject:SetValue (instance.bg_alpha)
	--
	_G.DetailsOptionsWindow9UseBackgroundSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow9BackgroundDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow9BackgroundDropdown2.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow9AnchorDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindow9BackgroundDropdown.MyObject:Select (instance.wallpaper.texture)
	
	if (instance.wallpaper.enabled) then
		_G.DetailsOptionsWindow9BackgroundDropdown.MyObject:Enable()
		_G.DetailsOptionsWindow9BackgroundDropdown2.MyObject:Enable()
		_G.DetailsOptionsWindow9UseBackgroundSlider.MyObject:SetValue (2)
	else
		_G.DetailsOptionsWindow9BackgroundDropdown.MyObject:Disable()
		_G.DetailsOptionsWindow9BackgroundDropdown2.MyObject:Disable()
		_G.DetailsOptionsWindow9UseBackgroundSlider.MyObject:SetValue (1)
	end

	_G.DetailsOptionsWindow6WindowColorPick.MyObject:SetColor (unpack (instance.color))
	--_G.DetailsOptionsWindow6InstanceColorTexture.MyObject:SetTexture (unpack (instance.color))
	
	--_G.DetailsOptionsWindow6BackgroundColorTexture.MyObject:SetTexture (instance.bg_r, instance.bg_g, instance.bg_b)
	_G.DetailsOptionsWindow6WindowBackgroundColorPick.MyObject:SetColor (instance.bg_r, instance.bg_g, instance.bg_b, instance.bg_alpha)
	
	_G.DetailsOptionsWindow4RowColorPick.MyObject:SetColor (unpack (instance.row_info.fixed_texture_color))
	
	_G.DetailsOptionsWindow5FixedTextColor.MyObject:SetColor (unpack (instance.row_info.fixed_text_color))
	
	_G.DetailsOptionsWindow1NicknameEntry.MyObject.text = _detalhes:GetNickname (UnitGUID ("player"), UnitName ("player"), true)
	_G.DetailsOptionsWindow2TTDropdown.MyObject:Select (_detalhes.time_type, true)
	
	_G.DetailsOptionsWindow.MyObject.instance = instance
	
	_G.DetailsOptionsWindowInstanceSelectDropdown.MyObject:Select (instance.meu_id, true)
	
	_G.DetailsOptionsWindow4IconFileEntry:SetText (instance.row_info.icon_file)
	
	window:Show()
	
	local avatar = NickTag:GetNicknameAvatar (UnitGUID ("player"), NICKTAG_DEFAULT_AVATAR, true)
	local background, cords, color = NickTag:GetNicknameBackground (UnitGUID ("player"), NICKTAG_DEFAULT_BACKGROUND, NICKTAG_DEFAULT_BACKGROUND_CORDS, {1, 1, 1, 1}, true)

	_G.DetailsOptionsWindow1AvatarPreviewTexture.MyObject.texture = avatar
	_G.DetailsOptionsWindow1AvatarPreviewTexture2.MyObject.texture = background
	_G.DetailsOptionsWindow1AvatarPreviewTexture2.MyObject.texcoord = cords
	_G.DetailsOptionsWindow1AvatarPreviewTexture2.MyObject:SetVertexColor (unpack (color))

	local nick = _detalhes:GetNickname (UnitGUID ("player"), UnitName ("player"), true)
	_G.DetailsOptionsWindow1AvatarNicknameLabel:SetText (nick)
	
	if (window.update_wallpaper_info) then
		window:update_wallpaper_info()
	end
	
end

