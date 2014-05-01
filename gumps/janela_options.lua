--[[ options panel file --]]

local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local LDB = LibStub ("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub ("LibDBIcon-1.0", true)
local tinsert = tinsert

local g =	_detalhes.gump
local _
local preset_version = 3
_detalhes.preset_version = preset_version

local slider_backdrop = {edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", edgeSize = 8,
bgFile = [[Interface\ACHIEVEMENTFRAME\UI-GuildAchievement-Parchment-Horizontal-Desaturated]], tile = true, tileSize = 130, insets = {left = 1, right = 1, top = 5, bottom = 5}}
local slider_backdrop_color = {1, 1, 1, 1}

local dropdown_backdrop = {edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 10,
bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16, insets = {left = 1, right = 1, top = 0, bottom = 1}}
local dropdown_backdrop_onenter = {0, 0, 0, 1}
local dropdown_backdrop_onleave = {.1, .1, .1, .9}

function _detalhes:OpenOptionsWindow (instance)

	GameCooltip:Close()
	local window = _G.DetailsOptionsWindow
	
	local editing_instance = instance
	
	if (_G.DetailsOptionsWindow) then
		_G.DetailsOptionsWindow.instance = instance
	end
	
	if (_G.DetailsOptionsWindow and _G.DetailsOptionsWindow.full_created) then
		return _G.DetailsOptionsWindow.MyObject:update_all (instance)
	end
	
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
		_G.DetailsOptionsWindow.instance = instance
		
		window.creating = true
		
		window:SetHook ("OnHide", function()
			DetailsDisable3D:Hide()
			DetailsOptionsWindowDisable3D:SetChecked (false)
			window.Disable3DColorPick:Hide()
			window.Disable3DColorPick:Cancel()
		end)
		
		--x 9 897 y 9 592
		
		local background = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 897, 592, nil, nil, "background", "$parentBackground")
		background:SetPoint (0, 0)
		background:SetDrawLayer ("border")
		--background:SetTexCoord (0.0087890625, 0.8759765625, 0.0087890625, 0.578125)
		background:SetTexCoord (0, 0.8759765625, 0, 0.578125)

		local bigdog = g:NewImage (window, [[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]], 180, 200, nil, {1, 0, 0, 1}, "backgroundBigDog", "$parentBackgroundBigDog")
		bigdog:SetPoint ("bottomright", window, "bottomright", -8, 31)
		bigdog:SetAlpha (.15)
		
		local window_icon = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 58, 58, nil, nil, "windowicon", "$parentWindowIcon")
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
		info_text.height = 380
		info_text.align = "<"
		info_text.valign = "^"
		info_text.active = false
		info_text.color = "white"

		local desc_anchor = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 75, 106, "artwork", {0.19921875, 0.2724609375, 0.6796875, 0.783203125}, "descAnchorImage", "$parentDescAnchorImage") --204 696 279 802
		desc_anchor:SetPoint ("topleft", info_text, "topleft", -28, 33)
		
		local desc_background = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 253, 198, "artwork", {0.3193359375, 0.56640625, 0.685546875, 0.87890625}, "descBackgroundImage", "$parentDescBackgroundImage") -- 327 702 580 900
		desc_background:SetPoint ("topleft", info_text, "topleft", 0, 0)
		
		--> select instance dropbox
		local onSelectInstance = function (_, _, instance)
		
			local this_instance = _detalhes.tabela_instancias [instance]
			
			if (not this_instance.iniciada) then
				this_instance:RestauraJanela (_G.DetailsOptionsWindow.instance)
				
			elseif (not this_instance:IsEnabled()) then
				_detalhes.CriarInstancia (_, _, this_instance.meu_id)
				
			end
			
			_detalhes:OpenOptionsWindow (this_instance)
		end

		local buildInstanceMenu = function()
			local InstanceList = {}
			for index = 1, math.min (#_detalhes.tabela_instancias, _detalhes.instances_amount), 1 do 
				local _this_instance = _detalhes.tabela_instancias [index]

				--> pegar o que ela ta mostrando
				local atributo = _this_instance.atributo
				local sub_atributo = _this_instance.sub_atributo
				
				if (atributo == 5) then --> custom
					local CustomObject = _detalhes.custom [sub_atributo]
					
					if (CustomObject) then
						InstanceList [#InstanceList+1] = {value = index, label = _detalhes.atributos.lista [atributo] .. " - " .. CustomObject.name, onclick = onSelectInstance, icon = CustomObject.icon}
					else
						InstanceList [#InstanceList+1] = {value = index, label = "unknown" .. " - " .. " invalid custom", onclick = onSelectInstance, icon = [[Interface\COMMON\VOICECHAT-MUTED]]}
					end
					
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

		--local profile_string = g:NewLabel (window, nil, nil, "instancetext", "Current Profile:", "GameFontNormal", 12)
		--profile_string:SetPoint ("bottomleft", window, "bottomleft", 27, 11)
		
		local instances = g:NewDropDown (window, _, "$parentInstanceSelectDropdown", "instanceDropdown", 200, 18, buildInstanceMenu, nil)	
		instances:SetPoint ("bottomright", window, "bottomright", -17, 09)
		
		local instances_string = g:NewLabel (window, nil, nil, "instancetext", Loc ["STRING_OPTIONS_EDITINSTANCE"], "GameFontNormal", 12)
		instances_string:SetPoint ("right", instances, "left", -2)
		
		local f = CreateFrame ("frame", "DetailsDisable3D", UIParent)
		tinsert (UISpecialFrames, "DetailsDisable3D")
		f:SetFrameStrata ("BACKGROUND")
		f:SetFrameLevel (0)
		f:SetPoint ("topleft", WorldFrame, "topleft")
		f:SetPoint ("bottomright", WorldFrame, "bottomright")
		f:Hide()
		
		local t = f:CreateTexture ("DetailsDisable3DTexture", "background")
		t:SetAllPoints (f)
		t:SetTexture (.5, .5, .5, 1)
		
		local c = f:CreateTexture ("DetailsDisable3DTexture", "border")
		c:SetPoint ("center", f, "center", 0, -5)
		c:SetTexture ([[Interface\Challenges\challenges-metalglow]])
		c:SetDesaturated (true)
		c:SetAlpha (.6)
		local tt = f:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
		tt:SetPoint ("center", f, "center", 0, -5)
		tt:SetText ("Character\nPosition")
		
		local hide_3d_world = CreateFrame ("CheckButton", "DetailsOptionsWindowDisable3D", window.widget, "ChatConfigCheckButtonTemplate")
		hide_3d_world:SetPoint ("bottomleft", window.widget, "bottomleft", 28, 7)
		DetailsOptionsWindowDisable3DText:SetText ("Interface Edit Mode")
		DetailsOptionsWindowDisable3DText:ClearAllPoints()
		DetailsOptionsWindowDisable3DText:SetPoint ("left", hide_3d_world, "right", -2, 1)
		DetailsOptionsWindowDisable3DText:SetTextColor (1, 0.8, 0)
		hide_3d_world.tooltip = "Goodbye Cruel World :("
		hide_3d_world:SetHitRectInsets (0, -105, 0, 0)
		
		hide_3d_world:SetScript ("OnClick", function()
			if (hide_3d_world:GetChecked()) then
				f:Show()
				window.Disable3DColorPick:Show()
			else
				f:Hide()
				window.Disable3DColorPick:Hide()
			end
		end)
		
		local last_change = GetTime()
		local disable3dcolor_callback = function (button, r, g, b)
			if (last_change+0.5 < GetTime()) then --protection agaist fast color changes
				t:SetTexture (r, g, b)
				last_change = GetTime()
			end
		end
		g:NewColorPickButton (window, "$parentDisable3DColorPick", "Disable3DColorPick", disable3dcolor_callback)
		window.Disable3DColorPick:SetPoint ("left", hide_3d_world, "right", 120, 0)
		window.Disable3DColorPick:SetColor (.5, .5, .5, 1)
		window.Disable3DColorPick:Hide()
	
	--> create bars
	
		local fill_bars = function()
			local current_combat = _detalhes:GetCombat ("current")
			
			local actors_name = {"Ragnaros", "The Lich King", "Your Neighbor", "Your Raid Leader", "Your Internet Girlfriend", "Mr. President", "A Shadow Priest Complaining About Dps", "Ms. Gray", "Parry Hotter", "Your Math Teacher", "King Djoffrey", UnitName ("player") .. " Snow", "A Drunk Dawrf", "Somebody That You Used To Know", "Low Dps Guy", "Helvis Phresley (Death Log Not Found)", "Stormwind Guard", "A PvP Player", "Bolvar Fordragon","Malygos","Akama","Anachronos","Lady Blaumeux","Cairne Bloodhoof","Borivar","C'Thun","Drek'Thar","Durotan","Eonar","Footman Malakai","Bolvar Fordragon","Fritz Fizzlesprocket","Lisa Gallywix","M'uru","High Priestess MacDonnell","Nazgrel","Ner'zhul","Saria Nightwatcher","Chief Ogg'ora","Ogoun","Grimm Onearm","Apothecary Oni'jus","Orman of Stromgarde","General Rajaxx","Baron Rivendare","Roland","Archmage Trelane","Liam Trollbane"}
			local actors_classes = CLASS_SORT_ORDER
			
			for i = 1, 10 do
				local robot = current_combat[1]:PegarCombatente (0x0000000000000, actors_name [math.random (1, #actors_name)], 0x114, true)
				robot.grupo = true
				robot.classe = actors_classes [math.random (1, #actors_classes)]
				robot.total = math.random (10000000, 60000000)
				robot.damage_taken = math.random (10000000, 60000000)
				robot.friendlyfire_total = math.random (10000000, 60000000)
				
				if (robot.nome == "King Djoffrey") then
					local robot_death = current_combat[4]:PegarCombatente (0x0000000000000, robot.nome, 0x114, true)
					robot_death.grupo = true
					robot_death.classe = robot.classe
					local esta_morte = {{true, 96648, 100000, time(), 0, "Lady Holenna"}, {true, 96648, 100000, time()-52, 100000, "Lady Holenna"}, {true, 96648, 100000, time()-86, 200000, "Lady Holenna"}, {true, 96648, 100000, time()-101, 300000, "Lady Holenna"}, {false, 55296, 400000, time()-54, 400000, "King Djoffrey"}, {true, 14185, 0, time()-59, 400000, "Lady Holenna"}, {false, 87351, 400000, time()-154, 400000, "King Djoffrey"}, {false, 56236, 400000, time()-158, 400000, "King Djoffrey"} } 
					local t = {esta_morte, time(), robot.nome, robot.classe, 400000, "52m 12s",  ["dead"] = true}
					table.insert (current_combat.last_events_tables, #current_combat.last_events_tables+1, t)
					
				elseif (robot.nome == "Mr. President") then	
					rawset (_detalhes.spellcache, 56488, {"Nuke", 56488, [[Interface\ICONS\inv_gizmo_supersappercharge]]})
					robot.spell_tables:PegaHabilidade (56488, true, "SPELL_DAMAGE")
					robot.spell_tables._ActorTable [56488].total = robot.total
				end
				
				local robot = current_combat[2]:PegarCombatente (0x0000000000000, actors_name [math.random (1, #actors_name)], 0x114, true)
				robot.grupo = true
				robot.classe = actors_classes [math.random (1, #actors_classes)]
				robot.total = math.random (10000000, 60000000)
				robot.totalover = math.random (10000000, 60000000)
				robot.totalabsorb = math.random (10000000, 60000000)
				robot.healing_taken = math.random (10000000, 60000000)
				robot.heal_enemy = math.random (10000000, 60000000)
				
			end
			
			current_combat.start_time = time()-360
			current_combat.end_time = time()
			
			for _, instance in ipairs (_detalhes.tabela_instancias) do 
				if (instance:IsEnabled()) then
					instance:InstanceReset()
				end
			end
			
		end
		local fillbars = g:NewButton (window, _, "$parentCreateExampleBarsButton", nil, 110, 14, fill_bars, nil, nil, nil, "Create Test Bars")
		fillbars:SetPoint ("bottomleft", window.widget, "bottomleft", 200, 12)
		--fillbars:InstallCustomTexture()
	
		
	--> left panel buttons
		
		local menus = { --labels nos menus
			{"Display", "Combat", "Profiles"},
			{"Skin Selection", "Row Settings", "Row Texts and Extra Bars", "Show & Hide Settings", "Window Settings", "Attribute Text", "Menus: Left Buttons", "Menus: Right Buttons", "Wallpaper"},
			{"Performance Tweaks", "Data Collector"},
			{"Plugins Management", "Spell Customization", "Data for Charts"}
		}

		local menus2 = {
			"Display", "Combat", 
			"Skin Selection", "Row Settings", "Row Texts and Extra Bars", "Window Settings", "Menus: Left Buttons", "Menus: Right Buttons", "Wallpaper",
			"Performance Tweaks", "Data Collector",
			"Plugins Management", "Profiles", "Attribute Text", "Spell Customization", "Data for Charts", "Show & Hide Settings"
		}
		
		local select_options = function (options_type, true_index)
			
			window:hide_all_options()
			
			window:un_hide_options (options_type)
			
			editing.text = menus2 [options_type]
			
			-- ~altura
			if (options_type == 12 or options_type == 15 or options_type == 16) then --plugins / spell custom / charts
				window.options [12][1].slider:SetMinMaxValues (0, 320)
				--info_text.text = ""
				info_text:Hide()
				window.descAnchorImage:Hide()
				window.descBackgroundImage:Hide()
			else
				info_text:Show()
				window.descAnchorImage:Show()
				window.descBackgroundImage:Show()
			end
			
		end

		local mouse_over_texture = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 156, 22, nil, nil, "buttonMouseOver", "$parentButtonMouseOver")
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
		
			local g_settings_texture = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 160, 33, nil, nil, "GeneralSettingsTexture", "$parentGeneralSettingsTexture")
			g_settings_texture:SetTexCoord (0, 0.15625, 0.685546875, 0.7177734375)
			g_settings_texture:SetPoint ("topleft", g_settings, "topleft", 0, 0)

		--apparance
			local g_appearance = g:NewButton (window, _, "$parentAppearanceButton", "g_appearance", 150, 33, function() end, 0x2)

			g:NewLabel (window, _, "$parentappearance_settings_text", "AppearanceSettingsLabel", Loc ["STRING_OPTIONS_APPEARANCE"], "GameFontNormal", 12)
			window.AppearanceSettingsLabel:SetPoint ("topleft", g_appearance, "topleft", 35, -11)
		
			local g_appearance_texture = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 160, 33, nil, nil, "AppearanceSettingsTexture", "$parentAppearanceSettingsTexture")
			g_appearance_texture:SetTexCoord (0, 0.15625, 0.71875, 0.7509765625)
			g_appearance_texture:SetPoint ("topleft", g_appearance, "topleft", 0, 0)
		
		--performance
			local g_performance = g:NewButton (window, _, "$parentPerformanceButton", "g_appearance", 150, 33, function() end, 0x3)

			g:NewLabel (window, _, "$parentperformance_settings_text", "PerformanceSettingsLabel", Loc ["STRING_OPTIONS_PERFORMANCE"], "GameFontNormal", 12)
			window.PerformanceSettingsLabel:SetPoint ("topleft", g_performance, "topleft", 35, -11)
		
			local g_performance_texture = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 160, 33, nil, nil, "PerformanceSettingsTexture", "$parentPerformanceSettingsTexture")
			g_performance_texture:SetTexCoord (0, 0.15625, 0.751953125, 0.7841796875)
			g_performance_texture:SetPoint ("topleft", g_performance, "topleft", 0, 0)
			
		--advanced
			local g_advanced = g:NewButton (window, _, "$parentAdvancedButton", "g_advanced", 150, 33, function() end, 0x4)
			
			g:NewLabel (window, _, "$parentadvanced_settings_text", "AdvancedSettingsLabel", Loc ["STRING_OPTIONS_ADVANCED"], "GameFontNormal", 12)
			window.AdvancedSettingsLabel:SetPoint ("topleft", g_advanced, "topleft", 35, -11)
		
			local g_advanced_texture = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 160, 33, nil, nil, "AdvancedSettingsTexture", "$parentAdvancedSettingsTexture")
			g_advanced_texture:SetTexCoord (0, 0.15625, 0.8173828125, 0.849609375)
			g_advanced_texture:SetPoint ("topleft", g_advanced, "topleft", 0, 0)
			
		-- advanced

		
		--> index dos menus
		local menus_settings = {1, 2, 13, 3, 4, 5, 17, 6, 14, 7, 8, 9, 10, 11, 12, 15, 16}
		
		
		--> create menus
		local anchors = {g_settings, g_appearance, g_performance, g_advanced}
		local y = -90
		local sub_menu_index = 1
		
		local textcolor = {.8, .8, .8, 1}
		local last_pressed
		local all_buttons = {}
		local true_index = 1
		local selected_textcolor = "wheat"
		
		local button_onenter = function (self)
			self.MyObject.my_bg_texture:SetVertexColor (1, 1, 1, 1)
			self.MyObject.textcolor = "yellow"
		end
		local button_onleave = function (self)
			self.MyObject.my_bg_texture:SetVertexColor (1, 1, 1, .5)
			if (last_pressed ~= self.MyObject) then
				self.MyObject.textcolor = textcolor
			else
				self.MyObject.textcolor = selected_textcolor
			end
		end
		local button_mouse_up = function (button)
			button = button.MyObject
			if (last_pressed ~= button) then
				button.func (button.param1, button.param2, button)
				last_pressed.widget.text:SetPoint ("left", last_pressed.widget, "left", 2, 0)
				last_pressed.textcolor = textcolor
				last_pressed = button
			end
			return true
		end
		
		--move buttons creation to loading process
		function window:create_left_menu()
			for index, menulist in ipairs (menus) do 
				
				anchors [index]:SetPoint (23, y)
				local amount = #menulist
				
				y = y - 37
				
				for i = 1, amount do 
				
					local texture = g:NewImage (window, [[Interface\ARCHEOLOGY\ArchaeologyParts]], 130, 14, nil, nil, nil, "$parentButton_" .. index .. "_" .. i .. "_texture")
					texture:SetTexCoord (0.146484375, 0.591796875, 0.0546875, 0.26171875)
					texture:SetPoint (38, y-2)
					texture:SetVertexColor (1, 1, 1, .5)

					local button = g:NewButton (window, _, "$parentButton_" .. index .. "_" .. i, nil, 150, 18, select_options, menus_settings [true_index], true_index, "", menus [index] [i])
					button:SetPoint (40, y)
					button.textalign = "<"
					button.textcolor = textcolor
					button.textsize = 11
					button.my_bg_texture = texture
					tinsert (all_buttons, button)
					y = y - 16
					
					button:SetHook ("OnEnter", button_onenter)
					button:SetHook ("OnLeave", button_onleave)
					button:SetHook ("OnMouseUp", button_mouse_up)
					
					true_index = true_index + 1
				
				end
				
				y = y - 10
				
			end
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
			[13] = {}, --profiles
			[14] = {}, --attribute text
			[15] = {}, --spellcustom
			[16] = {}, --charts data
			[17] = {}, --instance settings
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
		table.insert (window.options [13], window:create_box_no_scroll (13))
		table.insert (window.options [14], window:create_box_no_scroll (14))
		table.insert (window.options [15], window:create_box_no_scroll (15))
		table.insert (window.options [16], window:create_box_no_scroll (16))
		table.insert (window.options [17], window:create_box_no_scroll (17))

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
		
		--local yellow_point = window:CreateTexture (nil, "overlay")
		--yellow_point:SetSize (16, 16)
		--yellow_point:SetTexture ([[Interface\QUESTFRAME\UI-Quest-BulletPoint]])
		
		local background_on_enter = function (self)
			if (self.background_frame) then
				self = self.background_frame
			end
			
			if (self.parent and self.parent.info) then
				info_text.active = true
				info_text.text = self.parent.info
			end
			
			self.label:SetTextColor (1, .8, 0)
			
			--self:SetBackdrop ({edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 16, edgeSize = 8,
			--insets = {left = 1, right = 1, top = 0, bottom = 1},})
			
			--yellow_point:Show()
			--yellow_point:SetPoint ("right", self, "left", 5, -1)
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
			
			self.label:SetTextColor (1, 1, 1)
			
			--self:SetBackdrop (nil)
			
			--yellow_point:ClearAllPoints()
			--yellow_point:Hide()
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
			f.label = label
			if (parent.widget) then
				parent.widget.background_frame = f
			else
				parent.background_frame = f
			end
			
			if (label:GetObjectType() == "FontString") then
				local t = frameX:CreateTexture (nil, "artwork")
				t:SetPoint ("left", label.widget or label, "left")
				t:SetSize (label:GetStringWidth(), 12)
				t:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-HorizontalShadow]])
				t:SetDesaturated (true)
				t:SetAlpha (.5)
			end
			
		end
		
		function window:CreateLineBackground (frame, widget_name, label_name, desc_loc)
			frame [widget_name].info = desc_loc
			window:create_line_background (frame, frame [label_name], frame [widget_name])
			frame [widget_name]:SetHook ("OnEnter", background_on_enter)
			frame [widget_name]:SetHook ("OnLeave", background_on_leave)
		end
		
		select_options (1)
		
	--[[
	_detalhes.savedCustomSpells = {}
	local a, _, b = GetSpellInfo (124464)
	tinsert (_detalhes.savedCustomSpells, {124464, a, b})
	local a, _, b = GetSpellInfo (124465)
	tinsert (_detalhes.savedCustomSpells, {124465, a, b})
	local a, _, b = GetSpellInfo (124468)
	tinsert (_detalhes.savedCustomSpells, {1244684, a, b})
--]]

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Advanced Settings - Chart Data ~17
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function window:CreateFrame17()
	
	local frame17 = window.options [17][1]
	
		local titulo_instance_settings = g:NewLabel (frame17, _, "$parentTituloInstanceSettingsText", "InstanceSettingsLabel", Loc ["STRING_OPTIONS_SHOWHIDE"], "GameFontNormal", 16)
		local titulo_instance_settings_desc = g:NewLabel (frame17, _, "$parentInstanceSettingsText2", "InstanceSettingsLabel", Loc ["STRING_OPTIONS_SHOWHIDE_DESC"], "GameFontNormal", 9, "white")
		titulo_instance_settings_desc.width = 350
		titulo_instance_settings_desc.height = 40
	
	--> combat alpha modifier
	
		--anchor
		g:NewLabel (frame17, _, "$parentHideInCombatAnchor", "hideInCombatAnchor", "Combat and Group Alpha Mod:", "GameFontNormal")
		
		--> hide in combat
		g:NewLabel (frame17, _, "$parentCombatAlphaLabel", "combatAlphaLabel", Loc ["STRING_OPTIONS_COMBAT_ALPHA"], "GameFontHighlightLeft")
		
		local onSelectCombatAlpha = function (_, _, combat_alpha)
			_G.DetailsOptionsWindow.instance:SetCombatAlpha (combat_alpha)
		end
		local typeCombatAlpha = {
			{value = 1, label = "No Changes", onclick = onSelectCombatAlpha, icon = "Interface\\Icons\\INV_Misc_Spyglass_03", texcoord = {1, 0, 0, 1}},
			{value = 2, label = "While In Combat", onclick = onSelectCombatAlpha, icon = "Interface\\Icons\\INV_Misc_Spyglass_02", texcoord = {1, 0, 0, 1}},
			{value = 3, label = "While Out of Combat", onclick = onSelectCombatAlpha, icon = "Interface\\Icons\\INV_Misc_Spyglass_02", texcoord = {1, 0, 0, 1}},
			{value = 4, label = "While Out of a Group", onclick = onSelectCombatAlpha, icon = "Interface\\Icons\\INV_Misc_Spyglass_02", texcoord = {1, 0, 0, 1}}
		}
		local buildTypeCombatAlpha = function()
			return typeCombatAlpha
		end
		local d = g:NewDropDown (frame17, _, "$parentCombatAlphaDropdown", "combatAlphaDropdown", 160, 20, buildTypeCombatAlpha, nil)
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		frame17.combatAlphaDropdown:SetPoint ("left", frame17.combatAlphaLabel, "right", 2, 0)		
		
		frame17.combatAlphaDropdown.info = Loc ["STRING_OPTIONS_COMBAT_ALPHA_DESC"]

		window:create_line_background (frame17, frame17.combatAlphaLabel, frame17.combatAlphaDropdown)
		frame17.combatAlphaDropdown:SetHook ("OnEnter", background_on_enter)
		frame17.combatAlphaDropdown:SetHook ("OnLeave", background_on_leave)

		g:NewLabel (frame17, _, "$parentHideOnCombatAlphaLabel", "hideOnCombatAlphaLabel", Loc ["STRING_OPTIONS_HIDECOMBATALPHA"], "GameFontHighlightLeft")
		
		local s = g:NewSlider (frame17, _, "$parentHideOnCombatAlphaSlider", "hideOnCombatAlphaSlider", SLIDER_WIDTH, 20, 0, 100, 1, _G.DetailsOptionsWindow.instance.hide_in_combat_alpha) -- min, max, step, defaultv
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)
		
		frame17.hideOnCombatAlphaSlider:SetPoint ("left", frame17.hideOnCombatAlphaLabel, "right", 2, 0)
		frame17.hideOnCombatAlphaSlider:SetHook ("OnValueChange", function (self, instance, amount) --> slider, fixedValue, sliderValue
			instance.hide_in_combat_alpha = amount
			_G.DetailsOptionsWindow.instance:SetCombatAlpha (nil, nil, true)
		end)
		
		frame17.hideOnCombatAlphaSlider.info = Loc ["STRING_OPTIONS_HIDECOMBATALPHA_DESC"]
		
		window:create_line_background (frame17, frame17.hideOnCombatAlphaLabel, frame17.hideOnCombatAlphaSlider)
		frame17.hideOnCombatAlphaSlider:SetHook ("OnEnter", background_on_enter)
		frame17.hideOnCombatAlphaSlider:SetHook ("OnLeave", background_on_leave)
	
	--> auto transparency
		--> alpha onenter onleave auto transparency
		
		g:NewLabel (frame17, _, "$parentMenuAlphaAnchor", "menuAlphaAnchorLabel", Loc ["STRING_OPTIONS_MENU_ALPHA"], "GameFontNormal")
	
		g:NewSwitch (frame17, _, "$parentMenuOnEnterLeaveAlphaSwitch", "alphaSwitch", 60, 20, _, _, instance.menu_alpha.enabled)
		
		local s = g:NewSlider (frame17, _, "$parentMenuOnEnterAlphaSlider", "menuOnEnterSlider", SLIDER_WIDTH, 20, 0, 1, 0.02, instance.menu_alpha.onenter, true)
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)
		s.useDecimals = true
		
		local s = g:NewSlider (frame17, _, "$parentMenuOnLeaveAlphaSlider", "menuOnLeaveSlider", SLIDER_WIDTH, 20, 0, 1, 0.02, instance.menu_alpha.onleave, true)
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)
		
		frame17.menuOnEnterSlider.useDecimals = true
		frame17.menuOnLeaveSlider.useDecimals = true
		
		g:NewLabel (frame17, _, "$parentMenuOnEnterLeaveAlphaLabel", "alphaSwitchLabel", Loc ["STRING_OPTIONS_MENU_ALPHAENABLED"], "GameFontHighlightLeft")
		g:NewLabel (frame17, _, "$parentMenuOnEnterAlphaLabel", "menuOnEnterLabel", Loc ["STRING_OPTIONS_MENU_ALPHAENTER"], "GameFontHighlightLeft")
		g:NewLabel (frame17, _, "$parentMenuOnLeaveAlphaLabel", "menuOnLeaveLabel", Loc ["STRING_OPTIONS_MENU_ALPHALEAVE"], "GameFontHighlightLeft")

		frame17.alphaSwitch.info = Loc ["STRING_OPTIONS_MENU_ALPHAENABLED_DESC"]
		window:create_line_background (frame17, frame17.alphaSwitchLabel, frame17.alphaSwitch)
		frame17.alphaSwitch:SetHook ("OnEnter", background_on_enter)
		frame17.alphaSwitch:SetHook ("OnLeave", background_on_leave)
		
		frame17.menuOnEnterSlider.info = Loc ["STRING_OPTIONS_MENU_ALPHAENTER_DESC"]
		window:create_line_background (frame17, frame17.menuOnEnterLabel, frame17.menuOnEnterSlider)
		frame17.menuOnEnterSlider:SetHook ("OnEnter", background_on_enter)
		frame17.menuOnEnterSlider:SetHook ("OnLeave", background_on_leave)
		
		frame17.menuOnLeaveSlider.info = Loc ["STRING_OPTIONS_MENU_ALPHALEAVE_DESC"]
		window:create_line_background (frame17, frame17.menuOnLeaveLabel, frame17.menuOnLeaveSlider)
		frame17.menuOnLeaveSlider:SetHook ("OnEnter", background_on_enter)
		frame17.menuOnLeaveSlider:SetHook ("OnLeave", background_on_leave)
		
		frame17.alphaSwitch:SetPoint ("left", frame17.alphaSwitchLabel, "right", 2)
		frame17.menuOnEnterSlider:SetPoint ("left", frame17.menuOnEnterLabel, "right", 2)
		frame17.menuOnLeaveSlider:SetPoint ("left", frame17.menuOnLeaveLabel, "right", 2)

		frame17.menuOnEnterSlider:SetThumbSize (50)
		frame17.menuOnLeaveSlider:SetThumbSize (50)


		g:NewLabel (frame17, _, "$parentMenuOnEnterLeaveAlphaIconsTooLabel", "alphaIconsTooLabel", Loc ["STRING_OPTIONS_MENU_IGNOREBARS"], "GameFontHighlightLeft")		
		g:NewSwitch (frame17, _, "$parentMenuOnEnterLeaveAlphaIconsTooSwitch", "alphaIconsTooSwitch", 60, 20, _, _, instance.menu_alpha.ignorebars)
		
		frame17.alphaIconsTooSwitch.info = Loc ["STRING_OPTIONS_MENU_IGNOREBARS_DESC"]
		window:create_line_background (frame17, frame17.alphaIconsTooLabel, frame17.alphaIconsTooSwitch)
		frame17.alphaIconsTooSwitch:SetHook ("OnEnter", background_on_enter)
		frame17.alphaIconsTooSwitch:SetHook ("OnLeave", background_on_leave)
		
		frame17.alphaIconsTooSwitch:SetPoint ("left", frame17.alphaIconsTooLabel, "right", 2)
		
		frame17.alphaIconsTooSwitch.OnSwitch = function (self, instance, value)
			instance:SetMenuAlpha (nil, nil, nil, value)
		end
		frame17.alphaSwitch.OnSwitch = function (self, instance, value)
			--
			instance:SetMenuAlpha (value)
		end
		frame17.menuOnEnterSlider:SetHook ("OnValueChange", function (self, instance, value) 
			--
			self.amt:SetText (string.format ("%.2f", value))
			instance:SetMenuAlpha (nil, value)
			return true
		end)
		frame17.menuOnLeaveSlider:SetHook ("OnValueChange", function (self, instance, value) 
			--
			self.amt:SetText (string.format ("%.2f", value))
			instance:SetMenuAlpha (nil, nil, value)
			return true
		end)		

	
	--> auto hide menus
		
	
	
	--> anchors
		titulo_instance_settings:SetPoint (10, -10)
		titulo_instance_settings_desc:SetPoint (10, -30)
		
		frame17.hideInCombatAnchor:SetPoint (10, -80)
		frame17.combatAlphaLabel:SetPoint (10, -105)
		frame17.hideOnCombatAlphaLabel:SetPoint (10, -130)
		
		frame17.menuAlphaAnchorLabel:SetPoint (10, -165)
		frame17.alphaSwitchLabel:SetPoint (10, -190)
		frame17.menuOnEnterLabel:SetPoint (10, -215)
		frame17.menuOnLeaveLabel:SetPoint (10, -240)
		frame17.alphaIconsTooLabel:SetPoint (10, -265)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Advanced Settings - Chart Data ~16
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function window:CreateFrame16()

	--> general settings:
		local frame16 = window.options [16][1]

	--> title
		local titulo_datacharts = g:NewLabel (frame16, _, "$parentTituloDataChartsText", "DataChartsLabel", Loc ["STRING_OPTIONS_DATACHARTTITLE"], "GameFontNormal", 16)
		local titulo_datacharts_desc = g:NewLabel (frame16, _, "$parentDataChartsText2", "DataCharts2Label", Loc ["STRING_OPTIONS_DATACHARTTITLE_DESC"], "GameFontNormal", 9, "white")
		titulo_datacharts_desc.width = 350
	
	--> panel
		local edit_name = function (index, name)
			_detalhes:TimeDataUpdate (index, name)
			frame16.userTimeCaptureFillPanel:Refresh()
		end
		
		local big_code_editor = g:NewSpecialLuaEditorEntry (frame16, 643, 382, "bigCodeEditor", "$parentBigCodeEditor")
		big_code_editor:SetPoint ("topleft", frame16, "topleft", 7, -70)
		big_code_editor:SetFrameLevel (frame16:GetFrameLevel()+6)
		big_code_editor:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], 
		tile = 1, tileSize = 16, edgeSize = 16, insets = {left = 5, right = 5, top = 5, bottom = 5}})
		big_code_editor:SetBackdropColor (0, 0, 0, 1)
		big_code_editor:Hide()
		
		local accept = function()
			big_code_editor:ClearFocus()
			if (not big_code_editor.is_export) then
				_detalhes:TimeDataUpdate (big_code_editor.index, nil, big_code_editor:GetText())
			end
			big_code_editor:Hide()
		end
		local cancel = function()
			big_code_editor:ClearFocus()
			big_code_editor:Hide()
		end
		local accept_changes = g:NewButton (big_code_editor, nil, "$parentAccept", "acceptButton", 24, 24, accept, nil, nil, [[Interface\Buttons\UI-CheckBox-Check]])
		accept_changes:SetPoint (10, 18)
		local accept_changes_label = g:NewLabel (big_code_editor, nil, nil, nil, "Save")
		accept_changes_label:SetPoint ("left", accept_changes, "right", 2, 0)
		
		local cancel_changes = g:NewButton (big_code_editor, nil, "$parentCancel", "CancelButton", 20, 20, cancel, nil, nil, [[Interface\PetBattles\DeadPetIcon]])
		cancel_changes:SetPoint (100, 17)
		local cancel_changes_label = g:NewLabel (big_code_editor, nil, nil, nil, "Cancel")
		cancel_changes_label:SetPoint ("left", cancel_changes, "right", 2, 0)

		local edit_code = function (index)
			local data = _detalhes.savedTimeCaptures [index]
			if (data) then
				local func = data [2]
				
				if (type (func) == "function") then
					return _detalhes:Msg ("The code is already loaded and cannot be displayed.")
				end
				
				big_code_editor:SetText (func)
				big_code_editor.original_code = func
				big_code_editor.index = index
				big_code_editor.is_export = nil
				big_code_editor:Show()
				
				frame16.userTimeCaptureAddPanel:Hide()
				frame16.importEditor:ClearFocus()
				frame16.importEditor:Hide()
				if (DetailsIconPickFrame and DetailsIconPickFrame:IsShown()) then
					DetailsIconPickFrame:Hide()
				end
			end
		end
		
		local edit_icon = function (index, icon)
			_detalhes:TimeDataUpdate (index, nil, nil, nil, nil, nil, icon)
			frame16.userTimeCaptureFillPanel:Refresh()
		end
		local edit_author = function (index, author)
			_detalhes:TimeDataUpdate (index, nil, nil, nil, author)
			frame16.userTimeCaptureFillPanel:Refresh()
		end
		local edit_version = function (index, version)
			_detalhes:TimeDataUpdate (index, nil, nil, nil, nil, version)
			frame16.userTimeCaptureFillPanel:Refresh()
		end
		
		local big_code_editor2 = g:NewSpecialLuaEditorEntry (frame16, 643, 382, "exportEditor", "$parentExportEditor", true)
		big_code_editor2:SetPoint ("topleft", frame16, "topleft", 7, -70)
		big_code_editor2:SetFrameLevel (frame16:GetFrameLevel()+6)
		big_code_editor2:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], 
		tile = 1, tileSize = 16, edgeSize = 16, insets = {left = 5, right = 5, top = 5, bottom = 5}})
		big_code_editor2:SetBackdropColor (0, 0, 0, 1)
		big_code_editor2:Hide()
		
		local close_export_box = function()
			big_code_editor2:ClearFocus()
			big_code_editor2:Hide()
		end
		local close_export = g:NewButton (big_code_editor2, nil, "$parentClose", "closeButton", 24, 24, close_export_box, nil, nil, [[Interface\Buttons\UI-CheckBox-Check]])
		close_export:SetPoint (10, 18)
		local close_export_label = g:NewLabel (big_code_editor2, nil, nil, nil, "Close")
		close_export_label:SetPoint ("left", close_export, "right", 2, 0)
		
		local export_function = function (index)
			local data = _detalhes.savedTimeCaptures [index]
			if (data) then
				local serialized = _detalhes:Serialize (data)
				--serialized = LibStub:GetLibrary ("LibCompress"):CompressLZW (serialized)
				--local serialized = LibStub:GetLibrary ("LibCompress"):Compress (func)
				
				big_code_editor2:SetText (serialized)
				
				big_code_editor2:Show()
				big_code_editor2.editbox:HighlightText()
				big_code_editor2.editbox:SetFocus (true)
				
			end
		end
		
		local remove_capture = function (index)
			_detalhes:TimeDataUnregister (index)
			frame16.userTimeCaptureFillPanel:Refresh()
		end
		
		local edit_enabled = function (index, enabled)
			if (enabled) then
				_detalhes:TimeDataUpdate (index, nil, nil, nil, nil, nil, nil, false)
			else
				_detalhes:TimeDataUpdate (index, nil, nil, nil, nil, nil, nil, true)
			end
			
			frame16.userTimeCaptureFillPanel:Refresh()
		end
		
		local header = {
			{name = "Name", width = 175, type = "entry", func = edit_name},
			{name = "Edit Code", width = 55, type = "button", func = edit_code, icon = [[Interface\Buttons\UI-GuildButton-OfficerNote-Disabled]], notext = true, iconalign = "center"},
			{name = "Icon", width = 50, type = "icon", func = edit_icon},
			{name = "Author", width = 125, type = "text", func = edit_author},
			{name = "Version", width = 65, type = "entry", func = edit_version},
			{name = "Enabled", width = 50, type = "button", func = edit_enabled, icon = [[Interface\COMMON\Indicator-Green]], notext = true, iconalign = "center"},
			{name = "Export", width = 50, type = "button", func = export_function, icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Up]], notext = true, iconalign = "center"},
			{name = "Remove", width = 70, type = "button", func = remove_capture, icon = [[Interface\COMMON\VOICECHAT-MUTED]], notext = true, iconalign = "center"},
		}
		
		local total_lines = function()
			return #_detalhes.savedTimeCaptures
		end
		local fill_row = function (index)
			local data = _detalhes.savedTimeCaptures [index]
			if (data) then
			
				local enabled_texture
				if (data[7]) then
					enabled_texture = [[Interface\COMMON\Indicator-Green]]
				else
					enabled_texture = [[Interface\COMMON\Indicator-Red]]
				end

				return {
					data[1], --name
					"", --func
					data[6], --icon
					data[4], -- author
					data[5], --version
					{func = edit_enabled, icon = enabled_texture, value = data[7]} --enabled
				}
			else
				return {nil, nil, nil, nil, nil, nil}
			end
		end

		local panel = g:NewFillPanel (frame16, header, "$parentUserTimeCapturesFillPanel", "userTimeCaptureFillPanel", 640, 382, total_lines, fill_row, false)

		panel:SetHook ("OnMouseDown", function()
			if (DetailsIconPickFrame and DetailsIconPickFrame:IsShown()) then
				DetailsIconPickFrame:Hide()
			end
		end)
		
		panel:Refresh()
		
		--> add panel
			local addframe = g:NewPanel (frame16, nil, "$parentUserTimeCapturesAddPanel", "userTimeCaptureAddPanel", 640, 382)
			addframe.backdrop = {bgFile = [[Interface\AddOns\Details\images\background]]}
			addframe.color = "black"
			addframe:SetPoint (10, -70)
			addframe:SetFrameLevel (7)
			addframe:Hide()
			
			addframe:SetGradient ("OnEnter", {0, 0, 0, .95})
			addframe:SetGradient ("OnLeave", {0, 0, 0, .95})
			addframe:SetBackdropColor (0, 0, 0, .95)

			--> name
				local capture_name = g:NewLabel (addframe, nil, "$parentNameLabel", "nameLabel", "Name: ")
				local capture_name_entry = g:NewTextEntry (addframe, nil, "$parentNameEntry", "nameEntry", 160, 20, function() end)
				capture_name_entry:SetPoint ("left", capture_name, "right", 2, 0)
			
			--> function
				local capture_func = g:NewLabel (addframe, nil, "$parentFunctionLabel", "functionLabel", "Code: ")
				local capture_func_entry = g:NewSpecialLuaEditorEntry (addframe.widget, 300, 200, "funcEntry", "$parentFuncEntry")
				capture_func_entry:SetPoint ("topleft", capture_func.widget, "topright", 2, 0)
				capture_func_entry:SetSize (500, 200)
				
			--> icon
				local capture_icon = g:NewLabel (addframe, nil, "$parentIconLabel", "iconLabel", "Icon: ")
				local icon_button_func = function (texture)
					addframe.iconButton.icon.texture = texture
				end
				local capture_icon_button = g:NewButton (addframe, nil, "$parentIconButton", "iconButton", 20, 20, function() g:IconPick (icon_button_func) end)
				local capture_icon_button_icon = g:NewImage (capture_icon_button, [[Interface\ICONS\TEMP]], 19, 19, "background", nil, "icon", "$parentIcon")
				capture_icon_button_icon:SetPoint (0, 0)
				capture_icon_button:InstallCustomTexture()
				capture_icon_button:SetPoint ("left", capture_icon, "right", 2, 0)			
			
			--> author
				local capture_author = g:NewLabel (addframe, nil, "$parentAuthorLabel", "authorLabel", "Author: ")
				local capture_author_entry = g:NewTextEntry (addframe, nil, "$parentAuthorEntry", "authorEntry", 160, 20, function() end)
				capture_author_entry:SetPoint ("left", capture_author, "right", 2, 0)
				
			--> version
				local capture_version = g:NewLabel (addframe, nil, "$parentVersionLabel", "versionLabel", "Version: ")
				local capture_version_entry = g:NewTextEntry (addframe, nil, "$parentVersionEntry", "versionEntry", 160, 20, function() end)
				capture_version_entry:SetPoint ("left", capture_version, "right", 2, 0)
		
		--> open add panel button
			local add = function() 
				addframe:Show()
				frame16.importEditor:ClearFocus()
				frame16.importEditor:Hide()
				big_code_editor:ClearFocus()
				big_code_editor:Hide()
				if (DetailsIconPickFrame and DetailsIconPickFrame:IsShown()) then
					DetailsIconPickFrame:Hide()
				end
			end
			local addbutton = g:NewButton (frame16, nil, "$parentAddButton", "addbutton", 135, 21, add, nil, nil, nil, "Add Data Capture")
			addbutton:InstallCustomTexture()
			addbutton:SetPoint ("bottomright", panel, "topright", -30, 0)
			
			local left = g:NewImage (frame16, "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs", 64, 13, "artwork", {0, 1, 0, 0.05078125})
			left:SetPoint ("bottomright", addbutton, "bottomleft",  34, 0)
			left:SetBlendMode ("ADD")
			left:Hide()
			local right = g:NewImage (frame16, "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs", 64, 13, "artwork", {0, 1, 0.0546875, 0.1015625})
			right:SetPoint ("bottomleft", addbutton, "bottomright",  0, 0)
			right:SetBlendMode ("ADD")
			
		--> open import panel button
		
			local importframe = g:NewSpecialLuaEditorEntry (frame16, 643, 382, "importEditor", "$parentImportEditor", true)
			importframe:SetPoint ("topleft", frame16, "topleft", 7, -70)
			importframe:SetFrameLevel (frame16:GetFrameLevel()+6)
			importframe:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], 
			tile = 1, tileSize = 16, edgeSize = 16, insets = {left = 5, right = 5, top = 5, bottom = 5}})
			importframe:SetBackdropColor (0, 0, 0, 1)
			importframe:Hide()

			local doimport = function()
				local text = importframe:GetText()
				local unserialize, arg2, arg3 = select (2, _detalhes:Deserialize (text))
				
				if (type (unserialize) == "table") then
					if (unserialize[1] and unserialize[2] and unserialize[3] and unserialize[4] and unserialize[5]) then
						_detalhes:RegisterUserTimeCapture (unpack (unserialize))
					else
						_detalhes:Msg ("The import string is invalid.")
					end
				else
					_detalhes:Msg ("The import string is invalid.")
				end
				
				importframe:Hide()
				panel:Refresh()
			end
	
			local accept_import = g:NewButton (importframe, nil, "$parentAccept", "acceptButton", 24, 24, doimport, nil, nil, [[Interface\Buttons\UI-CheckBox-Check]])
			accept_import:SetPoint (10, 18)
			local accept_import_label = g:NewLabel (importframe, nil, nil, nil, "Import")
			accept_import_label:SetPoint ("left", accept_import, "right", 2, 0)
			
			local cancelimport = function()
				importframe:ClearFocus()
				importframe:Hide()
			end
			
			local cancel_changes = g:NewButton (importframe, nil, "$parentCancel", "CancelButton", 20, 20, cancelimport, nil, nil, [[Interface\PetBattles\DeadPetIcon]])
			cancel_changes:SetPoint (100, 17)
			local cancel_changes_label = g:NewLabel (importframe, nil, nil, nil, "Cancel")
			cancel_changes_label:SetPoint ("left", cancel_changes, "right", 2, 0)
		
			local import = function() 
				importframe:Show()
				importframe:SetText ("")
				importframe:SetFocus (true)
				addframe:Hide()
				big_code_editor:ClearFocus()
				big_code_editor:Hide()
				if (DetailsIconPickFrame and DetailsIconPickFrame:IsShown()) then
					DetailsIconPickFrame:Hide()
				end
			end
			local importbutton = g:NewButton (frame16, nil, "$parentImportButton", "importbutton", 75, 21, import, nil, nil, nil, "Import")
			importbutton:InstallCustomTexture()
			importbutton:SetPoint ("bottomright", panel, "topright", -165, 0)
			
			local left = g:NewImage (frame16, "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs", 64, 13, "artwork", {0, 1, 0, 0.05078125})
			left:SetPoint ("bottomright", importbutton, "bottomleft",  34, 0)
			left:SetBlendMode ("ADD")
			local right = g:NewImage (frame16, "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs", 64, 13, "artwork", {0, 1, 0.0546875, 0.1015625})
			right:SetPoint ("bottomleft", importbutton, "bottomright",  0, 0)
			right:SetBlendMode ("ADD")
			right:Hide()
	
		--> close button
			local closebutton = g:NewButton (addframe, nil, "$parentAddCloseButton", "addClosebutton", 135, 21, function() addframe:Hide() end, nil, nil, nil, "Close")
			closebutton:InstallCustomTexture()
			
		--> confirm add capture
			local addcapture = function()
				local name = capture_name_entry.text
				if (name == "") then
					return _detalhes:Msg ("The name is invalid.")
				end
				
				local author = capture_author_entry.text
				if (author == "") then
					return _detalhes:Msg ("Author name is invalid.")
				end
				
				local icon = capture_icon_button_icon.texture
				
				local version = capture_version_entry.text
				if (version == "") then
					return _detalhes:Msg ("Version is invalid.")
				end
				
				local func = capture_func_entry:GetText()
				if (func == "") then
					return _detalhes:Msg ("Function is invalid.")
				end
				
				_detalhes:RegisterUserTimeCapture (name, func, icon, author, version)
				
				panel:Refresh()
				
				capture_name_entry.text = ""
				capture_author_entry.text = ""
				capture_version_entry.text = ""
				capture_func_entry:SetText ("")
				capture_icon_button_icon.texture = [[Interface\ICONS\TEMP]]
				
				if (DetailsIconPickFrame and DetailsIconPickFrame:IsShown()) then
					DetailsIconPickFrame:Hide()
				end
				addframe:Hide();

			end
			local addcapturebutton = g:NewButton (addframe, nil, "$parentAddCaptureButton", "addCapturebutton", 135, 21, addcapture, nil, nil, nil, "Add")
			addcapturebutton:InstallCustomTexture()
	
		--> anchors
			local start = 25
			capture_name:SetPoint (start, -30)
			capture_icon:SetPoint (start, -55)
			capture_author:SetPoint (start, -80)
			capture_version:SetPoint (start, -105)
			capture_func:SetPoint (start, -130)
			closebutton:SetPoint ("bottomright", addframe, "bottomright", 0, 0)
			addcapturebutton:SetPoint (50, -360)
	
	--> anchors
	
		titulo_datacharts:SetPoint (10, -10)
		titulo_datacharts_desc:SetPoint (10, -30)
		
		panel:SetPoint (10, -70)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Advanced Settings - Custom Spells ~15
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function window:CreateFrame15()

	--> general settings:
		local frame15 = window.options [15][1]

	--> title
		local titulo_customspells = g:NewLabel (frame15, _, "$parentTituloCustomSpellsText", "customSpellsTextLabel", Loc ["STRING_OPTIONS_CUSTOMSPELLTITLE"], "GameFontNormal", 16)
		local titulo_customspells_desc = g:NewLabel (frame15, _, "$parentCustomSpellsText2", "customSpellsText2Label", Loc ["STRING_OPTIONS_CUSTOMSPELLTITLE_DESC"], "GameFontNormal", 9, "white")
		titulo_customspells_desc.width = 350		
	
		local name_entry_func = function (index, text)
			_detalhes:UserCustomSpellUpdate (index, text) 
		end
		local icon_func = function (index, icon)
			_detalhes:UserCustomSpellUpdate (index, nil, icon)
		end
		local remove_func = function (index)
			_detalhes:UserCustomSpellRemove (index)
		end
	
	--> custom spells panel
		local header = {
			{name = "Index", width = 55, type = "text"}, 
			{name = "Name", width = 310, type = "entry", func = name_entry_func}, 
			{name = "Icon", width = 50, type = "icon", func = icon_func}, 
			{name = "Spell ID", width = 100, type = "text"},
			{name = "Remove", width = 125, type = "button", func = remove_func, icon = [[Interface\COMMON\VOICECHAT-MUTED]]}, 
		}
		--local header = {{name = "Index", type = "text"}, {name = "Name", type = "entry"}, {name = "Icon", type = "icon"}, {name = "Author", type = "text"}, {name = "Version", type = "text"}}
		
		local total_lines = function()
			return #_detalhes.savedCustomSpells
		end
		local fill_row = function (index)
			local data = _detalhes.savedCustomSpells [index]
			if (data) then
				return {index, data [2], data [3], data [1], ""}
			else
				return {nil, nil, nil, nil, nil}
			end
		end
		
		local panel = g:NewFillPanel (frame15, header, "$parentCustomSpellsFillPanel", "customSpellsFillPanel", 640, 382, total_lines, fill_row, false)

		panel:Refresh()
	
	--> add
	
		--> add panel
			local addframe = g:NewPanel (frame15, nil, "$parentCustomSpellsAddPanel", "customSpellsAddPanel", 640, 382)
			addframe.backdrop = {bgFile = [[Interface\AddOns\Details\images\background]]}
			addframe.color = "black"
			addframe:SetPoint (10, -70)
			addframe:SetFrameLevel (7)
			addframe:Hide()
			
			addframe:SetGradient ("OnEnter", {0, 0, 0, .95})
			addframe:SetGradient ("OnLeave", {0, 0, 0, .95})
			addframe:SetBackdropColor (0, 0, 0, .95)
			
			local desc = "A ID is a unique number to identify the spell inside World of Warcraft. There is many ways to get the number:\n\n- On the Player Details Window, hold shift while hover over spells bars.\n- Type the spell name in the SpellId field, a tooltip is shown with suggested spells.\n- Community web sites, most of them have the spellid on the address link.\n- Browsing the spell cache below:"
			local desc_spellid = g:NewLabel (addframe, nil, "$parentSpellidDescLabel", "spellidDescLabel", desc)
			
			local spellid = g:NewLabel (addframe, nil, "$parentSpellidLabel", "spellidLabel", "SpellId: ")
			local spellname = g:NewLabel (addframe, nil, "$parentSpellnameLabel", "spellnameLabel", "Custom Name: ")
			local spellicon = g:NewLabel (addframe, nil, "$parentSpelliconLabel", "spelliconLabel", "Custom Icon: ")
		
			local spellname_entry_func = function() end
			local spellname_entry = g:NewTextEntry (addframe, nil, "$parentSpellnameEntry", "spellnameEntry", 160, 20, spellname_entry_func)
			spellname_entry:SetPoint ("left", spellname, "right", 2, 0)

			local spellid_entry_func = function (arg1, arg2, spellid) 
				local spellname, _, icon = GetSpellInfo (spellid)
				if (spellname) then
					spellname_entry:SetText (spellname) 
					addframe.spellIconButton.icon.texture = icon
				else
					_detalhes:Msg ("Spell not found.")
				end
			end
			local spellid_entry = g:NewSpellEntry (addframe, spellid_entry_func, 160, 20, nil, nil, "spellidEntry", "$parentSpellidEntry")
			spellid_entry:SetPoint ("left", spellid, "right", 2, 0)
			

			local icon_button_func = function (texture)
				addframe.spellIconButton.icon.texture = texture
			end
			local icon_button = g:NewButton (addframe, nil, "$parentSpellIconButton", "spellIconButton", 20, 20, function() g:IconPick (icon_button_func) end)
			local icon_button_icon = g:NewImage (icon_button, [[Interface\ICONS\TEMP]], 19, 19, "background", nil, "icon", "$parentSpellIcon")
			icon_button_icon:SetPoint (0, 0)
			icon_button:InstallCustomTexture()
			icon_button:SetPoint ("left", spellicon, "right", 2, 0)
			
			local all_cached_spells = {}
			
			local refresh_cache = function (self) 
			
				local offset = FauxScrollFrame_GetOffset (self)
				local total = #all_cached_spells
				
				for index = 1, #self.lines1 do
					
					local label1 = self.lines1 [index]
					local label2 = self.lines2 [index]
					
					local data = all_cached_spells [index + offset]
					
					if (data) then
						label1.text = data [1]
						label2.text = data [2]
					else
						label1.text = ""
						label2.text = ""
					end
					
				end
				
			end
			local scrollframe =  CreateFrame ("scrollframe", "SpellCacheBrowserFrame", addframe.widget, "FauxScrollFrameTemplate")
			scrollframe:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (self, offset, 10, refresh_cache) end)
			scrollframe:SetSize (250, 140)
			scrollframe.lines1 = {}
			scrollframe.lines2 = {}
			scrollframe:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, edgeSize = 8, tileSize = 5})
			
			for i = 1, 10 do
				local label1 = g:NewLabel (scrollframe, nil, "$parentLabel1" .. i, nil)
				local label2 = g:NewLabel (scrollframe, nil, "$parentLabel2" .. i, nil)
				local y = (i-1) * 13 * -1 - 5
				label1:SetPoint (3, y)
				label2:SetPoint (70, y)
				tinsert (scrollframe.lines1, label1)
				tinsert (scrollframe.lines2, label2)
			end
			
		--> close button
			local closebutton = g:NewButton (addframe, nil, "$parentAddCloseButton", "addClosebutton", 135, 21, function() addframe:Hide(); table.wipe (all_cached_spells) end, nil, nil, nil, "Close")
			closebutton:InstallCustomTexture()
			
		--> confirm add spell
			local addspell = function()
				local id = spellid_entry.text
				if (id == "") then
					return _detalhes:Msg ("Spell id invalid.")
				end
				local name = spellname_entry.text
				if (name == "") then
					return _detalhes:Msg ("Spell name invalid.")
				end
				local icon = addframe.spellIconButton.icon.texture
				
				id = tonumber (id)
				if (not id) then
					return _detalhes:Msg ("Spell id invalid.")
				end
				
				_detalhes:UserCustomSpellAdd (id, name, icon)
				
				panel:Refresh()
				
				spellid_entry.text = ""
				spellname_entry.text = ""
				addframe.spellIconButton.icon.texture = [[Interface\ICONS\TEMP]]
				
				if (DetailsIconPickFrame and DetailsIconPickFrame:IsShown()) then
					DetailsIconPickFrame:Hide()
				end
				addframe:Hide();
				table.wipe (all_cached_spells)
			end
			local addspellbutton = g:NewButton (addframe, nil, "$parentAddSpellButton", "addSpellbutton", 135, 21, addspell, nil, nil, nil, "Add")
			addspellbutton:InstallCustomTexture()
			
			closebutton:SetPoint ("bottomright", addframe, "bottomright", 0, 0)
			desc_spellid:SetPoint (50, -30)
			scrollframe:SetPoint ("topleft", addframe.widget, "topleft", 50, -110)
			spellid:SetPoint (50, -285)
			spellname:SetPoint (50, -310)
			spellicon:SetPoint (50, -335)
			addspellbutton:SetPoint (50, -360)
			
			scrollframe:Show()
		
			local update_cache_scroll = function()
			
				table.wipe (all_cached_spells)
			
				for spellid, t in pairs (_detalhes.spellcache) do 
					tinsert (all_cached_spells, {spellid, t[1]})
				end
			
				table.sort (all_cached_spells, function (t1, t2) local a = t1 and t1[2] or "z"; local b = t2 and t2[2] or "z"; return a < b end)
			
				FauxScrollFrame_Update (scrollframe, math.max (11, #all_cached_spells), 10, 12)
				refresh_cache (scrollframe)
			end
		

		
		--> open add panel button
			local add = function() 
				update_cache_scroll()
				addframe:Show()
			end
			local addbutton = g:NewButton (frame15, nil, "$parentAddButton", "addbutton", 135, 21, add, nil, nil, nil, "Add Spell")
			addbutton:InstallCustomTexture()
			addbutton:SetPoint ("bottomright", panel, "topright", -30, 0)
			
			local left = g:NewImage (frame15, "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs", 64, 13, "artwork", {0, 1, 0, 0.05078125})
			left:SetPoint ("bottomright", addbutton, "bottomleft",  34, 0)
			left:SetBlendMode ("ADD")
			local right = g:NewImage (frame15, "Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs", 64, 13, "artwork", {0, 1, 0.0546875, 0.1015625})
			right:SetPoint ("bottomleft", addbutton, "bottomright",  0, 0)
			right:SetBlendMode ("ADD")
	
	--> anchors
	
		titulo_customspells:SetPoint (10, -10)
		titulo_customspells_desc:SetPoint (10, -30)
		
		panel:SetPoint (10, -70)
end

		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- General Settings - Display ~14
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function window:CreateFrame14()

	--> general settings:
		local frame14 = window.options [14][1]

		local titulo_attributetext = g:NewLabel (frame14, _, "$parentTituloAttributeText", "attributeTextLabel", Loc ["STRING_OPTIONS_ATTRIBUTE_TEXT"], "GameFontNormal", 16)
		local titulo_attributetext_desc = g:NewLabel (frame14, _, "$parentAttributeText2", "attributeText2Label", Loc ["STRING_OPTIONS_ATTRIBUTE_TEXT_DESC"], "GameFontNormal", 9, "white")
		titulo_attributetext_desc.width = 350
		
--attribute text
	--text anchor on options menu
		--g:NewLabel (frame14, _, "$parentAttributeLabelAnchor", "attributeLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHOR"], "GameFontNormal")
	
	--enabled
		g:NewLabel (frame14, _, "$parentAttributeEnabledLabel", "attributeEnabledLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ENABLED"], "GameFontHighlightLeft")
		g:NewSwitch (frame14, _, "$parentAttributeEnabledSwitch", "attributeEnabledSwitch", 60, 20, nil, nil, instance.attribute_text.enabled)
		frame14.attributeEnabledSwitch:SetPoint ("left", frame14.attributeEnabledLabel, "right", 2)
		frame14.attributeEnabledSwitch.OnSwitch = function (self, instance, value)
			instance:AttributeMenu (value)
		end
		window:CreateLineBackground (frame14, "attributeEnabledSwitch", "attributeEnabledLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ENABLED_DESC"])
	
	--anchors
		g:NewLabel (frame14, _, "$parentAttributeAnchorXLabel", "attributeAnchorXLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORX"], "GameFontHighlightLeft")
		g:NewLabel (frame14, _, "$parentAttributeAnchorYLabel", "attributeAnchorYLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORY"], "GameFontHighlightLeft")
		local s = g:NewSlider (frame14, _, "$parentAttributeAnchorXSlider", "attributeAnchorXSlider", SLIDER_WIDTH, 20, -20, 300, 1, instance.attribute_text.anchor [1])
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)
		local s = g:NewSlider (frame14, _, "$parentAttributeAnchorYSlider", "attributeAnchorYSlider", SLIDER_WIDTH, 20, -100, 50, 1, instance.attribute_text.anchor [2])
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)
		
		frame14.attributeAnchorXSlider:SetPoint ("left", frame14.attributeAnchorXLabel, "right", 2)
		frame14.attributeAnchorYSlider:SetPoint ("left", frame14.attributeAnchorYLabel, "right", 2)
		
		frame14.attributeAnchorXSlider:SetHook ("OnValueChange", function (self, instance, amount) 
			instance:AttributeMenu (nil, amount)
		end)
		frame14.attributeAnchorYSlider:SetHook ("OnValueChange", function (self, instance, amount) 
			instance:AttributeMenu (nil, nil, amount)
		end)
		
		window:CreateLineBackground (frame14, "attributeAnchorXSlider", "attributeAnchorXLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORX_DESC"])
		window:CreateLineBackground (frame14, "attributeAnchorYSlider", "attributeAnchorYLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORY_DESC"])
		
	--font
		local on_select_attribute_font = function (self, instance, fontName)
			instance:AttributeMenu (nil, nil, nil, fontName)
		end

		local build_font_menu = function() 
			local fonts = {}
			for name, fontPath in pairs (SharedMedia:HashTable ("font")) do 
				fonts [#fonts+1] = {value = name, label = name, onclick = on_select_attribute_font, font = fontPath, descfont = name, desc = "Our thoughts strayed constantly\nAnd without boundary\nThe ringing of the division bell had began."}
			end
			table.sort (fonts, function (t1, t2) return t1.label < t2.label end)
			return fonts 
		end

		g:NewLabel (frame14, _, "$parentAttributeFontLabel", "attributeFontLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_FONT"], "GameFontHighlightLeft")
		local d = g:NewDropDown (frame14, _, "$parentAttributeFontDropdown", "attributeFontDropdown", DROPDOWN_WIDTH, 20, build_font_menu, instance.attribute_text.text_face)
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		frame14.attributeFontDropdown:SetPoint ("left", frame14.attributeFontLabel, "right", 2)
		
		window:CreateLineBackground (frame14, "attributeFontDropdown", "attributeFontLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_FONT_DESC"])
		
	--size
		g:NewLabel (frame14, _, "$parentAttributeTextSizeLabel", "attributeTextSizeLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTSIZE"], "GameFontHighlightLeft")
		local s = g:NewSlider (frame14, _, "$parentAttributeTextSizeSlider", "attributeTextSizeSlider", SLIDER_WIDTH, 20, 8, 25, 1, tonumber ( instance.attribute_text.text_size))
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)			
	
		frame14.attributeTextSizeSlider:SetPoint ("left", frame14.attributeTextSizeLabel, "right", 2)
	
		frame14.attributeTextSizeSlider:SetHook ("OnValueChange", function (self, instance, amount) 
			instance:AttributeMenu (nil, nil, nil, nil, amount)
		end)
		
		window:CreateLineBackground (frame14, "attributeTextSizeSlider", "attributeTextSizeLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTSIZE_DESC"])
		
	--color
		local attribute_text_color_callback = function (button, r, g, b, a)
			_G.DetailsOptionsWindow.instance:AttributeMenu (nil, nil, nil, nil, nil, {r, g, b, a})
		end
		g:NewColorPickButton (frame14, "$parentAttributeTextColorPick", "attributeTextColorPick", attribute_text_color_callback)
		g:NewLabel (frame14, _, "$parentAttributeTextColorLabel", "attributeTextColorLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTCOLOR"], "GameFontHighlightLeft")
		
		frame14.attributeTextColorPick:SetPoint ("left", frame14.attributeTextColorLabel, "right", 2, 0)

		window:CreateLineBackground (frame14, "attributeTextColorPick", "attributeTextColorLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTCOLOR_DESC"])
	
	--shadow
		g:NewLabel (frame14, _, "$parentAttributeShadowLabel", "attributeShadowLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SHADOW"], "GameFontHighlightLeft")
		g:NewSwitch (frame14, _, "$parentAttributeShadowSwitch", "attributeShadowSwitch", 60, 20, nil, nil, instance.attribute_text.shadow)
		frame14.attributeShadowSwitch:SetPoint ("left", frame14.attributeShadowLabel, "right", 2)
		frame14.attributeShadowSwitch.OnSwitch = function (self, instance, value)
			instance:AttributeMenu (nil, nil, nil, nil, nil, nil, nil, value)
		end
		window:CreateLineBackground (frame14, "attributeShadowSwitch", "attributeShadowLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SHADOW_DESC"])
	
	--side
		local side_switch_func = function (slider, value) if (value == 2) then return false elseif (value == 1) then return true end end
		local side_return_func = function (slider, value) if (value) then return 1 else return 2 end end
		
		g:NewLabel (frame14, _, "$parentAttributeSideLabel", "attributeSideLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SIDE"], "GameFontHighlightLeft")
		g:NewSwitch (frame14, _, "$parentAttributeSideSwitch", "attributeSideSwitch", 80, 20, "bottom", "top", instance.attribute_text.side, nil, side_switch_func, side_return_func)
		frame14.attributeSideSwitch:SetPoint ("left", frame14.attributeSideLabel, "right", 2)
		frame14.attributeSideSwitch.OnSwitch = function (self, instance, value)
			instance:AttributeMenu (nil, nil, nil, nil, nil, nil, value)
		end
		--frame14.attributeSideSwitch:SetThumbSize (50)
		window:CreateLineBackground (frame14, "attributeSideSwitch", "attributeSideLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SIDE_DESC"])

	--frame14.attributeLabel:SetPoint (10, -205)
	titulo_attributetext:SetPoint (10, -10)
	titulo_attributetext_desc:SetPoint (10, -30)
	frame14.attributeEnabledLabel:SetPoint (10, -70)
	frame14.attributeAnchorXLabel:SetPoint (10, -95)
	frame14.attributeAnchorYLabel:SetPoint (10, -120)
	frame14.attributeFontLabel:SetPoint (10, -145)
	frame14.attributeTextSizeLabel:SetPoint (10, -170)
	frame14.attributeTextColorLabel:SetPoint (10, -195)
	frame14.attributeShadowLabel:SetPoint (10, -220)
	frame14.attributeSideLabel:SetPoint (10, -245)
	
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- General Settings - Display ~1 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function window:CreateFrame1()

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
		g:NewImage (frame1, nil, 128, 64, nil, nil, "avatarPreview", "$parentAvatarPreviewTexture")
		g:NewImage (frame1, nil, 275, 60, nil, nil, "avatarPreview2", "$parentAvatarPreviewTexture2")
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
		local s = g:NewSlider (frame1, _, "$parentSlider", "segmentsSlider", SLIDER_WIDTH, 20, 1, 25, 1, _detalhes.segments_amount)
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)
		
		frame1.segmentsSlider:SetPoint ("left", frame1.segmentsLabel, "right", 2, -1)
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
		local s = g:NewSlider (frame1, _, "$parentSliderMaxInstances", "maxInstancesSlider", SLIDER_WIDTH, 20, 3, 30, 1, _detalhes.instances_amount) -- min, max, step, defaultv
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)
		
		frame1.maxInstancesSlider:SetPoint ("left", frame1.maxInstancesLabel, "right", 2, -1)
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
			
			_detalhes.atributo_damage:UpdateSelectedToKFunction()
			_detalhes.atributo_heal:UpdateSelectedToKFunction()
			_detalhes.atributo_energy:UpdateSelectedToKFunction()
			_detalhes.atributo_misc:UpdateSelectedToKFunction()
			
			_detalhes:AtualizaGumpPrincipal (-1, true)
		end
		local icon = [[Interface\COMMON\mini-hourglass]]
		local iconcolor = {1, 1, 1, .5}
		local abbreviationOptions = {
			{value = 1, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_NONE"], desc = "Example: 305.500 -> 305500", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor}, --, desc = ""
			{value = 2, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK"], desc = "Example: 305.500 -> 305.5K", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor}, --, desc = ""
			{value = 3, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK2"], desc = "Example: 305.500 -> 305K", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor}, --, desc = ""
			{value = 4, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK0"], desc = "Example: 25.305.500 -> 25M", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor}, --, desc = ""
			{value = 5, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOKMIN"], desc = "Example: 305.500 -> 305.5k", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor}, --, desc = ""
			{value = 6, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK2MIN"], desc = "Example: 305.500 -> 305k", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor}, --, desc = ""
			{value = 7, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK0MIN"], desc = "Example: 25.305.500 -> 25m", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor} --, desc = ""
		}
		local buildAbbreviationMenu = function()
			return abbreviationOptions
		end
		
		local d = g:NewDropDown (frame1, _, "$parentAbbreviateDropdown", "dpsAbbreviateDropdown", 160, 20, buildAbbreviationMenu, _detalhes.ps_abbreviation) -- func, default
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
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
		frame1.avatarPreview2:SetPoint (-8, -109)
		frame1.avatarNickname:SetPoint (100, -142)

		local avatar = NickTag:GetNicknameAvatar (UnitGUID ("player"), NICKTAG_DEFAULT_AVATAR, true)
		local background, cords, color = NickTag:GetNicknameBackground (UnitGUID ("player"), NICKTAG_DEFAULT_BACKGROUND, NICKTAG_DEFAULT_BACKGROUND_CORDS, {1, 1, 1, 1}, true)
		
		frame1.avatarPreview.texture = avatar
		frame1.avatarPreview2.texture = background
		frame1.avatarPreview2.texcoord = cords
		frame1.avatarPreview2:SetVertexColor (unpack (color))

	--> animate bars 
	
		g:NewLabel (frame1, _, "$parentAnimateLabel", "animateLabel", Loc ["STRING_OPTIONS_ANIMATEBARS"], "GameFontHighlightLeft")

		g:NewSwitch (frame1, _, "$parentAnimateSlider", "animateSlider", 60, 20, _, _, _detalhes.use_row_animations) -- ltext, rtext, defaultv
		frame1.animateSlider:SetPoint ("left",frame1.animateLabel, "right", 2, 0)
		frame1.animateSlider.info = Loc ["STRING_OPTIONS_ANIMATEBARS_DESC"]
		frame1.animateSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue (false, true)
			_detalhes.use_row_animations = value
		end
		
		window:create_line_background (frame1, frame1.animateLabel, frame1.animateSlider)
		frame1.animateSlider:SetHook ("OnEnter", background_on_enter)
		frame1.animateSlider:SetHook ("OnLeave", background_on_leave)
		
	--> update speed

		local s = g:NewSlider (frame1, _, "$parentSliderUpdateSpeed", "updatespeedSlider", SLIDER_WIDTH, 20, 0.3, 3, 0.1, _detalhes.update_speed, true)
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		
		g:NewLabel (frame1, _, "$parentUpdateSpeedLabel", "updatespeedLabel", Loc ["STRING_OPTIONS_WINDOWSPEED"], "GameFontHighlightLeft")
		--
		frame1.updatespeedSlider:SetPoint ("left", frame1.updatespeedLabel, "right", 2, -1)
		frame1.updatespeedSlider:SetThumbSize (50)
		frame1.updatespeedSlider.useDecimals = true
		local updateColor = function (slider, value)
			if (value < 1) then
				slider.amt:SetTextColor (1, value, 0)
			elseif (value > 1) then
				slider.amt:SetTextColor (-(value-3), 1, 0)
			else
				slider.amt:SetTextColor (1, 1, 0)
			end
		end
		frame1.updatespeedSlider:SetHook ("OnValueChange", function (self, _, amount) 
			_detalhes:CancelTimer (_detalhes.atualizador)
			_detalhes.update_speed = amount
			_detalhes.atualizador = _detalhes:ScheduleRepeatingTimer ("AtualizaGumpPrincipal", _detalhes.update_speed, -1)
			updateColor (self, amount)
		end)
		updateColor (frame1.updatespeedSlider, _detalhes.update_speed)
		
		frame1.updatespeedSlider.info = Loc ["STRING_OPTIONS_WINDOWSPEED_DESC"]

		window:create_line_background (frame1, frame1.updatespeedLabel, frame1.updatespeedSlider)
		frame1.updatespeedSlider:SetHook ("OnEnter", background_on_enter)
		frame1.updatespeedSlider:SetHook ("OnLeave", background_on_leave)	
		
	--> anchors
	
		local w_start = 10
	
		titulo_display:SetPoint (10, -200)
		titulo_display_desc:SetPoint (10, -220)
		
		frame1.animateLabel:SetPoint (w_start, -260)
		frame1.updatespeedLabel:SetPoint (w_start, -285)
		
		frame1.segmentsLabel:SetPoint (w_start, -310)
		frame1.scrollLabel:SetPoint (w_start, -335)
		frame1.maxInstancesLabel:SetPoint (w_start, -360)
		frame1.minimapLabel:SetPoint (w_start, -385)
		frame1.dpsAbbreviateLabel:SetPoint (w_start, -410)
		frame1.realmNameLabel:SetPoint (w_start, -435)
		
end		
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- General Settings - Combat ~2
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
function window:CreateFrame2()
	
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
			{value = 1, label = "Activity Time", onclick = onSelectTimeType, icon = "Interface\\Icons\\Achievement_Quests_Completed_Daily_08", iconcolor = {1, .9, .9}, texcoord = {0.078125, 0.921875, 0.078125, 0.921875}}, --, desc = ""
			{value = 2, label = "Effective Time", onclick = onSelectTimeType, icon = "Interface\\Icons\\Achievement_Quests_Completed_08"} --, desc = ""
		}
		local buildTimeTypeMenu = function()
			return timetypeOptions
		end
		local d = g:NewDropDown (frame2, _, "$parentTTDropdown", "timetypeDropdown", 160, 20, buildTimeTypeMenu, nil) -- func, default
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		frame2.timetypeDropdown:SetPoint ("left", frame2.timetypeLabel, "right", 2, 0)		
		
		frame2.timetypeDropdown.info = Loc ["STRING_OPTIONS_TIMEMEASURE_DESC"]

		window:create_line_background (frame2, frame2.timetypeLabel, frame2.timetypeDropdown)
		frame2.timetypeDropdown:SetHook ("OnEnter", background_on_enter)
		frame2.timetypeDropdown:SetHook ("OnLeave", background_on_leave)

	--> auto switch
		g:NewLabel (frame2, _, "$parentAutoSwitchLabel", "autoSwitchLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH"], "GameFontHighlightLeft")
		--
		local onSelectAutoSwitch = function (_, _, switch_to)
			if (switch_to == 0) then
				_G.DetailsOptionsWindow.instance.auto_switch_to = nil
				return
			end
			
			local selected = window.lastSwitchList [switch_to]
			
			if (selected [1] == "raid") then
				local name = _detalhes.RaidTables.Menu [selected [2]] [1]
				selected [2] = name
				_G.DetailsOptionsWindow.instance.auto_switch_to = selected
			else
				_G.DetailsOptionsWindow.instance.auto_switch_to = selected
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
		
		local d = g:NewDropDown (frame2, _, "$parentAutoSwitchDropdown", "autoSwitchDropdown", 160, 20, buildSwitchMenu, 1) -- func, default
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
		
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
		
		frame2.autoSwitchLabel:SetPoint (10, -135)
		frame2.autoCurrentLabel:SetPoint (10, -160) --auto current

end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- General Settings - Profiles ~13
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
function window:CreateFrame13()
	
	local frame13 = window.options [13][1]

	--> profiles title
		local titulo_profiles = g:NewLabel (frame13, _, "$parentTituloProfiles", "tituloProfilesLabel", Loc ["STRING_OPTIONS_PROFILES_TITLE"], "GameFontNormal", 16)
		local titulo_profiles_desc = g:NewLabel (frame13, _, "$parentTituloProfiles2", "tituloProfiles2Label", Loc ["STRING_OPTIONS_PROFILES_TITLE_DESC"], "GameFontNormal", 9, "white")
		titulo_profiles_desc.width = 320

	--> current profile
		local current_profile_label = g:NewLabel (frame13, _, "$parentCurrentProfileLabel1", "currentProfileLabel1",  Loc ["STRING_OPTIONS_PROFILES_CURRENT"], "GameFontHighlightLeft")
		local current_profile_label2 = g:NewLabel (frame13, _, "$parentCurrentProfileLabel2", "currentProfileLabel2",  "", "GameFontNormal")
		current_profile_label2:SetPoint ("left", current_profile_label, "right", 3, 0)
		
		local info_holder_frame = CreateFrame ("frame", nil, frame13.widget or frame13)
		info_holder_frame:SetPoint ("topleft", current_profile_label.widget, "topleft")
		info_holder_frame:SetPoint ("bottomright", current_profile_label2.widget, "bottomright")
		
		info_holder_frame.info = Loc ["STRING_OPTIONS_PROFILES_CURRENT_DESC"]
		window:create_line_background (frame13, current_profile_label.widget, info_holder_frame)
		info_holder_frame:SetScript ("OnEnter", background_on_enter)
		info_holder_frame:SetScript ("OnLeave", background_on_leave)
	
	--> select profile
		local profile_selected = function (_, instance, profile_name)
			_detalhes:ApplyProfile (profile_name)
			_detalhes:Msg ("Profile loaded:", profile_name)
			_detalhes:OpenOptionsWindow (_G.DetailsOptionsWindow.instance)
		end
		local build_profile_menu = function()
			local menu = {}
			
			for index, profile_name in ipairs (_detalhes:GetProfileList()) do 
				menu [#menu+1] = {value = profile_name, label = profile_name, onclick = profile_selected, icon = "Interface\\MINIMAP\\Vehicle-HammerGold-3"}
			end
			
			return menu
		end
		local select_profile_dropdown = g:NewDropDown (frame13, _, "$parentSelectProfileDropdown", "selectProfileDropdown", 160, 20, build_profile_menu, 1)	
		local d = select_profile_dropdown
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		local select_profile_label = g:NewLabel (frame13, _, "$parentSelectProfileLabel", "selectProfileLabel", Loc ["STRING_OPTIONS_PROFILES_SELECT"], "GameFontHighlightLeft")
		select_profile_dropdown:SetPoint ("left", select_profile_label, "right", 2, 0)
	
		select_profile_dropdown.info = Loc ["STRING_OPTIONS_PROFILES_SELECT_DESC"]
		window:create_line_background (frame13, select_profile_label, select_profile_dropdown)
		select_profile_dropdown:SetHook ("OnEnter", background_on_enter)
		select_profile_dropdown:SetHook ("OnLeave", background_on_leave)
	
	--> new profile
		local profile_name = g:NewTextEntry (frame13, _, "$parentProfileNameEntry", "profileNameEntry", 120, 20)
		local profile_name_label = g:NewLabel (frame13, _, "$parentProfileNameLabel", "profileNameLabel", Loc ["STRING_OPTIONS_PROFILES_CREATE"], "GameFontHighlightLeft")
		profile_name:SetPoint ("left", profile_name_label, "right", 2, 0)
		
		local create_profile = function()
			local text = profile_name:GetText()
			if (text == "") then
				return _detalhes:Msg ("Name field is empty.")
			end
			
			local new_profile = _detalhes:CreateProfile (text)
			if (new_profile) then
				_detalhes:ApplyProfile (text)
				_detalhes:OpenOptionsWindow (_G.DetailsOptionsWindow.instance)
			else
				return _detalhes:Msg ("Profile not created.")
			end
		end
		local profile_create_button = g:NewButton (frame13, _, "$parentProfileCreateButton", "profileCreateButton", 50, 19, create_profile, nil, nil, nil, Loc ["STRING_OPTIONS_SAVELOAD_SAVE"])
		profile_create_button:InstallCustomTexture()
		profile_create_button:SetPoint ("left", profile_name, "right", 2, 0)
		
		profile_name.info = Loc ["STRING_OPTIONS_PROFILES_CREATE_DESC"]
		window:create_line_background (frame13, profile_name_label, profile_name)
		profile_name:SetHook ("OnEnter", background_on_enter)
		profile_name:SetHook ("OnLeave", background_on_leave)
	
	
	--> copy profile
		local profile_selectedCopy = function (_, instance, profile_name)
			--copiar o profile
			local current_instance = _G.DetailsOptionsWindow.instance
			_detalhes:ApplyProfile (profile_name, nil, true)
			_detalhes:OpenOptionsWindow (current_instance)
		end
		local build_copy_menu = function()
			local menu = {}
			
			for index, profile_name in ipairs (_detalhes:GetProfileList()) do 
				menu [#menu+1] = {value = profile_name, label = profile_name, onclick = profile_selectedCopy, icon = "Interface\\MINIMAP\\Vehicle-HammerGold-2"}
			end
			
			return menu
		end
		local select_profileCopy_dropdown = g:NewDropDown (frame13, _, "$parentSelectProfileCopyDropdown", "selectProfileCopyDropdown", 160, 20, build_copy_menu, 1)	
		local d = select_profileCopy_dropdown
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		local select_profileCopy_label = g:NewLabel (frame13, _, "$parentSelectProfileCopyLabel", "selectProfileCopyLabel", Loc ["STRING_OPTIONS_PROFILES_COPY"], "GameFontHighlightLeft")
		select_profileCopy_dropdown:SetPoint ("left", select_profileCopy_label, "right", 2, 0)
	
		select_profileCopy_dropdown.info = Loc ["STRING_OPTIONS_PROFILES_COPY_DESC"]
		window:create_line_background (frame13, select_profileCopy_label, select_profileCopy_dropdown)
		select_profileCopy_dropdown:SetHook ("OnEnter", background_on_enter)
		select_profileCopy_dropdown:SetHook ("OnLeave", background_on_leave)
		
	--> erase profile
		local profile_selectedErase = function (_, instance, profile_name)
			local current_instance = _G.DetailsOptionsWindow.instance
			_detalhes:EraseProfile (profile_name)
			_detalhes:OpenOptionsWindow (current_instance)
		end
		local build_erase_menu = function()
			local menu = {}
			
			for index, profile_name in ipairs (_detalhes:GetProfileList()) do 
				menu [#menu+1] = {value = profile_name, label = profile_name, onclick = profile_selectedErase, icon = "Interface\\MINIMAP\\Vehicle-HammerGold-1", color = {1, 1, 1}, iconcolor = {1, .90, .90}}
			end
			
			return menu
		end
		local select_profileErase_dropdown = g:NewDropDown (frame13, _, "$parentSelectProfileEraseDropdown", "selectProfileEraseDropdown", 160, 20, build_erase_menu, 1)	
		local d = select_profileErase_dropdown
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		local select_profileErase_label = g:NewLabel (frame13, _, "$parentSelectProfileEraseLabel", "selectProfileLabel", Loc ["STRING_OPTIONS_PROFILES_ERASE"], "GameFontHighlightLeft")
		select_profileErase_dropdown:SetPoint ("left", select_profileErase_label, "right", 2, 0)
	
		select_profileErase_dropdown.info = Loc ["STRING_OPTIONS_PROFILES_ERASE_DESC"]
		window:create_line_background (frame13, select_profileErase_label, select_profileErase_dropdown)
		select_profileErase_dropdown:SetHook ("OnEnter", background_on_enter)
		select_profileErase_dropdown:SetHook ("OnLeave", background_on_leave)
		
	--> reset profile
	
		local reset_profile = function()
			local current_instance = _G.DetailsOptionsWindow.instance
			_detalhes:ResetProfile (_detalhes:GetCurrentProfileName())
			_detalhes:OpenOptionsWindow (current_instance)
		end
		
		local profile_reset_button = g:NewButton (frame13, _, "$parentProfileResetButton", "profileResetButton", 128, 19, reset_profile, nil, nil, nil, Loc ["STRING_OPTIONS_PROFILES_RESET"])
		profile_reset_button:InstallCustomTexture()
		
		local hiddenlabel = g:NewLabel (frame13, _, "$parentProfileResetButtonLabel", "profileResetButtonLabel", "", "GameFontHighlightLeft")
		hiddenlabel:SetPoint ("left", profile_reset_button, "left")
		
		profile_reset_button.info = Loc ["STRING_OPTIONS_PROFILES_RESET_DESC"]
		window:create_line_background (frame13, hiddenlabel, profile_reset_button)
		profile_reset_button:SetHook ("OnEnter", background_on_enter)
		profile_reset_button:SetHook ("OnLeave", background_on_leave)
		
		profile_reset_button.button.texture:SetVertexColor (1, .8, 0)

	--> anchors
		titulo_profiles:SetPoint (10, -10)
		titulo_profiles_desc:SetPoint (10, -30)
		
		current_profile_label:SetPoint (10, -90)
		select_profile_label:SetPoint (10, -125)
		profile_name_label:SetPoint (10, -150)
		select_profileCopy_label:SetPoint (10, -185)
		select_profileErase_label:SetPoint (10, -210)
		profile_reset_button:SetPoint (10, -245)
		
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Skin ~3
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
function window:CreateFrame3()
	
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
			_detalhes:OpenOptionsWindow (_G.DetailsOptionsWindow.instance)
			
		end
		_detalhes.loadStyleFunc = loadStyle 
	
		local resetToDefaults = function()
			loadStyle (nil, _G.DetailsOptionsWindow.instance, _detalhes.instance_defaults)
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
		local d = g:NewDropDown (frame3, _, "$parentSkinDropdown", "skinDropdown", 160, 20, buildSkinMenu, 1)	
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
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
			
			for key, value in pairs (_G.DetailsOptionsWindow.instance) do 
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
			local current_instance = _G.DetailsOptionsWindow.instance
			
			for _, this_instance in ipairs (_detalhes.tabela_instancias) do 
				if (this_instance.meu_id ~= _G.DetailsOptionsWindow.instance.meu_id) then
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
			_G.DetailsOptionsWindow.instance.skin = ""
			_G.DetailsOptionsWindow.instance:ChangeSkin (skin)
			
			--> overwrite all instance parameters with saved ones
			for key, value in pairs (style) do
				if (key ~= "skin") then
					if (type (value) == "table") then
						_G.DetailsOptionsWindow.instance [key] = table_deepcopy (value)
					else
						_G.DetailsOptionsWindow.instance [key] = value
					end
				end
			end
			
			--> apply all changed attributes
			_G.DetailsOptionsWindow.instance:ChangeSkin()
			
			--> reload options panel
			_detalhes:OpenOptionsWindow (_G.DetailsOptionsWindow.instance)
		end

		local loadtable = {}
		local buildCustomSkinMenu = function()
			table.wipe (loadtable)
			for index, _table in ipairs (_detalhes.savedStyles) do
				tinsert (loadtable, {value = index, label = _table.name, onclick = onSelectCustomSkin, icon = "Interface\\GossipFrame\\TabardGossipIcon", iconcolor = {.7, .7, .5, 1}})
			end
			return loadtable
		end
		
		local d = g:NewDropDown (frame3, _, "$parentCustomSkinLoadDropdown", "customSkinSelectDropdown", 160, 20, buildCustomSkinMenu, nil) -- func, default
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
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
		
		local d = g:NewDropDown (frame3, _, "$parentCustomSkinRemoveDropdown", "customSkinSelectToRemoveDropdown", 160, 20, buildCustomSkinToEraseMenu, nil) -- func, default
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
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
		
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Row ~4
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function window:CreateFrame4()

	local frame4 = window.options [4][1]

	--> bars general
		local titulo_bars = g:NewLabel (frame4, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_BARS"], "GameFontNormal", 16)
		local titulo_bars_desc = g:NewLabel (frame4, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_BARS_DESC"], "GameFontNormal", 9, "white")
		titulo_bars_desc.width = 320
	
	--> bar background color
	
		local rowcolorbackground_callback = function (button, r, g, b, a)
			_G.DetailsOptionsWindow.instance:SetBarSettings (nil, nil, nil, nil, nil, nil, {r, g, b, a})
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
		local s = g:NewSlider (frame4, _, "$parentSliderRowHeight", "rowHeightSlider", SLIDER_WIDTH, 20, 10, 30, 1, tonumber (instance.row_info.height))
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)

	--> row texture color
	
		local rowcolor_callback = function (button, r, g, b, a)
			_G.DetailsOptionsWindow.instance:SetBarSettings (nil, nil, nil, {r, g, b})
			_G.DetailsOptionsWindow.instance.row_info.alpha = a
			_G.DetailsOptionsWindow.instance:SetBarSettings (nil, nil, nil, nil, nil, nil, nil, a)
		end
		g:NewColorPickButton (frame4, "$parentRowColorPick", "rowColorPick", rowcolor_callback)
		g:NewLabel (frame4, _, "$parentRowColorPickLabel", "rowPickColorLabel", Loc ["STRING_OPTIONS_TEXT_ROWCOLOR2"], "GameFontHighlightLeft")
		frame4.rowColorPick:SetPoint ("left", frame4.rowPickColorLabel, "right", 2, 0)

		frame4.rowColorPick.info = Loc ["STRING_OPTIONS_BAR_COLOR_DESC"]
		window:create_line_background (frame4, frame4.rowPickColorLabel, frame4.rowColorPick)
		frame4.rowColorPick:SetHook ("OnEnter", background_on_enter)
		frame4.rowColorPick:SetHook ("OnLeave", background_on_leave)

		--> bar grow direction
			local grow_switch_func = function (slider, value)
				if (value == 1) then
					return true
				elseif (value == 2) then
					return false
				end
			end
			local grow_return_func = function (slider, value)
				if (value) then
					return 1
				else
					return 2
				end
			end
		
			g:NewSwitch (frame4, _, "$parentBarGrowDirectionSlider", "barGrowDirectionSlider", 80, 20, Loc ["STRING_BOTTOM"], Loc ["STRING_TOP"], instance.bars_grow_direction, nil, grow_switch_func, grow_return_func)
			g:NewLabel (frame4, _, "$parentBarGrowDirectionLabel", "barGrowDirectionLabel", Loc ["STRING_OPTIONS_BARGROW_DIRECTION"], "GameFontHighlightLeft")

			frame4.barGrowDirectionSlider:SetPoint ("left", frame4.barGrowDirectionLabel, "right", 2)
			frame4.barGrowDirectionSlider.OnSwitch = function (self, instance, value)
				instance:SetBarGrowDirection (value)
			end
			frame4.barGrowDirectionSlider.thumb:SetSize (50, 12)
			
			frame4.barGrowDirectionSlider.info = Loc ["STRING_OPTIONS_BARGROW_DIRECTION_DESC"]
			window:create_line_background (frame4, frame4.barGrowDirectionLabel, frame4.barGrowDirectionSlider)
			frame4.barGrowDirectionSlider:SetHook ("OnEnter", background_on_enter)
			frame4.barGrowDirectionSlider:SetHook ("OnLeave", background_on_leave)
			
		-- bar sort direction
		
			g:NewSwitch (frame4, _, "$parentBarSortDirectionSlider", "barSortDirectionSlider", 80, 20, Loc ["STRING_BOTTOM"], Loc ["STRING_TOP"], instance.bars_sort_direction, nil, grow_switch_func, grow_return_func)
			g:NewLabel (frame4, _, "$parentBarSortDirectionLabel", "barSortDirectionLabel", Loc ["STRING_OPTIONS_BARSORT_DIRECTION"], "GameFontHighlightLeft")

			frame4.barSortDirectionSlider:SetPoint ("left", frame4.barSortDirectionLabel, "right", 2)
			frame4.barSortDirectionSlider.OnSwitch = function (self, instance, value)
				instance.bars_sort_direction = value
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
		g:NewLabel (frame4, _, "$parentIconsAnchor", "rowIconsLabel", "Icons", "GameFontNormal")
	
		--alpha
		g:NewLabel (frame4, _, "$parentRowAlphaLabel", "rowAlphaLabel", "Alpha", "GameFontHighlightLeft")
		local s = g:NewSlider (frame4, _, "$parentRowAlphaSlider", "rowAlphaSlider", SLIDER_WIDTH, 20, 0.02, 1, 0.02, instance.row_info.alpha, true)
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)	
		
		frame4.rowAlphaSlider:SetPoint ("left", frame4.rowAlphaLabel, "right", 2, 0)
		frame4.rowAlphaSlider.useDecimals = true
		frame4.rowAlphaSlider:SetHook ("OnValueChange", function (self, instance, amount)
			self.amt:SetText (string.format ("%.2f", amount))
			instance:SetBarSettings (nil, nil, nil, nil, nil, nil, nil, amount)
			return true
		end)
		frame4.rowAlphaSlider.thumb:SetSize (30+(120*0.2)+2, 20*1.2)

		frame4.rowAlphaSlider.info = "Change the alpha of the row"
		window:create_line_background (frame4, frame4.rowAlphaLabel, frame4.rowAlphaSlider)
		frame4.rowAlphaSlider:SetHook ("OnEnter", background_on_enter)
		frame4.rowAlphaSlider:SetHook ("OnLeave", background_on_leave)
	
		-- texture
		local onSelectTexture = function (_, instance, textureName)
			instance:SetBarSettings (nil, textureName)
		end

		local buildTextureMenu = function() 
			local textures = SharedMedia:HashTable ("statusbar")
			local texTable = {}
			for name, texturePath in pairs (textures) do 
				texTable[#texTable+1] = {value = name, label = name, statusbar = texturePath,  onclick = onSelectTexture}
			end
			table.sort (texTable, function (t1, t2) return t1.label < t2.label end)
			return texTable 
		end
		
		local d = g:NewDropDown (frame4, _, "$parentTextureDropdown", "textureDropdown", DROPDOWN_WIDTH, 20, buildTextureMenu, nil)			
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		g:NewLabel (frame4, _, "$parentTextureLabel", "textureLabel", Loc ["STRING_OPTIONS_BAR_TEXTURE"], "GameFontHighlightLeft")
		--
		frame4.textureDropdown:SetPoint ("left", frame4.textureLabel, "right", 2)
		
		frame4.textureDropdown.info = Loc ["STRING_OPTIONS_BAR_TEXTURE_DESC"]
		window:create_line_background (frame4, frame4.textureLabel, frame4.textureDropdown)
		frame4.textureDropdown:SetHook ("OnEnter", background_on_enter)
		frame4.textureDropdown:SetHook ("OnLeave", background_on_leave)
		
		-- background texture

		--> bar background
		local onSelectTextureBackground = function (_, instance, textureName)
			instance:SetBarSettings (nil, nil, nil, nil, textureName)
		end

		local buildTextureMenu2 = function() 
			local textures2 = SharedMedia:HashTable ("statusbar")
			local texTable2 = {}
			for name, texturePath in pairs (textures2) do 
				texTable2[#texTable2+1] = {value = name, label = name, statusbar = texturePath,  onclick = onSelectTextureBackground}
			end
			table.sort (texTable2, function (t1, t2) return t1.label < t2.label end)
			return texTable2 
		end
		
		local d = g:NewDropDown (frame4, _, "$parentRowBackgroundTextureDropdown", "rowBackgroundDropdown", DROPDOWN_WIDTH, 20, buildTextureMenu2, nil)			
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
		
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
		g:NewTextEntry (frame4, _, "$parentIconFileEntry", "iconFileEntry", 240, 20)
		frame4.iconFileEntry:SetPoint ("left", frame4.iconFileLabel, "right", 2, 0)

		frame4.iconFileEntry.tooltip = "- Press escape to restore default value.\n- Leave empty to hide icons."
		frame4.iconFileEntry:SetHook ("OnEnterPressed", function()
			_G.DetailsOptionsWindow.instance:SetBarSettings (nil, nil, nil, nil, nil, nil, nil, nil, frame4.iconFileEntry.text)
		end)
		frame4.iconFileEntry:SetHook ("OnEscapePressed", function()
			frame4.iconFileEntry:SetText ([[Interface\AddOns\Details\images\classes_small]])
			frame4.iconFileEntry:ClearFocus()
			_G.DetailsOptionsWindow.instance:SetBarSettings (nil, nil, nil, nil, nil, nil, nil, nil, [[Interface\AddOns\Details\images\classes_small]])
			return true
		end)
		
		frame4.iconFileEntry.info = Loc ["STRING_OPTIONS_BAR_ICONFILE_DESC"]
		window:create_line_background (frame4, frame4.iconFileLabel, frame4.iconFileEntry)
		frame4.iconFileEntry:SetHook ("OnEnter", background_on_enter)
		frame4.iconFileEntry:SetHook ("OnLeave", background_on_leave)

		frame4.iconFileEntry.text = instance.row_info.icon_file
		
		g:NewButton (frame4, _, "$parentNoIconButton", "noIconButton", 20, 20, function()
			if (frame4.iconFileEntry.text == "") then
				frame4.iconFileEntry.text = [[Interface\AddOns\Details\images\classes_small]]
				frame4.iconFileEntry:PressEnter()
			else
				frame4.iconFileEntry.text = ""
				frame4.iconFileEntry:PressEnter()
			end
		end)
		frame4.noIconButton:SetPoint ("left", frame4.iconFileEntry, "right", 2, 1)
		frame4.noIconButton:SetNormalTexture ([[Interface\Buttons\UI-GroupLoot-Pass-Down]])
		frame4.noIconButton:SetHighlightTexture ([[Interface\Buttons\UI-GROUPLOOT-PASS-HIGHLIGHT]])
		frame4.noIconButton:SetPushedTexture ([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
		frame4.noIconButton.tooltip = "Clear icon file."

		--bar start at
		g:NewSwitch (frame4, _, "$parentBarStartSlider", "barStartSlider", 60, 20, nil, nil, instance.row_info.start_after_icon)
		g:NewLabel (frame4, _, "$parentBarStartLabel", "barStartLabel", Loc ["STRING_OPTIONS_BARSTART"], "GameFontHighlightLeft")

		frame4.barStartSlider:SetPoint ("left", frame4.barStartLabel, "right", 2)
		frame4.barStartSlider.OnSwitch = function (self, instance, value)
			instance:SetBarSettings (nil, nil, nil, nil, nil, nil, nil, nil, nil, value)
		end
		
		frame4.barStartSlider.info = Loc ["STRING_OPTIONS_BARSTART_DESC"]
		window:create_line_background (frame4, frame4.barStartLabel, frame4.barStartSlider)
		frame4.barStartSlider:SetHook ("OnEnter", background_on_enter)
		frame4.barStartSlider:SetHook ("OnLeave", background_on_leave)
		
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
		
		frame4.rowIconsLabel:SetPoint (10, -405)
		frame4.iconFileLabel:SetPoint (10, -430)
		frame4.barStartLabel:SetPoint (10, -455)
		
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Texts ~5
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function window:CreateFrame5()

	local frame5 = window.options [5][1]
	
	--> bars text
		local titulo_texts = g:NewLabel (frame5, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_TEXT"], "GameFontNormal", 16)
		local titulo_texts_desc = g:NewLabel (frame5, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_TEXT_DESC"], "GameFontNormal", 9, "white")
		titulo_texts_desc.width = 320
	
	--> text color
		local textcolor_callback = function (button, r, g, b, a)
			_G.DetailsOptionsWindow.instance:SetBarTextSettings (nil, nil, {r, g, b, 1})
		end
		g:NewColorPickButton (frame5, "$parentFixedTextColor", "fixedTextColor", textcolor_callback, false)
		local fixedColorText = g:NewLabel (frame5, _, "$parentFixedTextColorLabel", "fixedTextColorLabel", Loc ["STRING_OPTIONS_TEXT_FIXEDCOLOR"], "GameFontHighlightLeft")
		frame5.fixedTextColor:SetPoint ("left", fixedColorText, "right", 2, 0)
	
	--> text size
		local s = g:NewSlider (frame5, _, "$parentSliderFontSize", "fonsizeSlider", SLIDER_WIDTH, 20, 8, 15, 1, tonumber (instance.row_info.font_size))
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)
		
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

	--> Text Fonts

		local onSelectFont = function (_, instance, fontName)
			instance:SetBarTextSettings (nil, fontName)
		end
		
		local buildFontMenu = function() 
			local fontObjects = SharedMedia:HashTable ("font")
			local fontTable = {}
			for name, fontPath in pairs (fontObjects) do 
				fontTable[#fontTable+1] = {value = name, label = name, onclick = onSelectFont, font = fontPath, descfont = name, desc = Loc ["STRING_MUSIC_DETAILS_ROBERTOCARLOS"]}
			end
			table.sort (fontTable, function (t1, t2) return t1.label < t2.label end)
			return fontTable 
		end
		
		local d = g:NewDropDown (frame5, _, "$parentFontDropdown", "fontDropdown", DROPDOWN_WIDTH, 20, buildFontMenu, nil)		
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		g:NewLabel (frame5, _, "$parentFontLabel", "fontLabel", Loc ["STRING_OPTIONS_TEXT_FONT"], "GameFontHighlightLeft")
		frame5.fontDropdown:SetPoint ("left", frame5.fontLabel, "right", 2)
		
		frame5.fontDropdown.info = Loc ["STRING_OPTIONS_TEXT_FONT_DESC"]
		window:create_line_background (frame5, frame5.fontLabel, frame5.fontDropdown)
		frame5.fontDropdown:SetHook ("OnEnter", background_on_enter)
		frame5.fontDropdown:SetHook ("OnLeave", background_on_leave)		

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
		
	--> right text by class color
		g:NewLabel (frame5, _, "$parentUseClassColorsRightText", "classColorsRightTextLabel", Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR"], "GameFontHighlightLeft")

		frame5.classColorsRightTextSlider:SetPoint ("left", frame5.classColorsRightTextLabel, "right", 2)
		frame5.classColorsRightTextSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, nil, value)
		end
		
		frame5.classColorsRightTextSlider.info = Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR_DESC"]
		window:create_line_background (frame5, frame5.classColorsRightTextLabel, frame5.classColorsRightTextSlider)
		frame5.classColorsRightTextSlider:SetHook ("OnEnter", background_on_enter)
		frame5.classColorsRightTextSlider:SetHook ("OnLeave", background_on_leave)
		
	--> left outline
		g:NewSwitch (frame5, _, "$parentTextLeftOutlineSlider", "textLeftOutlineSlider", 60, 20, _, _, instance.row_info.textL_outline)
		
		
		g:NewLabel (frame5, _, "$parentTextLeftOutlineLabel", "textLeftOutlineLabel", Loc ["STRING_OPTIONS_TEXT_LOUTILINE"], "GameFontHighlightLeft")
		
		frame5.textLeftOutlineSlider:SetPoint ("left", frame5.textLeftOutlineLabel, "right", 2)
		frame5.textLeftOutlineSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, nil, nil, value)
		end

		frame5.textLeftOutlineSlider.info = Loc ["STRING_OPTIONS_TEXT_LOUTILINE_DESC"]
		window:create_line_background (frame5, frame5.textLeftOutlineLabel, frame5.textLeftOutlineSlider)
		frame5.textLeftOutlineSlider:SetHook ("OnEnter", background_on_enter)
		frame5.textLeftOutlineSlider:SetHook ("OnLeave", background_on_leave)
		
	--> right outline
		g:NewSwitch (frame5, _, "$parentTextRightOutlineSlider", "textRightOutlineSlider", 60, 20, _, _, instance.row_info.textR_outline)
		g:NewLabel (frame5, _, "$parentTextRightOutlineLabel", "textRightOutlineLabel", Loc ["STRING_OPTIONS_TEXT_ROUTILINE"], "GameFontHighlightLeft")
		
		frame5.textRightOutlineSlider:SetPoint ("left", frame5.textRightOutlineLabel, "right", 2)
		frame5.textRightOutlineSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, nil, nil, nil, value)
		end
		
		frame5.textRightOutlineSlider.info = Loc ["STRING_OPTIONS_TEXT_ROUTILINE_DESC"]
		window:create_line_background (frame5, frame5.textRightOutlineLabel, frame5.textRightOutlineSlider)
		frame5.textRightOutlineSlider:SetHook ("OnEnter", background_on_enter)
		frame5.textRightOutlineSlider:SetHook ("OnLeave", background_on_leave)
	
	--> right text customization
	
		g:NewLabel (frame5, _, "$parentCutomRightTextLabel", "cutomRightTextLabel", Loc ["STRING_OPTIONS_BARRIGHTTEXTCUSTOM"], "GameFontHighlightLeft")
		g:NewSwitch (frame5, _, "$parentCutomRightTextSlider", "cutomRightTextSlider", 60, 20, _, _, instance.row_info.textR_enable_custom_text)

		frame5.cutomRightTextSlider:SetPoint ("left", frame5.cutomRightTextLabel, "right", 2)
		frame5.cutomRightTextSlider.OnSwitch = function (self, instance, value)
			_G.DetailsOptionsWindow.instance:SetBarTextSettings (nil, nil, nil, nil, nil, nil, nil, value)
		end
		
		frame5.cutomRightTextSlider.info = Loc ["STRING_OPTIONS_BARRIGHTTEXTCUSTOM_DESC"]
		window:create_line_background (frame5, frame5.cutomRightTextLabel, frame5.cutomRightTextSlider)
		frame5.cutomRightTextSlider:SetHook ("OnEnter", background_on_enter)
		frame5.cutomRightTextSlider:SetHook ("OnLeave", background_on_leave)
		
		--text entry
		g:NewLabel (frame5, _, "$parentCutomRightText2Label", "cutomRightTextEntryLabel", Loc ["STRING_OPTIONS_BARRIGHTTEXTCUSTOM2"], "GameFontHighlightLeft")
		g:NewTextEntry (frame5, _, "$parentCutomRightTextEntry", "cutomRightTextEntry", 240, 20)
		frame5.cutomRightTextEntry:SetPoint ("left", frame5.cutomRightTextEntryLabel, "right", 2, 0)

		--frame5.cutomRightTextEntry.tooltip = "type the customized text"
		frame5.cutomRightTextEntry:SetHook ("OnTextChanged", function()
			if (not frame5.cutomRightTextEntry.text:find ("{func")) then
				_G.DetailsOptionsWindow.instance:SetBarTextSettings (nil, nil, nil, nil, nil, nil, nil, nil, frame5.cutomRightTextEntry.text)
			end
		end)
		
		frame5.cutomRightTextEntry:SetHook ("OnChar", function()
			if (frame5.cutomRightTextEntry.text:find ("{func")) then
				GameCooltip:Reset()
				GameCooltip:AddLine ("'func' keyword found, auto update disabled.")
				GameCooltip:Show (frame5.cutomRightTextEntry.widget)
			end
		end)

		frame5.cutomRightTextEntry:SetHook ("OnEnterPressed", function()
			_G.DetailsOptionsWindow.instance:SetBarTextSettings (nil, nil, nil, nil, nil, nil, nil, nil, frame5.cutomRightTextEntry.text)
		end)
		frame5.cutomRightTextEntry:SetHook ("OnEscapePressed", function()
			frame5.cutomRightTextEntry:ClearFocus()
			return true
		end)
		
		frame5.cutomRightTextEntry.info = Loc ["STRING_OPTIONS_BARRIGHTTEXTCUSTOM2_DESC"]
		window:create_line_background (frame5, frame5.cutomRightTextEntryLabel, frame5.cutomRightTextEntry)
		frame5.cutomRightTextEntry:SetHook ("OnEnter", background_on_enter)
		frame5.cutomRightTextEntry:SetHook ("OnLeave", background_on_leave)

		frame5.cutomRightTextEntry.text = instance.row_info.textR_custom_text
		
		g:NewButton (frame5, _, "$parentResetCustomRightTextButton", "customRightTextButton", 20, 20, function()
			frame5.cutomRightTextEntry.text = _detalhes.instance_defaults.row_info.textR_custom_text
			frame5.cutomRightTextEntry:PressEnter()
		end)
		frame5.customRightTextButton:SetPoint ("left", frame5.cutomRightTextEntry, "right", 2, 1)
		frame5.customRightTextButton:SetNormalTexture ([[Interface\Buttons\UI-GroupLoot-Pass-Down]])
		frame5.customRightTextButton:SetHighlightTexture ([[Interface\Buttons\UI-GROUPLOOT-PASS-HIGHLIGHT]])
		frame5.customRightTextButton:SetPushedTexture ([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
		frame5.customRightTextButton.tooltip = "Reset to Default"
	
	--> show total bar
		
		g:NewLabel (frame5, _, "$parentTotalBarLabel", "totalBarLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR"], "GameFontHighlightLeft")
		g:NewSwitch (frame5, _, "$parentTotalBarSlider", "totalBarSlider", 60, 20, _, _, instance.total_bar.enabled)

		frame5.totalBarSlider:SetPoint ("left", frame5.totalBarLabel, "right", 2)
		frame5.totalBarSlider.OnSwitch = function (self, instance, value)
			instance.total_bar.enabled = value
			instance:InstanceReset()
		end
		
		frame5.totalBarSlider.info = Loc ["STRING_OPTIONS_SHOW_TOTALBAR_DESC"]
		window:create_line_background (frame5, frame5.totalBarLabel, frame5.totalBarSlider)
		frame5.totalBarSlider:SetHook ("OnEnter", background_on_enter)
		frame5.totalBarSlider:SetHook ("OnLeave", background_on_leave)
		
	--> total bar color
			local totalbarcolor_callback = function (button, r, g, b, a)
				_G.DetailsOptionsWindow.instance.total_bar.color[1] = r
				_G.DetailsOptionsWindow.instance.total_bar.color[2] = g
				_G.DetailsOptionsWindow.instance.total_bar.color[3] = b
				_G.DetailsOptionsWindow.instance:InstanceReset()
			end
			g:NewColorPickButton (frame5, "$parentTotalBarColorPick", "totalBarColorPick", totalbarcolor_callback)
			g:NewLabel (frame5, _, "$parentTotalBarColorPickLabel", "totalBarPickColorLabel", Loc ["STRING_OPTIONS_COLOR"], "GameFontHighlightLeft")
			frame5.totalBarColorPick:SetPoint ("left", frame5.totalBarPickColorLabel, "right", 2, 0)

			frame5.totalBarColorPick.info = Loc ["STRING_OPTIONS_SHOW_TOTALBAR_COLOR_DESC"]
			window:create_line_background (frame5, frame5.totalBarPickColorLabel, frame5.totalBarColorPick)
			frame5.totalBarColorPick:SetHook ("OnEnter", background_on_enter)
			frame5.totalBarColorPick:SetHook ("OnLeave", background_on_leave)
		
	--> total bar only in group
		g:NewLabel (frame5, _, "$parentTotalBarOnlyInGroupLabel", "totalBarOnlyInGroupLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR_INGROUP"], "GameFontHighlightLeft")
		g:NewSwitch (frame5, _, "$parentTotalBarOnlyInGroupSlider", "totalBarOnlyInGroupSlider", 60, 20, _, _, instance.total_bar.only_in_group)

		frame5.totalBarOnlyInGroupSlider:SetPoint ("left", frame5.totalBarOnlyInGroupLabel, "right", 2)
		frame5.totalBarOnlyInGroupSlider.OnSwitch = function (self, instance, value)
			instance.total_bar.only_in_group = value
			instance:InstanceReset()
		end
		
		frame5.totalBarOnlyInGroupSlider.info = Loc ["STRING_OPTIONS_SHOW_TOTALBAR_INGROUP_DESC"]
		window:create_line_background (frame5, frame5.totalBarOnlyInGroupLabel, frame5.totalBarOnlyInGroupSlider)
		frame5.totalBarOnlyInGroupSlider:SetHook ("OnEnter", background_on_enter)
		frame5.totalBarOnlyInGroupSlider:SetHook ("OnLeave", background_on_leave)
		
	--> total bar icon
		local totalbar_pickicon_callback = function (texture)
			instance.total_bar.icon = texture
			frame5.totalBarIconTexture:SetTexture (texture)
			instance:InstanceReset()
		end
		local totalbar_pickicon = function()
			g:IconPick (totalbar_pickicon_callback)
		end
		g:NewLabel (frame5, _, "$parentTotalBarIconLabel", "totalBarIconLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR_ICON"], "GameFontHighlightLeft")
		g:NewImage (frame5, nil, 20, 20, nil, nil, "totalBarIconTexture", "$parentTotalBarIconTexture")
		g:NewButton (frame5, _, "$parentTotalBarIconButton", "totalBarIconButton", 20, 20, totalbar_pickicon)
		frame5.totalBarIconButton:InstallCustomTexture()
		frame5.totalBarIconButton:SetPoint ("left", frame5.totalBarIconLabel, "right", 2, 0)
		frame5.totalBarIconTexture:SetPoint ("left", frame5.totalBarIconLabel, "right", 2, 0)
		
		frame5.totalBarIconButton.info = Loc ["STRING_OPTIONS_SHOW_TOTALBAR_ICON_DESC"]
		window:create_line_background (frame5, frame5.totalBarIconLabel, frame5.totalBarIconButton)
		frame5.totalBarIconButton:SetHook ("OnEnter", background_on_enter)
		frame5.totalBarIconButton:SetHook ("OnLeave", background_on_leave)
		
	--> anchors
		titulo_texts:SetPoint (10, -10)
		titulo_texts_desc:SetPoint (10, -30)
		
		frame5.fonsizeLabel:SetPoint (10, -70) --text size
		frame5.fontLabel:SetPoint (10, -95) --text fontface
		frame5.textLeftOutlineLabel:SetPoint (10, -120) --left outline
		frame5.textRightOutlineLabel:SetPoint (10, -145) --right outline
		frame5.classColorsLeftTextLabel:SetPoint (10, -170) --left color by class
		frame5.classColorsRightTextLabel:SetPoint (10, -195) --right color by class
		frame5.fixedTextColorLabel:SetPoint (10, -220)

		g:NewLabel (frame5, _, "$parentCustomRightTextAnchor", "customRightTextAnchorLabel", "Custom Right Text", "GameFontNormal")
		frame5.customRightTextAnchorLabel:SetPoint (10, -255)
		frame5.cutomRightTextLabel:SetPoint (10, -280)
		frame5.cutomRightTextEntryLabel:SetPoint (10, -305)
		
		g:NewLabel (frame5, _, "$parentTotalBarAnchor", "totalBarAnchorLabel", "Total Bar", "GameFontNormal")
		frame5.totalBarAnchorLabel:SetPoint (10, -340)
		frame5.totalBarIconLabel:SetPoint (10, -365)
		frame5.totalBarPickColorLabel:SetPoint (10, -390)
		frame5.totalBarLabel:SetPoint (10, -415)
		frame5.totalBarOnlyInGroupLabel:SetPoint (10, -440)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Window Settings ~6
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function window:CreateFrame6()

	local frame6 = window.options [6][1]

	--> window
		local titulo_instance = g:NewLabel (frame6, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_WINDOW_TITLE"], "GameFontNormal", 16)
		local titulo_instance_desc = g:NewLabel (frame6, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_WINDOW_TITLE_DESC"], "GameFontNormal", 9, "white")
		titulo_instance_desc.width = 320

	--> window color
		local windowcolor_callback = function (button, r, g, b, a)
			if (_G.DetailsOptionsWindow.instance.menu_alpha.enabled and a ~= _G.DetailsOptionsWindow.instance.color[4]) then
				_detalhes:Msg (Loc ["STRING_OPTIONS_MENU_ALPHAWARNING"])
				_G.DetailsOptionsWindow6StatusbarColorPick.MyObject:SetColor (r, g, b, _G.DetailsOptionsWindow.instance.menu_alpha.onleave)
				return _G.DetailsOptionsWindow.instance:InstanceColor (r, g, b, _G.DetailsOptionsWindow.instance.menu_alpha.onleave, nil, true)
			end
			_G.DetailsOptionsWindow6StatusbarColorPick.MyObject:SetColor (r, g, b, a)
			_G.DetailsOptionsWindow.instance:InstanceColor (r, g, b, a, nil, true)
		end
		g:NewColorPickButton (frame6, "$parentWindowColorPick", "windowColorPick", windowcolor_callback)
		g:NewLabel (frame6, _, "$parentWindowColorPickLabel", "windowPickColorLabel", Loc ["STRING_OPTIONS_INSTANCE_COLOR"], "GameFontHighlightLeft")
		frame6.windowColorPick:SetPoint ("left", frame6.windowPickColorLabel, "right", 2, 0)

		frame6.windowColorPick.info = Loc ["STRING_OPTIONS_INSTANCE_COLOR_DESC"]
		window:create_line_background (frame6, frame6.windowPickColorLabel, frame6.windowColorPick)
		frame6.windowColorPick:SetHook ("OnEnter", background_on_enter)
		frame6.windowColorPick:SetHook ("OnLeave", background_on_leave)

	--> Transparency
		local s = g:NewSlider (frame6, _, "$parentAlphaSlider", "alphaSlider", SLIDER_WIDTH, 20, 0.02, 1, 0.02, instance.bg_alpha, true)
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)
	
	--> background color
	
		local windowbackgroundcolor_callback = function (button, r, g, b, a)
			_G.DetailsOptionsWindow.instance:SetBackgroundColor (r, g, b)
			_G.DetailsOptionsWindow.instance:SetBackgroundAlpha (a)
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

			local grow_switch_func = function (slider, value)
				if (value == 1) then
					return true
				elseif (value == 2) then
					return false
				end
			end
			local grow_return_func = function (slider, value)
				if (value) then
					return 1
				else
					return 2
				end
			end		
		
			g:NewSwitch (frame6, _, "$parentStretchAnchorSlider", "stretchAnchorSlider", 80, 20, Loc ["STRING_BOTTOM"], Loc ["STRING_TOP"], instance.toolbar_side, nil, grow_switch_func, grow_return_func)
			g:NewLabel (frame6, _, "$parentStretchAnchorLabel", "stretchAnchorLabel", Loc ["STRING_OPTIONS_STRETCH"], "GameFontHighlightLeft")

			frame6.stretchAnchorSlider:SetPoint ("left", frame6.stretchAnchorLabel, "right", 2)
			frame6.stretchAnchorSlider.OnSwitch = function (self, instance, value)
				instance:StretchButtonAnchor (value)
			end
			frame6.stretchAnchorSlider.thumb:SetSize (40, 12)
			
			frame6.stretchAnchorSlider.info = Loc ["STRING_OPTIONS_STRETCH_DESC"]
			window:create_line_background (frame6, frame6.stretchAnchorLabel, frame6.stretchAnchorSlider)
			frame6.stretchAnchorSlider:SetHook ("OnEnter", background_on_enter)
			frame6.stretchAnchorSlider:SetHook ("OnLeave", background_on_leave)		
		
		-- instance toolbar side
			g:NewSwitch (frame6, _, "$parentInstanceToolbarSideSlider", "instanceToolbarSideSlider", 80, 20, Loc ["STRING_BOTTOM"], Loc ["STRING_TOP"], instance.toolbar_side, nil, grow_switch_func, grow_return_func)
			g:NewLabel (frame6, _, "$parentInstanceToolbarSideLabel", "instanceToolbarSideLabel", Loc ["STRING_OPTIONS_TOOLBARSIDE"], "GameFontHighlightLeft")
			
			frame6.instanceToolbarSideSlider:SetPoint ("left", frame6.instanceToolbarSideLabel, "right", 2)
			frame6.instanceToolbarSideSlider.OnSwitch = function (self, instance, value)
				instance.toolbar_side = value
				instance:ToolbarSide (side)
				
			end
			frame6.instanceToolbarSideSlider.thumb:SetSize (50, 12)
			
			frame6.instanceToolbarSideSlider.info = Loc ["STRING_OPTIONS_TOOLBARSIDE_DESC"]
			window:create_line_background (frame6, frame6.instanceToolbarSideLabel, frame6.instanceToolbarSideSlider)
			frame6.instanceToolbarSideSlider:SetHook ("OnEnter", background_on_enter)
			frame6.instanceToolbarSideSlider:SetHook ("OnLeave", background_on_leave)		
			
	--> micro displays side
			g:NewSwitch (frame6, _, "$parentInstanceMicroDisplaysSideSlider", "instanceMicroDisplaysSideSlider", 80, 20, Loc ["STRING_BOTTOM"], Loc ["STRING_TOP"], instance.toolbar_side, nil, grow_switch_func, grow_return_func)
			g:NewLabel (frame6, _, "$parentInstanceMicroDisplaysSideLabel", "instanceMicroDisplaysSideLabel", Loc ["STRING_OPTIONS_MICRODISPLAYSSIDE"], "GameFontHighlightLeft")
			
			frame6.instanceMicroDisplaysSideSlider:SetPoint ("left", frame6.instanceMicroDisplaysSideLabel, "right", 2)
			frame6.instanceMicroDisplaysSideSlider.OnSwitch = function (self, instance, value)
				instance:MicroDisplaysSide (value, true)
			end
			frame6.instanceMicroDisplaysSideSlider.thumb:SetSize (50, 12)
			
			frame6.instanceMicroDisplaysSideSlider.info = Loc ["STRING_OPTIONS_MICRODISPLAYSSIDE_DESC"]
			window:create_line_background (frame6, frame6.instanceMicroDisplaysSideLabel, frame6.instanceMicroDisplaysSideSlider)
			frame6.instanceMicroDisplaysSideSlider:SetHook ("OnEnter", background_on_enter)
			frame6.instanceMicroDisplaysSideSlider:SetHook ("OnLeave", background_on_leave)	
	
	--> show side bars
		
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
			instance:BaseFrameSnap()
		end
		
		frame6.statusbarSlider.info = Loc ["STRING_OPTIONS_SHOW_STATUSBAR_DESC"]
		window:create_line_background (frame6, frame6.statusbarLabel, frame6.statusbarSlider)
		frame6.statusbarSlider:SetHook ("OnEnter", background_on_enter)
		frame6.statusbarSlider:SetHook ("OnLeave", background_on_leave)
		
		--> backdrop texture
		local onBackdropSelect = function (_, instance, backdropName)
			instance:SetBackdropTexture (backdropName)
		end
		local backdropObjects = SharedMedia:HashTable ("background")
		local backdropTable = {}
		for name, backdropPath in pairs (backdropObjects) do 
			backdropTable[#backdropTable+1] = {value = name, label = name, onclick = onBackdropSelect}
		end
		local buildBackdropMenu = function() return backdropTable end
		
		local d = g:NewDropDown (frame6, _, "$parentBackdropDropdown", "backdropDropdown", DROPDOWN_WIDTH, 20, buildBackdropMenu, nil)		
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		g:NewLabel (frame6, _, "$parentBackdropLabel", "backdropLabel", Loc ["STRING_OPTIONS_INSTANCE_BACKDROP"], "GameFontHighlightLeft")
		frame6.backdropDropdown:SetPoint ("left", frame6.backdropLabel, "right", 2)
		
		frame6.backdropDropdown.info = Loc ["STRING_OPTIONS_INSTANCE_BACKDROP_DESC"]
		window:create_line_background (frame6, frame6.backdropLabel, frame6.backdropDropdown)
		frame6.backdropDropdown:SetHook ("OnEnter", background_on_enter)
		frame6.backdropDropdown:SetHook ("OnLeave", background_on_leave)
		
		--> frame strata
			local onStrataSelect = function (_, instance, strataName)
				instance:SetFrameStrata (strataName)
			end
			local strataTable = {
				{value = "LOW", label = "Low", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Green]] , texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
				{value = "MEDIUM", label = "Medium", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Yellow]] , texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
				{value = "HIGH", label = "High", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Red]] , texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
			}
			local buildStrataMenu = function() return strataTable end
			
			local d = g:NewDropDown (frame6, _, "$parentStrataDropdown", "strataDropdown", DROPDOWN_WIDTH, 20, buildStrataMenu, nil)		
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
			
			g:NewLabel (frame6, _, "$parentStrataLabel", "strataLabel", Loc ["STRING_OPTIONS_INSTANCE_STRATA"], "GameFontHighlightLeft")
			frame6.strataDropdown:SetPoint ("left", frame6.strataLabel, "right", 2)
			
			frame6.strataDropdown.info = Loc ["STRING_OPTIONS_INSTANCE_STRATA_DESC"]
			window:create_line_background (frame6, frame6.strataLabel, frame6.strataDropdown)
			frame6.strataDropdown:SetHook ("OnEnter", background_on_enter)
			frame6.strataDropdown:SetHook ("OnLeave", background_on_leave)
		
		

		--> statusbar color overwrite
			g:NewLabel (frame6, _, "$parentStatusbarLabelAnchor", "statusbarAnchorLabel", Loc ["STRING_OPTIONS_INSTANCE_STATUSBAR_ANCHOR"], "GameFontNormal")
		
			local statusbar_color_callback = function (button, r, g, b, a)
				--do something
				_G.DetailsOptionsWindow.instance:StatusBarColor (r, g, b, a)
			end
			g:NewColorPickButton (frame6, "$parentStatusbarColorPick", "statusbarColorPick", statusbar_color_callback)
			g:NewLabel (frame6, _, "$parentStatusbarColorLabel", "statusbarColorLabel", Loc ["STRING_OPTIONS_INSTANCE_STATUSBARCOLOR"], "GameFontHighlightLeft")
			frame6.statusbarColorPick:SetPoint ("left", frame6.statusbarColorLabel, "right", 2, 0)
			window:CreateLineBackground (frame6, "statusbarColorPick", "statusbarColorLabel", Loc ["STRING_OPTIONS_INSTANCE_STATUSBARCOLOR_DESC"])
			
		
		--anchors
		titulo_instance:SetPoint (10, -10)
		titulo_instance_desc:SetPoint (10, -30)
		
		frame6.windowPickColorLabel:SetPoint (10, -70) --window color
		--frame6.alphaLabel:SetPoint (10, -95) --background alpha
		frame6.windowBackgroundPickColorLabel:SetPoint (10, -95) --background color
		
		frame6.instanceToolbarSideLabel:SetPoint (10, -120)
		frame6.sideBarsLabel:SetPoint (10, -145) --borders
		frame6.stretchAnchorLabel:SetPoint (10, -170) --stretch direction		
		frame6.instanceMicroDisplaysSideLabel:SetPoint (10, -195)
		frame6.backdropLabel:SetPoint (10, -220)
		frame6.strataLabel:SetPoint (10, -245)

		frame6.statusbarAnchorLabel:SetPoint (10, -280)
		frame6.statusbarLabel:SetPoint (10, -305) --statusbar
		frame6.statusbarColorLabel:SetPoint (10, -330)
		
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Top Menu Bar ~7
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function window:CreateFrame7()

	local frame7 = window.options [7][1]
	
		local titulo_toolbar = g:NewLabel (frame7, _, "$parentTituloToolbar", "tituloToolbarLabel", Loc ["STRING_OPTIONS_TOOLBAR_SETTINGS"], "GameFontNormal", 16)
		local titulo_toolbar_desc = g:NewLabel (frame7, _, "$parentTituloToolbar2", "tituloToolbar2Label", Loc ["STRING_OPTIONS_TOOLBAR_SETTINGS_DESC"], "GameFontNormal", 9, "white")
		titulo_toolbar_desc.width = 320

		-- menu anchors
			local s = g:NewSlider (frame7, _, "$parentMenuAnchorXSlider", "menuAnchorXSlider", SLIDER_WIDTH, 20, -200, 200, 1, instance.menu_anchor[1])
			s:SetBackdrop (slider_backdrop)
			s:SetBackdropColor (unpack (slider_backdrop_color))
			s:SetThumbSize (50)			
			local s = g:NewSlider (frame7, _, "$parentMenuAnchorYSlider", "menuAnchorYSlider", SLIDER_WIDTH, 20, -10, 10, 1, instance.menu_anchor[2])
			s:SetBackdrop (slider_backdrop)
			s:SetBackdropColor (unpack (slider_backdrop_color))
			s:SetThumbSize (50)
			
			--g:NewLabel (frame7, _, "$parentMenuAnchorXLabel", "menuAnchorXLabel", Loc ["STRING_OPTIONS_MENU_X"], "GameFontHighlightLeft")
			g:NewLabel (frame7, _, "$parentMenuAnchorXLabel", "menuAnchorXLabel", Loc ["STRING_OPTIONS_MENU_X"], "GameFontHighlightLeft")
			g:NewLabel (frame7, _, "$parentMenuAnchorYLabel", "menuAnchorYLabel", Loc ["STRING_OPTIONS_MENU_Y"], "GameFontHighlightLeft")
			
			frame7.menuAnchorXSlider:SetPoint ("left", frame7.menuAnchorXLabel, "right", 2, -1)
			frame7.menuAnchorYSlider:SetPoint ("left", frame7.menuAnchorYLabel, "right", 2)
			--frame7.menuAnchorYSlider:SetPoint ("left", frame7.menuAnchorXSlider, "right", 2)
			
			frame7.menuAnchorXSlider:SetThumbSize (50)
			frame7.menuAnchorXSlider:SetHook ("OnValueChange", function (self, instance, x) 
				instance:MenuAnchor (x, nil)
			end)
			frame7.menuAnchorYSlider:SetThumbSize (50)
			frame7.menuAnchorYSlider:SetHook ("OnValueChange", function (self, instance, y)
				instance:MenuAnchor (nil, y)
			end)
			
			frame7.menuAnchorXSlider.info = Loc ["STRING_OPTIONS_MENU_X_DESC"]
			window:create_line_background (frame7, frame7.menuAnchorXLabel, frame7.menuAnchorXSlider)
			frame7.menuAnchorXSlider:SetHook ("OnEnter", background_on_enter)
			frame7.menuAnchorXSlider:SetHook ("OnLeave", background_on_leave)	
			
			frame7.menuAnchorYSlider.info = Loc ["STRING_OPTIONS_MENU_X_DESC"]
			window:create_line_background (frame7, frame7.menuAnchorYLabel, frame7.menuAnchorYSlider)
			frame7.menuAnchorYSlider:SetHook ("OnEnter", background_on_enter)
			frame7.menuAnchorYSlider:SetHook ("OnLeave", background_on_leave)

		-- menu anchor left and right
		
			local menusode_switch_func = function (slider, value)
				if (value == 1) then
					return false
				elseif (value == 2) then
					return true
				end
			end
			local menuside_return_func = function (slider, value)
				if (value) then
					return 2
				else
					return 1
				end
			end	
			
			g:NewSwitch (frame7, _, "$parentMenuAnchorSideSlider", "pluginMenuAnchorSideSlider", 80, 20, Loc ["STRING_LEFT"], Loc ["STRING_RIGHT"], instance.menu_anchor.side, nil, menusode_switch_func, menuside_return_func)
			g:NewLabel (frame7, _, "$parentMenuAnchorSideLabel", "menuAnchorSideLabel", Loc ["STRING_OPTIONS_MENU_ANCHOR"], "GameFontHighlightLeft")
			
			frame7.pluginMenuAnchorSideSlider:SetPoint ("left", frame7.menuAnchorSideLabel, "right", 2)
			frame7.pluginMenuAnchorSideSlider.OnSwitch = function (self, instance, value)
				instance:LeftMenuAnchorSide (value)
			end
			
			window:CreateLineBackground (frame7, "pluginMenuAnchorSideSlider", "menuAnchorSideLabel", Loc ["STRING_OPTIONS_MENU_ANCHOR_DESC"])
			
		-- desaturate
			g:NewSwitch (frame7, _, "$parentDesaturateMenuSlider", "desaturateMenuSlider", 60, 20, _, _, instance.desaturated_menu)
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
			g:NewSwitch (frame7, _, "$parentHideIconSlider", "hideIconSlider", 60, 20, _, _, instance.hide_icon)			
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
			local grow_switch_func = function (slider, value)
				if (value == 1) then
					return false
				elseif (value == 2) then
					return true
				end
			end
			local grow_return_func = function (slider, value)
				if (value) then
					return 2
				else
					return 1
				end
			end	
			
			g:NewSwitch (frame7, _, "$parentPluginIconsDirectionSlider", "pluginIconsDirectionSlider", 80, 20, Loc ["STRING_LEFT"], Loc ["STRING_RIGHT"], instance.plugins_grow_direction, nil, grow_switch_func, grow_return_func)
			g:NewLabel (frame7, _, "$parentPluginIconsDirectionLabel", "pluginIconsDirectionLabel", Loc ["STRING_OPTIONS_PICONS_DIRECTION"], "GameFontHighlightLeft")

			frame7.pluginIconsDirectionSlider:SetPoint ("left", frame7.pluginIconsDirectionLabel, "right", 2)
			frame7.pluginIconsDirectionSlider.OnSwitch = function (self, instance, value)
				instance.plugins_grow_direction = value
				--instance:DefaultIcons()
				_detalhes.ToolBar:ReorganizeIcons (nil, true)
			end
			frame7.pluginIconsDirectionSlider.thumb:SetSize (40, 12)
			
			frame7.pluginIconsDirectionSlider.info = Loc ["STRING_OPTIONS_PICONS_DIRECTION_DESC"]
			window:create_line_background (frame7, frame7.pluginIconsDirectionLabel, frame7.pluginIconsDirectionSlider)
			frame7.pluginIconsDirectionSlider:SetHook ("OnEnter", background_on_enter)
			frame7.pluginIconsDirectionSlider:SetHook ("OnLeave", background_on_leave)
			
--auto hide menus
	--text anchor on options menu
		g:NewLabel (frame7, _, "$parentAutoHideLabelAnchor", "autoHideLabel", Loc ["STRING_OPTIONS_MENU_AUTOHIDE_ANCHOR"], "GameFontNormal")
		
	--left
		g:NewLabel (frame7, _, "$parentAutoHideLeftMenuLabel", "autoHideLeftMenuLabel", Loc ["STRING_OPTIONS_MENU_AUTOHIDE_LEFT"], "GameFontHighlightLeft")
		g:NewSwitch (frame7, _, "$parentAutoHideLeftMenuSwitch", "autoHideLeftMenuSwitch", 60, 20, nil, nil, instance.auto_hide_menu.left)
		frame7.autoHideLeftMenuSwitch:SetPoint ("left", frame7.autoHideLeftMenuLabel, "right", 2)
		frame7.autoHideLeftMenuSwitch.OnSwitch = function (self, instance, value)
			--do something
			instance:SetAutoHideMenu (value)
		end
		window:CreateLineBackground (frame7, "autoHideLeftMenuSwitch", "autoHideLeftMenuLabel", Loc ["STRING_OPTIONS_MENU_AUTOHIDE_DESC"])
	--right
		g:NewLabel (frame7, _, "$parentAutoHideRightMenuLabel", "autoHideRightMenuLabel", Loc ["STRING_OPTIONS_MENU_AUTOHIDE_RIGHT"], "GameFontHighlightLeft")
		g:NewSwitch (frame7, _, "$parentAutoHideRightMenuSwitch", "autoHideRightMenuSwitch", 60, 20, nil, nil, instance.auto_hide_menu.right)
		frame7.autoHideRightMenuSwitch:SetPoint ("left", frame7.autoHideRightMenuLabel, "right", 2)
		frame7.autoHideRightMenuSwitch.OnSwitch = function (self, instance, value)
			--do something
			instance:SetAutoHideMenu (nil, value)
		end
		window:CreateLineBackground (frame7, "autoHideRightMenuSwitch", "autoHideRightMenuLabel", Loc ["STRING_OPTIONS_MENU_AUTOHIDE_DESC"])
		
		--> anchors
		titulo_toolbar:SetPoint (10, -10)
		titulo_toolbar_desc:SetPoint (10, -30)
		frame7.menuAnchorXLabel:SetPoint (10, -70)
		frame7.menuAnchorYLabel:SetPoint (10, -95)
		frame7.menuAnchorSideLabel:SetPoint (10, -120)
		frame7.desaturateMenuLabel:SetPoint (10, -145)
		frame7.hideIconLabel:SetPoint (10, -170)
		frame7.pluginIconsDirectionLabel:SetPoint (10, -195)

		frame7.autoHideLabel:SetPoint (10, -230)
		frame7.autoHideLeftMenuLabel:SetPoint (10, -255)
		frame7.autoHideRightMenuLabel:SetPoint (10, -280)
		
		
		
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Reset Instance Close ~8
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function window:CreateFrame8()

		local frame8 = window.options [8][1]

		local titulo_toolbar2 = g:NewLabel (frame8, _, "$parentTituloToolbar_buttons", "tituloToolbarLabel", Loc ["STRING_OPTIONS_TOOLBAR2_SETTINGS"], "GameFontNormal", 16)
		local titulo_toolbar2_desc = g:NewLabel (frame8, _, "$parentTituloToolbar_buttons", "tituloToolbar2Label", Loc ["STRING_OPTIONS_TOOLBAR2_SETTINGS_DESC"], "GameFontNormal", 9, "white")
		titulo_toolbar2_desc.width = 320
		
		--> close button
			--button overlay
			local close_overlay_callback = function (button, r, g, b, a)
				_G.DetailsOptionsWindow.instance:SetCloseButtonSettings ({r, g, b, a})
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
				_G.DetailsOptionsWindow.instance:SetDeleteButtonSettings (nil, nil, {r, g, b, a}, nil)
			end
			g:NewColorPickButton (frame8, "$parentResetTextColorPick", "resetTextColorPick", reset_textcolor_callback)
			g:NewLabel (frame8, _, "$parentResetTextLabel", "resetTextColorPickLabel", Loc ["STRING_OPTIONS_RESET_TEXTCOLOR"], "GameFontHighlightLeft")
			frame8.resetTextColorPick:SetPoint ("left", frame8.resetTextColorPickLabel, "right", 2, 0)

			frame8.resetTextColorPick.info = Loc ["STRING_OPTIONS_RESET_TEXTCOLOR_DESC"]
			window:create_line_background (frame8, frame8.resetTextColorPickLabel, frame8.resetTextColorPick)
			frame8.resetTextColorPick:SetHook ("OnEnter", background_on_enter)
			frame8.resetTextColorPick:SetHook ("OnLeave", background_on_leave)
			
			--text size
			local s = g:NewSlider (frame8, _, "$parentResetTextSizeSlider", "resetTextSizeSlider", SLIDER_WIDTH, 20, 8, 15, 1, tonumber (instance.resetbutton_info.text_size))
			s:SetBackdrop (slider_backdrop)
			s:SetBackdropColor (unpack (slider_backdrop_color))
			s:SetThumbSize (50)
			
			frame8.resetTextSizeSlider:SetHook ("OnValueChange", function (self, instance, amount) 
				instance:SetDeleteButtonSettings (nil, amount)
			end)
			
			--reset always small
			g:NewSwitch (frame8, _, "$parentResetAlwaysSmallSlider", "resetAlwaysSmallSlider", 60, 20, _, _, instance.resetbutton_info.always_small)
			
			--text face
			local reset_text_color_onselectfont = function (_, instance, fontName)
				_G.DetailsOptionsWindow.instance:SetDeleteButtonSettings (fontName)
			end
			local  reset_text_color_build_font_menu = function() 
				local fontObjects = SharedMedia:HashTable ("font")
				local fontTable = {}
				for name, fontPath in pairs (fontObjects) do 
					fontTable[#fontTable+1] = {value = name, label = name, onclick = reset_text_color_onselectfont, font = fontPath, descfont = name, desc = "Way back up in the woods among the evergreens\nThere stood a log cabin made of earth and wood."}
				end
				table.sort (fontTable, function (t1, t2) return t1.label < t2.label end)
				return fontTable 
			end
			local d = g:NewDropDown (frame8, _, "$parentResetTextFontDropdown", "resetTextFontDropdown", DROPDOWN_WIDTH, 20, reset_text_color_build_font_menu, nil)
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
			
		--> instance button
			--text color pick
			--text size
			local s = g:NewSlider (frame8, _, "$parentInstanceTextSizeSlider", "instanceTextSizeSlider", SLIDER_WIDTH, 20, 8, 15, 1, tonumber (instance.instancebutton_info.text_size))
			s:SetBackdrop (slider_backdrop)
			s:SetBackdropColor (unpack (slider_backdrop_color))
			s:SetThumbSize (50)			
			
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
					fontTable[#fontTable+1] = {value = name, label = name, onclick = instance_text_color_onselectfont, font = fontPath, descfont = name, desc = "If there's a bustle in your hedgerow, don't be alarmed now\nIt's just a spring clean for the may queen."}
				end
				table.sort (fontTable, function (t1, t2) return t1.label < t2.label end)
				return fontTable 
			end
			local d = g:NewDropDown (frame8, _, "$parentInstanceTextFontDropdown", "instanceTextFontDropdown", DROPDOWN_WIDTH, 20, instance_text_color_build_font_menu, nil)
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
			

		
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
				_G.DetailsOptionsWindow.instance:SetDeleteButtonSettings (nil, nil, nil, {r, g, b, a})
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
				_G.DetailsOptionsWindow.instance:SetInstanceButtonSettings (nil, nil, {r, g, b, a})
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
				_G.DetailsOptionsWindow.instance:SetInstanceButtonSettings (nil, nil, nil, {r, g, b, a})
			end
			g:NewColorPickButton (frame8, "$parentInstanceOverlayColorPick", "instanceOverlayColorPick", instance_overlaycolor_callback)
			g:NewLabel (frame8, _, "$parentInstanceOverlayLabel", "instanceOverlayColorPickLabel", Loc ["STRING_OPTIONS_INSTANCE_OVERLAY"], "GameFontHighlightLeft")
			frame8.instanceOverlayColorPick:SetPoint ("left", frame8.instanceOverlayColorPickLabel, "right", 2, 0)

			frame8.instanceOverlayColorPick.info = Loc ["STRING_OPTIONS_INSTANCE_OVERLAY_DESC"]
			window:create_line_background (frame8, frame8.instanceOverlayColorPickLabel, frame8.instanceOverlayColorPick)
			frame8.instanceOverlayColorPick:SetHook ("OnEnter", background_on_enter)
			frame8.instanceOverlayColorPick:SetHook ("OnLeave", background_on_leave)			
			
		--> instance button anchor
			local s = g:NewSlider (frame8, _, "$parentInstanceButtonAnchorXSlider", "instanceButtonAnchorXSlider", SLIDER_WIDTH, 20, -200, 20, 1, instance.instance_button_anchor[1])
			s:SetBackdrop (slider_backdrop)
			s:SetBackdropColor (unpack (slider_backdrop_color))
			s:SetThumbSize (50)			
			local s = g:NewSlider (frame8, _, "$parentInstanceButtonAnchorYSlider", "instanceButtonAnchorYSlider", SLIDER_WIDTH, 20, -10, 10, 1, instance.instance_button_anchor[2])
			s:SetBackdrop (slider_backdrop)
			s:SetBackdropColor (unpack (slider_backdrop_color))
			s:SetThumbSize (50)
		
			g:NewLabel (frame8, _, "$parentInstanceButtonAnchorXLabel", "instanceButtonAnchorXLabel", Loc ["STRING_OPTIONS_INSBUTTON_X"], "GameFontHighlightLeft")
			frame8.instanceButtonAnchorXSlider:SetPoint ("left", frame8.instanceButtonAnchorXLabel, "right", 2)
			frame8.instanceButtonAnchorXSlider:SetThumbSize (50)
			frame8.instanceButtonAnchorXSlider:SetHook ("OnValueChange", function (self, instance, x)
				instance:InstanceButtonAnchor (x, nil)
			end)
			
			frame8.instanceButtonAnchorXSlider.info = Loc ["STRING_OPTIONS_INSBUTTON_X_DESC"]
			window:create_line_background (frame8, frame8.instanceButtonAnchorXLabel, frame8.instanceButtonAnchorXSlider)
			frame8.instanceButtonAnchorXSlider:SetHook ("OnEnter", background_on_enter)
			frame8.instanceButtonAnchorXSlider:SetHook ("OnLeave", background_on_leave)
			
			g:NewLabel (frame8, _, "$parentInstanceButtonAnchorYLabel", "instanceButtonAnchorYLabel", Loc ["STRING_OPTIONS_INSBUTTON_Y"], "GameFontHighlightLeft")
			frame8.instanceButtonAnchorYSlider:SetPoint ("left", frame8.instanceButtonAnchorYLabel, "right", 2)
			frame8.instanceButtonAnchorYSlider:SetThumbSize (50)
			frame8.instanceButtonAnchorYSlider:SetHook ("OnValueChange", function (self, instance, y)
				instance:InstanceButtonAnchor (nil, y)
			end)

			frame8.instanceButtonAnchorYSlider.info =Loc ["STRING_OPTIONS_INSBUTTON_Y_DESC"]
			window:create_line_background (frame8, frame8.instanceButtonAnchorYLabel, frame8.instanceButtonAnchorYSlider)
			frame8.instanceButtonAnchorYSlider:SetHook ("OnEnter", background_on_enter)
			frame8.instanceButtonAnchorYSlider:SetHook ("OnLeave", background_on_leave)
			

			
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
		frame8.instanceButtonAnchorXLabel:SetPoint (10, -200)
		frame8.instanceButtonAnchorYLabel:SetPoint (10, -225)

		frame8.resetAnchorLabel:SetPoint (10, -260)
		
		frame8.resetTextColorPickLabel:SetPoint (10, -285)
		frame8.resetTextFontLabel:SetPoint (10, -310)
		frame8.resetTextSizeLabel:SetPoint (10, -335)
		frame8.resetOverlayColorPickLabel:SetPoint (10, -360)
		frame8.resetAlwaysSmallLabel:SetPoint (10, -385)

		frame8.closeAnchorLabel:SetPoint (10, -420)
		
		frame8.closeButtonColorLabel:SetPoint (10, -445)

end
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Wallpaper ~9
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function window:CreateFrame9()

	local frame9 = window.options [9][1]

		local titulo_wallpaper = g:NewLabel (frame9, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_WP"], "GameFontNormal", 16)
		local titulo_wallpaper_desc = g:NewLabel (frame9, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_WP_DESC"], "GameFontNormal", 9, "white")
		titulo_wallpaper_desc.width = 320
		
		--> wallpaper
		
			--> primeiro o botão de editar a imagem
			local callmeback = function (width, height, overlayColor, alpha, texCoords)
				local tinstance = _G.DetailsOptionsWindow.instance
				tinstance:InstanceWallpaper (nil, nil, alpha, texCoords, width, height, overlayColor)
				window:update_wallpaper_info()
			end
			
			local startImageEdit = function()
				local tinstance = _G.DetailsOptionsWindow.instance
				
				if (not tinstance.wallpaper.texture) then
					return
				end

				local wp = tinstance.wallpaper

				if (wp.texture:find ("TALENTFRAME")) then
					g:ImageEditor (callmeback, wp.texture, wp.texcoord, wp.overlay, tinstance.baseframe.wallpaper:GetWidth(), tinstance.baseframe.wallpaper:GetHeight(), nil, wp.alpha)
				else
					g:ImageEditor (callmeback, wp.texture, wp.texcoord, wp.overlay, tinstance.baseframe.wallpaper:GetWidth(), tinstance.baseframe.wallpaper:GetHeight(), nil, wp.alpha)
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

			local d = g:NewDropDown (frame9, _, "$parentAnchorDropdown", "anchorDropdown", DROPDOWN_WIDTH, 20, buildAnchorMenu, nil)			
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))			
			
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
			
			g:NewSwitch (frame9, _, "$parentUseBackgroundSlider", "useBackgroundSlider", 60, 20, _, _, _G.DetailsOptionsWindow.instance.wallpaper.enabled)
			local d = g:NewDropDown (frame9, _, "$parentBackgroundDropdown", "backgroundDropdown", DROPDOWN_WIDTH, 20, buildBackgroundMenu, nil)
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))			
			
			local d = g:NewDropDown (frame9, _, "$parentBackgroundDropdown2", "backgroundDropdown2", DROPDOWN_WIDTH, 20, buildBackgroundMenu2, nil)
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
			
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

		g:NewLabel (frame9, _, "$parentWallpaperPreviewAnchor", "wallpaperPreviewAnchorLabel", "Preview:", "GameFontNormal")
		
		--128 64
		
		local icon1 = g:NewImage (frame9, nil, 128, 64, nil, nil, nil, "$parentIcon1")
		icon1:SetTexture ("Interface\\AddOns\\Details\\images\\icons")
		icon1:SetPoint ("topleft", frame9.wallpaperPreviewAnchorLabel.widget, "bottomleft", 0, -5)
		icon1:SetDrawLayer ("artwork", 0)
		icon1:SetTexCoord (0.337890625, 0.5859375, 0.59375, 0.716796875-0.0009765625) --173 304 300 367
		local icon2 = g:NewImage (frame9, nil, 128, 64, nil, nil, nil, "$parentIcon2")
		icon2:SetTexture ("Interface\\AddOns\\Details\\images\\icons")
		icon2:SetPoint ("left", icon1.widget, "right")
		icon2:SetDrawLayer ("artwork", 0)
		icon2:SetTexCoord (0.337890625, 0.5859375, 0.59375, 0.716796875-0.0009765625) --173 304 300 367
		
		local icon3 = g:NewImage (frame9, nil, 128, 64, nil, nil, nil, "$parentIcon3")
		icon3:SetTexture ("Interface\\AddOns\\Details\\images\\icons")
		icon3:SetPoint ("top", icon1.widget, "bottom")
		icon3:SetDrawLayer ("artwork", 0)
		icon3:SetTexCoord (0.337890625, 0.5859375, 0.59375+0.0009765625, 0.716796875) --173 304 300 367
		local icon4 = g:NewImage (frame9, nil, 128, 64, nil, nil, nil, "$parentIcon4")
		icon4:SetTexture ("Interface\\AddOns\\Details\\images\\icons")
		icon4:SetPoint ("left", icon3.widget, "right")
		icon4:SetDrawLayer ("artwork", 0)
		icon4:SetTexCoord (0.337890625, 0.5859375, 0.59375+0.0009765625, 0.716796875) --173 304 300 367
		
		icon1:SetVertexColor (.15, .15, .15, 1)
		icon2:SetVertexColor (.15, .15, .15, 1)
		icon3:SetVertexColor (.15, .15, .15, 1)
		icon4:SetVertexColor (.15, .15, .15, 1)
		
		local preview = frame9:CreateTexture (nil, "overlay")
		preview:SetSize (256, 128)
		preview:SetPoint ("topleft", frame9.wallpaperPreviewAnchorLabel.widget, "bottomleft", 0, -5)
		
		function window:update_wallpaper_info()
			local w = _G.DetailsOptionsWindow.instance.wallpaper
			
			local a = w.alpha or 0
			a = a * 100
			a = string.format ("%.1f", a) .. "%"

			local t = w.texcoord [3] or 0
			t = t * 100
			t = string.format ("%.3f", t) .. "%"
			
			local b = w.texcoord [4] or 1
			b = b * 100
			b = string.format ("%.3f", b) .. "%"
			
			local l = w.texcoord [1] or 0
			l = l * 100
			l = string.format ("%.3f", l) .. "%"
			
			local r = w.texcoord [2] or 1
			r = r * 100
			r = string.format ("%.3f", r) .. "%"
			
			local red = w.overlay[1] or 0
			red = math.ceil (red * 255)
			local green = w.overlay[2] or "0"
			green = math.ceil (green * 255)
			local blue = w.overlay[3] or "0"
			blue = math.ceil (blue * 255)
			
			preview:SetTexture (w.texture)
			preview:SetTexCoord (unpack (w.texcoord))
			preview:SetVertexColor (unpack (w.overlay))
			preview:SetAlpha (w.alpha)
			
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
		
		frame9.wallpaperPreviewAnchorLabel:SetPoint (10, -210)
		
		frame9.wallpaperCurrentAnchorLabel:SetPoint (10, -380)
		frame9.wallpaperCurrentLabel:SetPoint (10, -400)
		
	--> wallpaper settings

end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Performance - Tweaks ~10
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function window:CreateFrame10()

		local frame10 = window.options [10][1]
		local frame11 = window.options [11][1]
		
		local titulo_performance_general = g:NewLabel (frame10, _, "$parentTituloPerformance1", "tituloPerformance1Label", Loc ["STRING_OPTIONS_PERFORMANCE1"], "GameFontNormal", 16)
		local titulo_performance_general_desc = g:NewLabel (frame10, _, "$parentTituloPersona2", "tituloPersona2Label", Loc ["STRING_OPTIONS_PERFORMANCE1_DESC"], "GameFontNormal", 9, "white")
		titulo_performance_general_desc.width = 320
		
	--------------- Memory		
		local s = g:NewSlider (frame10, _, "$parentSliderSegmentsSave", "segmentsSliderToSave", SLIDER_WIDTH, 20, 1, 5, 1, _detalhes.segments_amount_to_save)
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)
		
		g:NewLabel (frame10, _, "$parentLabelMemory", "memoryLabel", Loc ["STRING_OPTIONS_MEMORYT"], "GameFontHighlightLeft")

		local s = g:NewSlider (frame10, _, "$parentSliderMemory", "memorySlider", SLIDER_WIDTH, 20, 1, 4, 1, _detalhes.memory_threshold)
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		
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
		--frame10.animateLabel:SetPoint (10, -145)
		--frame10.animatescrollLabel:SetPoint (10, -170)
		--frame10.updatespeedLabel:SetPoint (10, -170)
		frame10.eraseTrashLabel:SetPoint (10, -145)

end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Performance - Captures ~11
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function window:CreateFrame11()

	local frame10 = window.options [10][1]
	local frame11 = window.options [11][1]

		local titulo_performance_captures = g:NewLabel (frame11, _, "$parentTituloPerformanceCaptures", "tituloPerformanceCaptures", Loc ["STRING_OPTIONS_PERFORMANCECAPTURES"], "GameFontNormal", 16)
		local titulo_performance_captures_desc = g:NewLabel (frame11, _, "$parentTituloPersonaCaptures2", "tituloPersonaCaptures2Label", Loc ["STRING_OPTIONS_PERFORMANCECAPTURES_DESC"], "GameFontNormal", 9, "white")
		titulo_performance_captures_desc.width = 320
		
	--------------- Captures
		g:NewImage (frame11, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "damageCaptureImage", "$parentCaptureDamage")
		frame11.damageCaptureImage:SetTexCoord (0, 0.125, 0, 1)
		
		g:NewImage (frame11, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "healCaptureImage", "$parentCaptureHeal")
		frame11.healCaptureImage:SetTexCoord (0.125, 0.25, 0, 1)
		
		g:NewImage (frame11, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "energyCaptureImage", "$parentCaptureEnergy")
		frame11.energyCaptureImage:SetTexCoord (0.25, 0.375, 0, 1)
		
		g:NewImage (frame11, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "miscCaptureImage", "$parentCaptureMisc")
		frame11.miscCaptureImage:SetTexCoord (0.375, 0.5, 0, 1)
		
		g:NewImage (frame11, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "auraCaptureImage", "$parentCaptureAura")
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
	
	window.creating = nil
end
		
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
function window:CreateFrame12()

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
	
		g:NewImage (bframe, pluginObject.__icon, 18, 18, nil, nil, "toolbarPluginsIcon"..i, "$parentToolbarPluginsIcon"..i)
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
	
		g:NewImage (bframe, pluginObject.__icon, 18, 18, nil, nil, "raidPluginsIcon"..i, "$parentRaidPluginsIcon"..i)
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
	
		g:NewImage (bframe, pluginObject.__icon, 18, 18, nil, nil, "soloPluginsIcon"..i, "$parentSoloPluginsIcon"..i)
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

end
	
	--> create the frames
	if (UnitAffectingCombat ("player")) then

		local panel_index = 1
		local percent_string = g:NewLabel (window, nil, nil, "percent_string", "loading: 0%", "GameFontNormal", 12)
		percent_string.textcolor = "white"
		percent_string:SetPoint ("bottomleft", window, "bottomleft", 340, 12)
		local step = 5.8823
		
		function _detalhes:create_options_panels()
		
			window ["CreateFrame" .. panel_index]()

			if (panel_index == 17) then
				_detalhes:CancelTimer (window.create_thread)
				window:create_left_menu()
				
				percent_string.hide = true
				_G.DetailsOptionsWindow.full_created = true
				
				local first_button = all_buttons [1]
				last_pressed = first_button
				first_button.widget.text:SetPoint ("left", first_button.widget, "left", 3, -1)
				first_button.textcolor = selected_textcolor

			end
			
			percent_string.text = "wait... " .. math.floor (step * panel_index) .. "%"
			panel_index = panel_index + 1
			
		end
		
		window.create_thread = _detalhes:ScheduleRepeatingTimer ("create_options_panels", 0.1)
		
	else
		
		for i = 1, 17 do
			window ["CreateFrame" .. i]()
		end
		window:create_left_menu()
		
		_G.DetailsOptionsWindow.full_created = true

		local first_button = all_buttons [1]
		last_pressed = first_button
		first_button.widget.text:SetPoint ("left", first_button.widget, "left", 3, -1)
		first_button.textcolor = selected_textcolor
		
	end
	

	
	select_options (1)
	
end --> if not window

----------------------------------------------------------------------------------------
--> Show

local strata = {
	["LOW"] = "Low",
	["MEDIUM"] = "Medium",
	["HIGH"] = "High"
}

function window:update_all (editing_instance)

	--> window 1
	_G.DetailsOptionsWindow1RealmNameSlider.MyObject:SetValue (_detalhes.remove_realm_from_name)
	_G.DetailsOptionsWindow1Slider.MyObject:SetValue (_detalhes.segments_amount) --segments
	
	_G.DetailsOptionsWindow1UseScrollSlider.MyObject:SetValue (_detalhes.use_scroll)
	
	_G.DetailsOptionsWindow1SliderMaxInstances.MyObject:SetValue (_detalhes.instances_amount)
	_G.DetailsOptionsWindow1MinimapSlider.MyObject:SetValue (not _detalhes.minimap.hide)
	_G.DetailsOptionsWindow1AbbreviateDropdown.MyObject:Select (_detalhes.ps_abbreviation)
	_G.DetailsOptionsWindow1SliderUpdateSpeed.MyObject:SetValue (_detalhes.update_speed)
	_G.DetailsOptionsWindow1AnimateSlider.MyObject:SetValue (_detalhes.use_row_animations)

	--> window 2
	_G.DetailsOptionsWindow2FragsPvpSlider.MyObject:SetValue (_detalhes.only_pvp_frags)
	_G.DetailsOptionsWindow2TTDropdown.MyObject:Select (_detalhes.time_type)
	
	_G.DetailsOptionsWindow2AutoCurrentSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow2AutoCurrentSlider.MyObject:SetValue (editing_instance.auto_current)	
	
	--> window 4
	_G.DetailsOptionsWindow4BarStartSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4BarStartSlider.MyObject:SetValue (editing_instance.row_info.start_after_icon)
	
	--> window 5
	_G.DetailsOptionsWindow5TotalBarSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow5TotalBarSlider.MyObject:SetValue (editing_instance.total_bar.enabled)
	
	_G.DetailsOptionsWindow5TotalBarColorPick.MyObject:SetColor (unpack (editing_instance.total_bar.color))
	
	_G.DetailsOptionsWindow5TotalBarOnlyInGroupSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow5TotalBarOnlyInGroupSlider.MyObject:SetValue (editing_instance.total_bar.only_in_group)
	_G.DetailsOptionsWindow5TotalBarIconTexture.MyObject:SetTexture (editing_instance.total_bar.icon)
	
	_G.DetailsOptionsWindow5CutomRightTextSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow5CutomRightTextSlider.MyObject:SetValue (editing_instance.row_info.textR_enable_custom_text)
	_G.DetailsOptionsWindow5CutomRightTextEntry.MyObject:SetText (editing_instance.row_info.textR_custom_text)
	
	--> window 6
	_G.DetailsOptionsWindow6BackdropDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6BackdropDropdown.MyObject:Select (editing_instance.backdrop_texture)
	
	local r, g, b = unpack (editing_instance.statusbar_info.overlay)
	_G.DetailsOptionsWindow6StatusbarColorPick.MyObject:SetColor (r, g, b, editing_instance.statusbar_info.alpha)
	
	_G.DetailsOptionsWindow6StrataDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6StrataDropdown.MyObject:Select (strata [editing_instance.strata] or "Low")
	
	_G.DetailsOptionsWindow6InstanceMicroDisplaysSideSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6InstanceMicroDisplaysSideSlider.MyObject:SetValue (editing_instance.micro_displays_side)
	
	--> window 7
	_G.DetailsOptionsWindow7AutoHideRightMenuSwitch.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7AutoHideRightMenuSwitch.MyObject:SetValue (editing_instance.auto_hide_menu.right)
	
	_G.DetailsOptionsWindow7AutoHideLeftMenuSwitch.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7AutoHideLeftMenuSwitch.MyObject:SetValue (editing_instance.auto_hide_menu.left)
	
	_G.DetailsOptionsWindow7MenuAnchorSideSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7MenuAnchorSideSlider.MyObject:SetValue (editing_instance.menu_anchor.side)
	
	--> window 8
	_G.DetailsOptionsWindow8InstanceButtonAnchorXSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow8InstanceButtonAnchorXSlider.MyObject:SetValue (editing_instance.instance_button_anchor[1])
	
	_G.DetailsOptionsWindow8InstanceButtonAnchorYSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow8InstanceButtonAnchorYSlider.MyObject:SetValue (editing_instance.instance_button_anchor[2])
	
	--> window 10	
	_G.DetailsOptionsWindow10SliderMemory.MyObject:SetValue (_detalhes.memory_threshold)
	_G.DetailsOptionsWindow10PanicModeSlider.MyObject:SetValue (_detalhes.segments_panic_mode)
	_G.DetailsOptionsWindow10ClearAnimateScrollSlider.MyObject:SetValue (_detalhes.animate_scroll)
	_G.DetailsOptionsWindow10SliderSegmentsSave.MyObject:SetValue (_detalhes.segments_amount_to_save)
	
	--> window 11
	_G.DetailsOptionsWindow11CaptureDamageSlider.MyObject:SetValue (_detalhes.capture_real ["damage"])
	_G.DetailsOptionsWindow11CaptureHealSlider.MyObject:SetValue (_detalhes.capture_real ["heal"])
	_G.DetailsOptionsWindow11CaptureEnergySlider.MyObject:SetValue (_detalhes.capture_real ["energy"])
	_G.DetailsOptionsWindow11CaptureMiscSlider.MyObject:SetValue (_detalhes.capture_real ["miscdata"])
	_G.DetailsOptionsWindow11CaptureAuraSlider.MyObject:SetValue (_detalhes.capture_real ["aura"])
	_G.DetailsOptionsWindow11CloudAuraSlider.MyObject:SetValue (_detalhes.cloud_capture)	
	
	--> window 13
	_G.DetailsOptionsWindow13SelectProfileDropdown.MyObject:Select (_detalhes:GetCurrentProfileName())
	_G.DetailsOptionsWindow13SelectProfileDropdown.MyObject:SetFixedParameter (editing_instance)
	
	--> window 14

	_G.DetailsOptionsWindow14AttributeEnabledSwitch.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow14AttributeAnchorXSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow14AttributeAnchorYSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow14AttributeFontDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow14AttributeTextSizeSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow14AttributeShadowSwitch.MyObject:SetFixedParameter (editing_instance)
	
	_G.DetailsOptionsWindow14AttributeEnabledSwitch.MyObject:SetValue (editing_instance.attribute_text.enabled)
	_G.DetailsOptionsWindow14AttributeAnchorXSlider.MyObject:SetValue (editing_instance.attribute_text.anchor [1])
	_G.DetailsOptionsWindow14AttributeAnchorYSlider.MyObject:SetValue (editing_instance.attribute_text.anchor [2])
	_G.DetailsOptionsWindow14AttributeFontDropdown.MyObject:Select (instance.attribute_text.text_face)
	_G.DetailsOptionsWindow14AttributeTextSizeSlider.MyObject:SetValue (tonumber (editing_instance.attribute_text.text_size))
	_G.DetailsOptionsWindow14AttributeTextColorPick.MyObject:SetColor (unpack (editing_instance.attribute_text.text_color))
	_G.DetailsOptionsWindow14AttributeShadowSwitch.MyObject:SetValue (editing_instance.attribute_text.shadow)

	_G.DetailsOptionsWindow14AttributeSideSwitch.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow14AttributeSideSwitch.MyObject:SetValue (editing_instance.attribute_text.side)
	
	--> window 17
	_G.DetailsOptionsWindow17CombatAlphaDropdown.MyObject:Select (editing_instance.hide_in_combat_type, true)
	_G.DetailsOptionsWindow17HideOnCombatAlphaSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow17HideOnCombatAlphaSlider.MyObject:SetValue (editing_instance.hide_in_combat_alpha)
	
	_G.DetailsOptionsWindow17MenuOnEnterLeaveAlphaSwitch.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow17MenuOnEnterAlphaSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow17MenuOnLeaveAlphaSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow17MenuOnEnterLeaveAlphaIconsTooSwitch.MyObject:SetFixedParameter (editing_instance)	
	
	_G.DetailsOptionsWindow17MenuOnEnterAlphaSlider.MyObject:SetValue (editing_instance.menu_alpha.onenter)
	_G.DetailsOptionsWindow17MenuOnLeaveAlphaSlider.MyObject:SetValue (editing_instance.menu_alpha.onleave)
	_G.DetailsOptionsWindow17MenuOnEnterLeaveAlphaSwitch.MyObject:SetValue (editing_instance.menu_alpha.enabled)
	_G.DetailsOptionsWindow17MenuOnEnterLeaveAlphaIconsTooSwitch.MyObject:SetValue (editing_instance.menu_alpha.ignorebars)
	
	----------
	_G.DetailsOptionsWindow8ResetTextColorPick.MyObject:SetColor (unpack (editing_instance.resetbutton_info.text_color))
	_G.DetailsOptionsWindow8ResetTextSizeSlider.MyObject:SetValue (editing_instance.resetbutton_info.text_size)
	_G.DetailsOptionsWindow8ResetTextFontDropdown.MyObject:Select (editing_instance.resetbutton_info.text_face)
	_G.DetailsOptionsWindow8ResetOverlayColorPick.MyObject:SetColor (unpack (editing_instance.resetbutton_info.color_overlay))

	_G.DetailsOptionsWindow8InstanceTextColorPick.MyObject:SetColor (unpack (editing_instance.instancebutton_info.text_color))
	_G.DetailsOptionsWindow8InstanceTextSizeSlider.MyObject:SetValue (editing_instance.instancebutton_info.text_size)
	_G.DetailsOptionsWindow8InstanceTextFontDropdown.MyObject:Select (editing_instance.instancebutton_info.text_face)
	_G.DetailsOptionsWindow8InstanceOverlayColorPick.MyObject:SetColor (unpack (editing_instance.instancebutton_info.color_overlay))

	_G.DetailsOptionsWindow8CloseButtonColorPick.MyObject:SetColor (unpack (editing_instance.closebutton_info.color_overlay))


	
	_G.DetailsOptionsWindow6SideBarsSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6SideBarsSlider.MyObject:SetValue (editing_instance.show_sidebars)
	

	
	_G.DetailsOptionsWindow6StatusbarSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6StatusbarSlider.MyObject:SetValue (editing_instance.show_statusbar)
	
	_G.DetailsOptionsWindow6StretchAnchorSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6StretchAnchorSlider.MyObject:SetValue (editing_instance.stretch_button_side)
	
	_G.DetailsOptionsWindow7PluginIconsDirectionSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7PluginIconsDirectionSlider.MyObject:SetValue (editing_instance.plugins_grow_direction)
	
	_G.DetailsOptionsWindow6InstanceToolbarSideSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6InstanceToolbarSideSlider.MyObject:SetValue (editing_instance.toolbar_side)
	
	_G.DetailsOptionsWindow4BarSortDirectionSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4BarSortDirectionSlider.MyObject:SetValue (editing_instance.bars_sort_direction)
	
	_G.DetailsOptionsWindow4BarGrowDirectionSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4BarGrowDirectionSlider.MyObject:SetValue (editing_instance.bars_grow_direction)

	_G.DetailsOptionsWindow7DesaturateMenuSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7DesaturateMenuSlider.MyObject:SetValue (editing_instance.desaturated_menu)
	
	_G.DetailsOptionsWindow7HideIconSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7HideIconSlider.MyObject:SetValue (editing_instance.hide_icon)
	
	_G.DetailsOptionsWindow7MenuAnchorXSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7MenuAnchorXSlider.MyObject:SetValue (editing_instance.menu_anchor[1])
	
	_G.DetailsOptionsWindow7MenuAnchorYSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7MenuAnchorYSlider.MyObject:SetValue (editing_instance.menu_anchor[2])

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
	_G.DetailsOptionsWindow8ResetTextFontDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow8ResetTextSizeSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow8ResetAlwaysSmallSlider.MyObject:SetFixedParameter (editing_instance)
	--resetOverlayColorLabel

	--instanceTextColorLabel
	_G.DetailsOptionsWindow8InstanceTextFontDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow8InstanceTextSizeSlider.MyObject:SetFixedParameter (editing_instance)
	--instanceOverlayColorLabel

	--closeOverlayColorLabel
	
	_G.DetailsOptionsWindow3SkinDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow3SkinDropdown.MyObject:Select (editing_instance.skin)
	
	_G.DetailsOptionsWindow4TextureDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4RowBackgroundTextureDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4TextureDropdown.MyObject:Select (editing_instance.row_info.texture)
	_G.DetailsOptionsWindow4RowBackgroundTextureDropdown.MyObject:Select (editing_instance.row_info.texture_background)
	
	_G.DetailsOptionsWindow4RowBackgroundColorPick.MyObject:SetColor (unpack (editing_instance.row_info.fixed_texture_background_color))
	
	_G.DetailsOptionsWindow4BackgroundClassColorSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4BackgroundClassColorSlider.MyObject:SetValue (editing_instance.row_info.texture_background_class_color)
	
	_G.DetailsOptionsWindow5FontDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow5FontDropdown.MyObject:Select (editing_instance.row_info.font_face)
	--
	_G.DetailsOptionsWindow4SliderRowHeight.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4SliderRowHeight.MyObject:SetValue (editing_instance.row_info.height)
	--
	_G.DetailsOptionsWindow5SliderFontSize.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow5SliderFontSize.MyObject:SetValue (editing_instance.row_info.font_size)
	--
	--
	_G.DetailsOptionsWindow4ClassColorSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4ClassColorSlider.MyObject:SetValue (editing_instance.row_info.texture_class_colors)
	
	_G.DetailsOptionsWindow5UseClassColorsLeftTextSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow5UseClassColorsLeftTextSlider.MyObject:SetValue (editing_instance.row_info.textL_class_colors)
	_G.DetailsOptionsWindow5UseClassColorsRightTextSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow5UseClassColorsRightTextSlider.MyObject:SetValue (editing_instance.row_info.textR_class_colors)
	
	_G.DetailsOptionsWindow5TextLeftOutlineSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow5TextLeftOutlineSlider.MyObject:SetValue (editing_instance.row_info.textL_outline)
	_G.DetailsOptionsWindow5TextRightOutlineSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow5TextRightOutlineSlider.MyObject:SetValue (editing_instance.row_info.textR_outline)
	--
	_G.DetailsOptionsWindow4RowAlphaSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4RowAlphaSlider.MyObject:SetValue (editing_instance.row_info.alpha)
	
	_G.DetailsOptionsWindow6AlphaSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6AlphaSlider.MyObject:SetValue (editing_instance.bg_alpha)
	--
	_G.DetailsOptionsWindow9UseBackgroundSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow9BackgroundDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow9BackgroundDropdown2.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow9AnchorDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow9BackgroundDropdown.MyObject:Select (editing_instance.wallpaper.texture)
	
	_G.DetailsOptionsWindow9UseBackgroundSlider.MyObject:SetValue (editing_instance.wallpaper.enabled)
	
	_G.DetailsOptionsWindow6WindowColorPick.MyObject:SetColor (unpack (editing_instance.color))
	--_G.DetailsOptionsWindow6InstanceColorTexture.MyObject:SetTexture (unpack (editing_instance.color))
	
	--_G.DetailsOptionsWindow6BackgroundColorTexture.MyObject:SetTexture (editing_instance.bg_r, editing_instance.bg_g, editing_instance.bg_b)
	_G.DetailsOptionsWindow6WindowBackgroundColorPick.MyObject:SetColor (editing_instance.bg_r, editing_instance.bg_g, editing_instance.bg_b, editing_instance.bg_alpha)
	
	_G.DetailsOptionsWindow4RowColorPick.MyObject:SetColor (unpack (editing_instance.row_info.fixed_texture_color))
	
	_G.DetailsOptionsWindow5FixedTextColor.MyObject:SetColor (unpack (editing_instance.row_info.fixed_text_color))
	
	_G.DetailsOptionsWindow1NicknameEntry.MyObject.text = _detalhes:GetNickname (UnitGUID ("player"), UnitName ("player"), true) or ""
	_G.DetailsOptionsWindow2TTDropdown.MyObject:Select (_detalhes.time_type, true)
	
	_G.DetailsOptionsWindow.MyObject.instance = instance
	
	if (editing_instance.meu_id > _detalhes.instances_amount) then
	else
		_G.DetailsOptionsWindowInstanceSelectDropdown.MyObject:Select (editing_instance.meu_id, true)
	end
	
	_G.DetailsOptionsWindow4IconFileEntry:SetText (editing_instance.row_info.icon_file)
	
	--profiles
	_G.DetailsOptionsWindow13CurrentProfileLabel2.MyObject:SetText (_detalhes_database.active_profile)
	
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



if (_G.DetailsOptionsWindow.full_created) then
	_G.DetailsOptionsWindow.MyObject:update_all (instance)
else
	--> its loading while in combat
	function _detalhes:options_loading_done()
		if (_G.DetailsOptionsWindow.full_created) then
			_G.DetailsOptionsWindow.MyObject:update_all (instance)
			_detalhes:CancelTimer (window.loading_check, true)
		end
	end
	window.loading_check = _detalhes:ScheduleRepeatingTimer ("options_loading_done", 0.1)
end

window:Show()

end --> OpenOptionsWindow

