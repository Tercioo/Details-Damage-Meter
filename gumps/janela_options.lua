--[[ options panel file --]]

--[[
	1 - general
	2 - combat
	3 - skin
	4 - row settings
	5 - row texts
	6 - window settings
	7 - left menu
	8 - right menu
	9 - wallpaper
	10 - performance teaks
	11 - captures
	12 - plugins
	13 - profiles
	14 - attribute text
	15 - custom spells
	16 - data for charts
	17 - hide and show
	18 - misc settings
	19 - externals widgets
	20 - tooltip
--]]

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

_detalhes.options_window_background = [[Interface\AddOns\Details\images\options_window]]

function _detalhes:SetOptionsWindowTexture (texture)
	_detalhes.options_window_background = texture
	if (_G.DetailsOptionsWindowBackground) then
		_G.DetailsOptionsWindowBackground:SetTexture (texture)
	end
end

function _detalhes:OpenOptionsWindow (instance, no_reopen)

	if (not instance.meu_id) then
		instance, no_reopen = unpack (instance)
	end

	GameCooltip:Close()
	local window = _G.DetailsOptionsWindow
	
	local editing_instance = instance
	
	if (_G.DetailsOptionsWindow) then
		_G.DetailsOptionsWindow.instance = instance
	end
	
	if (not no_reopen and not instance:IsEnabled() or not instance:IsStarted()) then
		_detalhes.CriarInstancia (_, _, instance:GetId())
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
		
		window:SetHook ("OnHide", function()
			DetailsDisable3D:Hide()
			DetailsOptionsWindowDisable3D:SetChecked (false)
			window.Disable3DColorPick:Hide()
			window.Disable3DColorPick:Cancel()
			GameCooltip:Hide()
		end)
		
		--x 9 897 y 9 592
		
		local background = g:NewImage (window, _detalhes.options_window_background, 897, 592, nil, nil, "background", "$parentBackground")
		background:SetPoint (0, 0)
		background:SetDrawLayer ("border")
		background:SetTexCoord (0, 0.8759765625, 0, 0.578125)

		local bigdog = g:NewImage (window, [[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]], 180, 200, nil, {1, 0, 0, 1}, "backgroundBigDog", "$parentBackgroundBigDog")
		bigdog:SetPoint ("bottomright", window, "bottomright", -8, 31)
		bigdog:SetAlpha (.25)
		
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

		local desc_anchor_topright = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 75, 106, "artwork", {0.2724609375, 0.19921875, 0.6796875, 0.783203125}, "descAnchorTopRightImage", "$parentDescAnchorTopRightImage") --204 696 279 802
		desc_anchor_topright:SetPoint ("topleft", window.widget, "topleft", 796, -76)
		desc_anchor_topright:Hide()
		desc_anchor_topright:SetAlpha (.8)
		local desc_anchor_topleft = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 75, 106, "artwork", {0.19921875, 0.2724609375, 0.783203125, 0.6796875}, "descAnchorBottomLeftImage", "$parentDescAnchorBottomLeftImage") --204 696 279 802
		desc_anchor_topleft:SetPoint ("topleft", window.widget, "topleft", 191, -465)
		desc_anchor_topleft:Hide()
		desc_anchor_topleft:SetAlpha (.8)
		local desc_anchor_bottomleft = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 75, 106, "artwork", {0.19921875, 0.2724609375, 0.6796875, 0.783203125}, "descAnchorTopLeftImage", "$parentDescAnchorTopLeftImage") --204 696 279 802
		desc_anchor_bottomleft:SetPoint ("topleft", window.widget, "topleft", 191, -76)
		desc_anchor_bottomleft:Hide()
		desc_anchor_bottomleft:SetAlpha (.8)
		
		local desc_anchor = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 75, 106, "artwork", {0.19921875, 0.2724609375, 0.6796875, 0.783203125}, "descAnchorImage", "$parentDescAnchorImage") --204 696 279 802
		desc_anchor:SetPoint ("topleft", info_text, "topleft", -28, 33)
		
		local desc_background = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 253, 198, "artwork", {0.3193359375, 0.56640625, 0.685546875, 0.87890625}, "descBackgroundImage", "$parentDescBackgroundImage") -- 327 702 580 900
		desc_background:SetPoint ("topleft", info_text, "topleft", 0, 0)
		
		--> select instance dropbox
		local onSelectInstance = function (_, _, instance)
		
			local this_instance = _detalhes.tabela_instancias [instance]
			
			if (not this_instance:IsEnabled() or not this_instance:IsStarted()) then
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
					
					if (not CustomObject) then
						_this_instance:ResetAttribute()
						atributo = _this_instance.atributo
						sub_atributo = _this_instance.sub_atributo
						InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " " .. _detalhes.atributos.lista [atributo] .. " - " .. _detalhes.sub_atributos [atributo].lista [sub_atributo], onclick = onSelectInstance, icon = _detalhes.sub_atributos [atributo].icones[sub_atributo] [1], texcoord = _detalhes.sub_atributos [atributo].icones[sub_atributo] [2]}
					else
						InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " " .. CustomObject.name, onclick = onSelectInstance, icon = CustomObject.icon}
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
						local plugin_name = _this_instance.current_raid_plugin or _this_instance.last_raid_plugin
						if (plugin_name) then
							local plugin_object = _detalhes:GetPlugin (plugin_name)
							if (plugin_object) then
								InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " " .. plugin_object.__name, onclick = onSelectInstance, icon = plugin_object.__icon}
							else
								InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " unknown", onclick = onSelectInstance, icon = ""}
							end
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
			
			local total_damage = 0
			local total_heal = 0
			
			for i = 1, 10 do
				local robot = current_combat[1]:PegarCombatente (0x0000000000000, actors_name [math.random (1, #actors_name)], 0x114, true)
				robot.grupo = true
				robot.classe = actors_classes [math.random (1, #actors_classes)]
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
				
				total_heal = total_heal + robot.total
				
			end
			
			current_combat.start_time = time()-360
			current_combat.end_time = time()
			
			current_combat.totals_grupo [1] = total_damage
			current_combat.totals_grupo [2] = total_heal
			current_combat.totals [1] = total_damage
			current_combat.totals [2] = total_heal
			
			for _, instance in ipairs (_detalhes.tabela_instancias) do 
				if (instance:IsEnabled()) then
					instance:InstanceReset()
				end
			end
			
		end
		local fillbars = g:NewButton (window, _, "$parentCreateExampleBarsButton", nil, 110, 14, fill_bars, nil, nil, nil, "Create Test Bars")
		fillbars:SetPoint ("bottomleft", window.widget, "bottomleft", 200, 12)
		--fillbars:InstallCustomTexture()
		
	--> right click to close
		--local right_click_close = window:CreateRightClickLabel ("short", 14, 14, "Close")
		--right_click_close:SetPoint ("left", fillbars, "right", 90, 0)
		--_detalhes:SetFontColor (right_click_close.widget, {1, 0.82, 0, 1})
		--_detalhes:SetFontFace (right_click_close.widget, [[Fonts\FRIZQT__.TTF]])
		--_detalhes:SetFontOutline (right_click_close.widget, true)
		--_detalhes:SetFontSize (right_click_close.widget, 12)
		
	--> left panel buttons
		
local menus = { --labels nos menus
	{"Display", "Combat", "Tooltips", "Data Feed", "Profiles"},
	{"Skin Selection", "Row Settings", "Row Texts", "Show & Hide Settings", "Window Settings", "Title Text", "Menus: Left Buttons", "Menus: Right Buttons", "Wallpaper", "Miscellaneous"},
	{"Data Collector", "Performance Tweaks", "Plugins Management", "Spell Customization", "Data for Charts"}
}

		local menus2 = {
			"Display", --1
			"Combat", --2
			"Skin Selection", --3
			"Row Settings", --4
			"Row Texts", --5
			"Window Settings", --6
			"Menus: Left Buttons", --7
			"Menus: Right Buttons", --8
			"Wallpaper", --9
			"Performance Tweaks",--10
			"Data Collector", --11
			"Plugins Management",--12
			"Profiles", --13
			"Title Text", --14
			"Spell Customization", --15
			"Data for Charts", --16
			"Show & Hide Settings", --17
			"Miscellaneous", --18
			"Data Feed", --19
			"Tooltip", --20
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
				
				window.descAnchorTopLeftImage:Hide()
				window.descAnchorBottomLeftImage:Hide()
				window.descAnchorTopRightImage:Hide()
				
			else
				info_text:Hide()
				window.descAnchorImage:Hide()
				window.descBackgroundImage:Hide()
				window.descAnchorTopLeftImage:Show()
				window.descAnchorBottomLeftImage:Show()
				window.descAnchorTopRightImage:Show()
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
		--[
			--local g_performance = g:NewButton (window, _, "$parentPerformanceButton", "g_appearance", 150, 33, function() end, 0x3)

			--g:NewLabel (window, _, "$parentperformance_settings_text", "PerformanceSettingsLabel", Loc ["STRING_OPTIONS_PERFORMANCE"], "GameFontNormal", 12)
			--window.PerformanceSettingsLabel:SetPoint ("topleft", g_performance, "topleft", 35, -11)
		
			--local g_performance_texture = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 160, 33, nil, nil, "PerformanceSettingsTexture", "$parentPerformanceSettingsTexture")
			--g_performance_texture:SetTexCoord (0, 0.15625, 0.751953125, 0.7841796875)
			--g_performance_texture:SetPoint ("topleft", g_performance, "topleft", 0, 0)
		--]]
		--advanced
			local g_advanced = g:NewButton (window, _, "$parentAdvancedButton", "g_advanced", 150, 33, function() end, 0x4)
			
			g:NewLabel (window, _, "$parentadvanced_settings_text", "AdvancedSettingsLabel", Loc ["STRING_OPTIONS_ADVANCED"], "GameFontNormal", 12)
			window.AdvancedSettingsLabel:SetPoint ("topleft", g_advanced, "topleft", 35, -11)
		
			local g_advanced_texture = g:NewImage (window, [[Interface\AddOns\Details\images\options_window]], 160, 33, nil, nil, "AdvancedSettingsTexture", "$parentAdvancedSettingsTexture")
			g_advanced_texture:SetTexCoord (0, 0.15625, 0.8173828125, 0.849609375)
			g_advanced_texture:SetPoint ("topleft", g_advanced, "topleft", 0, 0)
			
		-- advanced

		
		--> index dos menus
		local menus_settings = {1, 2, 20, 19, 13, 3, 4, 5, 17, 6, 14, 7, 8, 9, 18, 11, 10, 12, 15, 16}
		
		
		--> create menus
		local anchors = {g_settings, g_appearance, g_advanced} --g_performance
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
			[18] = {}, --miscellaneous settings
			[19] = {}, --data feed widgets
			[20] = {}, --tooltips
		} --> vai armazenar os frames das opções
		
		
		function window:create_box_no_scroll (n)
			local container = CreateFrame ("Frame", "DetailsOptionsWindow" .. n, window.widget)

			container:SetScript ("OnMouseDown", function()
				if (not window.widget.isMoving) then
					window.widget:StartMoving()
					window.widget.isMoving = true
				end
			end)
			container:SetScript ("OnMouseUp", function (self, button)
				if (window.widget.isMoving) then
					window.widget:StopMovingOrSizing()
					window.widget.isMoving = false
				end
				if (button == "RightButton")then
					DetailsOptionsWindow:Hide()
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
			container_slave:SetScript ("OnMouseUp", function (self, button)
				if (window.widget.isMoving) then
					window.widget:StopMovingOrSizing()
					window.widget.isMoving = false
				end
				if (button == "RightButton")then
					DetailsOptionsWindow:Hide()
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
		table.insert (window.options [18], window:create_box_no_scroll (18))
		table.insert (window.options [19], window:create_box_no_scroll (19))
		table.insert (window.options [20], window:create_box_no_scroll (20))

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
		
		local background_on_mouse_down = function (self)
			if (not window.widget.isMoving) then
				window.widget:StartMoving()
				window.widget.isMoving = true
			end
		end
		
		local background_on_mouse_up = function (self, button)
			if (window.widget.isMoving) then
				window.widget:StopMovingOrSizing()
				window.widget.isMoving = false
			end
			if (button == "RightButton")then
				DetailsOptionsWindow:Hide()
			end
		end
		
		function window:create_line_background (frameX, label, parent)
			local f = CreateFrame ("frame", nil, frameX)
			f:SetPoint ("left", label.widget or label, "left", -2, 0)
			f:SetSize (260, 16)
			f:SetScript ("OnEnter", background_on_enter)
			f:SetScript ("OnLeave", background_on_leave)
			f:SetScript ("OnMouseDown", background_on_mouse_down)
			f:SetScript ("OnMouseUp", background_on_mouse_up)
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
			
			return f
		end
		
		function window:CreateLineBackground (frame, widget_name, label_name, desc_loc)
			frame [widget_name].info = desc_loc
			local f = window:create_line_background (frame, frame [label_name], frame [widget_name])
			frame [widget_name]:SetHook ("OnEnter", background_on_enter)
			frame [widget_name]:SetHook ("OnLeave", background_on_leave)
			return f
		end
		
		
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		

		
		local background_on_enter2 = function (self)
			if (self.background_frame) then
				self = self.background_frame
			end
			
			if (self.is_button) then
				self.label:SetTextColor ("white")
			else
				self.label:SetTextColor (1, .8, 0)
			end
			
			if (self.have_icon) then
				self.have_icon:SetBlendMode ("ADD")
			end
			
			if (self.MyObject and self.MyObject.have_icon) then
				self.MyObject.have_icon:SetBlendMode ("ADD")
			end
			
			if (self.parent and self.parent.info) then
				_detalhes:CooltipPreset (2)
				GameCooltip:AddLine (self.parent.info)
				GameCooltip:ShowCooltip (self, "tooltip")
				return true
			end
			
		end
		
		local background_on_leave2 = function (self)
			if (self.background_frame) then
				self = self.background_frame
			end
			
			if (self.have_icon) then
				self.have_icon:SetBlendMode ("BLEND")
			end
			if (self.MyObject and self.MyObject.have_icon) then
				self.MyObject.have_icon:SetBlendMode ("BLEND")
			end
			
			GameCooltip:Hide()
			
			if (self.is_button) then
				self.label:SetTextColor ({1, 0.8, 0})
			else
				self.label:SetTextColor (1, 1, 1)
			end
		end
		
		function window:create_line_background2 (frameX, label, parent, icon, is_button)
			local f = CreateFrame ("frame", nil, frameX)
			f:SetPoint ("left", label.widget or label, "left", -2, 0)
			f:SetSize (260, 16)
			f.is_button = is_button
			f:SetScript ("OnEnter", background_on_enter2)
			f:SetScript ("OnLeave", background_on_leave2)
			f:SetScript ("OnMouseDown", background_on_mouse_down)
			f:SetScript ("OnMouseUp", background_on_mouse_up)
			f:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}})		
			f:SetBackdropColor (0, 0, 0, 0)
			f.parent = parent
			f.label = label
			f.have_icon = icon
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
			
			return f
		end		
		
		function window:CreateLineBackground2 (frame, widget_name, label_name, desc_loc, icon, is_button)
		
			if (type (widget_name) == "table") then
				widget_name.info = desc_loc
				widget_name.have_tooltip = desc_loc
				widget_name.have_icon = icon
				local f = window:create_line_background2 (frame, label_name, widget_name, icon)
				if (widget_name.SetHook) then
					widget_name:SetHook ("OnEnter", background_on_enter2)
					widget_name:SetHook ("OnLeave", background_on_leave2)
				else
					widget_name:SetScript ("OnEnter", background_on_enter2)
					widget_name:SetScript ("OnLeave", background_on_leave2)
				end
				return f
			end
		
			frame [widget_name].info = desc_loc
			frame [widget_name].have_tooltip = desc_loc
			frame [widget_name].have_icon = icon
			local f = window:create_line_background2 (frame, frame [label_name], frame [widget_name], icon, is_button)
			frame [widget_name]:SetHook ("OnEnter", background_on_enter2)
			frame [widget_name]:SetHook ("OnLeave", background_on_leave2)
			f.is_button = is_button
			frame [widget_name].is_button = is_button
			return f
		end
		
		select_options (1)
		
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		window.left_start_at = 30
		window.right_start_at = 360
		window.top_start_at = -90
		
		function window:arrange_menu (frame, t, x, y_start)		
			local y = y_start
		
			table.sort (t, function (a, b) return a[2] < b[2] end)
		
			for index, _table in ipairs (t) do
				local widget = _table [1]
				local istitle = _table [3]

				if (type (istitle) == "boolean" and istitle and y ~= y_start) then
					y = y - 10
				elseif (type (istitle) == "boolean" and not istitle and y ~= y_start) then
					y = y + 5 
				end

				if (type (widget) == "string") then
					widget = frame [widget]
				end
				widget:SetPoint (x, y)
				y = y - 25
			end
		end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Advanced Settings - Tooltips ~20
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function window:CreateFrame20()

	local frame20 = window.options [20][1]

		local titulo_tooltips = g:NewLabel (frame20, _, "$parentTituloTooltipsText", "tooltipsTituloLabel", Loc ["STRING_OPTIONS_TOOLTIPS_TITLE"], "GameFontNormal", 16)
		local titulo_tooltips_desc = g:NewLabel (frame20, _, "$parentTituloTooltipsText2", "tooltips2TituloLabel", Loc ["STRING_OPTIONS_TOOLTIPS_TITLE_DESC"], "GameFontNormal", 9, "white")
		titulo_tooltips_desc.width = 350
		titulo_tooltips_desc.height = 20
		
		-- text color
		local tooltip_text_color_callback = function (button, r, g, b, a)
			_detalhes.tooltip.fontcolor = {r, g, b, a}
		end
		g:NewColorPickButton (frame20, "$parentTooltipTextColorPick", "TooltipTextColorPick", tooltip_text_color_callback)
		g:NewLabel (frame20, _, "$parentTooltipTextColorLabel", "TooltipTextColorLabel", Loc ["STRING_OPTIONS_TOOLTIPS_FONTCOLOR"], "GameFontHighlightLeft")
		frame20.TooltipTextColorPick:SetPoint ("left", frame20.TooltipTextColorLabel, "right", 2, 0)
		window:CreateLineBackground2 (frame20, "TooltipTextColorPick", "TooltipTextColorLabel", Loc ["STRING_OPTIONS_TOOLTIPS_FONTCOLOR_DESC"])
			
		-- text size
		g:NewLabel (frame20, _, "$parentTooltipTextSizeLabel", "TooltipTextSizeLabel", Loc ["STRING_OPTIONS_TOOLTIPS_FONTSIZE"], "GameFontHighlightLeft")
		local s = g:NewSlider (frame20, _, "$parentTooltipTextSizeSlider", "TooltipTextSizeSlider", SLIDER_WIDTH, 20, 8, 25, 1, tonumber (_detalhes.tooltip.fontsize))
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)
	
		frame20.TooltipTextSizeSlider:SetPoint ("left", frame20.TooltipTextSizeLabel, "right", 2)
		frame20.TooltipTextSizeSlider:SetHook ("OnValueChange", function (self, _, amount)
			_detalhes.tooltip.fontsize = amount
		end)
		window:CreateLineBackground2 (frame20, "TooltipTextSizeSlider", "TooltipTextSizeLabel", Loc ["STRING_OPTIONS_TOOLTIPS_FONTSIZE_DESC"])
		
		-- text face
		local on_select_tooltip_font = function (self, _, fontName)
			_detalhes.tooltip.fontface = fontName
		end

		local build_tooltip_menu = function() 
			local fonts = {}
			for name, fontPath in pairs (SharedMedia:HashTable ("font")) do 
				fonts [#fonts+1] = {value = name, label = name, onclick = on_select_tooltip_font, font = fontPath, descfont = name, desc = "Our thoughts strayed constantly\nAnd without boundary\nThe ringing of the division bell had began."}
			end
			table.sort (fonts, function (t1, t2) return t1.label < t2.label end)
			return fonts 
		end

		g:NewLabel (frame20, _, "$parentTooltipFontLabel", "TooltipFontLabel", Loc ["STRING_OPTIONS_TOOLTIPS_FONTFACE"] , "GameFontHighlightLeft")
		local d = g:NewDropDown (frame20, _, "$parentTooltipFontDropdown", "TooltipFontDropdown", DROPDOWN_WIDTH, 20, build_tooltip_menu, _detalhes.tooltip.fontface)
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		frame20.TooltipFontDropdown:SetPoint ("left", frame20.TooltipFontLabel, "right", 2)
		
		window:CreateLineBackground2 (frame20, "TooltipFontDropdown", "TooltipFontLabel", Loc ["STRING_OPTIONS_TOOLTIPS_FONTFACE_DESC"])
		
		-- text shadow
		g:NewLabel (frame20, _, "$parentTooltipShadowLabel", "TooltipShadowLabel", Loc ["STRING_OPTIONS_TOOLTIPS_FONTSHADOW"], "GameFontHighlightLeft")
		g:NewSwitch (frame20, _, "$parentTooltipShadowSwitch", "TooltipShadowSwitch", 60, 20, nil, nil, _detalhes.tooltip.fontshadow)
		frame20.TooltipShadowSwitch:SetPoint ("left", frame20.TooltipShadowLabel, "right", 2)
		frame20.TooltipShadowSwitch.OnSwitch = function (self, _, value)
			_detalhes.tooltip.fontshadow = value
		end
		window:CreateLineBackground2 (frame20, "TooltipShadowSwitch", "TooltipShadowLabel", Loc ["STRING_OPTIONS_TOOLTIPS_FONTSHADOW_DESC"])
			
		-- background color
		local tooltip_background_color_callback = function (button, r, g, b, a)
			_detalhes.tooltip.background = {r, g, b, a}
		end
		g:NewColorPickButton (frame20, "$parentTooltipBackgroundColorPick", "TooltipBackgroundColorPick", tooltip_background_color_callback)
		g:NewLabel (frame20, _, "$parentTooltipBackgroundColorLabel", "TooltipBackgroundColorLabel", Loc ["STRING_OPTIONS_TOOLTIPS_BACKGROUNDCOLOR"], "GameFontHighlightLeft")
		frame20.TooltipBackgroundColorPick:SetPoint ("left", frame20.TooltipBackgroundColorLabel, "right", 2, 0)
		window:CreateLineBackground2 (frame20, "TooltipBackgroundColorPick", "TooltipBackgroundColorLabel", Loc ["STRING_OPTIONS_TOOLTIPS_BACKGROUNDCOLOR_DESC"])
		
		-- abbreviation method
		g:NewLabel (frame20, _, "$parentTooltipDpsAbbreviateLabel", "TooltipdpsAbbreviateLabel", Loc ["STRING_OPTIONS_TOOLTIPS_ABBREVIATION"], "GameFontHighlightLeft")
		--
		local onSelectTimeAbbreviation = function (_, _, abbreviationtype)
			_detalhes.tooltip.abbreviation = abbreviationtype
			
			_detalhes.atributo_damage:UpdateSelectedToKFunction()
			_detalhes.atributo_heal:UpdateSelectedToKFunction()
			_detalhes.atributo_energy:UpdateSelectedToKFunction()
			_detalhes.atributo_misc:UpdateSelectedToKFunction()
			_detalhes.atributo_custom:UpdateSelectedToKFunction()
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
			{value = 7, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK0MIN"], desc = "Example: 25.305.500 -> 25m", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor}, --, desc = ""
			{value = 8, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_COMMA"], desc = "Example: 25305500 -> 25.305.500", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor} --, desc = ""
		}
		local buildAbbreviationMenu = function()
			return abbreviationOptions
		end
		
		local d = g:NewDropDown (frame20, _, "$parentTooltipAbbreviateDropdown", "TooltipdpsAbbreviateDropdown", 160, 20, buildAbbreviationMenu, _detalhes.tooltip.abbreviation)
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		frame20.TooltipdpsAbbreviateDropdown:SetPoint ("left", frame20.TooltipdpsAbbreviateLabel, "right", 2, 0)		
		
		window:CreateLineBackground2 (frame20, "TooltipdpsAbbreviateDropdown", "TooltipdpsAbbreviateLabel", Loc ["STRING_OPTIONS_TOOLTIPS_ABBREVIATION_DESC"])
			
		-- maximize
		g:NewLabel (frame20, _, "$parentTooltipMaximizeLabel", "TooltipMaximizeLabel", Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE"], "GameFontHighlightLeft")
		local onSelectMaximize = function (_, _, maximizeType)
			_detalhes.tooltip.maximize_method = maximizeType
			_detalhes.atributo_damage:UpdateSelectedToKFunction()
			_detalhes.atributo_heal:UpdateSelectedToKFunction()
			_detalhes.atributo_energy:UpdateSelectedToKFunction()
			_detalhes.atributo_misc:UpdateSelectedToKFunction()
			_detalhes.atributo_custom:UpdateSelectedToKFunction()
		end
		
		local icon = [[Interface\Buttons\UI-Panel-BiggerButton-Up]]
		local iconcolor = {1, 1, 1, 1}
		local iconcord = {0.1875, 0.78125+0.109375, 0.78125+0.109375+0.03, 0.21875-0.109375-0.03}
		
		local maximizeOptions = {
			{value = 1, label = Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE1"], onclick = onSelectMaximize, icon = icon, iconcolor = iconcolor, texcoord = iconcord}, --, desc = ""
			{value = 2, label = Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE2"], onclick = onSelectMaximize, icon = icon, iconcolor = iconcolor, texcoord = iconcord}, --, desc = ""
			{value = 3, label = Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE3"], onclick = onSelectMaximize, icon = icon, iconcolor = iconcolor, texcoord = iconcord}, --, desc = ""
			{value = 4, label = Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE4"], onclick = onSelectMaximize, icon = icon, iconcolor = iconcolor, texcoord = iconcord}, --, desc = ""
			{value = 5, label = Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE5"], onclick = onSelectMaximize, icon = icon, iconcolor = iconcolor, texcoord = iconcord}, --, desc = ""
		}
		local buildMaximizeMenu = function()
			return maximizeOptions
		end
		
		local d = g:NewDropDown (frame20, _, "$parentTooltipMaximizeDropdown", "TooltipMaximizeDropdown", 160, 20, buildMaximizeMenu, _detalhes.tooltip.maximize_method)
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		frame20.TooltipMaximizeDropdown:SetPoint ("left", frame20.TooltipMaximizeLabel, "right", 2, 0)		
		
		window:CreateLineBackground2 (frame20, "TooltipMaximizeDropdown", "TooltipMaximizeLabel", Loc ["STRING_OPTIONS_TOOLTIPS_MAXIMIZE_DESC"])
		
		--show amount
		g:NewLabel (frame20, _, "$parentTooltipShowAmountLabel", "TooltipShowAmountLabel", Loc ["STRING_OPTIONS_TOOLTIPS_SHOWAMT"], "GameFontHighlightLeft")
		g:NewSwitch (frame20, _, "$parentTooltipShowAmountSlider", "TooltipShowAmountSlider", 60, 20, _, _, _detalhes.tooltip.show_amount)
		frame20.TooltipShowAmountSlider:SetPoint ("left", frame20.TooltipShowAmountLabel, "right", 2)

		frame20.TooltipShowAmountSlider.OnSwitch = function (self, _, value)
			_detalhes.tooltip.show_amount = value
		end
		
		window:CreateLineBackground2 (frame20, "TooltipShowAmountSlider", "TooltipShowAmountLabel", Loc ["STRING_OPTIONS_TOOLTIPS_SHOWAMT_DESC"])
		
	--> tooltip anchors

		--unlock screen anchor
			g:NewLabel (frame20, _, "$parentUnlockAnchorButtonLabel", "UnlockAnchorButtonLabel", "", "GameFontHighlightLeft")
			
			local unlock_function = function()
				DetailsTooltipAnchor:MoveAnchor()
			end
			local unlock_anchor_button = g:NewButton (frame20, nil, "$parentUnlockAnchorButton", "UnlockAnchorButton", 160, 20, unlock_function, nil, nil, nil, Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO_CHOOSE"])
			unlock_anchor_button:InstallCustomTexture()
	
			if (_detalhes.tooltip.anchored_to == 1) then
				unlock_anchor_button:Disable()
			else
				unlock_anchor_button:Enable()
			end
			
			frame20.UnlockAnchorButton:SetPoint ("left", frame20.UnlockAnchorButtonLabel, "right", 0, 0)
			window:CreateLineBackground2 (frame20, "UnlockAnchorButton", "UnlockAnchorButtonLabel", Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO_CHOOSE_DESC"])

		--main anchor
			g:NewLabel (frame20, _, "$parentTooltipAnchorLabel", "TooltipAnchorLabel", Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO"], "GameFontHighlightLeft")
			local onSelectAnchor = function (_, _, selected_anchor)
				_detalhes.tooltip.anchored_to = selected_anchor
				if (selected_anchor == 1) then
					unlock_anchor_button:Disable()
				else
					unlock_anchor_button:Enable()
				end
			end
			
			local anchorOptions = {
				{value = 1, label = Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO1"], onclick = onSelectAnchor, icon = [[Interface\Buttons\UI-GuildButton-OfficerNote-Disabled]]},
				{value = 2, label = Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO2"], onclick = onSelectAnchor, icon = [[Interface\Buttons\UI-GuildButton-OfficerNote-Disabled]]},
			}
			local buildAnchorMenu = function()
				return anchorOptions
			end
			
			local d = g:NewDropDown (frame20, _, "$parentTooltipAnchorDropdown", "TooltipAnchorDropdown", 160, 20, buildAnchorMenu, _detalhes.tooltip.anchored_to)
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
			
			frame20.TooltipAnchorDropdown:SetPoint ("left", frame20.TooltipAnchorLabel, "right", 2, 0)
			
			window:CreateLineBackground2 (frame20, "TooltipAnchorDropdown", "TooltipAnchorLabel", Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO_DESC"])

			unlock_anchor_button:SetWidth (frame20.TooltipAnchorLabel:GetStringWidth() + 2 + frame20.TooltipAnchorDropdown:GetWidth())
			
		--tooltip side
			g:NewLabel (frame20, _, "$parentTooltipAnchorSideLabel", "TooltipAnchorSideLabel", Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_ATTACH"], "GameFontHighlightLeft")
			local onSelectAnchorPoint = function (_, _, selected_anchor)
				_detalhes.tooltip.anchor_point = selected_anchor
			end
			
			local anchorPointOptions = {
				{value = "top", label = Loc ["STRING_ANCHOR_TOP"], onclick = onSelectAnchorPoint, icon = [[Interface\Buttons\Arrow-Up-Up]], texcoord = {0, 0.8125, 0.1875, 0.875}},
				{value = "bottom", label = Loc ["STRING_ANCHOR_BOTTOM"], onclick = onSelectAnchorPoint, icon = [[Interface\Buttons\Arrow-Up-Up]], texcoord = {0, 0.875, 1, 0.1875}},
				{value = "left", label = Loc ["STRING_ANCHOR_LEFT"], onclick = onSelectAnchorPoint, icon = [[Interface\CHATFRAME\UI-InChatFriendsArrow]], texcoord = {0.5, 0, 0, 0.8125}},
				{value = "right", label = Loc ["STRING_ANCHOR_RIGHT"], onclick = onSelectAnchorPoint, icon = [[Interface\CHATFRAME\UI-InChatFriendsArrow]], texcoord = {0, 0.5, 0, 0.8125}},
				{value = "topleft", label = Loc ["STRING_ANCHOR_TOPLEFT"], onclick = onSelectAnchorPoint, icon = [[Interface\Buttons\UI-AutoCastableOverlay]], texcoord = {0.796875, 0.609375, 0.1875, 0.375}},
				{value = "bottomleft", label = Loc ["STRING_ANCHOR_BOTTOMLEFT"], onclick = onSelectAnchorPoint, icon = [[Interface\Buttons\UI-AutoCastableOverlay]], texcoord = {0.796875, 0.609375, 0.375, 0.1875}},
				{value = "topright", label = Loc ["STRING_ANCHOR_TOPRIGHT"], onclick = onSelectAnchorPoint, icon = [[Interface\Buttons\UI-AutoCastableOverlay]], texcoord = {0.609375, 0.796875, 0.1875, 0.375}},
				{value = "bottomright", label = Loc ["STRING_ANCHOR_BOTTOMRIGHT"], onclick = onSelectAnchorPoint, icon = [[Interface\Buttons\UI-AutoCastableOverlay]], texcoord = {0.609375, 0.796875, 0.375, 0.1875}},
			}
			
			local buildAnchorPointMenu = function()
				return anchorPointOptions
			end
			
			local d = g:NewDropDown (frame20, _, "$parentTooltipAnchorSideDropdown", "TooltipAnchorSideDropdown", 160, 20, buildAnchorPointMenu, _detalhes.tooltip.anchor_point)
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
			
			frame20.TooltipAnchorSideDropdown:SetPoint ("left", frame20.TooltipAnchorSideLabel, "right", 2, 0)		
			
			window:CreateLineBackground2 (frame20, "TooltipAnchorSideDropdown", "TooltipAnchorSideLabel", Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_ATTACH_DESC"])

		--tooltip relative side
			g:NewLabel (frame20, _, "$parentTooltipRelativeSideLabel", "TooltipRelativeSideLabel", Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_RELATIVE"], "GameFontHighlightLeft")
			local onSelectAnchorRelative = function (_, _, selected_anchor)
				_detalhes.tooltip.anchor_relative = selected_anchor
			end
			
			local anchorRelativeOptions = {
				{value = "top", label = Loc ["STRING_ANCHOR_TOP"], onclick = onSelectAnchorRelative, icon = [[Interface\Buttons\Arrow-Up-Up]], texcoord = {0, 0.8125, 0.1875, 0.875}},
				{value = "bottom", label = Loc ["STRING_ANCHOR_BOTTOM"], onclick = onSelectAnchorRelative, icon = [[Interface\Buttons\Arrow-Up-Up]], texcoord = {0, 0.875, 1, 0.1875}},
				{value = "left", label = Loc ["STRING_ANCHOR_LEFT"], onclick = onSelectAnchorRelative, icon = [[Interface\CHATFRAME\UI-InChatFriendsArrow]], texcoord = {0.5, 0, 0, 0.8125}},
				{value = "right", label = Loc ["STRING_ANCHOR_RIGHT"], onclick = onSelectAnchorRelative, icon = [[Interface\CHATFRAME\UI-InChatFriendsArrow]], texcoord = {0, 0.5, 0, 0.8125}},
				{value = "topleft", label = Loc ["STRING_ANCHOR_TOPLEFT"], onclick = onSelectAnchorRelative, icon = [[Interface\Buttons\UI-AutoCastableOverlay]], texcoord = {0.796875, 0.609375, 0.1875, 0.375}},
				{value = "bottomleft", label = Loc ["STRING_ANCHOR_BOTTOMLEFT"], onclick = onSelectAnchorRelative, icon = [[Interface\Buttons\UI-AutoCastableOverlay]], texcoord = {0.796875, 0.609375, 0.375, 0.1875}},
				{value = "topright", label = Loc ["STRING_ANCHOR_TOPRIGHT"], onclick = onSelectAnchorRelative, icon = [[Interface\Buttons\UI-AutoCastableOverlay]], texcoord = {0.609375, 0.796875, 0.1875, 0.375}},
				{value = "bottomright", label = Loc ["STRING_ANCHOR_BOTTOMRIGHT"], onclick = onSelectAnchorRelative, icon = [[Interface\Buttons\UI-AutoCastableOverlay]], texcoord = {0.609375, 0.796875, 0.375, 0.1875}},
			}
			
			local buildAnchorRelativeMenu = function()
				return anchorRelativeOptions
			end
			
			local d = g:NewDropDown (frame20, _, "$parentTooltipRelativeSideDropdown", "TooltipRelativeSideDropdown", 160, 20, buildAnchorRelativeMenu, _detalhes.tooltip.anchor_relative)
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
			
			frame20.TooltipRelativeSideDropdown:SetPoint ("left", frame20.TooltipRelativeSideLabel, "right", 2, 0)		
			
			window:CreateLineBackground2 (frame20, "TooltipRelativeSideDropdown", "TooltipRelativeSideLabel", Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_RELATIVE_DESC"])

		--tooltip offset
			g:NewLabel (frame20, _, "$parentTooltipOffsetXLabel", "TooltipOffsetXLabel", Loc ["STRING_OPTIONS_TOOLTIPS_OFFSETX"], "GameFontHighlightLeft")
			local s = g:NewSlider (frame20, _, "$parentTooltipOffsetXSlider", "TooltipOffsetXSlider", SLIDER_WIDTH, 20, -100, 100, 1, tonumber (_detalhes.tooltip.anchor_offset[1]))
			s:SetBackdrop (slider_backdrop)
			s:SetBackdropColor (unpack (slider_backdrop_color))
			s:SetThumbSize (50)
		
			frame20.TooltipOffsetXSlider:SetPoint ("left", frame20.TooltipOffsetXLabel, "right", 2)
			frame20.TooltipOffsetXSlider:SetHook ("OnValueChange", function (self, _, amount)
				_detalhes.tooltip.anchor_offset[1] = amount
			end)
			window:CreateLineBackground2 (frame20, "TooltipOffsetXSlider", "TooltipOffsetXLabel", Loc ["STRING_OPTIONS_TOOLTIPS_OFFSETX_DESC"])
			
			g:NewLabel (frame20, _, "$parentTooltipOffsetYLabel", "TooltipOffsetYLabel", Loc ["STRING_OPTIONS_TOOLTIPS_OFFSETY"], "GameFontHighlightLeft")
			local s = g:NewSlider (frame20, _, "$parentTooltipOffsetYSlider", "TooltipOffsetYSlider", SLIDER_WIDTH, 20, -100, 100, 1, tonumber (_detalhes.tooltip.anchor_offset[2]))
			s:SetBackdrop (slider_backdrop)
			s:SetBackdropColor (unpack (slider_backdrop_color))
			s:SetThumbSize (50)
		
			frame20.TooltipOffsetYSlider:SetPoint ("left", frame20.TooltipOffsetYLabel, "right", 2)
			frame20.TooltipOffsetYSlider:SetHook ("OnValueChange", function (self, _, amount)
				_detalhes.tooltip.anchor_offset[2] = amount
			end)
			window:CreateLineBackground2 (frame20, "TooltipOffsetYSlider", "TooltipOffsetYLabel", Loc ["STRING_OPTIONS_TOOLTIPS_OFFSETY_DESC"])

	--> anchors:
	
		--general anchor
		g:NewLabel (frame20, _, "$parentTooltipsTextsAnchor", "TooltipsTextsAnchorLabel", Loc ["STRING_OPTIONS_TOOLTIP_ANCHORTEXTS"], "GameFontNormal")
		g:NewLabel (frame20, _, "$parentTooltipsAnchor", "TooltipsAnchorLabel", Loc ["STRING_OPTIONS_TOOLTIP_ANCHOR"], "GameFontNormal")
		
		g:NewLabel (frame20, _, "$parentTooltipsAnchorPoint", "TooltipsAnchorPointLabel", Loc ["STRING_OPTIONS_TOOLTIPS_ANCHOR_POINT"], "GameFontNormal")
		
		local x = window.left_start_at
		
		titulo_tooltips:SetPoint (x, -30)
		titulo_tooltips_desc:SetPoint (x, -50)
		
		local left_side = {
			{"TooltipsTextsAnchorLabel", 1, true},
			{"TooltipTextColorLabel", 2},
			{"TooltipTextSizeLabel", 3},
			{"TooltipFontLabel", 4},
			{"TooltipShadowLabel", 5},
			{"TooltipsAnchorLabel", 6, true},
			{"TooltipBackgroundColorLabel", 7},
			{"TooltipdpsAbbreviateLabel", 8},
			{"TooltipMaximizeLabel", 9},
			{"TooltipShowAmountLabel", 10},

		}
		
		window:arrange_menu (frame20, left_side, x, -90)
		
		x = window.right_start_at
		
		local right_side = {
			{"TooltipsAnchorPointLabel", 1, true},
			{"TooltipAnchorLabel", 2},
			{"UnlockAnchorButtonLabel", 3, true},
			{"TooltipAnchorSideLabel", 4},
			{"TooltipRelativeSideLabel", 5},
			{"TooltipOffsetXLabel", 6},
			{"TooltipOffsetYLabel", 7},
		}
		
		window:arrange_menu (frame20, right_side, x, -90)
		
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Advanced Settings - Data Feed Widgets ~19
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function window:CreateFrame19()
	
	local frame19 = window.options [19][1]

		local titulo_externals = g:NewLabel (frame19, _, "$parentTituloExternalsText", "ExternalsTituloLabel", Loc ["STRING_OPTIONS_EXTERNALS_TITLE"], "GameFontNormal", 16)
		local titulo_externals_desc = g:NewLabel (frame19, _, "$parentTituloExternalsText2", "Externals2TituloLabel", Loc ["STRING_OPTIONS_EXTERNALS_TITLE2"], "GameFontNormal", 9, "white")
		titulo_externals_desc.width = 350
		titulo_externals_desc.height = 20
	
	--> minimap  
		--anchor
		g:NewLabel (frame19, _, "$parentMinimapAnchor", "minimapAnchorLabel", Loc ["STRING_OPTIONS_MINIMAP_ANCHOR"], "GameFontNormal")
		
		--show or hide
			g:NewLabel (frame19, _, "$parentMinimapLabel", "minimapLabel", Loc ["STRING_OPTIONS_MINIMAP"], "GameFontHighlightLeft")
			g:NewSwitch (frame19, _, "$parentMinimapSlider", "minimapSlider", 60, 20, _, _, not _detalhes.minimap.hide)
			
			frame19.minimapSlider:SetPoint ("left", frame19.minimapLabel, "right", 2, 0)
			frame19.minimapSlider.OnSwitch = function (self, _, value)
				_detalhes.minimap.hide = not value
				
				LDBIcon:Refresh ("Details!", _detalhes.minimap)
				if (_detalhes.minimap.hide) then
					LDBIcon:Hide ("Details!")
				else
					LDBIcon:Show ("Details!")
				end
			end
			window:CreateLineBackground2 (frame19, "minimapSlider", "minimapLabel", Loc ["STRING_OPTIONS_MINIMAP_DESC"])

		--on click action
			do
				g:NewLabel (frame19, _, "$parentMinimapActionLabel", "minimapActionLabel", Loc ["STRING_OPTIONS_MINIMAP_ACTION"], "GameFontHighlightLeft")
				local on_select = function (_, _, option)
					_detalhes.minimap.onclick_what_todo = option
				end
				local build_menu = function()
					return {
						{value = 1, label = Loc ["STRING_OPTIONS_MINIMAP_ACTION1"], onclick = on_select, icon = [[Interface\FriendsFrame\FriendsFrameScrollIcon]]},
						{value = 2, label = Loc ["STRING_OPTIONS_MINIMAP_ACTION2"], onclick = on_select, icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Up]], iconcolor = {1, .8, 0, 1}},
					}
				end
				local dropdown = g:NewDropDown (frame19, _, "$parentMinimapActionDropdown", "minimapActionDropdown", 160, 20, build_menu, _detalhes.minimap.onclick_what_todo)
				dropdown.onenter_backdrop = dropdown_backdrop_onenter
				dropdown.onleave_backdrop = dropdown_backdrop_onleave
				dropdown:SetBackdrop (dropdown_backdrop)
				dropdown:SetBackdropColor (unpack (dropdown_backdrop_onleave))
				
				frame19.minimapActionDropdown:SetPoint ("left", frame19.minimapActionLabel, "right", 2, 0)
				window:CreateLineBackground2 (frame19, "minimapActionDropdown", "minimapActionLabel", Loc ["STRING_OPTIONS_MINIMAP_ACTION_DESC"])
			end
	--> hot corner
	
		--anchor
		g:NewLabel (frame19, _, "$parentHotcornerAnchor", "hotcornerAnchorLabel", Loc ["STRING_OPTIONS_HOTCORNER_ANCHOR"], "GameFontNormal")
		
		--show or hide
			g:NewLabel (frame19, _, "$parentHotcornerLabel", "hotcornerLabel", Loc ["STRING_OPTIONS_HOTCORNER"], "GameFontHighlightLeft")
			g:NewSwitch (frame19, _, "$parentHotcornerSlider", "hotcornerSlider", 60, 20, _, _, not _detalhes.hotcorner_topleft.hide)
			
			frame19.hotcornerSlider:SetPoint ("left", frame19.hotcornerLabel, "right", 2, 0)
			frame19.hotcornerSlider.OnSwitch = function (self, _, value)
				_detalhes:HideHotCornerButton ("Details!", "TOPLEFT", not value)
			end
			window:CreateLineBackground2 (frame19, "hotcornerSlider", "hotcornerLabel", Loc ["STRING_OPTIONS_HOTCORNER_DESC"])
			
		--on click action
			do
				g:NewLabel (frame19, _, "$parentHotcornerActionLabel", "hotcornerActionLabel", Loc ["STRING_OPTIONS_HOTCORNER_ACTION"], "GameFontHighlightLeft")
				local on_select = function (_, _, option)
					_detalhes.hotcorner_topleft.onclick_what_todo = option
				end
				local build_menu = function()
					return {
						{value = 1, label = Loc ["STRING_OPTIONS_MINIMAP_ACTION1"], onclick = on_select, icon = [[Interface\FriendsFrame\FriendsFrameScrollIcon]]},
						{value = 2, label = Loc ["STRING_OPTIONS_MINIMAP_ACTION2"], onclick = on_select, icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Up]], iconcolor = {1, .8, 0, 1}},
					}
				end
				local dropdown = g:NewDropDown (frame19, _, "$parentHotcornerActionDropdown", "hotcornerActionDropdown", 160, 20, build_menu, _detalhes.hotcorner_topleft.onclick_what_todo)
				dropdown.onenter_backdrop = dropdown_backdrop_onenter
				dropdown.onleave_backdrop = dropdown_backdrop_onleave
				dropdown:SetBackdrop (dropdown_backdrop)
				dropdown:SetBackdropColor (unpack (dropdown_backdrop_onleave))
				
				frame19.hotcornerActionDropdown:SetPoint ("left", frame19.hotcornerActionLabel, "right", 2, 0)
				window:CreateLineBackground2 (frame19, "hotcornerActionDropdown", "hotcornerActionLabel", Loc ["STRING_OPTIONS_HOTCORNER_ACTION_DESC"])
			end
			
		--quick click enabled
			g:NewLabel (frame19, _, "$parentHotcornerQuickClickLabel", "hotcornerQuickClickLabel", Loc ["STRING_OPTIONS_HOTCORNER_QUICK_CLICK"], "GameFontHighlightLeft")
			g:NewSwitch (frame19, _, "$parentHotcornerQuickClickSlider", "hotcornerQuickClickSlider", 60, 20, _, _, _detalhes.hotcorner_topleft.topleft_quick_click)
			
			frame19.hotcornerQuickClickSlider:SetPoint ("left", frame19.hotcornerQuickClickLabel, "right", 2, 0)
			frame19.hotcornerQuickClickSlider.OnSwitch = function (self, _, value)
				_detalhes:QuickHotCornerEnable ("Details!", "TOPLEFT", value)
			end
			window:CreateLineBackground2 (frame19, "hotcornerQuickClickSlider", "hotcornerQuickClickLabel", Loc ["STRING_OPTIONS_HOTCORNER_QUICK_CLICK_DESC"])

		--quick click function
			do
				g:NewLabel (frame19, _, "$parentQuickClickLabel", "quickClickLabel", Loc ["STRING_OPTIONS_HOTCORNER_QUICK_CLICK_FUNC"], "GameFontHighlightLeft")
				local on_select = function (_, _, option)
					_detalhes.hotcorner_topleft.quickclick_what_todo = option
				end
				local build_menu = function()
					return {
						{value = 1, label = Loc ["STRING_OPTIONS_MINIMAP_ACTION1"], onclick = on_select, icon = [[Interface\FriendsFrame\FriendsFrameScrollIcon]]},
						{value = 2, label = Loc ["STRING_OPTIONS_MINIMAP_ACTION2"], onclick = on_select, icon = [[Interface\Buttons\UI-GuildButton-PublicNote-Up]], iconcolor = {1, .8, 0, 1}},
					}
				end
				local dropdown = g:NewDropDown (frame19, _, "$parentQuickClickDropdown", "quickClickDropdown", 160, 20, build_menu, _detalhes.hotcorner_topleft.quickclick_what_todo)
				dropdown.onenter_backdrop = dropdown_backdrop_onenter
				dropdown.onleave_backdrop = dropdown_backdrop_onleave
				dropdown:SetBackdrop (dropdown_backdrop)
				dropdown:SetBackdropColor (unpack (dropdown_backdrop_onleave))
				
				frame19.quickClickDropdown:SetPoint ("left", frame19.quickClickLabel, "right", 2, 0)
				window:CreateLineBackground2 (frame19, "quickClickDropdown", "quickClickLabel", Loc ["STRING_OPTIONS_HOTCORNER_QUICK_CLICK_FUNC_DESC"])
			end
	--> broker
		--anchor
		g:NewLabel (frame19, _, "$parentHotcornerAnchor", "brokerAnchorLabel", Loc ["STRING_OPTIONS_DATABROKER"], "GameFontNormal")
		
		--broker text
			do
				g:NewLabel (frame19, _, "$parentBrokerTextLabel", "brokerTextLabel", Loc ["STRING_OPTIONS_DATABROKER_TEXT"], "GameFontHighlightLeft")
				local on_select = function (_, _, option)
					_detalhes.minimap.text_type = option
				end
				local build_menu = function()
					return {
						{value = 1, label = Loc ["STRING_OPTIONS_DATABROKER_TEXT1"], onclick = on_select, icon = "Interface\\AddOns\\Details\\images\\atributos_icones", texcoord = {0, 0.125, 0, 1}},
						{value = 2, label = Loc ["STRING_OPTIONS_DATABROKER_TEXT2"], onclick = on_select, icon = "Interface\\AddOns\\Details\\images\\atributos_icones", texcoord = {0.125, 0.25, 0, 1}},
					}
				end
				local dropdown = g:NewDropDown (frame19, _, "$parentBrokerTextDropdown", "brokerTextDropdown", 160, 20, build_menu, _detalhes.minimap.text_type)
				dropdown.onenter_backdrop = dropdown_backdrop_onenter
				dropdown.onleave_backdrop = dropdown_backdrop_onleave
				dropdown:SetBackdrop (dropdown_backdrop)
				dropdown:SetBackdropColor (unpack (dropdown_backdrop_onleave))
				
				frame19.brokerTextDropdown:SetPoint ("left", frame19.brokerTextLabel, "right", 2, 0)
				window:CreateLineBackground2 (frame19, "brokerTextDropdown", "brokerTextLabel", Loc ["STRING_OPTIONS_DATABROKER_TEXT_DESC"])
			end

	--> anchors:

		local x = window.left_start_at
		
		titulo_externals:SetPoint (x, -30)
		titulo_externals_desc:SetPoint (x, -50)
		
		local left_side = {
			{"minimapAnchorLabel", 1, true},
			{"minimapLabel", 2},
			{"minimapActionLabel", 3},
			{"hotcornerAnchorLabel", 4, true},
			{"hotcornerLabel", 5},
			{"hotcornerActionLabel", 6},
			{"hotcornerQuickClickLabel", 7},
			{"quickClickLabel", 8},
			{"brokerAnchorLabel", 9, true},
			{"brokerTextLabel", 10},
		}
		
		window:arrange_menu (frame19, left_side, x, -90)	
		
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Advanced Settings - Miscellaneous ~18
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function window:CreateFrame18()

	local frame18 = window.options [18][1]

		local titulo_misc_settings = g:NewLabel (frame18, _, "$parentTituloMiscSettingsText", "MiscSettingsLabel", Loc ["STRING_OPTIONS_MISCTITLE"], "GameFontNormal", 16)
		local titulo_misc_settings_desc = g:NewLabel (frame18, _, "$parentTituloMiscSettingsText2", "Misc2SettingsLabel", Loc ["STRING_OPTIONS_MISCTITLE2"], "GameFontNormal", 9, "white")
		titulo_misc_settings_desc.width = 350
		titulo_misc_settings_desc.height = 20
	
		local Current_Switch_Func = function()end
	
		local BuildSwitchMenu = function()
		
			window.lastSwitchList = {}
			local t = {{value = 0, label = "do not switch", color = {.7, .7, .7, 1}, onclick = Current_Switch_Func, icon = [[Interface\Glues\LOGIN\Glues-CheckBox-Check]]}}
			
			local attributes = _detalhes.sub_atributos
			local i = 1
			
			for atributo, sub_atributo in ipairs (attributes) do
				local icones = sub_atributo.icones
				for index, att_name in ipairs (sub_atributo.lista) do
					local texture, texcoord = unpack (icones [index])
					tinsert (t, {value = i, label = att_name, onclick = Current_Switch_Func, icon = texture, texcoord = texcoord})
					window.lastSwitchList [i] = {atributo, index, i}
					i = i + 1
				end
			end
			
			for index, ptable in ipairs (_detalhes.RaidTables.Menu) do
				tinsert (t, {value = i, label = ptable [1], onclick = Current_Switch_Func, icon = ptable [2]})
				window.lastSwitchList [i] = {"raid", ptable [4], i}
				i = i + 1
			end
		
			return t
		end
	
		local healer_icon1 = g:NewImage (frame18, [[Interface\LFGFRAME\UI-LFG-ICON-ROLES]], 20, 20, nil, {GetTexCoordsForRole("HEALER")}, "HealerIcon1", "$parentHealerIcon1")
		local healer_icon2 = g:NewImage (frame18, [[Interface\LFGFRAME\UI-LFG-ICON-ROLES]], 20, 20, nil, {GetTexCoordsForRole("HEALER")}, "HealerIcon2", "$parentHealerIcon2")

		local dps_icon1 = g:NewImage (frame18, [[Interface\LFGFRAME\UI-LFG-ICON-ROLES]], 20, 20, nil, {GetTexCoordsForRole("DAMAGER")}, "DpsIcon1", "$parentDpsIcon1")
		local dps_icon2 = g:NewImage (frame18, [[Interface\LFGFRAME\UI-LFG-ICON-ROLES]], 20, 20, nil, {GetTexCoordsForRole("DAMAGER")}, "DpsIcon2", "$parentDpsIcon2")
		
		local tank_icon1 = g:NewImage (frame18, [[Interface\LFGFRAME\UI-LFG-ICON-ROLES]], 20, 20, nil, {GetTexCoordsForRole("TANK")}, "TankIcon1", "$parentTankIcon1")
		local tank_icon2 = g:NewImage (frame18, [[Interface\LFGFRAME\UI-LFG-ICON-ROLES]], 20, 20, nil, {GetTexCoordsForRole("TANK")}, "TankIcon2", "$parentTankIcon2")
	
		-- auto switch all roles in combat
			g:NewLabel (frame18, _, "$parentAutoSwitchLabel", "autoSwitchLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH"], "GameFontHighlightLeft")
			--
			local OnSelectAutoSwitchOnCombatAllRoles = function (_, _, switch_to)
				if (switch_to == 0) then
					_G.DetailsOptionsWindow.instance.switch_all_roles_in_combat = false
					return
				end
				
				local selected = window.lastSwitchList [switch_to]
				_G.DetailsOptionsWindow.instance.switch_all_roles_in_combat = selected
			end

			local BuildThisMenu = function()
				Current_Switch_Func = OnSelectAutoSwitchOnCombatAllRoles
				return BuildSwitchMenu()
			end
			
			local d = g:NewDropDown (frame18, _, "$parentAutoSwitchDropdown", "autoSwitchDropdown", 160, 20, BuildThisMenu, 1)
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
			
			frame18.autoSwitchDropdown:SetPoint ("left", frame18.autoSwitchLabel, "right", 2, 0)		
			
			window:CreateLineBackground2 (frame18, "autoSwitchDropdown", "autoSwitchLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH_DESC"])
		
		-- auto switch after a wipe
			g:NewLabel (frame18, _, "$parentAutoSwitchWipeLabel", "AutoSwitchWipeLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH_WIPE"], "GameFontHighlightLeft")
			--
			local OnSelectAutoSwitchWipe = function (_, _, switch_to)
				if (switch_to == 0) then
					_G.DetailsOptionsWindow.instance.switch_all_roles_after_wipe = false
					return
				end
				
				local selected = window.lastSwitchList [switch_to]
				_G.DetailsOptionsWindow.instance.switch_all_roles_after_wipe = selected
			end
			
			local BuildThisMenu = function()
				Current_Switch_Func = OnSelectAutoSwitchWipe
				return BuildSwitchMenu()
			end
			
			local d = g:NewDropDown (frame18, _, "$parentAutoSwitchWipeDropdown", "autoSwitchWipeDropdown", 160, 20, BuildThisMenu, 1) -- func, default
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
			
			frame18.autoSwitchWipeDropdown:SetPoint ("left", frame18.AutoSwitchWipeLabel, "right", 2, 0)		
			
			window:CreateLineBackground2 (frame18, "autoSwitchWipeDropdown", "AutoSwitchWipeLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH_WIPE_DESC"])

		-- auto switch damage no in combat
			g:NewLabel (frame18, _, "$parentAutoSwitchDamageNoCombatLabel", "AutoSwitchDamageNoCombatLabel", "", "GameFontHighlightLeft")
			--
			local OnSelectAutoSwitchDamageNoCombat = function (_, _, switch_to)
				if (switch_to == 0) then
					_G.DetailsOptionsWindow.instance.switch_damager = false
					return
				end
				
				local selected = window.lastSwitchList [switch_to]
				_G.DetailsOptionsWindow.instance.switch_damager = selected
			end
			
			local BuildThisMenu = function()
				Current_Switch_Func = OnSelectAutoSwitchDamageNoCombat
				return BuildSwitchMenu()
			end
			
			local d = g:NewDropDown (frame18, _, "$parentAutoSwitchDamageNoCombatDropdown", "AutoSwitchDamageNoCombatDropdown", 160, 20, BuildThisMenu, 1) -- func, default
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
			
			frame18.AutoSwitchDamageNoCombatDropdown:SetPoint ("left", dps_icon1, "right", 2, 0)
			frame18.AutoSwitchDamageNoCombatLabel:SetPoint ("left", dps_icon1, "left", 0, 0)
			
			window:CreateLineBackground2 (frame18, "AutoSwitchDamageNoCombatDropdown", "AutoSwitchDamageNoCombatLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH_DAMAGER_DESC"], dps_icon1)

		-- auto switch damage in combat
			g:NewLabel (frame18, _, "$parentAutoSwitchDamageCombatLabel", "AutoSwitchDamageCombatLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH_COMBAT"], "GameFontHighlightLeft")
			--
			local OnSelectAutoSwitchDamageCombat = function (_, _, switch_to)
				if (switch_to == 0) then
					_G.DetailsOptionsWindow.instance.switch_damager_in_combat = false
					return
				end
				
				local selected = window.lastSwitchList [switch_to]
				_G.DetailsOptionsWindow.instance.switch_damager_in_combat = selected
			end
			
			local BuildThisMenu = function()
				Current_Switch_Func = OnSelectAutoSwitchDamageCombat
				return BuildSwitchMenu()
			end
			
			local d = g:NewDropDown (frame18, _, "$parentAutoSwitchDamageCombatDropdown", "AutoSwitchDamageCombatDropdown", 160, 20, BuildThisMenu, 1) -- func, default
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
			
			frame18.AutoSwitchDamageCombatDropdown:SetPoint ("left", frame18.AutoSwitchDamageCombatLabel, "right", 2, -1)		
			frame18.AutoSwitchDamageCombatLabel:SetPoint ("left", dps_icon2, "right", 2, 1)
			
			window:CreateLineBackground2 (frame18, "AutoSwitchDamageCombatDropdown", "AutoSwitchDamageCombatLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH_DAMAGER_DESC"], dps_icon2)

		-- auto switch heal in no combat
			g:NewLabel (frame18, _, "$parentAutoSwitchHealNoCombatLabel", "AutoSwitchHealNoCombatLabel", "", "GameFontHighlightLeft")
			--
			local OnSelectAutoSwitchHealNoCombat = function (_, _, switch_to)
				if (switch_to == 0) then
					_G.DetailsOptionsWindow.instance.switch_healer = false
					return
				end
				
				local selected = window.lastSwitchList [switch_to]
				_G.DetailsOptionsWindow.instance.switch_healer = selected
			end
			
			local BuildThisMenu = function()
				Current_Switch_Func = OnSelectAutoSwitchHealNoCombat
				return BuildSwitchMenu()
			end
			
			local d = g:NewDropDown (frame18, _, "$parentAutoSwitchHealNoCombatDropdown", "AutoSwitchHealNoCombatDropdown", 160, 20, BuildThisMenu, 1) -- func, default
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
			
			--frame18.AutoSwitchHealNoCombatDropdown:SetPoint ("left", frame18.AutoSwitchHealNoCombatLabel, "right", 2, 0)		
			frame18.AutoSwitchHealNoCombatDropdown:SetPoint ("left", healer_icon1, "right", 2, 0)
			frame18.AutoSwitchHealNoCombatLabel:SetPoint ("left", healer_icon1, "left", 0, 0)
			
			window:CreateLineBackground2 (frame18, "AutoSwitchHealNoCombatDropdown", "AutoSwitchHealNoCombatLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH_HEALER_DESC"], healer_icon1)

		-- auto switch heal in combat
			g:NewLabel (frame18, _, "$parentAutoSwitchHealCombatLabel", "AutoSwitchHealCombatLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH_COMBAT"], "GameFontHighlightLeft")
			--
			local OnSelectAutoSwitchHealCombat = function (_, _, switch_to)
				if (switch_to == 0) then
					_G.DetailsOptionsWindow.instance.switch_healer_in_combat = false
					return
				end
				
				local selected = window.lastSwitchList [switch_to]
				_G.DetailsOptionsWindow.instance.switch_healer_in_combat = selected
			end
			
			local BuildThisMenu = function()
				Current_Switch_Func = OnSelectAutoSwitchHealCombat
				return BuildSwitchMenu()
			end
			
			local d = g:NewDropDown (frame18, _, "$parentAutoSwitchHealCombatDropdown", "AutoSwitchHealCombatDropdown", 160, 20, BuildThisMenu, 1) -- func, default
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
			
			--frame18.AutoSwitchHealCombatDropdown:SetPoint ("left", frame18.AutoSwitchHealCombatLabel, "right", 2, 0)		
			frame18.AutoSwitchHealCombatDropdown:SetPoint ("left", frame18.AutoSwitchHealCombatLabel, "right", 2, -1)
			frame18.AutoSwitchHealCombatLabel:SetPoint ("left", healer_icon2, "right", 2, 1)
			
			window:CreateLineBackground2 (frame18, "AutoSwitchHealCombatDropdown", "AutoSwitchHealCombatLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH_HEALER_DESC"], healer_icon2)
			
		-- auto switch tank in no combat
			g:NewLabel (frame18, _, "$parentAutoSwitchTankNoCombatLabel", "AutoSwitchTankNoCombatLabel", "", "GameFontHighlightLeft")
			--
			local OnSelectAutoSwitchTankNoCombat = function (_, _, switch_to)
				if (switch_to == 0) then
					_G.DetailsOptionsWindow.instance.switch_tank = false
					return
				end
				
				local selected = window.lastSwitchList [switch_to]
				_G.DetailsOptionsWindow.instance.switch_tank = selected
			end
			
			local BuildThisMenu = function()
				Current_Switch_Func = OnSelectAutoSwitchTankNoCombat
				return BuildSwitchMenu()
			end
			
			local d = g:NewDropDown (frame18, _, "$parentAutoSwitchTankNoCombatDropdown", "AutoSwitchTankNoCombatDropdown", 160, 20, BuildThisMenu, 1) -- func, default
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
			
			frame18.AutoSwitchTankNoCombatDropdown:SetPoint ("left", tank_icon1, "right", 2, 0)		
			frame18.AutoSwitchTankNoCombatLabel:SetPoint ("left", tank_icon1, "left", 0, 0)
			
			window:CreateLineBackground2 (frame18, "AutoSwitchTankNoCombatDropdown", "AutoSwitchTankNoCombatLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH_TANK_DESC"], tank_icon1)

		-- auto switch tank in combat
			g:NewLabel (frame18, _, "$parentAutoSwitchTankCombatLabel", "AutoSwitchTankCombatLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH_COMBAT"], "GameFontHighlightLeft")
			--
			local OnSelectAutoSwitchTankCombat = function (_, _, switch_to)
				if (switch_to == 0) then
					_G.DetailsOptionsWindow.instance.switch_tank_in_combat = false
					return
				end
				
				local selected = window.lastSwitchList [switch_to]
				_G.DetailsOptionsWindow.instance.switch_tank_in_combat = selected
			end
			
			local BuildThisMenu = function()
				Current_Switch_Func = OnSelectAutoSwitchTankCombat
				return BuildSwitchMenu()
			end
			
			local d = g:NewDropDown (frame18, _, "$parentAutoSwitchTankCombatDropdown", "AutoSwitchTankCombatDropdown", 160, 20, BuildThisMenu, 1) -- func, default
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
			
			frame18.AutoSwitchTankCombatDropdown:SetPoint ("left", frame18.AutoSwitchTankCombatLabel, "right", 2, -1)
			frame18.AutoSwitchTankCombatLabel:SetPoint ("left", tank_icon2, "right", 2, 1)
			
			window:CreateLineBackground2 (frame18, "AutoSwitchTankCombatDropdown", "AutoSwitchTankCombatLabel", Loc ["STRING_OPTIONS_AUTO_SWITCH_TANK_DESC"], tank_icon2)
		
		
		--> auto current segment
		g:NewSwitch (frame18, _, "$parentAutoCurrentSlider", "autoCurrentSlider", 60, 20, _, _, instance.auto_current)
		
		-- Auto Current Segment
	
		g:NewLabel (frame18, _, "$parentAutoCurrentLabel", "autoCurrentLabel", Loc ["STRING_OPTIONS_INSTANCE_CURRENT"], "GameFontHighlightLeft")

		frame18.autoCurrentSlider:SetPoint ("left", frame18.autoCurrentLabel, "right", 2)
		frame18.autoCurrentSlider.OnSwitch = function (self, instance, value)
			instance.auto_current = value
		end
		
		window:CreateLineBackground2 (frame18, "autoCurrentSlider", "autoCurrentLabel", Loc ["STRING_OPTIONS_INSTANCE_CURRENT_DESC"])
		
	--> show total bar
		
		g:NewLabel (frame18, _, "$parentTotalBarLabel", "totalBarLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR"], "GameFontHighlightLeft")
		g:NewSwitch (frame18, _, "$parentTotalBarSlider", "totalBarSlider", 60, 20, _, _, instance.total_bar.enabled)

		frame18.totalBarSlider:SetPoint ("left", frame18.totalBarLabel, "right", 2)
		frame18.totalBarSlider.OnSwitch = function (self, instance, value)
			instance.total_bar.enabled = value
			instance:InstanceReset()
		end
		
		window:CreateLineBackground2 (frame18, "totalBarSlider", "totalBarLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR_DESC"])
		
	--> total bar color
			local totalbarcolor_callback = function (button, r, g, b, a)
				_G.DetailsOptionsWindow.instance.total_bar.color[1] = r
				_G.DetailsOptionsWindow.instance.total_bar.color[2] = g
				_G.DetailsOptionsWindow.instance.total_bar.color[3] = b
				_G.DetailsOptionsWindow.instance:InstanceReset()
			end
			g:NewColorPickButton (frame18, "$parentTotalBarColorPick", "totalBarColorPick", totalbarcolor_callback)
			g:NewLabel (frame18, _, "$parentTotalBarColorPickLabel", "totalBarPickColorLabel", Loc ["STRING_OPTIONS_COLOR"], "GameFontHighlightLeft")
			frame18.totalBarColorPick:SetPoint ("left", frame18.totalBarPickColorLabel, "right", 2, 0)
		
			window:CreateLineBackground2 (frame18, "totalBarColorPick", "totalBarPickColorLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR_COLOR_DESC"])
		
	--> total bar only in group
		g:NewLabel (frame18, _, "$parentTotalBarOnlyInGroupLabel", "totalBarOnlyInGroupLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR_INGROUP"], "GameFontHighlightLeft")
		g:NewSwitch (frame18, _, "$parentTotalBarOnlyInGroupSlider", "totalBarOnlyInGroupSlider", 60, 20, _, _, instance.total_bar.only_in_group)

		frame18.totalBarOnlyInGroupSlider:SetPoint ("left", frame18.totalBarOnlyInGroupLabel, "right", 2)
		frame18.totalBarOnlyInGroupSlider.OnSwitch = function (self, instance, value)
			instance.total_bar.only_in_group = value
			instance:InstanceReset()
		end
		
		window:CreateLineBackground2 (frame18, "totalBarOnlyInGroupSlider", "totalBarOnlyInGroupLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR_INGROUP_DESC"])
		
	--> total bar icon
		local totalbar_pickicon_callback = function (texture)
			instance.total_bar.icon = texture
			frame18.totalBarIconTexture:SetTexture (texture)
			instance:InstanceReset()
		end
		local totalbar_pickicon = function()
			g:IconPick (totalbar_pickicon_callback)
		end
		g:NewLabel (frame18, _, "$parentTotalBarIconLabel", "totalBarIconLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR_ICON"], "GameFontHighlightLeft")
		g:NewImage (frame18, nil, 20, 20, nil, nil, "totalBarIconTexture", "$parentTotalBarIconTexture")
		g:NewButton (frame18, _, "$parentTotalBarIconButton", "totalBarIconButton", 20, 20, totalbar_pickicon)
		frame18.totalBarIconButton:InstallCustomTexture()
		frame18.totalBarIconButton:SetPoint ("left", frame18.totalBarIconLabel, "right", 2, 0)
		frame18.totalBarIconTexture:SetPoint ("left", frame18.totalBarIconLabel, "right", 2, 0)
		
		window:CreateLineBackground2 (frame18, "totalBarIconButton", "totalBarIconLabel", Loc ["STRING_OPTIONS_SHOW_TOTALBAR_ICON_DESC"])
		
	--> instances
	
		g:NewLabel (frame18, _, "$parentDeleteInstanceLabel", "deleteInstanceLabel", Loc ["STRING_OPTIONS_INSTANCE_DELETE"], "GameFontHighlightLeft")
		
		local onSelectDeleteInstance = function (_, _, selected)
			frame18.deleteInstanceButton.selected_instance = selected
		end
		
		local buildSelectDeleteInstance = function()
			local InstanceList = {}
			for index = 1, math.min (#_detalhes.tabela_instancias, _detalhes.instances_amount), 1 do 
				local _this_instance = _detalhes.tabela_instancias [index]

				--> pegar o que ela ta mostrando
				local atributo = _this_instance.atributo
				local sub_atributo = _this_instance.sub_atributo
				
				if (atributo == 5) then --> custom
					local CustomObject = _detalhes.custom [sub_atributo]
					
					if (CustomObject) then
						InstanceList [#InstanceList+1] = {value = index, label = _detalhes.atributos.lista [atributo] .. " - " .. CustomObject.name, onclick = onSelectDeleteInstance, icon = CustomObject.icon}
					else
						InstanceList [#InstanceList+1] = {value = index, label = "unknown" .. " - " .. " invalid custom", onclick = onSelectDeleteInstance, icon = [[Interface\COMMON\VOICECHAT-MUTED]]}
					end
					
				else
					local modo = _this_instance.modo
					
					if (modo == 1) then --alone
						atributo = _detalhes.SoloTables.Mode or 1
						local SoloInfo = _detalhes.SoloTables.Menu [atributo]
						if (SoloInfo) then
							InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " " .. SoloInfo [1], onclick = onSelectDeleteInstance, icon = SoloInfo [2]}
						else
							InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " unknown", onclick = onSelectDeleteInstance, icon = ""}
						end
						
					elseif (modo == 4) then --raid
						atributo = _detalhes.RaidTables.Mode or 1
						local RaidInfo = _detalhes.RaidTables.Menu [atributo]
						if (RaidInfo) then
							InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " " .. RaidInfo [1], onclick = onSelectDeleteInstance, icon = RaidInfo [2]}
						else
							InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " unknown", onclick = onSelectDeleteInstance, icon = ""}
						end
					else
						InstanceList [#InstanceList+1] = {value = index, label = "#".. index .. " " .. _detalhes.atributos.lista [atributo] .. " - " .. _detalhes.sub_atributos [atributo].lista [sub_atributo], onclick = onSelectDeleteInstance, icon = _detalhes.sub_atributos [atributo].icones[sub_atributo] [1], texcoord = _detalhes.sub_atributos [atributo].icones[sub_atributo] [2]}
						
					end
				end
			end
			return InstanceList
		end
		
		local d = g:NewDropDown (frame18, _, "$parentDeleteInstanceDropdown", "deleteInstanceDropdown", 160, 20, buildSelectDeleteInstance, 0) -- func, default
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
		
		frame18.deleteInstanceDropdown:SetPoint ("left", frame18.deleteInstanceLabel, "right", 2, 0)		
		
		local desc = window:CreateLineBackground2 (frame18, "deleteInstanceDropdown", "deleteInstanceLabel", Loc ["STRING_OPTIONS_INSTANCE_DELETE_DESC"])
		desc:SetWidth (180)
		
		local delete_instance = function (self)
			if (self.selected_instance) then
				_detalhes:DeleteInstance (self.selected_instance)
				ReloadUI()
			end
		end
		
		local confirm_button = CreateFrame ("button", "DetailsDeleteInstanceButton", frame18, "OptionsButtonTemplate")
		confirm_button:SetSize (60, 20)
		confirm_button:SetPoint ("left", frame18.deleteInstanceDropdown.widget, "right", 2, 0)
		confirm_button:SetText ("confirm")
		confirm_button:SetScript ("OnClick", delete_instance)
		frame18.deleteInstanceButton = confirm_button
		
		--local confirm_button = g:NewButton (frame18, nil, "$parentDeleteInstanceButton", "deleteInstanceButton", 60, 20, delete_instance, nil, nil, nil, "delete")
		--confirm_button:InstallCustomTexture()
		
	--> Anchors
		
		g:NewLabel (frame18, _, "$parentInstancesMiscAnchor", "instancesMiscLabel", Loc ["STRING_OPTIONS_INSTANCES"], "GameFontNormal")
		g:NewLabel (frame18, _, "$parentSwitchesAnchor", "switchesAnchorLabel", "Switches:", "GameFontNormal")
		g:NewLabel (frame18, _, "$parentTotalBarAnchor", "totalBarAnchorLabel", "Total Bar:", "GameFontNormal")
		
		--frame18.totalBarPickColorLabel:SetPoint ("left", frame18.totalBarIconTexture, "right", 10, 0)
		
		local x = window.left_start_at
		
		titulo_misc_settings:SetPoint (x, -30)
		titulo_misc_settings_desc:SetPoint (x, -50)
		
		local left_side = {
			{"switchesAnchorLabel", 1, true},
			{"autoSwitchLabel", 8},
			{"AutoSwitchWipeLabel", 9},
			{dps_icon1, 2},
			{healer_icon1, 3},
			{tank_icon1, 4},
			{dps_icon2, 5},
			{healer_icon2, 6},
			{tank_icon2, 7},
			
			{"autoCurrentLabel", 10},
			
			{"totalBarAnchorLabel", 11, true},
			{"totalBarIconLabel", 12},
			{"totalBarPickColorLabel", 13},
			{"totalBarLabel", 14},
			{"totalBarOnlyInGroupLabel", 15},
		}
		
		window:arrange_menu (frame18, left_side, x, -90)
		
		local right_side = {
			{"instancesMiscLabel", 1, true},
			{"deleteInstanceLabel", 2},
		}
		
		window:arrange_menu (frame18, right_side, window.right_start_at, -90)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Advanced Settings - Hide/Show Controls ~17
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function window:CreateFrame17()
	
	local frame17 = window.options [17][1]
	
		local titulo_instance_settings = g:NewLabel (frame17, _, "$parentTituloInstanceSettingsText", "InstanceSettingsLabel", Loc ["STRING_OPTIONS_SHOWHIDE"], "GameFontNormal", 16)
		local titulo_instance_settings_desc = g:NewLabel (frame17, _, "$parentInstanceSettingsText2", "InstanceSettingsLabel", Loc ["STRING_OPTIONS_SHOWHIDE_DESC"], "GameFontNormal", 9, "white")
		titulo_instance_settings_desc:SetSize (450, 20)
	
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
		
		window:CreateLineBackground2 (frame17, "combatAlphaDropdown", "combatAlphaLabel", Loc ["STRING_OPTIONS_COMBAT_ALPHA_DESC"])

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
		
		window:CreateLineBackground2 (frame17, "hideOnCombatAlphaSlider", "hideOnCombatAlphaLabel", Loc ["STRING_OPTIONS_HIDECOMBATALPHA_DESC"])
	
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
		
		window:CreateLineBackground2 (frame17, "alphaSwitch", "alphaSwitchLabel", Loc ["STRING_OPTIONS_MENU_ALPHAENABLED_DESC"])
		
		window:CreateLineBackground2 (frame17, "menuOnEnterSlider", "menuOnEnterLabel", Loc ["STRING_OPTIONS_MENU_ALPHAENTER_DESC"])
		
		window:CreateLineBackground2 (frame17, "menuOnLeaveSlider", "menuOnLeaveLabel", Loc ["STRING_OPTIONS_MENU_ALPHALEAVE_DESC"])
		
		frame17.alphaSwitch:SetPoint ("left", frame17.alphaSwitchLabel, "right", 2)
		frame17.menuOnEnterSlider:SetPoint ("left", frame17.menuOnEnterLabel, "right", 2)
		frame17.menuOnLeaveSlider:SetPoint ("left", frame17.menuOnLeaveLabel, "right", 2)

		frame17.menuOnEnterSlider:SetThumbSize (50)
		frame17.menuOnLeaveSlider:SetThumbSize (50)


		g:NewLabel (frame17, _, "$parentMenuOnEnterLeaveAlphaIconsTooLabel", "alphaIconsTooLabel", Loc ["STRING_OPTIONS_MENU_IGNOREBARS"], "GameFontHighlightLeft")		
		g:NewSwitch (frame17, _, "$parentMenuOnEnterLeaveAlphaIconsTooSwitch", "alphaIconsTooSwitch", 60, 20, _, _, instance.menu_alpha.ignorebars)
		
		window:CreateLineBackground2 (frame17, "alphaIconsTooSwitch", "alphaIconsTooLabel", Loc ["STRING_OPTIONS_MENU_IGNOREBARS_DESC"])
		
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

	--> anchors

		local x = window.left_start_at
		
		titulo_instance_settings:SetPoint (x, -30)
		titulo_instance_settings_desc:SetPoint (x, -50)
		
		local left_side = {
			{"hideInCombatAnchor", 1, true},
			{"combatAlphaLabel", 2},
			{"hideOnCombatAlphaLabel", 3},
			{"menuAlphaAnchorLabel", 4, true},
			{"alphaSwitchLabel", 5},
			{"menuOnEnterLabel", 6},
			{"menuOnLeaveLabel", 7},
			{"alphaIconsTooLabel", 8},

		}
		
		window:arrange_menu (frame17, left_side, x, -90)
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
			{name = "Remove", width = 70, type = "button", func = remove_capture, icon = [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], notext = true, iconalign = "center"},
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
				capture_name_entry:SetMaxLetters (16)
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
				local unserialize = select (2, _detalhes:Deserialize (text))
				
				if (type (unserialize) == "table") then
					if (unserialize[1] and unserialize[2] and unserialize[3] and unserialize[4] and unserialize[5]) then
						local register = _detalhes:TimeDataRegister (unpack (unserialize))
						if (type (register) == "string") then
							_detalhes:Msg (register)
						end
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
				
				_detalhes:TimeDataRegister (name, func, nil, author, version, icon, true)
				
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
		local reset_func = function (index)
			_detalhes:UserCustomSpellReset (index)
		end
	
	--> custom spells panel
		local header = {
			{name = "Index", width = 55, type = "text"}, 
			{name = "Name", width = 310, type = "entry", func = name_entry_func}, 
			{name = "Icon", width = 50, type = "icon", func = icon_func}, 
			{name = "Spell ID", width = 100, type = "text"},
			{name = "Reset", width = 50, type = "button", func = reset_func, icon = [[Interface\Buttons\UI-RefreshButton]], notext = true, iconalign = "center"}, 
			{name = "Remove", width = 75, type = "button", func = remove_func, icon = [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], notext = true, iconalign = "center"}, 
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
-- General Settings - attribute ~14
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
		window:CreateLineBackground2 (frame14, "attributeEnabledSwitch", "attributeEnabledLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ENABLED_DESC"])
	
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
		
		window:CreateLineBackground2 (frame14, "attributeAnchorXSlider", "attributeAnchorXLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORX_DESC"])
		window:CreateLineBackground2 (frame14, "attributeAnchorYSlider", "attributeAnchorYLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORY_DESC"])
		
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
		
		window:CreateLineBackground2 (frame14, "attributeFontDropdown", "attributeFontLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_FONT_DESC"])
		
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
		
		window:CreateLineBackground2 (frame14, "attributeTextSizeSlider", "attributeTextSizeLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTSIZE_DESC"])
		
	--color
		local attribute_text_color_callback = function (button, r, g, b, a)
			_G.DetailsOptionsWindow.instance:AttributeMenu (nil, nil, nil, nil, nil, {r, g, b, a})
		end
		g:NewColorPickButton (frame14, "$parentAttributeTextColorPick", "attributeTextColorPick", attribute_text_color_callback)
		g:NewLabel (frame14, _, "$parentAttributeTextColorLabel", "attributeTextColorLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTCOLOR"], "GameFontHighlightLeft")
		
		frame14.attributeTextColorPick:SetPoint ("left", frame14.attributeTextColorLabel, "right", 2, 0)

		window:CreateLineBackground2 (frame14, "attributeTextColorPick", "attributeTextColorLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTCOLOR_DESC"])
	
	--shadow
		g:NewLabel (frame14, _, "$parentAttributeShadowLabel", "attributeShadowLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SHADOW"], "GameFontHighlightLeft")
		g:NewSwitch (frame14, _, "$parentAttributeShadowSwitch", "attributeShadowSwitch", 60, 20, nil, nil, instance.attribute_text.shadow)
		frame14.attributeShadowSwitch:SetPoint ("left", frame14.attributeShadowLabel, "right", 2)
		frame14.attributeShadowSwitch.OnSwitch = function (self, instance, value)
			instance:AttributeMenu (nil, nil, nil, nil, nil, nil, nil, value)
		end
		window:CreateLineBackground2 (frame14, "attributeShadowSwitch", "attributeShadowLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SHADOW_DESC"])
	
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
		window:CreateLineBackground2 (frame14, "attributeSideSwitch", "attributeSideLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SIDE_DESC"])

	--frame14.attributeLabel:SetPoint (10, -205)
	
		--general anchor
		g:NewLabel (frame14, _, "$parentAttributeTextTextAnchor", "TextAnchorLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTETEXT_ANCHOR"], "GameFontNormal")
		g:NewLabel (frame14, _, "$parentAttributeTextSettingsAnchor", "SettingsAnchorLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTESETTINGS_ANCHOR"], "GameFontNormal")
		
		local x = window.left_start_at
		
		titulo_attributetext:SetPoint (x, -30)
		titulo_attributetext_desc:SetPoint (x, -50)
		
		local left_side = {
			{"TextAnchorLabel", 6, true},
			{"attributeTextColorLabel", 7},
			{"attributeTextSizeLabel", 8},
			{"attributeFontLabel", 9},
			{"attributeShadowLabel", 10},
			{"SettingsAnchorLabel", 1, true},
			{"attributeEnabledLabel", 2},
			{"attributeAnchorXLabel", 3},
			{"attributeAnchorYLabel", 4},
			{"attributeSideLabel", 5},
		}
		
		window:arrange_menu (frame14, left_side, x, -90)

	
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
		
		local box = g:NewTextEntry (frame1, _, "$parentNicknameEntry", "nicknameEntry", SLIDER_WIDTH, 20, onPressEnter)
		--box:SetBackdrop ({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true,
		--edgeSize = 10, tileSize = 16, insets = {left = 1, right = 1, top = 0, bottom = 1}})
		
		frame1.nicknameEntry:SetPoint ("left", frame1.nicknameLabel, "right", 2, 0)

		window:CreateLineBackground2 (frame1, "nicknameEntry", "nicknameLabel", Loc ["STRING_OPTIONS_NICKNAME_DESC"])
		
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
		
		g:NewButton (frame1, _, "$parentAvatarFrame", "chooseAvatarButton", frame1.nicknameLabel:GetStringWidth() + SLIDER_WIDTH + 2, 18, openAtavarPickFrame, nil, nil, nil, Loc ["STRING_OPTIONS_AVATAR"])
		frame1.chooseAvatarButton:InstallCustomTexture()
		
		window:CreateLineBackground2 (frame1, "chooseAvatarButton", "chooseAvatarButton", Loc ["STRING_OPTIONS_AVATAR_DESC"])
		
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

		frame1.realmNameSlider.OnSwitch = function (self, _, value)
			_detalhes.remove_realm_from_name = value
		end
		
		window:CreateLineBackground2 (frame1, "realmNameSlider", "realmNameLabel", Loc ["STRING_OPTIONS_REALMNAME_DESC"])

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
		
		window:CreateLineBackground2 (frame1, "segmentsSlider", "segmentsLabel", Loc ["STRING_OPTIONS_MAXSEGMENTS_DESC"])
	
	--> Segments Locked
	
		g:NewLabel (frame1, _, "$parentSegmentsLockedLabel", "SegmentsLockedLabel", Loc ["STRING_OPTIONS_LOCKSEGMENTS"], "GameFontHighlightLeft")
		g:NewSwitch (frame1, _, "$parentSegmentsLockedSlider", "SegmentsLockedSlider", 60, 20, _, _, _detalhes.instances_segments_locked)
		frame1.SegmentsLockedSlider:SetPoint ("left", frame1.SegmentsLockedLabel, "right", 2)

		frame1.SegmentsLockedSlider.OnSwitch = function (self, _, value)
			_detalhes.instances_segments_locked = value
		end
		
		window:CreateLineBackground2 (frame1, "SegmentsLockedSlider", "SegmentsLockedLabel", Loc ["STRING_OPTIONS_LOCKSEGMENTS_DESC"])
	
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
		
		window:CreateLineBackground2 (frame1, "scrollSlider", "scrollLabel", Loc ["STRING_OPTIONS_SCROLLBAR_DESC"])
		
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
		
		window:CreateLineBackground2 (frame1, "maxInstancesSlider", "maxInstancesLabel", Loc ["STRING_OPTIONS_MAXINSTANCES_DESC"])

	---> Abbreviation Type
		g:NewLabel (frame1, _, "$parentDpsAbbreviateLabel", "dpsAbbreviateLabel", Loc ["STRING_OPTIONS_PS_ABBREVIATE"], "GameFontHighlightLeft")
		--
		local onSelectTimeAbbreviation = function (_, _, abbreviationtype)
			_detalhes.ps_abbreviation = abbreviationtype
			
			_detalhes.atributo_damage:UpdateSelectedToKFunction()
			_detalhes.atributo_heal:UpdateSelectedToKFunction()
			_detalhes.atributo_energy:UpdateSelectedToKFunction()
			_detalhes.atributo_misc:UpdateSelectedToKFunction()
			_detalhes.atributo_custom:UpdateSelectedToKFunction()
			
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
			{value = 7, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK0MIN"], desc = "Example: 25.305.500 -> 25m", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor}, --, desc = ""
			{value = 8, label = Loc ["STRING_OPTIONS_PS_ABBREVIATE_COMMA"], desc = "Example: 25305500 -> 25.305.500", onclick = onSelectTimeAbbreviation, icon = icon, iconcolor = iconcolor} --, desc = ""
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

		window:CreateLineBackground2 (frame1, "dpsAbbreviateDropdown", "dpsAbbreviateLabel", Loc ["STRING_OPTIONS_PS_ABBREVIATE_DESC"])
		
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
		frame1.animateSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue (false, true)
			_detalhes:SetUseAnimations (value)
		end
		
		window:CreateLineBackground2 (frame1, "animateSlider", "animateLabel", Loc ["STRING_OPTIONS_ANIMATEBARS_DESC"])
		
	--> update speed

		local s = g:NewSlider (frame1, _, "$parentSliderUpdateSpeed", "updatespeedSlider", SLIDER_WIDTH, 20, 0.050, 3, 0.050, _detalhes.update_speed, true)
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		
		g:NewLabel (frame1, _, "$parentUpdateSpeedLabel", "updatespeedLabel", Loc ["STRING_OPTIONS_WINDOWSPEED"], "GameFontHighlightLeft")
		--
		frame1.updatespeedSlider:SetPoint ("left", frame1.updatespeedLabel, "right", 2, -1)
		frame1.updatespeedSlider:SetThumbSize (50)
		frame1.updatespeedSlider.useDecimals = true
		local updateColor = function (slider, value)
			if (value < 1) then
				slider.amt:SetTextColor (1, value, .2)
			elseif (value > 1) then
				slider.amt:SetTextColor (-(value-3), 1, 0)
			else
				slider.amt:SetTextColor (1, 1, 0)
			end
		end
		
		frame1.updatespeedSlider:SetHook ("OnValueChange", function (self, _, amount) 
			_detalhes:SetWindowUpdateSpeed (amount)
			updateColor (self, amount)
		end)
		updateColor (frame1.updatespeedSlider, _detalhes.update_speed)
		
		window:CreateLineBackground2 (frame1, "updatespeedSlider", "updatespeedLabel", Loc ["STRING_OPTIONS_WINDOWSPEED_DESC"])
		
	--> window controls
		
		--lock unlock
			g:NewButton (frame1, _, "$parentLockButton", "LockButton", 160, 18, _detalhes.lock_instance_function, nil, nil, nil, Loc ["STRING_OPTIONS_WC_LOCK"])
			frame1.LockButton:InstallCustomTexture()
			window:CreateLineBackground2 (frame1, "LockButton", "LockButton", Loc ["STRING_OPTIONS_WC_LOCK_DESC"], nil, true)
			
		--break snap
			g:NewButton (frame1, _, "$parentBreakSnapButton", "BreakSnapButton", 160, 18, _G.DetailsOptionsWindow.instance.Desagrupar, -1, nil, nil, Loc ["STRING_OPTIONS_WC_UNSNAP"])
			frame1.BreakSnapButton:InstallCustomTexture()
			window:CreateLineBackground2 (frame1, "BreakSnapButton", "BreakSnapButton", Loc ["STRING_OPTIONS_WC_UNSNAP_DESC"], nil, true)
		
		--close
			g:NewButton (frame1, _, "$parentCloseButton", "CloseButton", 160, 18, _detalhes.close_instancia_func, _G.DetailsOptionsWindow.instance, nil, nil, Loc ["STRING_OPTIONS_WC_CLOSE"])
			frame1.CloseButton:InstallCustomTexture()
			window:CreateLineBackground2 (frame1, "CloseButton", "CloseButton", Loc ["STRING_OPTIONS_WC_CLOSE_DESC"], nil, true)
		
		--create
			g:NewButton (frame1, _, "$parentCreateWindowButton", "CreateWindowButton", 160, 18, function() _detalhes.CriarInstancia (nil, nil, true) end, nil, nil, nil, Loc ["STRING_OPTIONS_WC_CREATE"])
			frame1.CreateWindowButton:InstallCustomTexture()
			window:CreateLineBackground2 (frame1, "CreateWindowButton", "CreateWindowButton", Loc ["STRING_OPTIONS_WC_CREATE_DESC"], nil, true)
		
	--> anchors
	
		g:NewLabel (frame1, _, "$parentGeneralAnchor", "GeneralAnchorLabel", Loc ["STRING_OPTIONS_GENERAL_ANCHOR"], "GameFontNormal")
		g:NewLabel (frame1, _, "$parentIdentityAnchor", "GeneralIdentityLabel", Loc ["STRING_OPTIONS_AVATAR_ANCHOR"], "GameFontNormal")
		
		g:NewLabel (frame1, _, "$parentWindowControlsAnchor", "WindowControlsLabel", Loc ["STRING_OPTIONS_WC_ANCHOR"], "GameFontNormal")

		local w_start = 10
	
		titulo_display:SetPoint (window.left_start_at, -30)
		titulo_display_desc:SetPoint (window.left_start_at, -50)
		
		local avatar_x_anchor = window.right_start_at
		
		frame1.GeneralIdentityLabel:SetPoint (avatar_x_anchor, -90)
		
		frame1.nicknameLabel:SetPoint (avatar_x_anchor, -115)
		frame1.chooseAvatarButton:SetPoint (avatar_x_anchor+1, -140)
		
		frame1.avatarPreview:SetPoint (avatar_x_anchor-8, -157)
		frame1.avatarPreview2:SetPoint (avatar_x_anchor-8, -159)
		frame1.avatarNickname:SetPoint (avatar_x_anchor+100, -191)
		
		frame1.realmNameLabel:SetPoint (avatar_x_anchor, -235)
		
		local left_side = {
			{"GeneralAnchorLabel", 1, true},
			{"animateLabel", 2},
			{"updatespeedLabel", 3},
			{"segmentsLabel", 4},
			{"scrollLabel", 6},
			{"maxInstancesLabel", 7},
			{"dpsAbbreviateLabel", 8},
			{"SegmentsLockedLabel", 5},
			{"WindowControlsLabel", 9, true},
			{"LockButton", 10},
			{"BreakSnapButton", 12},
			{"CloseButton", 11},
			{"CreateWindowButton", 13, true},
		}
		
		window:arrange_menu (frame1, left_side, window.left_start_at, window.top_start_at)
		
end		
		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- General Settings - Combat ~2 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
function window:CreateFrame2()
	
	--> general settings:
		local frame2 = window.options [2][1]
		
	--> titles
		local titulo_combattweeks = g:NewLabel (frame2, _, "$parentTituloCombatTweeks", "tituloCombatTweeksLabel", Loc ["STRING_OPTIONS_COMBATTWEEKS"], "GameFontNormal", 16)
		local titulo_combattweeks_desc = g:NewLabel (frame2, _, "$parentCombatTweeks2", "tituloCombatTweeks2Label", Loc ["STRING_OPTIONS_COMBATTWEEKS_DESC"], "GameFontNormal", 9, "white")
		titulo_combattweeks_desc.width = 320

		
	--> Frags PVP Mode
		g:NewLabel (frame2, _, "$parentLabelFragsPvP", "fragsPvpLabel", Loc ["STRING_OPTIONS_PVPFRAGS"], "GameFontHighlightLeft")
		--
		g:NewSwitch (frame2, _, "$parentFragsPvpSlider", "fragsPvpSlider", 60, 20, _, _, _detalhes.only_pvp_frags)
		frame2.fragsPvpSlider:SetPoint ("left", frame2.fragsPvpLabel, "right", 2, 0)
		frame2.fragsPvpSlider.OnSwitch = function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.only_pvp_frags = amount
		end
		
		window:CreateLineBackground2 (frame2, "fragsPvpSlider", "fragsPvpLabel", Loc ["STRING_OPTIONS_PVPFRAGS_DESC"])
		
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

		window:CreateLineBackground2 (frame2, "timetypeDropdown", "timetypeLabel", Loc ["STRING_OPTIONS_TIMEMEASURE_DESC"])

	--> Overall Data
		g:NewLabel (frame2, _, "$parentOverallDataAnchor", "OverallDataLabel", Loc ["STRING_OPTIONS_OVERALL_ANCHOR"], "GameFontNormal")
		
		--raid boss
		g:NewLabel (frame2, _, "$parentOverallDataRaidBossLabel", "OverallDataRaidBossLabel", Loc ["STRING_OPTIONS_OVERALL_RAIDBOSS"], "GameFontHighlightLeft")
		--
		g:NewSwitch (frame2, _, "$parentOverallDataRaidBossSlider", "OverallDataRaidBossSlider", 60, 20, _, _, false)
		frame2.OverallDataRaidBossSlider:SetPoint ("left", frame2.OverallDataRaidBossLabel, "right", 2, 0)
		--
		frame2.OverallDataRaidBossSlider.OnSwitch = function (self, _, value)
			if (value and bit.band (_detalhes.overall_flag, 0x1) == 0) then
				_detalhes.overall_flag = _detalhes.overall_flag + 0x1
			elseif (not value and bit.band (_detalhes.overall_flag, 0x1) ~= 0) then
				_detalhes.overall_flag = _detalhes.overall_flag - 0x1
			end
		end
		--
		window:CreateLineBackground2 (frame2, "OverallDataRaidBossSlider", "OverallDataRaidBossLabel", Loc ["STRING_OPTIONS_OVERALL_RAIDBOSS_DESC"])
		
		--raid cleanup
		g:NewLabel (frame2, _, "$parentOverallDataRaidCleaupLabel", "OverallDataRaidCleaupLabel", Loc ["STRING_OPTIONS_OVERALL_RAIDCLEAN"], "GameFontHighlightLeft")
		--
		local raid_cleanup = g:NewSwitch (frame2, _, "$parentOverallDataRaidCleaupSlider", "OverallDataRaidCleaupSlider", 60, 20, _, _, false)
		frame2.OverallDataRaidCleaupSlider:SetPoint ("left", frame2.OverallDataRaidCleaupLabel, "right", 2, 0)
		--
		frame2.OverallDataRaidCleaupSlider.OnSwitch = function (self, _, value)
			if (value and bit.band (_detalhes.overall_flag, 0x2) == 0) then
				_detalhes.overall_flag = _detalhes.overall_flag + 0x2
			elseif (not value and bit.band (_detalhes.overall_flag, 0x2) ~= 0) then
				_detalhes.overall_flag = _detalhes.overall_flag - 0x2
			end
		end
		--
		window:CreateLineBackground2 (frame2, "OverallDataRaidCleaupSlider", "OverallDataRaidCleaupLabel", Loc ["STRING_OPTIONS_OVERALL_RAIDCLEAN_DESC"])
		
		--dungeon boss
		g:NewLabel (frame2, _, "$parentOverallDataDungeonBossLabel", "OverallDataDungeonBossLabel", Loc ["STRING_OPTIONS_OVERALL_DUNGEONBOSS"], "GameFontHighlightLeft")
		--
		g:NewSwitch (frame2, _, "$parentOverallDataDungeonBossSlider", "OverallDataDungeonBossSlider", 60, 20, _, _, false)
		frame2.OverallDataDungeonBossSlider:SetPoint ("left", frame2.OverallDataDungeonBossLabel, "right", 2, 0)
		--
		frame2.OverallDataDungeonBossSlider.OnSwitch = function (self, _, value)
			if (value and bit.band (_detalhes.overall_flag, 0x4) == 0) then
				_detalhes.overall_flag = _detalhes.overall_flag + 0x4
			elseif (not value and bit.band (_detalhes.overall_flag, 0x4) ~= 0) then
				_detalhes.overall_flag = _detalhes.overall_flag - 0x4
			end
		end
		--
		window:CreateLineBackground2 (frame2, "OverallDataDungeonBossSlider", "OverallDataDungeonBossLabel", Loc ["STRING_OPTIONS_OVERALL_DUNGEONBOSS_DESC"])
		
		--dungeon cleanup
		g:NewLabel (frame2, _, "$parentOverallDataDungeonCleaupLabel", "OverallDataDungeonCleaupLabel", Loc ["STRING_OPTIONS_OVERALL_DUNGEONCLEAN"], "GameFontHighlightLeft")
		--
		g:NewSwitch (frame2, _, "$parentOverallDataDungeonCleaupSlider", "OverallDataDungeonCleaupSlider", 60, 20, _, _, false)
		frame2.OverallDataDungeonCleaupSlider:SetPoint ("left", frame2.OverallDataDungeonCleaupLabel, "right", 2, 0)
		--
		frame2.OverallDataDungeonCleaupSlider.OnSwitch = function (self, _, value)
			if (value and bit.band (_detalhes.overall_flag, 0x8) == 0) then
				_detalhes.overall_flag = _detalhes.overall_flag + 0x8
			elseif (not value and bit.band (_detalhes.overall_flag, 0x8) ~= 0) then
				_detalhes.overall_flag = _detalhes.overall_flag - 0x8
			end
		end
		--
		window:CreateLineBackground2 (frame2, "OverallDataDungeonCleaupSlider", "OverallDataDungeonCleaupLabel", Loc ["STRING_OPTIONS_OVERALL_DUNGEONCLEAN_DESC"])
		
		--everything
		g:NewLabel (frame2, _, "$parentOverallDataAllLabel", "OverallDataAllLabel", Loc ["STRING_OPTIONS_OVERALL_ALL"], "GameFontHighlightLeft")
		--
		g:NewSwitch (frame2, _, "$parentOverallDataAllSlider", "OverallDataAllSlider", 60, 20, _, _, false)
		frame2.OverallDataAllSlider:SetPoint ("left", frame2.OverallDataAllLabel, "right", 2, 0)
		--
		frame2.OverallDataAllSlider.OnSwitch = function (self, _, value)
			if (value and bit.band (_detalhes.overall_flag, 0x10) == 0) then
				_detalhes.overall_flag = _detalhes.overall_flag + 0x10
				
				frame2.OverallDataRaidBossSlider:Disable()
				frame2.OverallDataRaidCleaupSlider:Disable()
				frame2.OverallDataDungeonBossSlider:Disable()
				frame2.OverallDataDungeonCleaupSlider:Disable()
				
			elseif (not value and bit.band (_detalhes.overall_flag, 0x10) ~= 0) then
				_detalhes.overall_flag = _detalhes.overall_flag - 0x10
				
				frame2.OverallDataRaidBossSlider:Enable()
				frame2.OverallDataRaidCleaupSlider:Enable()
				frame2.OverallDataDungeonBossSlider:Enable()
				frame2.OverallDataDungeonCleaupSlider:Enable()
			end
		end
		--
		window:CreateLineBackground2 (frame2, "OverallDataAllSlider", "OverallDataAllLabel", Loc ["STRING_OPTIONS_OVERALL_ALL_DESC"])
		
		--erase on new boss
		g:NewLabel (frame2, _, "$parentOverallNewBossLabel", "OverallNewBossLabel", Loc ["STRING_OPTIONS_OVERALL_NEWBOSS"], "GameFontHighlightLeft")
		--
		g:NewSwitch (frame2, _, "$parentOverallNewBossSlider", "OverallNewBossSlider", 60, 20, _, _, false)
		frame2.OverallNewBossSlider:SetPoint ("left", frame2.OverallNewBossLabel, "right", 2, 0)
		--
		frame2.OverallNewBossSlider.OnSwitch = function (self, _, value)
			_detalhes:OverallOptions (value)
		end
		--
		window:CreateLineBackground2 (frame2, "OverallNewBossSlider", "OverallNewBossLabel", Loc ["STRING_OPTIONS_OVERALL_NEWBOSS_DESC"])

		--erase on challenge mode
		g:NewLabel (frame2, _, "$parentOverallNewChallengeLabel", "OverallNewChallengeLabel", Loc ["STRING_OPTIONS_OVERALL_CHALLENGE"], "GameFontHighlightLeft")
		--
		g:NewSwitch (frame2, _, "$parentOverallNewChallengeSlider", "OverallNewChallengeSlider", 60, 20, _, _, false)
		frame2.OverallNewChallengeSlider:SetPoint ("left", frame2.OverallNewChallengeLabel, "right", 2, 0)
		--
		frame2.OverallNewChallengeSlider.OnSwitch = function (self, _, value)
			_detalhes:OverallOptions (nil, value)
		end
		--
		window:CreateLineBackground2 (frame2, "OverallNewChallengeSlider", "OverallNewChallengeLabel", Loc ["STRING_OPTIONS_OVERALL_CHALLENGE_DESC"])
		
	--> captures
			
		--> icons
		g:NewImage (frame2, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "damageCaptureImage", "$parentCaptureDamage")
		frame2.damageCaptureImage:SetTexCoord (0, 0.125, 0, 1)
		
		g:NewImage (frame2, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "healCaptureImage", "$parentCaptureHeal")
		frame2.healCaptureImage:SetTexCoord (0.125, 0.25, 0, 1)
		
		g:NewImage (frame2, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "energyCaptureImage", "$parentCaptureEnergy")
		frame2.energyCaptureImage:SetTexCoord (0.25, 0.375, 0, 1)
		
		g:NewImage (frame2, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "miscCaptureImage", "$parentCaptureMisc")
		frame2.miscCaptureImage:SetTexCoord (0.375, 0.5, 0, 1)
		
		g:NewImage (frame2, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "auraCaptureImage", "$parentCaptureAura")
		frame2.auraCaptureImage:SetTexCoord (0.5, 0.625, 0, 1)
		
		--> labels
		g:NewLabel (frame2, _, "$parentCaptureDamageLabel", "damageCaptureLabel", Loc ["STRING_OPTIONS_CDAMAGE"], "GameFontHighlightLeft")
		frame2.damageCaptureLabel:SetPoint ("left", frame2.damageCaptureImage, "right", 2)
		
		g:NewLabel (frame2, _, "$parentCaptureHealLabel", "healCaptureLabel", Loc ["STRING_OPTIONS_CHEAL"], "GameFontHighlightLeft")
		frame2.healCaptureLabel:SetPoint ("left", frame2.healCaptureImage, "right", 2)
		
		g:NewLabel (frame2, _, "$parentCaptureEnergyLabel", "energyCaptureLabel", Loc ["STRING_OPTIONS_CENERGY"], "GameFontHighlightLeft")
		frame2.energyCaptureLabel:SetPoint ("left", frame2.energyCaptureImage, "right", 2)
		
		g:NewLabel (frame2, _, "$parentCaptureMiscLabel", "miscCaptureLabel", Loc ["STRING_OPTIONS_CMISC"], "GameFontHighlightLeft")
		frame2.miscCaptureLabel:SetPoint ("left", frame2.miscCaptureImage, "right", 2)
		
		g:NewLabel (frame2, _, "$parentCaptureAuraLabel", "auraCaptureLabel", Loc ["STRING_OPTIONS_CAURAS"], "GameFontHighlightLeft")
		frame2.auraCaptureLabel:SetPoint ("left", frame2.auraCaptureImage, "right", 2)
		
		--> switches
		
		local switch_icon_color = function (icon, on_off)
			icon:SetDesaturated (not on_off)
		end
		
		g:NewSwitch (frame2, _, "$parentCaptureDamageSlider", "damageCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["damage"])
		frame2.damageCaptureSlider:SetPoint ("left", frame2.damageCaptureLabel, "right", 2)
		frame2.damageCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "damage", true)
			switch_icon_color (frame2.damageCaptureImage, value)
		end
		switch_icon_color (frame2.damageCaptureImage, _detalhes.capture_real ["damage"])
		
		window:CreateLineBackground2 (frame2, "damageCaptureSlider", "damageCaptureLabel", Loc ["STRING_OPTIONS_CDAMAGE_DESC"], frame2.damageCaptureImage)
		
		g:NewSwitch (frame2, _, "$parentCaptureHealSlider", "healCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["heal"])
		frame2.healCaptureSlider:SetPoint ("left", frame2.healCaptureLabel, "right", 2)
		frame2.healCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "heal", true)
			switch_icon_color (frame2.healCaptureImage, value)
		end
		switch_icon_color (frame2.healCaptureImage, _detalhes.capture_real ["heal"])
		
		window:CreateLineBackground2 (frame2, "healCaptureSlider", "healCaptureLabel", Loc ["STRING_OPTIONS_CHEAL_DESC"], frame2.healCaptureImage)
		
		g:NewSwitch (frame2, _, "$parentCaptureEnergySlider", "energyCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["energy"])
		frame2.energyCaptureSlider:SetPoint ("left", frame2.energyCaptureLabel, "right", 2)

		frame2.energyCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "energy", true)
			switch_icon_color (frame2.energyCaptureImage, value)
		end
		switch_icon_color (frame2.energyCaptureImage, _detalhes.capture_real ["energy"])
		
		window:CreateLineBackground2 (frame2, "energyCaptureSlider", "energyCaptureLabel", Loc ["STRING_OPTIONS_CENERGY_DESC"], frame2.energyCaptureImage)
		
		g:NewSwitch (frame2, _, "$parentCaptureMiscSlider", "miscCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["miscdata"])
		frame2.miscCaptureSlider:SetPoint ("left", frame2.miscCaptureLabel, "right", 2)
		frame2.miscCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "miscdata", true)
			switch_icon_color (frame2.miscCaptureImage, value)
		end
		switch_icon_color (frame2.miscCaptureImage, _detalhes.capture_real ["miscdata"])
		
		window:CreateLineBackground2 (frame2, "miscCaptureSlider", "miscCaptureLabel", Loc ["STRING_OPTIONS_CMISC_DESC"], frame2.miscCaptureImage)
		
		g:NewSwitch (frame2, _, "$parentCaptureAuraSlider", "auraCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["aura"])
		frame2.auraCaptureSlider:SetPoint ("left", frame2.auraCaptureLabel, "right", 2)
		frame2.auraCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "aura", true)
			switch_icon_color (frame2.auraCaptureImage, value)
		end
		switch_icon_color (frame2.auraCaptureImage, _detalhes.capture_real ["aura"])
		
		window:CreateLineBackground2 (frame2, "auraCaptureSlider", "auraCaptureLabel", Loc ["STRING_OPTIONS_CAURAS_DESC"], frame2.auraCaptureImage)
			
		--> cloud capture
		g:NewLabel (frame2, _, "$parentCloudCaptureLabel", "cloudCaptureLabel", Loc ["STRING_OPTIONS_CLOUD"], "GameFontHighlightLeft")

		g:NewSwitch (frame2, _, "$parentCloudAuraSlider", "cloudCaptureSlider", 60, 20, _, _, _detalhes.cloud_capture)
		frame2.cloudCaptureSlider:SetPoint ("left", frame2.cloudCaptureLabel, "right", 2)
		frame2.cloudCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes.cloud_capture = value
		end
		
		window:CreateLineBackground2 (frame2, "cloudCaptureSlider", "cloudCaptureLabel", Loc ["STRING_OPTIONS_CLOUD_DESC"] )

	--> anchors
	
		--general anchor
		g:NewLabel (frame2, _, "$parentGeneralAnchor", "GeneralAnchorLabel", Loc ["STRING_OPTIONS_GENERAL_ANCHOR"], "GameFontNormal")
		--captures anchor
		g:NewLabel (frame2, _, "$parentDataCollectAnchor", "DataCollectAnchorLabel", Loc ["STRING_OPTIONS_DATACOLLECT_ANCHOR"], "GameFontNormal")
		
		local x = window.left_start_at
		
		titulo_combattweeks:SetPoint (x, -30)
		titulo_combattweeks_desc:SetPoint (x, -50)

		local left_side = {
			{"GeneralAnchorLabel", 1, true},
			{"fragsPvpLabel", 2},
			{"timetypeLabel", 3},
			
			{"OverallDataLabel", 4, true},
			{"OverallDataRaidBossLabel", 5},
			{"OverallDataRaidCleaupLabel", 6},
			{"OverallDataDungeonBossLabel", 7},
			{"OverallDataDungeonCleaupLabel", 8},
			{"OverallDataAllLabel", 9},
			{"OverallNewBossLabel", 10},
			{"OverallNewChallengeLabel", 11},
		}
		
		window:arrange_menu (frame2, left_side, x, window.top_start_at)

		local x = window.right_start_at
		
		local right_side = {
			{"DataCollectAnchorLabel", 1, true},
			{"damageCaptureImage", 2},
			{"healCaptureImage", 3},
			{"energyCaptureImage", 4},
			{"miscCaptureImage", 5},
			{"auraCaptureImage", 6},
			{"cloudCaptureLabel", 7, true},
		}
		
		window:arrange_menu (frame2, right_side, x, -90)
		
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
		
		window:CreateLineBackground2 (frame13, info_holder_frame, current_profile_label.widget, Loc ["STRING_OPTIONS_PROFILES_CURRENT_DESC"])
	
	--> select profile
		local profile_selected = function (_, instance, profile_name)
			_detalhes:ApplyProfile (profile_name)
			_detalhes:Msg (Loc ["STRING_OPTIONS_PROFILE_LOADED"], profile_name)
			_detalhes:OpenOptionsWindow (_G.DetailsOptionsWindow.instance)
		end
		local build_profile_menu = function()
			local menu = {}
			
			for index, profile_name in ipairs (_detalhes:GetProfileList()) do 
				menu [#menu+1] = {value = profile_name, label = profile_name, onclick = profile_selected, icon = "Interface\\MINIMAP\\Vehicle-HammerGold-3"}
			end
			
			return menu
		end
		local select_profile_dropdown = g:NewDropDown (frame13, _, "$parentSelectProfileDropdown", "selectProfileDropdown", 160, 20, build_profile_menu, 0)	
		local d = select_profile_dropdown
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		local select_profile_label = g:NewLabel (frame13, _, "$parentSelectProfileLabel", "selectProfileLabel", Loc ["STRING_OPTIONS_PROFILES_SELECT"], "GameFontHighlightLeft")
		select_profile_dropdown:SetPoint ("left", select_profile_label, "right", 2, 0)
	
		window:CreateLineBackground2 (frame13, select_profile_dropdown, select_profile_label, Loc ["STRING_OPTIONS_PROFILES_SELECT_DESC"])
	
	--> new profile
		local profile_name = g:NewTextEntry (frame13, _, "$parentProfileNameEntry", "profileNameEntry", 120, 20)
		local profile_name_label = g:NewLabel (frame13, _, "$parentProfileNameLabel", "profileNameLabel", Loc ["STRING_OPTIONS_PROFILES_CREATE"], "GameFontHighlightLeft")
		profile_name:SetPoint ("left", profile_name_label, "right", 2, 0)
		
		local create_profile = function()
			local text = profile_name:GetText()
			if (text == "") then
				return _detalhes:Msg (Loc ["STRING_OPTIONS_PROFILE_FIELDEMPTY"])
			end
			
			profile_name:SetText ("")
			profile_name:ClearFocus()
			
			local new_profile = _detalhes:CreateProfile (text)
			if (new_profile) then
				_detalhes:ApplyProfile (text)
				_detalhes:OpenOptionsWindow (_G.DetailsOptionsWindow.instance)
				_G.DetailsOptionsWindow13SelectProfileCopyDropdown.MyObject:Refresh()
				_G.DetailsOptionsWindow13SelectProfileEraseDropdown.MyObject:Refresh()
			else
				return _detalhes:Msg (Loc ["STRING_OPTIONS_PROFILE_NOTCREATED"])
			end
		end
		local profile_create_button = g:NewButton (frame13, _, "$parentProfileCreateButton", "profileCreateButton", 50, 18, create_profile, nil, nil, nil, Loc ["STRING_OPTIONS_SAVELOAD_SAVE"])
		profile_create_button:InstallCustomTexture()
		profile_create_button:SetPoint ("left", profile_name, "right", 2, 0)
		
		window:CreateLineBackground2 (frame13, profile_name, profile_name_label, Loc ["STRING_OPTIONS_PROFILES_CREATE_DESC"])
	
	
	--> copy profile
		local profile_selectedCopy = function (_, instance, profile_name)
			--copiar o profile
			local current_instance = _G.DetailsOptionsWindow.instance
			_detalhes:ApplyProfile (profile_name, nil, true)
			_G.DetailsOptionsWindow13SelectProfileCopyDropdown.MyObject:Select (false)
			_G.DetailsOptionsWindow13SelectProfileCopyDropdown.MyObject:Refresh()
			
			_detalhes:OpenOptionsWindow (current_instance)
			_detalhes:Msg (Loc ["STRING_OPTIONS_PROFILE_COPYOKEY"])
		end
		local build_copy_menu = function()
			local menu = {}
			
			local current = _detalhes:GetCurrentProfileName()
			
			for index, profile_name in ipairs (_detalhes:GetProfileList()) do 
				if (profile_name ~= current) then
					menu [#menu+1] = {value = profile_name, label = profile_name, onclick = profile_selectedCopy, icon = "Interface\\MINIMAP\\Vehicle-HammerGold-2"}
				end
			end
			
			return menu
		end
		
		local select_profileCopy_dropdown = g:NewDropDown (frame13, _, "$parentSelectProfileCopyDropdown", "selectProfileCopyDropdown", 160, 20, build_copy_menu, 0)	
		select_profileCopy_dropdown:SetEmptyTextAndIcon (Loc ["STRING_OPTIONS_PROFILE_SELECT"])
		
		local d = select_profileCopy_dropdown
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		local select_profileCopy_label = g:NewLabel (frame13, _, "$parentSelectProfileCopyLabel", "selectProfileCopyLabel", Loc ["STRING_OPTIONS_PROFILES_COPY"], "GameFontHighlightLeft")
		select_profileCopy_dropdown:SetPoint ("left", select_profileCopy_label, "right", 2, 0)
		
		window:CreateLineBackground2 (frame13, select_profileCopy_dropdown,  select_profileCopy_label, Loc ["STRING_OPTIONS_PROFILES_COPY_DESC"])
		
	--> erase profile
		local profile_selectedErase = function (_, instance, profile_name)
			local current_instance = _G.DetailsOptionsWindow.instance
			_detalhes:EraseProfile (profile_name)
			
			_detalhes:OpenOptionsWindow (current_instance)
			_detalhes:Msg (Loc ["STRING_OPTIONS_PROFILE_REMOVEOKEY"])
			
			_G.DetailsOptionsWindow13SelectProfileEraseDropdown.MyObject:Select (false)
			_G.DetailsOptionsWindow13SelectProfileCopyDropdown.MyObject:Refresh()
			_G.DetailsOptionsWindow13SelectProfileEraseDropdown.MyObject:Refresh()
		end
		local build_erase_menu = function()
			local menu = {}

			local current = _detalhes:GetCurrentProfileName()
			
			for index, profile_name in ipairs (_detalhes:GetProfileList()) do 
				if (profile_name ~= current) then
					menu [#menu+1] = {value = profile_name, label = profile_name, onclick = profile_selectedErase, icon = [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], color = {1, 1, 1}, iconcolor = {1, .9, .9, 0.8}}
				end
			end
			
			return menu
		end
		local select_profileErase_dropdown = g:NewDropDown (frame13, _, "$parentSelectProfileEraseDropdown", "selectProfileEraseDropdown", 160, 20, build_erase_menu, 0)	
		select_profileErase_dropdown:SetEmptyTextAndIcon (Loc ["STRING_OPTIONS_PROFILE_SELECT"])
		
		local d = select_profileErase_dropdown
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		local select_profileErase_label = g:NewLabel (frame13, _, "$parentSelectProfileEraseLabel", "selectProfileLabel", Loc ["STRING_OPTIONS_PROFILES_ERASE"], "GameFontHighlightLeft")
		select_profileErase_dropdown:SetPoint ("left", select_profileErase_label, "right", 2, 0)
		
		window:CreateLineBackground2 (frame13, select_profileErase_dropdown, select_profileErase_label, Loc ["STRING_OPTIONS_PROFILES_ERASE_DESC"])
		
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
		
		window:CreateLineBackground2 (frame13, profile_reset_button, hiddenlabel, Loc ["STRING_OPTIONS_PROFILES_RESET_DESC"])
		
		--profile_reset_button.button.texture:SetVertexColor (1, .8, 0)

		g:NewLabel (frame13, _, "$parentSavePosAndSizeLabel", "PosAndSizeLabel", Loc ["STRING_OPTIONS_PROFILE_POSSIZE"], "GameFontHighlightLeft")
		g:NewSwitch (frame13, _, "$parentPosAndSizeSlider", "PosAndSizeSlider", 60, 20, _, _, _detalhes.profile_save_pos)
		frame13.PosAndSizeSlider:SetPoint ("left", frame13.PosAndSizeLabel, "right", 2, -1)
		frame13.PosAndSizeSlider.OnSwitch = function (self, _, value)
			_detalhes.profile_save_pos = value
		end
		frame13.PosAndSizeSlider:SetPoint ("left", frame13.PosAndSizeLabel, "right", 3, 0)
		window:CreateLineBackground2 (frame13, "PosAndSizeSlider", "PosAndSizeLabel", Loc ["STRING_OPTIONS_PROFILE_POSSIZE_DESC"])
		
	--> anchors
	
		--general anchor
		g:NewLabel (frame13, _, "$parentProfilesAnchor", "ProfileAnchorLabel", Loc ["STRING_OPTIONS_PROFILES_ANCHOR"], "GameFontNormal")
		
		local x = window.left_start_at
		
		titulo_profiles:SetPoint (x, -30)
		titulo_profiles_desc:SetPoint (x, -50)

		local left_side = {
			{"ProfileAnchorLabel", 1, true},
			{current_profile_label, 2},
			{select_profile_label, 3},
			{profile_name_label, 4},
			{select_profileCopy_label, 5},
			{select_profileErase_label, 6},
			{profile_reset_button, 7},
			{"PosAndSizeLabel", 8, true},
		}
		
		window:arrange_menu (frame13, left_side, x, window.top_start_at)	
		
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
	--	local titulo_save = g:NewLabel (frame3, _, "$parentTituloPersona", "tituloBarsLabel", Loc ["STRING_OPTIONS_SAVELOAD"], "GameFontNormal", 16)
	--	local titulo_save_desc = g:NewLabel (frame3, _, "$parentTituloPersona2", "tituloBars2Label", Loc ["STRING_OPTIONS_SAVELOAD_DESC"], "GameFontNormal", 9, "white")
	--	titulo_save_desc.width = 320
		
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
				local desc = "Author: |cFFFFFFFF" .. skin_table.author .. "|r\nVersion: |cFFFFFFFF" .. skin_table.version .. "|r\nSite: |cFFFFFFFF" .. skin_table.site .. "|r\nDesc: |cFFFFFFFF" .. skin_table.desc .. "|r"
				skinOptions [#skinOptions+1] = {value = skin_name, label = skin_name, onclick = onSelectSkin, icon = "Interface\\GossipFrame\\TabardGossipIcon", desc = desc}
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
		
		window:CreateLineBackground2 (frame3, "skinDropdown", "skinLabel", Loc ["STRING_OPTIONS_INSTANCE_SKIN_DESC"])
		
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
			frame3.saveStyleName:ClearFocus()
			
			_detalhes:Msg (Loc ["STRING_OPTIONS_SAVELOAD_SKINCREATED"])

			_G.DetailsOptionsWindow3CustomSkinLoadDropdown.MyObject:Refresh()
			_G.DetailsOptionsWindow3CustomSkinRemoveDropdown.MyObject:Refresh()
			
		end	
	
		g:NewTextEntry (frame3, _, "$parentSaveStyleName", "saveStyleName", 120, 20)
		g:NewLabel (frame3, _, "$parentSaveSkinLabel", "saveSkinLabel", Loc ["STRING_OPTIONS_SAVELOAD_PNAME"], "GameFontHighlightLeft")
		frame3.saveStyleName:SetPoint ("left", frame3.saveSkinLabel, "right", 2)
		g:NewButton (frame3, _, "$parentSaveStyleButton", "saveStyle", 50, 19, saveStyleFunc, nil, nil, nil, Loc ["STRING_OPTIONS_SAVELOAD_SAVE"])
		frame3.saveStyle:InstallCustomTexture()
		
		window:CreateLineBackground2 (frame3, "saveStyleName", "saveSkinLabel", Loc ["STRING_OPTIONS_SAVELOAD_CREATE_DESC"])

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
		
		window:CreateLineBackground2 (frame3, "applyToAll", "toAllStyleLabel", Loc ["STRING_OPTIONS_SAVELOAD_APPLYALL_DESC"])
		
		window:CreateLineBackground2 (frame3, "makeDefault", "makeDefaultLabel", Loc ["STRING_OPTIONS_SAVELOAD_STD_DESC"])
		
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
			
			_G.DetailsOptionsWindow3CustomSkinLoadDropdown.MyObject:Select (false)
			_G.DetailsOptionsWindow3CustomSkinLoadDropdown.MyObject:Refresh()
			
			_detalhes:Msg (Loc ["STRING_OPTIONS_SKIN_LOADED"])
		end

		local loadtable = {}
		local buildCustomSkinMenu = function()
			table.wipe (loadtable)
			for index, _table in ipairs (_detalhes.savedStyles) do
				tinsert (loadtable, {value = index, label = _table.name, onclick = onSelectCustomSkin, icon = "Interface\\GossipFrame\\TabardGossipIcon", iconcolor = {.7, .7, .5, 1}})
			end
			return loadtable
		end
		
		local d = g:NewDropDown (frame3, _, "$parentCustomSkinLoadDropdown", "customSkinSelectDropdown", 160, 20, buildCustomSkinMenu, 0) -- func, default
		d:SetEmptyTextAndIcon (Loc ["STRING_OPTIONS_SKIN_SELECT"])
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		frame3.customSkinSelectDropdown:SetPoint ("left", frame3.loadCustomSkinLabel, "right", 2, 0)
		
		window:CreateLineBackground2 (frame3, "customSkinSelectDropdown", "loadCustomSkinLabel", Loc ["STRING_OPTIONS_SAVELOAD_LOAD_DESC"])
		
	--> Remove Custom Skin
		g:NewLabel (frame3, _, "$parentRemoveCustomSkinLabel", "removeCustomSkinLabel", Loc ["STRING_OPTIONS_SAVELOAD_REMOVE"], "GameFontHighlightLeft")
		--
		local onSelectCustomSkinToErase = function (_, _, index)
			table.remove (_detalhes.savedStyles, index)
			_G.DetailsOptionsWindow3CustomSkinRemoveDropdown.MyObject:Select (false)
			_G.DetailsOptionsWindow3CustomSkinLoadDropdown.MyObject:Refresh()
			_G.DetailsOptionsWindow3CustomSkinRemoveDropdown.MyObject:Refresh()
			_detalhes:Msg (Loc ["STRING_OPTIONS_SKIN_REMOVED"])
		end

		local loadtable2 = {}
		local buildCustomSkinToEraseMenu = function()
			table.wipe (loadtable2)
			for index, _table in ipairs (_detalhes.savedStyles) do
				tinsert (loadtable2, {value = index, label = _table.name, onclick = onSelectCustomSkinToErase, icon = [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], color = {1, 1, 1}, iconcolor = {1, .9, .9, 0.8}})
			end
			return loadtable2
		end
		
		local d = g:NewDropDown (frame3, _, "$parentCustomSkinRemoveDropdown", "customSkinSelectToRemoveDropdown", 160, 20, buildCustomSkinToEraseMenu, 0) -- func, default
		d:SetEmptyTextAndIcon (Loc ["STRING_OPTIONS_SKIN_SELECT"])
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		frame3.customSkinSelectToRemoveDropdown:SetPoint ("left", frame3.removeCustomSkinLabel, "right", 2, 0)

		window:CreateLineBackground2 (frame3, "customSkinSelectToRemoveDropdown", "removeCustomSkinLabel", Loc ["STRING_OPTIONS_SAVELOAD_ERASE_DESC"])
		
	--> extra Options
		g:NewLabel (frame3, _, "$parentSkinExtraOptionsAnchor", "SkinExtraOptionsAnchor", Loc ["STRING_OPTIONS_SKIN_EXTRA_OPTIONS_ANCHOR"], "GameFontNormal")
		frame3.SkinExtraOptionsAnchor:Hide()
		frame3.SkinExtraOptionsAnchor:SetPoint (window.right_start_at, -90)
		frame3.ExtraOptions = {}
		
	--> Anchors
		
		--general anchor
		g:NewLabel (frame3, _, "$parentSkinSelectionAnchor", "SkinSelectionAnchorLabel", Loc ["STRING_OPTIONS_SKIN_SELECT_ANCHOR"], "GameFontNormal")
		g:NewLabel (frame3, _, "$parentSkinPresetAnchor", "SkinPresetAnchorLabel", Loc ["STRING_OPTIONS_SKIN_PRESETS_ANCHOR"], "GameFontNormal")
		
		frame3.saveStyle:SetPoint ("left", frame3.saveStyleName, "right", 2)
		
		local x = window.left_start_at
		
		titulo_skin:SetPoint (x, -30)
		titulo_skin_desc:SetPoint (x, -50)
		
		local left_side = {
			{"SkinSelectionAnchorLabel", 1, true},
			{"skinLabel", 2},
			{"SkinPresetAnchorLabel", 3, true},
			{"saveSkinLabel", 4},
			{"loadCustomSkinLabel", 5},
			{"removeCustomSkinLabel", 6},
			{"makeDefault", 7, true},
			{"applyToAll", 8},
			--{"", 9},
			--{"", 10},
		}
		
		window:arrange_menu (frame3, left_side, x, -90)
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
	
	--> general anchor
		g:NewLabel (frame4, _, "$parentRowGeneralAnchor", "RowGeneralAnchorLabel", Loc ["STRING_OPTIONS_GENERAL_ANCHOR"], "GameFontNormal")
	
	--> bar height
		g:NewLabel (frame4, _, "$parentRowHeightLabel", "rowHeightLabel", Loc ["STRING_OPTIONS_BAR_HEIGHT"], "GameFontHighlightLeft")
		local s = g:NewSlider (frame4, _, "$parentSliderRowHeight", "rowHeightSlider", SLIDER_WIDTH, 20, 10, 30, 1, tonumber (instance.row_info.height))
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)

		frame4.rowHeightSlider:SetPoint ("left", frame4.rowHeightLabel, "right", 2)
		frame4.rowHeightSlider:SetThumbSize (50)
		frame4.rowHeightSlider:SetHook ("OnValueChange", function (self, instance, amount) 
			instance.row_info.height = amount
			instance.row_height = instance.row_info.height+instance.row_info.space.between
			instance:RefreshBars()
			instance:InstanceReset()
			instance:ReajustaGump()
		end)	
		window:CreateLineBackground2 (frame4, "rowHeightSlider", "rowHeightLabel", Loc ["STRING_OPTIONS_BAR_HEIGHT_DESC"])
	
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
		window:CreateLineBackground2 (frame4, "barGrowDirectionSlider", "barGrowDirectionLabel", Loc ["STRING_OPTIONS_BARGROW_DIRECTION_DESC"])
			
	-- bar sort direction
		
		g:NewSwitch (frame4, _, "$parentBarSortDirectionSlider", "barSortDirectionSlider", 80, 20, Loc ["STRING_BOTTOM"], Loc ["STRING_TOP"], instance.bars_sort_direction, nil, grow_switch_func, grow_return_func)
		g:NewLabel (frame4, _, "$parentBarSortDirectionLabel", "barSortDirectionLabel", Loc ["STRING_OPTIONS_BARSORT_DIRECTION"], "GameFontHighlightLeft")

		frame4.barSortDirectionSlider:SetPoint ("left", frame4.barSortDirectionLabel, "right", 2)
		frame4.barSortDirectionSlider.OnSwitch = function (self, instance, value)
			instance.bars_sort_direction = value
			_detalhes:AtualizaGumpPrincipal (-1, true)
		end
		frame4.barSortDirectionSlider.thumb:SetSize (50, 12)
		window:CreateLineBackground2 (frame4, "barSortDirectionSlider", "barSortDirectionLabel", Loc ["STRING_OPTIONS_BARSORT_DIRECTION_DESC"])
		
	-- spacement
		g:NewLabel (frame4, _, "$parentBarSpacementLabel", "BarSpacementLabel", Loc ["STRING_OPTIONS_BAR_SPACING"], "GameFontHighlightLeft")
		local s = g:NewSlider (frame4, _, "$parentBarSpacementSizeSlider", "BarSpacementSlider", SLIDER_WIDTH, 20, 0, 10, 1, instance.row_info.space.between)
		s:SetThumbSize (50)
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
	
		frame4.BarSpacementSlider:SetPoint ("left", frame4.BarSpacementLabel, "right", 2)
		frame4.BarSpacementSlider:SetHook ("OnValueChange", function (self, instancia, amount)
			instancia:SetBarSettings (nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, amount)
		end)
		window:CreateLineBackground2 (frame4, "BarSpacementSlider", "BarSpacementLabel", Loc ["STRING_OPTIONS_BAR_SPACING_DESC"])
	
	--> Top Texture
		--anchor
		g:NewLabel (frame4, _, "$parentRowUpperTextureAnchor", "rowUpperTextureLabel", Loc ["STRING_OPTIONS_TEXT_TEXTUREU_ANCHOR"], "GameFontNormal")
	
		--texture
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
		
		g:NewLabel (frame4, _, "$parentTextureLabel", "textureLabel", Loc ["STRING_OPTIONS_BAR_TEXTURE"], "GameFontHighlightLeft")
		local d = g:NewDropDown (frame4, _, "$parentTextureDropdown", "textureDropdown", DROPDOWN_WIDTH, 20, buildTextureMenu, nil)			
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))

		frame4.textureDropdown:SetPoint ("left", frame4.textureLabel, "right", 2)
		window:CreateLineBackground2 (frame4, "textureDropdown", "textureLabel", Loc ["STRING_OPTIONS_BAR_TEXTURE_DESC"])

		-- row texture color	
		local rowcolor_callback = function (button, r, g, b, a)
			_G.DetailsOptionsWindow.instance:SetBarSettings (nil, nil, nil, {r, g, b})
			_G.DetailsOptionsWindow.instance.row_info.alpha = a
			_G.DetailsOptionsWindow.instance:SetBarSettings (nil, nil, nil, nil, nil, nil, nil, a)
		end
		g:NewLabel (frame4, _, "$parentRowColorPickLabel", "rowPickColorLabel", Loc ["STRING_OPTIONS_TEXT_ROWCOLOR2"], "GameFontHighlightLeft")
		g:NewColorPickButton (frame4, "$parentRowColorPick", "rowColorPick", rowcolor_callback)
		frame4.rowColorPick:SetPoint ("left", frame4.rowPickColorLabel, "right", 2, 0)
		local background = window:CreateLineBackground2 (frame4, "rowColorPick", "rowPickColorLabel", Loc ["STRING_OPTIONS_BAR_COLOR_DESC"])
		background:SetSize (50, 16)

		-- bar texture by class color
		g:NewLabel (frame4, _, "$parentUseClassColorsLabel", "classColorsLabel", Loc ["STRING_OPTIONS_TEXT_ROWCOLOR_NOTCLASS"], "GameFontHighlightLeft")
		g:NewSwitch (frame4, _, "$parentClassColorSlider", "classColorSlider", 60, 20, _, _, instance.row_info.texture_class_colors)
		frame4.classColorSlider:SetFrameLevel (frame4.rowColorPick:GetFrameLevel()+2)
		frame4.classColorSlider:SetPoint ("left", frame4.classColorsLabel, "right", 2, -1)
		frame4.classColorSlider.OnSwitch = function (self, instance, value)
			instance:SetBarSettings (nil, nil, value)
		end
		frame4.classColorsLabel:SetPoint ("left", frame4.rowColorPick, "right", 3, 0)
		window:CreateLineBackground2 (frame4, "classColorSlider", "classColorsLabel", Loc ["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"])
	
	
	--> Bottom Texture
	
		--anchor
		g:NewLabel (frame4, _, "$parentRowLowerTextureAnchor", "rowLowerTextureLabel", Loc ["STRING_OPTIONS_TEXT_TEXTUREL_ANCHOR"], "GameFontNormal")
	
		--texture
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
		
		g:NewLabel (frame4, _, "$parentRowBackgroundTextureLabel", "rowBackgroundLabel", Loc ["STRING_OPTIONS_BAR_TEXTURE"], "GameFontHighlightLeft")
		local d = g:NewDropDown (frame4, _, "$parentRowBackgroundTextureDropdown", "rowBackgroundDropdown", DROPDOWN_WIDTH, 20, buildTextureMenu2, nil)			
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
		
		frame4.rowBackgroundDropdown:SetPoint ("left", frame4.rowBackgroundLabel, "right", 2)
		window:CreateLineBackground2 (frame4, "rowBackgroundDropdown", "rowBackgroundLabel", Loc ["STRING_OPTIONS_BAR_BTEXTURE_DESC"])
		
		--bar background color	
		local rowcolorbackground_callback = function (button, r, g, b, a)
			_G.DetailsOptionsWindow.instance:SetBarSettings (nil, nil, nil, nil, nil, nil, {r, g, b, a})
		end
		g:NewColorPickButton (frame4, "$parentRowBackgroundColorPick", "rowBackgroundColorPick", rowcolorbackground_callback)
		g:NewLabel (frame4, _, "$parentRowBackgroundColorPickLabel", "rowBackgroundPickLabel", Loc ["STRING_OPTIONS_TEXT_ROWCOLOR"], "GameFontHighlightLeft")
		frame4.rowBackgroundColorPick:SetPoint ("left", frame4.rowBackgroundPickLabel, "right", 2, 0)

		local background = window:CreateLineBackground2 (frame4, "rowBackgroundColorPick", "rowBackgroundPickLabel", Loc ["STRING_OPTIONS_BAR_BCOLOR_DESC"])
		background:SetSize (50, 16)
		
		--bar texture by class color
		g:NewSwitch (frame4, _, "$parentBackgroundClassColorSlider", "rowBackgroundColorByClassSlider", 60, 20, _, _, instance.row_info.texture_background_class_color)
		g:NewLabel (frame4, _, "$parentRowBackgroundClassColorLabel", "rowBackgroundColorByClassLabel", Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2"], "GameFontHighlightLeft")
		frame4.rowBackgroundColorByClassSlider:SetFrameLevel (frame4.rowBackgroundColorPick:GetFrameLevel()+2)
		frame4.rowBackgroundColorByClassSlider:SetPoint ("left", frame4.rowBackgroundColorByClassLabel, "right", 2)
		frame4.rowBackgroundColorByClassSlider.OnSwitch = function (self, instance, value)
			instance:SetBarSettings (nil, nil, nil, nil, nil, value)
		end

		window:CreateLineBackground2 (frame4, "rowBackgroundColorByClassSlider", "rowBackgroundColorByClassLabel", Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2_DESC"])
	
		frame4.rowBackgroundColorByClassLabel:SetPoint ("left", frame4.rowBackgroundColorPick, "right", 3)
		
		
	--> Icons
		--anchors
		g:NewLabel (frame4, _, "$parentIconsAnchor", "rowIconsLabel", Loc ["STRING_OPTIONS_TEXT_ROWICONS_ANCHOR"], "GameFontNormal")
		
		--icon file
		g:NewLabel (frame4, _, "$parentIconFileLabel", "iconFileLabel", Loc ["STRING_OPTIONS_BAR_ICONFILE"], "GameFontHighlightLeft")
		g:NewTextEntry (frame4, _, "$parentIconFileEntry", "iconFileEntry", 180, 20)
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
		
		window:CreateLineBackground2 (frame4, "iconFileEntry", "iconFileLabel", Loc ["STRING_OPTIONS_BAR_ICONFILE_DESC"])
		
		frame4.iconFileEntry.text = instance.row_info.icon_file
		
		g:NewButton (frame4.iconFileEntry, _, "$parentNoIconButton", "noIconButton", 20, 20, function()
			if (frame4.iconFileEntry.text == "") then
				frame4.iconFileEntry.text = [[Interface\AddOns\Details\images\classes_small]]
				frame4.iconFileEntry:PressEnter()
			else
				frame4.iconFileEntry.text = ""
				frame4.iconFileEntry:PressEnter()
			end
		end)
		
		frame4.noIconButton = frame4.iconFileEntry.noIconButton
		frame4.noIconButton:SetPoint ("left", frame4.iconFileEntry, "right", 2, 0)
		frame4.noIconButton:SetNormalTexture ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]] or [[Interface\Buttons\UI-GroupLoot-Pass-Down]])
		frame4.noIconButton:SetHighlightTexture ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]] or [[Interface\Buttons\UI-GROUPLOOT-PASS-HIGHLIGHT]])
		frame4.noIconButton:SetPushedTexture ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]] or [[Interface\Buttons\UI-GroupLoot-Pass-Up]])
		frame4.noIconButton:GetNormalTexture():SetDesaturated (true)
		frame4.noIconButton.tooltip = "Clear icon file / Restore default"

		--bar start at
		g:NewSwitch (frame4, _, "$parentBarStartSlider", "barStartSlider", 60, 20, nil, nil, instance.row_info.start_after_icon)
		g:NewLabel (frame4, _, "$parentBarStartLabel", "barStartLabel", Loc ["STRING_OPTIONS_BARSTART"], "GameFontHighlightLeft")

		frame4.barStartSlider:SetPoint ("left", frame4.barStartLabel, "right", 2)
		frame4.barStartSlider.OnSwitch = function (self, instance, value)
			instance:SetBarSettings (nil, nil, nil, nil, nil, nil, nil, nil, nil, value)
		end
		
		window:CreateLineBackground2 (frame4, "barStartSlider", "barStartLabel", Loc ["STRING_OPTIONS_BARSTART_DESC"])
		
	--> Backdrop
		--anchor
		g:NewLabel (frame4, _, "$parentBackdropAnchor", "BackdropAnchorLabel", Loc ["STRING_OPTIONS_BAR_BACKDROP_ANCHOR"], "GameFontNormal")

		--enabled
		g:NewLabel (frame4, _, "$parentBackdropEnabledLabel", "BackdropEnabledLabel", Loc ["STRING_OPTIONS_BAR_BACKDROP_ENABLED"], "GameFontHighlightLeft")
		g:NewSwitch (frame4, _, "$parentBackdropEnabledSlider", "BackdropEnabledSlider", 60, 20, _, _, instance.row_info.backdrop.enabled)
		frame4.BackdropEnabledSlider:SetPoint ("left", frame4.BackdropEnabledLabel, "right", 2, -1)
		frame4.BackdropEnabledSlider.OnSwitch = function (self, instance, value)
			instance:SetBarBackdropSettings (value)
		end
		window:CreateLineBackground2 (frame4, "BackdropEnabledSlider", "BackdropEnabledLabel", Loc ["STRING_OPTIONS_BAR_BACKDROP_ENABLED_DESC"])
		
		--texture
		local onSelectTextureBackdrop = function (_, instance, textureName)
			instance:SetBarBackdropSettings (nil, nil, nil, textureName)
		end

		local buildTextureBackdropMenu = function() 
			local textures2 = SharedMedia:HashTable ("border")
			local texTable2 = {}
			for name, texturePath in pairs (textures2) do 
				texTable2 [#texTable2+1] = {value = name, label = name, onclick = onSelectTextureBackdrop}
			end
			table.sort (texTable2, function (t1, t2) return t1.label < t2.label end)
			return texTable2 
		end
		
		g:NewLabel (frame4, _, "$parentBackdropBorderTextureLabel", "BackdropBorderTextureLabel", Loc ["STRING_OPTIONS_BAR_BACKDROP_TEXTURE"], "GameFontHighlightLeft")
		local d = g:NewDropDown (frame4, _, "$parentBackdropBorderTextureDropdown", "BackdropBorderTextureDropdown", DROPDOWN_WIDTH, 20, buildTextureBackdropMenu, nil)			
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))		
		
		frame4.BackdropBorderTextureDropdown:SetPoint ("left", frame4.BackdropBorderTextureLabel, "right", 2)
		window:CreateLineBackground2 (frame4, "BackdropBorderTextureDropdown", "BackdropBorderTextureLabel", Loc ["STRING_OPTIONS_BAR_BACKDROP_TEXTURE_DESC"])
		
		--size
		g:NewLabel (frame4, _, "$parentBackdropSizeLabel", "BackdropSizeLabel", Loc ["STRING_OPTIONS_BAR_BACKDROP_SIZE"], "GameFontHighlightLeft")
		local s = g:NewSlider (frame4, _, "$parentBackdropSizeHeight", "BackdropSizeSlider", SLIDER_WIDTH, 20, 1, 20, 1, tonumber (instance.row_info.height))
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s:SetThumbSize (50)

		frame4.BackdropSizeSlider:SetPoint ("left", frame4.BackdropSizeLabel, "right", 2)
		frame4.BackdropSizeSlider:SetThumbSize (50)
		frame4.BackdropSizeSlider:SetHook ("OnValueChange", function (self, instance, amount) 
			instance:SetBarBackdropSettings (nil, amount)
		end)	
		window:CreateLineBackground2 (frame4, "BackdropSizeSlider", "BackdropSizeLabel", Loc ["STRING_OPTIONS_BAR_BACKDROP_SIZE_DESC"])

		--color
		local backdropcolor_callback = function (button, r, g, b, a)
			_G.DetailsOptionsWindow.instance:SetBarBackdropSettings (nil, nil, {r, g, b, a})
		end
		g:NewColorPickButton (frame4, "$parentBackdropColorPick", "BackdropColorPick", backdropcolor_callback)
		g:NewLabel (frame4, _, "$parentBackdropColorLabel", "BackdropColorLabel", Loc ["STRING_OPTIONS_BAR_BACKDROP_COLOR"], "GameFontHighlightLeft")
		frame4.BackdropColorPick:SetPoint ("left", frame4.BackdropColorLabel, "right", 2, 0)

		local background = window:CreateLineBackground2 (frame4, "BackdropColorPick", "BackdropColorLabel", Loc ["STRING_OPTIONS_BAR_BACKDROP_COLOR_DESC"])
		
	--> Anchors:
		local x = window.left_start_at
		
		titulo_bars:SetPoint (x, -30)
		titulo_bars_desc:SetPoint (x, -50)

		local left_side = {
			--basic
			{frame4.RowGeneralAnchorLabel, 1, true},
			{frame4.rowHeightLabel, 2},
			{frame4.barGrowDirectionLabel, 3},
			{frame4.barSortDirectionLabel, 4},
			{frame4.BarSpacementLabel, 5},
			--icon
			{frame4.rowIconsLabel, 6, true},
			{frame4.iconFileLabel, 7},
			{frame4.barStartLabel, 8},
			--backdrop
			{frame4.BackdropAnchorLabel, 9, true},
			{frame4.BackdropEnabledLabel, 10},
			{frame4.BackdropBorderTextureLabel, 11},
			{frame4.BackdropSizeLabel, 12},
			{frame4.BackdropColorLabel, 13},
		}
		
		local right_side = {
			{frame4.rowUpperTextureLabel, 1, true},
			{frame4.textureLabel, 2},
			{frame4.rowPickColorLabel, 3},
			{frame4.rowLowerTextureLabel, 4, true},
			{frame4.rowBackgroundLabel, 5},
			{frame4.rowBackgroundPickLabel, 6},
		}

		window:arrange_menu (frame4, left_side, x, -90)
		window:arrange_menu (frame4, right_side, 360, -90)
		
		--[[
		frame4.rowHeightLabel:SetPoint (x, -90) --bar height
		frame4.barGrowDirectionLabel:SetPoint (x, -125) --grow direction
		frame4.barSortDirectionLabel:SetPoint (x, -150) --sort direction
		frame4.BarSpacementLabel:SetPoint (x, -175) --spacement
		
		frame4.rowUpperTextureLabel:SetPoint (x, -210) --anchor
		frame4.textureLabel:SetPoint (x, -235) --bar texture
		frame4.rowPickColorLabel:SetPoint (x, -260) --color pick
		
		frame4.rowLowerTextureLabel:SetPoint (x, -295)
		frame4.rowBackgroundLabel:SetPoint (x, -320) --select background
		frame4.rowBackgroundPickLabel:SetPoint (x, -345) --bar color background
		
		frame4.rowIconsLabel:SetPoint (x, -380)
		frame4.iconFileLabel:SetPoint (x, -405)
		frame4.barStartLabel:SetPoint (x, -430)
		--]]
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
	
		window:CreateLineBackground2 (frame5, "fixedTextColor", "fixedTextColorLabel", Loc ["STRING_OPTIONS_TEXT_FIXEDCOLOR_DESC"])
	
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

		window:CreateLineBackground2 (frame5, "fonsizeSlider", "fonsizeLabel", Loc ["STRING_OPTIONS_TEXT_SIZE_DESC"])
		
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

		window:CreateLineBackground2 (frame5, "fontDropdown", "fontLabel", Loc ["STRING_OPTIONS_TEXT_FONT_DESC"])		

	--> left text and right class color
		g:NewSwitch (frame5, _, "$parentUseClassColorsLeftTextSlider", "classColorsLeftTextSlider", 60, 20, _, _, instance.row_info.textL_class_colors)
		g:NewSwitch (frame5, _, "$parentUseClassColorsRightTextSlider", "classColorsRightTextSlider", 60, 20, _, _, instance.row_info.textR_class_colors)
		g:NewLabel (frame5, _, "$parentUseClassColorsLeftText", "classColorsLeftTextLabel", Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR"], "GameFontHighlightLeft")

		frame5.classColorsLeftTextSlider:SetPoint ("left", frame5.classColorsLeftTextLabel, "right", 2)
		frame5.classColorsLeftTextSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, value)
		end
		
		window:CreateLineBackground2 (frame5, "classColorsLeftTextSlider", "classColorsLeftTextLabel", Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR_DESC"])
		
	--> right text by class color
		g:NewLabel (frame5, _, "$parentUseClassColorsRightText", "classColorsRightTextLabel", Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR"], "GameFontHighlightLeft")

		frame5.classColorsRightTextSlider:SetPoint ("left", frame5.classColorsRightTextLabel, "right", 2)
		frame5.classColorsRightTextSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, nil, value)
		end
		
		window:CreateLineBackground2 (frame5, "classColorsRightTextSlider", "classColorsRightTextLabel", Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR_DESC"])
		
	--> left outline
		g:NewSwitch (frame5, _, "$parentTextLeftOutlineSlider", "textLeftOutlineSlider", 60, 20, _, _, instance.row_info.textL_outline)
		g:NewLabel (frame5, _, "$parentTextLeftOutlineLabel", "textLeftOutlineLabel", Loc ["STRING_OPTIONS_TEXT_LOUTILINE"], "GameFontHighlightLeft")
		
		frame5.textLeftOutlineSlider:SetPoint ("left", frame5.textLeftOutlineLabel, "right", 2)
		frame5.textLeftOutlineSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, nil, nil, value)
		end
		
		window:CreateLineBackground2 (frame5, "textLeftOutlineSlider", "textLeftOutlineLabel", Loc ["STRING_OPTIONS_TEXT_LOUTILINE_DESC"])
		
	--> right outline
		g:NewSwitch (frame5, _, "$parentTextRightOutlineSlider", "textRightOutlineSlider", 60, 20, _, _, instance.row_info.textR_outline)
		g:NewLabel (frame5, _, "$parentTextRightOutlineLabel", "textRightOutlineLabel", Loc ["STRING_OPTIONS_TEXT_ROUTILINE"], "GameFontHighlightLeft")
		
		frame5.textRightOutlineSlider:SetPoint ("left", frame5.textRightOutlineLabel, "right", 2)
		frame5.textRightOutlineSlider.OnSwitch = function (self, instance, value)
			instance:SetBarTextSettings (nil, nil, nil, nil, nil, nil, value)
		end

		window:CreateLineBackground2 (frame5, "textRightOutlineSlider", "textRightOutlineLabel", Loc ["STRING_OPTIONS_TEXT_ROUTILINE_DESC"])
	
	--> percent type
		local onSelectPercent = function (_, instance, percentType)
			instance:SetBarTextSettings (nil, nil, nil, nil, nil, nil, nil, nil, nil, percentType)
		end
		
		local buildPercentMenu = function() 
			local percentTable = {
				{value = 1, label = "Relative to Total", onclick = onSelectPercent, icon = [[Interface\GROUPFRAME\UI-GROUP-MAINTANKICON]]},
				{value = 2, label = "Relative to Top Player", onclick = onSelectPercent, icon = [[Interface\GROUPFRAME\UI-Group-LeaderIcon]]}
			}
			return percentTable 
		end
		
		local d = g:NewDropDown (frame5, _, "$parentPercentDropdown", "percentDropdown", DROPDOWN_WIDTH, 20, buildPercentMenu, nil)
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		g:NewLabel (frame5, _, "$parentPercentLabel", "percentLabel", Loc ["STRING_OPTIONS_PERCENT_TYPE"], "GameFontHighlightLeft")
		frame5.percentDropdown:SetPoint ("left", frame5.percentLabel, "right", 2)

		window:CreateLineBackground2 (frame5, "percentDropdown", "percentLabel", Loc ["STRING_OPTIONS_PERCENT_TYPE_DESC"])
	
	--> right text customization
	
		g:NewLabel (frame5, _, "$parentCutomRightTextLabel", "cutomRightTextLabel", Loc ["STRING_OPTIONS_BARRIGHTTEXTCUSTOM"], "GameFontHighlightLeft")
		g:NewSwitch (frame5, _, "$parentCutomRightTextSlider", "cutomRightTextSlider", 60, 20, _, _, instance.row_info.textR_enable_custom_text)

		frame5.cutomRightTextSlider:SetPoint ("left", frame5.cutomRightTextLabel, "right", 2)
		frame5.cutomRightTextSlider.OnSwitch = function (self, instance, value)
			_G.DetailsOptionsWindow.instance:SetBarTextSettings (nil, nil, nil, nil, nil, nil, nil, value)
		end

		window:CreateLineBackground2 (frame5, "cutomRightTextSlider", "cutomRightTextLabel", Loc ["STRING_OPTIONS_BARRIGHTTEXTCUSTOM_DESC"])
		
		--text entry
		g:NewLabel (frame5, _, "$parentCutomRightText2Label", "cutomRightTextEntryLabel", Loc ["STRING_OPTIONS_BARRIGHTTEXTCUSTOM2"], "GameFontHighlightLeft")
		g:NewTextEntry (frame5, _, "$parentCutomRightTextEntry", "cutomRightTextEntry", 180, 20)
		frame5.cutomRightTextEntry:SetPoint ("left", frame5.cutomRightTextEntryLabel, "right", 2, -1)

		--frame5.cutomRightTextEntry.tooltip = "type the customized text"
		frame5.cutomRightTextEntry:SetHook ("OnTextChanged", function (self, byUser)
		
			if (not frame5.cutomRightTextEntry.text:find ("{func")) then
			
				if (frame5.cutomRightTextEntry.changing and not byUser) then
					frame5.cutomRightTextEntry.changing = false
					return
				elseif (frame5.cutomRightTextEntry.changing and byUser) then
					frame5.cutomRightTextEntry.changing = false
				end

				if (byUser) then
					local t = frame5.cutomRightTextEntry.text
					t = t:gsub ("||", "|")
					_G.DetailsOptionsWindow.instance:SetBarTextSettings (nil, nil, nil, nil, nil, nil, nil, nil, t)
				else
					local t = frame5.cutomRightTextEntry.text
					t = t:gsub ("|", "||")
					frame5.cutomRightTextEntry.changing = true
					frame5.cutomRightTextEntry.text = t
				end
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
			local t = frame5.cutomRightTextEntry.text
			t = t:gsub ("||", "|")
			_G.DetailsOptionsWindow.instance:SetBarTextSettings (nil, nil, nil, nil, nil, nil, nil, nil, t)
		end)
		frame5.cutomRightTextEntry:SetHook ("OnEscapePressed", function()
			frame5.cutomRightTextEntry:ClearFocus()
			return true
		end)

		window:CreateLineBackground2 (frame5, "cutomRightTextEntry", "cutomRightTextEntryLabel", Loc ["STRING_OPTIONS_BARRIGHTTEXTCUSTOM2_DESC"])
		
		frame5.cutomRightTextEntry.text = instance.row_info.textR_custom_text
		
		local callback = function (text)
			frame5.cutomRightTextEntry.text = text
			frame5.cutomRightTextEntry:PressEnter()
		end
		g:NewButton (frame5.cutomRightTextEntry, _, "$parentOpenTextBarEditorButton", "TextBarEditorButton", 22, 22, function()
			DetailsWindowOptionsBarTextEditor:Open (frame5.cutomRightTextEntry.text, callback, _G.DetailsOptionsWindow)
		end)
		frame5.TextBarEditorButton = frame5.cutomRightTextEntry.TextBarEditorButton
		frame5.TextBarEditorButton:SetPoint ("left", frame5.cutomRightTextEntry, "right", 2, 1)
		frame5.TextBarEditorButton:SetNormalTexture ([[Interface\HELPFRAME\OpenTicketIcon]])
		frame5.TextBarEditorButton:SetHighlightTexture ([[Interface\HELPFRAME\OpenTicketIcon]])
		frame5.TextBarEditorButton:SetPushedTexture ([[Interface\HELPFRAME\OpenTicketIcon]])
		frame5.TextBarEditorButton:GetNormalTexture():SetDesaturated (true)
		frame5.TextBarEditorButton.tooltip = "Row Text Editor"
		
		g:NewButton (frame5.cutomRightTextEntry, _, "$parentResetCustomRightTextButton", "customRightTextButton", 20, 20, function()
			frame5.cutomRightTextEntry.text = _detalhes.instance_defaults.row_info.textR_custom_text
			frame5.cutomRightTextEntry:PressEnter()
		end)
		frame5.customRightTextButton = frame5.cutomRightTextEntry.customRightTextButton
		frame5.customRightTextButton:SetPoint ("left", frame5.TextBarEditorButton, "right", 0, 0)
		frame5.customRightTextButton:SetNormalTexture ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]] or [[Interface\Buttons\UI-GroupLoot-Pass-Down]])
		frame5.customRightTextButton:SetHighlightTexture ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]] or [[Interface\Buttons\UI-GROUPLOOT-PASS-HIGHLIGHT]])
		frame5.customRightTextButton:SetPushedTexture ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]] or [[Interface\Buttons\UI-GroupLoot-Pass-Up]])
		frame5.customRightTextButton:GetNormalTexture():SetDesaturated (true)
		frame5.customRightTextButton.tooltip = "Reset to Default"
		
	--> anchors
	
		--general anchor
		g:NewLabel (frame5, _, "$parentRowTextGeneralAnchor", "RowGeneralAnchorLabel", Loc ["STRING_OPTIONS_GENERAL_ANCHOR"], "GameFontNormal")
		
		--left text anchor
		g:NewLabel (frame5, _, "$parentLeftTextAnchor", "LeftTextAnchorLabel", Loc ["STRING_OPTIONS_TEXT_LEFT_ANCHOR"], "GameFontNormal")
		--right text anchor
		g:NewLabel (frame5, _, "$parentRightTextAnchor", "RightTextAnchorLabel", Loc ["STRING_OPTIONS_TEXT_RIGHT_ANCHOR"], "GameFontNormal")
		
		local x = window.left_start_at
		
		titulo_texts:SetPoint (x, -30)
		titulo_texts_desc:SetPoint (x, -50)

		local left_side = {
			{"LeftTextAnchorLabel", 1, true},
			{"textLeftOutlineLabel", 2},
			{"classColorsLeftTextLabel", 3},
			{"RightTextAnchorLabel", 4, true},
			{"textRightOutlineLabel", 5},
			{"classColorsRightTextLabel", 6},
			{"cutomRightTextLabel", 7},
			{"cutomRightTextEntryLabel", 8},
		}
		
		window:arrange_menu (frame5, left_side, x, window.top_start_at)
		
		local right_side = {
			{"RowGeneralAnchorLabel", 1, true},
			{frame5.fonsizeLabel, 2}, --text size
			{frame5.fontLabel, 3},--text fontface
			{frame5.fixedTextColorLabel, 4},
			{frame5.percentLabel, 5},
		}
	
		window:arrange_menu (frame5, right_side, window.right_start_at, window.top_start_at)
	

		

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

		window:CreateLineBackground2 (frame6, "windowColorPick", "windowPickColorLabel", Loc ["STRING_OPTIONS_INSTANCE_COLOR_DESC"])
		
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

		window:CreateLineBackground2 (frame6, "windowBackgroundColorPick", "windowBackgroundPickColorLabel", Loc ["STRING_OPTIONS_INSTANCE_ALPHA2_DESC"])

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
		
		window:CreateLineBackground2 (frame6, "alphaSlider", "alphaLabel", Loc ["STRING_OPTIONS_INSTANCE_ALPHA_DESC"])
		
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
			
			window:CreateLineBackground2 (frame6, "stretchAnchorSlider", "stretchAnchorLabel", Loc ["STRING_OPTIONS_STRETCH_DESC"])

		--stretch button always on top
			g:NewSwitch (frame6, _, "$parentStretchAlwaysOnTopSlider", "stretchAlwaysOnTopSlider", 60, 20, _, _, instance.grab_on_top)
			g:NewLabel (frame6, _, "$parentStretchAlwaysOnTopLabel", "stretchAlwaysOnTopLabel", Loc ["STRING_OPTIONS_STRETCHTOP"], "GameFontHighlightLeft")
			
			frame6.stretchAlwaysOnTopSlider:SetPoint ("left", frame6.stretchAlwaysOnTopLabel, "right", 2, 0)
		
			frame6.stretchAlwaysOnTopSlider.OnSwitch = function (self, instance, value)
				instance:StretchButtonAlwaysOnTop (value)
			end
			
			window:CreateLineBackground2 (frame6, "stretchAlwaysOnTopSlider", "stretchAlwaysOnTopLabel", Loc ["STRING_OPTIONS_STRETCHTOP_DESC"])

		-- instance toolbar side
			g:NewSwitch (frame6, _, "$parentInstanceToolbarSideSlider", "instanceToolbarSideSlider", 80, 20, Loc ["STRING_BOTTOM"], Loc ["STRING_TOP"], instance.toolbar_side, nil, grow_switch_func, grow_return_func)
			g:NewLabel (frame6, _, "$parentInstanceToolbarSideLabel", "instanceToolbarSideLabel", Loc ["STRING_OPTIONS_TOOLBARSIDE"], "GameFontHighlightLeft")
			
			frame6.instanceToolbarSideSlider:SetPoint ("left", frame6.instanceToolbarSideLabel, "right", 2)
			frame6.instanceToolbarSideSlider.OnSwitch = function (self, instance, value)
				instance.toolbar_side = value
				instance:ToolbarSide (side)
				_G.DetailsOptionsWindow8:update_menuanchor_xy (instance)
				_G.DetailsOptionsWindow7:update_menuanchor_xy (instance)
			end
			frame6.instanceToolbarSideSlider.thumb:SetSize (50, 12)
			
			window:CreateLineBackground2 (frame6, "instanceToolbarSideSlider", "instanceToolbarSideLabel", Loc ["STRING_OPTIONS_TOOLBARSIDE_DESC"])
			
	--> micro displays side
			g:NewSwitch (frame6, _, "$parentInstanceMicroDisplaysSideSlider", "instanceMicroDisplaysSideSlider", 80, 20, Loc ["STRING_BOTTOM"], Loc ["STRING_TOP"], instance.toolbar_side, nil, grow_switch_func, grow_return_func)
			g:NewLabel (frame6, _, "$parentInstanceMicroDisplaysSideLabel", "instanceMicroDisplaysSideLabel", Loc ["STRING_OPTIONS_MICRODISPLAYSSIDE"], "GameFontHighlightLeft")
			
			frame6.instanceMicroDisplaysSideSlider:SetPoint ("left", frame6.instanceMicroDisplaysSideLabel, "right", 2)
			frame6.instanceMicroDisplaysSideSlider.OnSwitch = function (self, instance, value)
				instance:MicroDisplaysSide (value, true)
			end
			frame6.instanceMicroDisplaysSideSlider.thumb:SetSize (50, 12)
			
			window:CreateLineBackground2 (frame6, "instanceMicroDisplaysSideSlider", "instanceMicroDisplaysSideLabel", Loc ["STRING_OPTIONS_MICRODISPLAYSSIDE_DESC"])
	
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
		
		window:CreateLineBackground2 (frame6, "sideBarsSlider", "sideBarsLabel", Loc ["STRING_OPTIONS_SHOW_SIDEBARS_DESC"])
		
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

		window:CreateLineBackground2 (frame6, "statusbarSlider", "statusbarLabel", Loc ["STRING_OPTIONS_SHOW_STATUSBAR_DESC"])
		
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
		
		window:CreateLineBackground2 (frame6, "backdropDropdown", "backdropLabel", Loc ["STRING_OPTIONS_INSTANCE_BACKDROP_DESC"])
		
		--> frame strata
			local onStrataSelect = function (_, instance, strataName)
				instance:SetFrameStrata (strataName)
			end
			local strataTable = {
				{value = "BACKGROUND", label = "Background", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Green]], iconcolor = {0, .5, 0, .8}, texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
				{value = "LOW", label = "Low", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Green]] , texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
				{value = "MEDIUM", label = "Medium", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Yellow]] , texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
				{value = "HIGH", label = "High", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Yellow]] , iconcolor = {1, .7, 0, 1}, texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
				{value = "DIALOG", label = "Dialog", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Red]] , iconcolor = {1, 0, 0, 1},  texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
			}
			local buildStrataMenu = function() return strataTable end
			
			local d = g:NewDropDown (frame6, _, "$parentStrataDropdown", "strataDropdown", DROPDOWN_WIDTH, 20, buildStrataMenu, nil)		
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
			
			g:NewLabel (frame6, _, "$parentStrataLabel", "strataLabel", Loc ["STRING_OPTIONS_INSTANCE_STRATA"], "GameFontHighlightLeft")
			frame6.strataDropdown:SetPoint ("left", frame6.strataLabel, "right", 2)
			
			window:CreateLineBackground2 (frame6, "strataDropdown", "strataLabel", Loc ["STRING_OPTIONS_INSTANCE_STRATA_DESC"])
		
		

		--> statusbar color overwrite
			g:NewLabel (frame6, _, "$parentStatusbarLabelAnchor", "statusbarAnchorLabel", Loc ["STRING_OPTIONS_INSTANCE_STATUSBAR_ANCHOR"], "GameFontNormal")
		
			local statusbar_color_callback = function (button, r, g, b, a)
				--do something
				_G.DetailsOptionsWindow.instance:StatusBarColor (r, g, b, a)
			end
			g:NewColorPickButton (frame6, "$parentStatusbarColorPick", "statusbarColorPick", statusbar_color_callback)
			g:NewLabel (frame6, _, "$parentStatusbarColorLabel", "statusbarColorLabel", Loc ["STRING_OPTIONS_INSTANCE_STATUSBARCOLOR"], "GameFontHighlightLeft")
			frame6.statusbarColorPick:SetPoint ("left", frame6.statusbarColorLabel, "right", 2, 0)
			window:CreateLineBackground2 (frame6, "statusbarColorPick", "statusbarColorLabel", Loc ["STRING_OPTIONS_INSTANCE_STATUSBARCOLOR_DESC"])
			

		--general anchor
		g:NewLabel (frame6, _, "$parentAdjustmentsAnchor", "AdjustmentsAnchorLabel", Loc ["STRING_OPTIONS_WINDOW_ANCHOR"], "GameFontNormal")
		
		local x = window.left_start_at
		
		titulo_instance:SetPoint (x, -30)
		titulo_instance_desc:SetPoint (x, -50)
		
		local left_side = {
			{"AdjustmentsAnchorLabel", 1, true},
			{"windowPickColorLabel", 2},
			{"windowBackgroundPickColorLabel", 3},
			{"instanceToolbarSideLabel", 4},
			{"stretchAnchorLabel", 6},
			{"instanceMicroDisplaysSideLabel", 5},
			{"sideBarsLabel", 8},
			{"stretchAlwaysOnTopLabel", 7},
			{"backdropLabel", 9},
			{"strataLabel", 10},
		}
		
		window:arrange_menu (frame6, left_side, x, window.top_start_at)
		
		local right_side = {
			{"statusbarAnchorLabel", 1, true},
			{"statusbarLabel", 2},
			{"statusbarColorLabel", 3},
		}
	
		window:arrange_menu (frame6, right_side, window.right_start_at, window.top_start_at)
	
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
			local s = g:NewSlider (frame7, _, "$parentMenuAnchorYSlider", "menuAnchorYSlider", SLIDER_WIDTH, 20, -30, 30, 1, instance.menu_anchor[2])
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
			
			window:CreateLineBackground2 (frame7, "menuAnchorXSlider", "menuAnchorXLabel", Loc ["STRING_OPTIONS_MENU_X_DESC"])
			window:CreateLineBackground2 (frame7, "menuAnchorYSlider", "menuAnchorYLabel", Loc ["STRING_OPTIONS_MENU_X_DESC"])

			function frame7:update_menuanchor_xy (instance)
				if (instance.toolbar_side == 1) then --top
					frame7.menuAnchorXSlider:SetValue (editing_instance.menu_anchor [1])
					frame7.menuAnchorYSlider:SetValue (editing_instance.menu_anchor [2])
				elseif (instance.toolbar_side == 2) then --bottom
					frame7.menuAnchorXSlider:SetValue (editing_instance.menu_anchor_down [1])
					frame7.menuAnchorYSlider:SetValue (editing_instance.menu_anchor_down [2])
				end
			end
			
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
			
			window:CreateLineBackground2 (frame7, "pluginMenuAnchorSideSlider", "menuAnchorSideLabel", Loc ["STRING_OPTIONS_MENU_ANCHOR_DESC"])
			
		-- desaturate
			g:NewSwitch (frame7, _, "$parentDesaturateMenuSlider", "desaturateMenuSlider", 60, 20, _, _, instance.desaturated_menu)
			g:NewLabel (frame7, _, "$parentDesaturateMenuLabel", "desaturateMenuLabel", Loc ["STRING_OPTIONS_DESATURATE_MENU"], "GameFontHighlightLeft")

			frame7.desaturateMenuSlider:SetPoint ("left", frame7.desaturateMenuLabel, "right", 2)
			frame7.desaturateMenuSlider.OnSwitch = function (self, instance, value)
				instance:DesaturateMenu (value)
			end
			
			window:CreateLineBackground2 (frame7, "desaturateMenuSlider", "desaturateMenuLabel", Loc ["STRING_OPTIONS_DESATURATE_MENU_DESC"])

		-- hide icon
			g:NewSwitch (frame7, _, "$parentHideIconSlider", "hideIconSlider", 60, 20, _, _, instance.hide_icon)			
			g:NewLabel (frame7, _, "$parentHideIconLabel", "hideIconLabel", Loc ["STRING_OPTIONS_HIDE_ICON"], "GameFontHighlightLeft")

			frame7.hideIconSlider:SetPoint ("left", frame7.hideIconLabel, "right", 2)
			frame7.hideIconSlider.OnSwitch = function (self, instance, value)
				instance:HideMainIcon (value)
			end
			
			window:CreateLineBackground2 (frame7, "hideIconSlider", "hideIconLabel", Loc ["STRING_OPTIONS_HIDE_ICON_DESC"])
			
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
				instance:ToolbarMenuButtons()
			end
			frame7.pluginIconsDirectionSlider.thumb:SetSize (40, 12)
			
			window:CreateLineBackground2 (frame7, "pluginIconsDirectionSlider", "pluginIconsDirectionLabel", Loc ["STRING_OPTIONS_PICONS_DIRECTION_DESC"])
			
		--> show or hide buttons
			local label_icons = g:NewLabel (frame7, _, "$parentShowButtonsLabel", "showButtonsLabel", Loc ["STRING_OPTIONS_MENU_SHOWBUTTONS"], "GameFontHighlightLeft")
			local icon1 = g:NewImage (frame7, [[Interface\GossipFrame\HealerGossipIcon]], 20, 20, "border", nil, "icon1", nil)
			local icon2 = g:NewImage (frame7, [[Interface\GossipFrame\TrainerGossipIcon]], 20, 20, "border", nil, "icon2", nil)
			local icon3 = g:NewImage (frame7, [[Interface\AddOns\Details\images\sword]], 20, 20, "border", nil, "icon3", nil)
			local icon4 = g:NewImage (frame7, [[Interface\COMMON\VOICECHAT-ON]], 20, 20, "border", nil, "icon4", nil)
			
			local X1 = g:NewImage (frame7, [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], 16, 16, nil, nil, "x1", nil)
			local X2 = g:NewImage (frame7, [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], 16, 16, nil, nil, "x2", nil)
			local X3 = g:NewImage (frame7, [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], 16, 16, nil, nil, "x3", nil)
			local X4 = g:NewImage (frame7, [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], 16, 16, nil, nil, "x4", nil)
			X1:SetVertexColor (1, 1, 1, .9)
			X2:SetVertexColor (1, 1, 1, .9)
			X3:SetVertexColor (1, 1, 1, .9)
			X4:SetVertexColor (1, 1, 1, .9)
			local x_container = {X1, X2, X3, X4}
			
			local func = function (menu_button, arg1, arg2)
				local instance = _G.DetailsOptionsWindow.instance
				instance.menu_icons [menu_button] = not instance.menu_icons [menu_button]
				instance:ToolbarMenuButtons()
				
				if (instance.menu_icons [menu_button]) then
					x_container [menu_button]:Hide()
				else
					x_container [menu_button]:Show()
				end
			end
			
			local button1 = g:NewButton (frame7, _, "$parentShowButtons1", "showButtons1Button", 21, 21, func, 1)
			button1:InstallCustomTexture()
			local button2 = g:NewButton (frame7, _, "$parentShowButtons2", "showButtons2Button", 21, 21, func, 2)
			button2:InstallCustomTexture()
			local button3 = g:NewButton (frame7, _, "$parentShowButtons3", "showButtons3Button", 21, 21, func, 3)
			button3:InstallCustomTexture()
			local button4 = g:NewButton (frame7, _, "$parentShowButtons4", "showButtons4Button", 21, 21, func, 4)
			button4:InstallCustomTexture()

			function frame7:update_icon_buttons (instance)
				for i = 1, 4 do 
					if (instance.menu_icons [i]) then
						x_container [i]:Hide()
					else
						x_container [i]:Show()
					end
				end
			end
			
			button1:SetPoint ("left", label_icons, "right", 5, 0)
			icon1:SetPoint ("left", label_icons, "right", 5, 0)
			X1:SetPoint ("center", button1, "center")
			
			button2:SetPoint ("left", icon1, "right", 2, 0)
			icon2:SetPoint ("left", icon1, "right", 2, 0)
			X2:SetPoint ("center", button2, "center")
			
			button3:SetPoint ("left", icon2, "right", 2, 0)
			icon3:SetPoint ("left", icon2, "right", 2, 0)
			X3:SetPoint ("center", button3, "center")
			
			button4:SetPoint ("left", icon3, "right", 2, 0)
			icon4:SetPoint ("left", icon3, "right", -2, 0)
			X4:SetPoint ("center", button4, "center")
			
			window:CreateLineBackground2 (frame7, "showButtons1Button", "showButtonsLabel", Loc ["STRING_OPTIONS_MENU_SHOWBUTTONS_DESC"])
			
	--icon sizes
		local s = g:NewSlider (frame7, _, "$parentMenuIconSizeSlider", "menuIconSizeSlider", SLIDER_WIDTH, 20, 0.4, 1.6, 0.05, instance.menu_icons_size, true)
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		s.useDecimals = true
		s.fine_tuning = 0.05
		
		g:NewLabel (frame7, _, "$parentMenuIconSizeLabel", "menuIconSizeLabel", Loc ["STRING_OPTIONS_MENU_BUTTONSSIZE"], "GameFontHighlightLeft")
		
		frame7.menuIconSizeSlider:SetPoint ("left", frame7.menuIconSizeLabel, "right", 2, -1)
		
		frame7.menuIconSizeSlider:SetHook ("OnValueChange", function (self, instance, value)
			instance:ToolbarMenuButtonsSize (value)
		end)
		
		window:CreateLineBackground2 (frame7, "menuIconSizeSlider", "menuIconSizeLabel", Loc ["STRING_OPTIONS_MENU_BUTTONSSIZE_DESC"])
		
--auto hide menus
	--text anchor on options menu
		--g:NewLabel (frame7, _, "$parentAutoHideLabelAnchor", "autoHideLabel", Loc ["STRING_OPTIONS_MENU_AUTOHIDE_ANCHOR"], "GameFontNormal")
		
	--left
		g:NewLabel (frame7, _, "$parentAutoHideLeftMenuLabel", "autoHideLeftMenuLabel", Loc ["STRING_OPTIONS_MENU_AUTOHIDE_LEFT"], "GameFontHighlightLeft")
		g:NewSwitch (frame7, _, "$parentAutoHideLeftMenuSwitch", "autoHideLeftMenuSwitch", 60, 20, nil, nil, instance.auto_hide_menu.left)
		frame7.autoHideLeftMenuSwitch:SetPoint ("left", frame7.autoHideLeftMenuLabel, "right", 2)
		frame7.autoHideLeftMenuSwitch.OnSwitch = function (self, instance, value)
			--do something
			instance:SetAutoHideMenu (value)
		end
		window:CreateLineBackground2 (frame7, "autoHideLeftMenuSwitch", "autoHideLeftMenuLabel", Loc ["STRING_OPTIONS_MENU_AUTOHIDE_DESC"])
	--right

		
	--> Anchors
	
		--general anchor
		g:NewLabel (frame7, _, "$parentLeftMenuAnchor", "LeftMenuAnchorLabel", Loc ["STRING_OPTIONS_LEFT_MENU_ANCHOR"], "GameFontNormal")
		
		local x = window.left_start_at
		
		titulo_toolbar:SetPoint (x, -30)
		titulo_toolbar_desc:SetPoint (x, -50)
		
		local left_side = {
			{"LeftMenuAnchorLabel", 1, true},
			{"menuAnchorXLabel", 2},
			{"menuAnchorYLabel", 3},
			{"menuAnchorSideLabel", 4},
			{"desaturateMenuLabel", 5},
			{"hideIconLabel", 6},
			{"pluginIconsDirectionLabel", 7},
			{label_icons, 8},
			{"menuIconSizeLabel", 9},
			{"autoHideLeftMenuLabel", 10},
		}
		
		window:arrange_menu (frame7, left_side, x, -90)
	
		
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Appearance - Reset Instance Close ~8
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function window:CreateFrame8()

		local frame8 = window.options [8][1]

		local titulo_toolbar2 = g:NewLabel (frame8, _, "$parentTituloToolbar_buttons", "tituloToolbarLabel", Loc ["STRING_OPTIONS_TOOLBAR2_SETTINGS"], "GameFontNormal", 16)
		local titulo_toolbar2_desc = g:NewLabel (frame8, _, "$parentTituloToolbar_buttons", "tituloToolbar2Label", Loc ["STRING_OPTIONS_TOOLBAR2_SETTINGS_DESC"], "GameFontNormal", 9, "white")
		titulo_toolbar2_desc.width = 320
		
	--> general settings:
		-- menu anchors
			local s = g:NewSlider (frame8, _, "$parentMenuAnchorXSlider", "menuAnchorXSlider", SLIDER_WIDTH, 20, -200, 200, 1, instance.menu2_anchor[1])
			s:SetBackdrop (slider_backdrop)
			s:SetBackdropColor (unpack (slider_backdrop_color))
			s:SetThumbSize (50)			
			local s = g:NewSlider (frame8, _, "$parentMenuAnchorYSlider", "menuAnchorYSlider", SLIDER_WIDTH, 20, -30, 30, 1, instance.menu2_anchor[2])
			s:SetBackdrop (slider_backdrop)
			s:SetBackdropColor (unpack (slider_backdrop_color))
			s:SetThumbSize (50)
			
			g:NewLabel (frame8, _, "$parentMenuAnchorXLabel", "menuAnchorXLabel", Loc ["STRING_OPTIONS_MENU2_X"], "GameFontHighlightLeft")
			g:NewLabel (frame8, _, "$parentMenuAnchorYLabel", "menuAnchorYLabel", Loc ["STRING_OPTIONS_MENU2_Y"], "GameFontHighlightLeft")
			
			frame8.menuAnchorXSlider:SetPoint ("left", frame8.menuAnchorXLabel, "right", 2, -1)
			frame8.menuAnchorYSlider:SetPoint ("left", frame8.menuAnchorYLabel, "right", 2)
			
			frame8.menuAnchorXSlider:SetThumbSize (50)
			frame8.menuAnchorXSlider:SetHook ("OnValueChange", function (self, instance, x) 
				instance:Menu2Anchor (x, nil)
			end)
			frame8.menuAnchorYSlider:SetThumbSize (50)
			frame8.menuAnchorYSlider:SetHook ("OnValueChange", function (self, instance, y)
				instance:Menu2Anchor (nil, y)
			end)
					
			window:CreateLineBackground2 (frame8, "menuAnchorXSlider", "menuAnchorXLabel", Loc ["STRING_OPTIONS_MENU2_X_DESC"])
			window:CreateLineBackground2 (frame8, "menuAnchorYSlider", "menuAnchorYLabel", Loc ["STRING_OPTIONS_MENU2_X_DESC"])
	
			function frame8:update_menuanchor_xy (instance)
				if (instance.toolbar_side == 1) then --top
					frame8.menuAnchorXSlider:SetValue (editing_instance.menu2_anchor [1])
					frame8.menuAnchorYSlider:SetValue (editing_instance.menu2_anchor [2])
				elseif (instance.toolbar_side == 2) then --bottom
					frame8.menuAnchorXSlider:SetValue (editing_instance.menu2_anchor_down [1])
					frame8.menuAnchorYSlider:SetValue (editing_instance.menu2_anchor_down [2])
				end
			end
	
		-- desaturate
			g:NewSwitch (frame8, _, "$parentDesaturateMenuSlider", "desaturateMenuSlider", 60, 20, _, _, instance.desaturated_menu2)
			g:NewLabel (frame8, _, "$parentDesaturateMenuLabel", "desaturateMenuLabel", Loc ["STRING_OPTIONS_DESATURATE_MENU"], "GameFontHighlightLeft")

			frame8.desaturateMenuSlider:SetPoint ("left", frame8.desaturateMenuLabel, "right", 2)
			frame8.desaturateMenuSlider.OnSwitch = function (self, instance, value)
				instance:DesaturateMenu2 (value)
			end
			
			window:CreateLineBackground2 (frame8, "desaturateMenuSlider", "desaturateMenuLabel", Loc ["STRING_OPTIONS_DESATURATE_MENU_DESC"])
	
		--> show or hide buttons
			local label_icons = g:NewLabel (frame8, _, "$parentShowButtonsLabel", "showButtonsLabel", Loc ["STRING_OPTIONS_MENU_SHOWBUTTONS"], "GameFontHighlightLeft")
			local icon1 = g:NewImage (frame8, [[Interface\Buttons\UI-Panel-MinimizeButton-Up]], 20, 20, "border", nil, "icon1", nil)
			local icon2 = g:NewImage (frame8, [[Interface\AddOns\Details\images\icons]], 10, 14, "border", nil, "icon2", nil)
			icon2:SetTexCoord (0.248046875, 0.287109375, 0.078125, 0.12890625) --127 40 147 66
			icon2:SetVertexColor (.8, .8, .8, 1)
			local icon3 = g:NewImage (frame8, [[Interface\AddOns\Details\images\reset_button]], 12, 20, "border", nil, "icon3", nil)
			
			local X1 = g:NewImage (frame8, [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], 16, 16, nil, nil, "x1", nil)
			local X2 = g:NewImage (frame8, [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], 16, 16, nil, nil, "x2", nil)
			local X3 = g:NewImage (frame8, [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], 16, 16, nil, nil, "x3", nil)
			X1:SetVertexColor (1, 1, 1, .9)
			X2:SetVertexColor (1, 1, 1, .9)
			X3:SetVertexColor (1, 1, 1, .9)
			local x_container = {X1, X2, X3}
			
			local func = function (menu_button, arg1, arg2)
				local instance = _G.DetailsOptionsWindow.instance
				instance.menu2_icons [menu_button] = not instance.menu2_icons [menu_button]
				instance:ToolbarMenu2Buttons()
				
				if (instance.menu2_icons [menu_button]) then
					x_container [menu_button]:Hide()
				else
					x_container [menu_button]:Show()
				end
			end
			
			local button1 = g:NewButton (frame8, _, "$parentShowButtons1", "showButtons1Button", 21, 21, func, 1)
			button1:InstallCustomTexture()
			local button2 = g:NewButton (frame8, _, "$parentShowButtons2", "showButtons2Button", 21, 21, func, 2)
			button2:InstallCustomTexture()
			local button3 = g:NewButton (frame8, _, "$parentShowButtons3", "showButtons3Button", 21, 21, func, 3)
			button3:InstallCustomTexture()

			function frame8:update_icon_buttons (instance)
				for i = 1, 3 do 
					if (instance.menu2_icons [i]) then
						x_container [i]:Hide()
					else
						x_container [i]:Show()
					end
				end
			end
			
			button1:SetPoint ("left", label_icons, "right", 5, 0)
			icon1:SetPoint ("center", button1, "center")
			X1:SetPoint ("center", button1, "center")
			
			button2:SetPoint ("left", icon1, "right", 2, 0)
			icon2:SetPoint ("center", button2, "center")
			X2:SetPoint ("center", button2, "center")
			
			button3:SetPoint ("left", button2, "right", 2, 0)
			icon3:SetPoint ("center", button3, "center")
			X3:SetPoint ("center", button3, "center")
			
			window:CreateLineBackground2 (frame8, "showButtons1Button", "showButtonsLabel", Loc ["STRING_OPTIONS_MENU_SHOWBUTTONS_DESC"])
	
		--icon sizes
			local s = g:NewSlider (frame8, _, "$parentMenuIconSizeSlider", "menuIconSizeSlider", SLIDER_WIDTH, 20, 0.4, 1.6, 0.05, instance.menu_icons_size, true)
			s:SetBackdrop (slider_backdrop)
			s:SetBackdropColor (unpack (slider_backdrop_color))
			s.useDecimals = true
			s.fine_tuning = 0.05
			
			g:NewLabel (frame8, _, "$parentMenuIconSizeLabel", "menuIconSizeLabel", Loc ["STRING_OPTIONS_MENU_BUTTONSSIZE"], "GameFontHighlightLeft")
			
			frame8.menuIconSizeSlider:SetPoint ("left", frame8.menuIconSizeLabel, "right", 2, -1)
			
			frame8.menuIconSizeSlider:SetHook ("OnValueChange", function (self, instance, value)
				instance:ToolbarMenu2ButtonsSize (value)
			end)
			
			window:CreateLineBackground2 (frame8, "menuIconSizeSlider", "menuIconSizeLabel", Loc ["STRING_OPTIONS_MENU_BUTTONSSIZE_DESC"])
	
		--> instance button
			--text size
			local s = g:NewSlider (frame8, _, "$parentInstanceTextSizeSlider", "instanceTextSizeSlider", SLIDER_WIDTH, 20, 8, 15, 1, tonumber (instance.instancebutton_config.textsize))
			s:SetBackdrop (slider_backdrop)
			s:SetBackdropColor (unpack (slider_backdrop_color))
			s:SetThumbSize (50)			
			
			frame8.instanceTextSizeSlider:SetHook ("OnValueChange", function (self, instance, amount) 
				instance:ToolbarMenu2InstanceButtonSettings (nil, nil, amount, nil)
			end)
			
			g:NewLabel (frame8, _, "$parentInstanceTextSizeLabel", "instanceTextSizeLabel", Loc ["STRING_OPTIONS_INSTANCE_TEXTSIZE"], "GameFontHighlightLeft")
			frame8.instanceTextSizeSlider:SetPoint ("left", frame8.instanceTextSizeLabel, "right", 2)
			
			window:CreateLineBackground2 (frame8, "instanceTextSizeSlider", "instanceTextSizeLabel", Loc ["STRING_OPTIONS_INSTANCE_TEXTSIZE_DESC"])

			--text face
			local instance_text_color_onselectfont = function (_, instance, fontName)
				instance:ToolbarMenu2InstanceButtonSettings (nil, fontName, nil, nil)
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
			
			g:NewLabel (frame8, _, "$parentInstanceTextFontLabel", "instanceTextFontLabel", Loc ["STRING_OPTIONS_INSTANCE_TEXTFONT"], "GameFontHighlightLeft")
			frame8.instanceTextFontDropdown:SetPoint ("left", frame8.instanceTextFontLabel, "right", 2)
			
			window:CreateLineBackground2 (frame8, "instanceTextFontDropdown", "instanceTextFontLabel", Loc ["STRING_OPTIONS_INSTANCE_TEXTCOLOR_DESC"])
			
			-- text color
			local instance_textcolor_callback = function (button, r, g, b, a)
				_G.DetailsOptionsWindow.instance:ToolbarMenu2InstanceButtonSettings ({r, g, b, a}, nil, nil, nil)
			end
			g:NewColorPickButton (frame8, "$parentInstanceTextColorPick", "instanceTextColorPick", instance_textcolor_callback)
			g:NewLabel (frame8, _, "$parentInstanceTextLabel", "instanceTextColorPickLabel", Loc ["STRING_OPTIONS_INSTANCE_TEXTCOLOR"], "GameFontHighlightLeft")
			frame8.instanceTextColorPick:SetPoint ("left", frame8.instanceTextColorPickLabel, "right", 2, 0)

			window:CreateLineBackground2 (frame8, "instanceTextColorPick", "instanceTextColorPickLabel", Loc ["STRING_OPTIONS_RESET_OVERLAY_DESC"])

			--text shadow
			g:NewLabel (frame8, _, "$parentInstanceTextShadowLabel", "instanceTextShadowLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SHADOW"], "GameFontHighlightLeft")
			g:NewSwitch (frame8, _, "$parentInstanceTexShadowtSwitch", "instanceTextShadowSwitch", 60, 20, nil, nil, instance.instancebutton_config.textshadow)
			frame8.instanceTextShadowSwitch:SetPoint ("left", frame8.instanceTextShadowLabel, "right", 2)
			frame8.instanceTextShadowSwitch.OnSwitch = function (self, instance, value)
				instance:ToolbarMenu2InstanceButtonSettings (nil, nil, nil, value)
			end
			window:CreateLineBackground2 (frame8, "instanceTextShadowSwitch", "instanceTextShadowLabel", Loc ["STRING_OPTIONS_MENU_ATTRIBUTE_SHADOW_DESC"])
			
	--> auto hide menu
		g:NewLabel (frame8, _, "$parentAutoHideRightMenuLabel", "autoHideRightMenuLabel", Loc ["STRING_OPTIONS_MENU_AUTOHIDE_RIGHT"], "GameFontHighlightLeft")
		g:NewSwitch (frame8, _, "$parentAutoHideRightMenuSwitch", "autoHideRightMenuSwitch", 60, 20, nil, nil, instance.auto_hide_menu.right)
		frame8.autoHideRightMenuSwitch:SetPoint ("left", frame8.autoHideRightMenuLabel, "right", 2)
		frame8.autoHideRightMenuSwitch.OnSwitch = function (self, instance, value)
			--do something
			instance:SetAutoHideMenu (nil, value)
		end
		window:CreateLineBackground2 (frame8, "autoHideRightMenuSwitch", "autoHideRightMenuLabel", Loc ["STRING_OPTIONS_MENU_AUTOHIDE_DESC"])	
			
	--> Anchors	
	
		--general anchor
		g:NewLabel (frame8, _, "$parentRightMenuAnchor", "RightMenuAnchorLabel", Loc ["STRING_OPTIONS_LEFT_MENU_ANCHOR"], "GameFontNormal")
		
		local x = window.left_start_at
		
		titulo_toolbar2:SetPoint (x, -30)
		titulo_toolbar2_desc:SetPoint (x, -50)
		
		local left_side = {
			{"RightMenuAnchorLabel", 1, true},
			{"menuAnchorXLabel", 2},
			{"menuAnchorYLabel", 3},
			{"desaturateMenuLabel", 4},
			{"showButtonsLabel", 5},
			{"menuIconSizeLabel", 6},
			{"autoHideRightMenuLabel", 7},
		}
		
		window:arrange_menu (frame8, left_side, x, -90)

		g:NewLabel (frame8, _, "$parentInstanceButtonAnchor", "instanceAnchorLabel", Loc ["STRING_OPTIONS_INSTANCE_BUTTON_ANCHOR"], "GameFontNormal")
		
		local right_menu = {
			{"instanceAnchorLabel", 1, true},
			{"instanceTextColorPickLabel", 2},
			{"instanceTextFontLabel", 3},
			{"instanceTextSizeLabel", 4},
			{"instanceTextShadowLabel", 5},
		}

		window:arrange_menu (frame8, right_menu, window.right_start_at, -90)
		
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
					if (wp.anchor == "all") then
						g:ImageEditor (callmeback, wp.texture, wp.texcoord, wp.overlay, tinstance.baseframe.wallpaper:GetWidth(), tinstance.baseframe.wallpaper:GetHeight(), nil, wp.alpha, true)
					else
						g:ImageEditor (callmeback, wp.texture, wp.texcoord, wp.overlay, tinstance.baseframe.wallpaper:GetWidth(), tinstance.baseframe.wallpaper:GetHeight(), nil, wp.alpha)
					end
					
				else
					if (wp.anchor == "all") then
						g:ImageEditor (callmeback, wp.texture, wp.texcoord, wp.overlay, tinstance.baseframe.wallpaper:GetWidth(), tinstance.baseframe.wallpaper:GetHeight(), nil, wp.alpha, true)
					else
						g:ImageEditor (callmeback, wp.texture, wp.texcoord, wp.overlay, tinstance.baseframe.wallpaper:GetWidth(), tinstance.baseframe.wallpaper:GetHeight(), nil, wp.alpha)
					end
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
					instance:InstanceWallpaper (texturePath, nil, nil, {0, 1, 0, 0.703125}, nil, nil, {1, 1, 1, 1})
					if (DetailsImageEdit and DetailsImageEdit:IsShown()) then
						local wp = instance.wallpaper
						if (wp.anchor == "all") then
							g:ImageEditor (callmeback, wp.texture, wp.texcoord, wp.overlay, instance.baseframe.wallpaper:GetWidth(), instance.baseframe.wallpaper:GetHeight(), nil, wp.alpha, true)
						else
							g:ImageEditor (callmeback, wp.texture, wp.texcoord, wp.overlay, instance.baseframe.wallpaper:GetWidth(), instance.baseframe.wallpaper:GetHeight(), nil, wp.alpha)
						end
					end
				
				elseif (texturePath:find ("EncounterJournal")) then
					instance:InstanceWallpaper (texturePath, nil, nil, {0.06, 0.68, 0.1, 0.57}, nil, nil, {1, 1, 1, 1})
					if (DetailsImageEdit and DetailsImageEdit:IsShown()) then
						local wp = instance.wallpaper
						if (wp.anchor == "all") then
							g:ImageEditor (callmeback, wp.texture, wp.texcoord, wp.overlay, instance.baseframe.wallpaper:GetWidth(), instance.baseframe.wallpaper:GetHeight(), nil, wp.alpha, true)
						else
							g:ImageEditor (callmeback, wp.texture, wp.texcoord, wp.overlay, instance.baseframe.wallpaper:GetWidth(), instance.baseframe.wallpaper:GetHeight(), nil, wp.alpha)
						end
					end
				
				else
					instance:InstanceWallpaper (texturePath, nil, nil, {0, 1, 0, 1}, nil, nil, {1, 1, 1, 1})
					if (DetailsImageEdit and DetailsImageEdit:IsShown()) then
						local wp = instance.wallpaper
						if (wp.anchor == "all") then
							g:ImageEditor (callmeback, wp.texture, wp.texcoord, wp.overlay, instance.baseframe.wallpaper:GetWidth(), instance.baseframe.wallpaper:GetHeight(), nil, wp.alpha, true)
						else
							g:ImageEditor (callmeback, wp.texture, wp.texcoord, wp.overlay, instance.baseframe.wallpaper:GetWidth(), instance.baseframe.wallpaper:GetHeight(), nil, wp.alpha)
						end
					end
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
			
				["RAIDS"] = {
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-BlackrockCaverns]], label = "Blackrock Caverns", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-BlackrockCaverns]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-BlackrockSpire]], label = "Blackrock Spire", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-BlackrockSpire]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-DragonSoul]], label = "Dragon Soul", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-DragonSoul]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-EndTime]], label = "End Time", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-EndTime]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-Firelands1]], label = "Firelands", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-Firelands1]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-HallsofReflection]], label = "Halls of Reflection", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-HallsofReflection]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-HellfireCitadel]], label = "Hellfire Citadel", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-HellfireCitadel]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-Pandaria]], label = "Pandaria", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-Pandaria]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-RagefireChasm]], label = "Ragefire Chasm", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-RagefireChasm]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-SiegeofOrgrimmar]], label = "Siege of Orgrimmar", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-SiegeofOrgrimmar]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-TheNexus]], label = "The Nexus", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-TheNexus]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-TheOculus]], label = "The Oculus", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-TheOculus]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-TheStonecore]], label = "The Stonecore", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-TheStonecore]], texcoord = nil},
					{value = [[Interface\EncounterJournal\UI-EJ-LOREBG-ThunderKingRaid]], label = "Throne of Thunder", onclick = onSelectSecTexture, icon = [[Interface\EncounterJournal\UI-EJ-LOREBG-ThunderKingRaid]], texcoord = nil},
				},
			
				["LOGOS"] = {
					{value = [[Interface\Timer\Alliance-Logo]], label = "For the Alliance", onclick = onSelectSecTexture, icon = [[Interface\Timer\Alliance-Logo]], texcoord = nil},
					{value = [[Interface\Timer\Horde-Logo]], label = "For the Horde", onclick = onSelectSecTexture, icon = [[Interface\Timer\Horde-Logo]], texcoord = nil},
					{value = [[Interface\Destiny\EndscreenImage]], label = "Pandaria Logo", onclick = onSelectSecTexture, icon = [[Interface\Destiny\EndscreenImage]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ARCH-RACE-ORC]], label = "Orc Crest", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ARCH-RACE-ORC]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ARCH-RACE-DWARF]], label = "Dwarf Crest", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ARCH-RACE-DWARF]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ARCH-RACE-NIGHTELF]], label = "Night Elf Crest", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ARCH-RACE-NIGHTELF]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-Pandaren]], label = "Padaren Crest", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-Pandaren]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ARCH-RACE-TROLL]], label = "Troll Crest", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ARCH-RACE-TROLL]], texcoord = nil},
					{value = [[Interface\FlavorImages\BloodElfLogo-small]], label = "Blood Elf Crest", onclick = onSelectSecTexture, icon = [[Interface\FlavorImages\BloodElfLogo-small]], texcoord = nil},
					{value = [[Interface\Glues\COMMON\Glues-Logo]], label = "Wow Logo", onclick = onSelectSecTexture, icon = [[Interface\Glues\COMMON\Glues-Logo]], texcoord = nil},
					{value = [[Interface\Glues\COMMON\GLUES-WOW-BCLOGO]], label = "Burning Cruzade Logo", onclick = onSelectSecTexture, icon = [[Interface\Glues\COMMON\GLUES-WOW-BCLOGO]], texcoord = nil},
					{value = [[Interface\Glues\COMMON\GLUES-WOW-CCLOGO]], label = "Cataclysm Logo", onclick = onSelectSecTexture, icon = [[Interface\Glues\COMMON\GLUES-WOW-CCLOGO]], texcoord = nil},
					{value = [[Interface\Glues\COMMON\Glues-WOW-WoltkLogo]], label = "WotLK Logo", onclick = onSelectSecTexture, icon = [[Interface\Glues\COMMON\Glues-WOW-WoltkLogo]], texcoord = nil},


					--{value = [[]], label = "", onclick = onSelectSecTexture, icon = [[]], texcoord = nil},
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
					{value = [[Interface\Glues\CREDITS\CATACLYSM\LESSERELEMENTAL_FIRE_03B1]], label = "Fire Elemental", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\CATACLYSM\LESSERELEMENTAL_FIRE_03B1]], texcoord = nil},
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
				{value = "LOGOS", label = "Logos", onclick = onSelectMainTexture, icon = [[Interface\WorldStateFrame\ColumnIcon-FlagCapture0]]},
				{value = "DRESSUP", label = "Race Background", onclick = onSelectMainTexture, icon = [[Interface\ICONS\INV_Chest_Cloth_17]]},
				{value = "RAIDS", label = "Dungeons & Raids", onclick = onSelectMainTexture, icon = [[Interface\COMMON\friendship-FistHuman]]},
				{value = "DEATHKNIGHT", label = "Death Knight", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["DEATHKNIGHT"]},
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
			
			--category
			local d = g:NewDropDown (frame9, _, "$parentBackgroundDropdown", "backgroundDropdown", DROPDOWN_WIDTH, 20, buildBackgroundMenu, nil)
			d.onenter_backdrop = dropdown_backdrop_onenter
			d.onleave_backdrop = dropdown_backdrop_onleave
			d:SetBackdrop (dropdown_backdrop)
			d:SetBackdropColor (unpack (dropdown_backdrop_onleave))			
			
			--wallpaper
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
		
		g:NewLabel (frame9, _, "$parentBackgroundLabel1", "wallpapergroupLabel", Loc ["STRING_OPTIONS_WP_GROUP"], "GameFontHighlightLeft")
		g:NewLabel (frame9, _, "$parentBackgroundLabel2", "selectwallpaperLabel", Loc ["STRING_OPTIONS_WP_GROUP2"], "GameFontHighlightLeft")
		g:NewLabel (frame9, _, "$parentAnchorLabel", "anchorLabel", Loc ["STRING_OPTIONS_WP_ALIGN"], "GameFontHighlightLeft")
		--
		frame9.anchorDropdown:SetPoint ("left", frame9.anchorLabel, "right", 2)
		--
		frame9.editImage:InstallCustomTexture()
		
		window:CreateLineBackground2 (frame9, "useBackgroundSlider", "enablewallpaperLabel", Loc ["STRING_OPTIONS_WP_ENABLE_DESC"])
		
		window:CreateLineBackground2 (frame9, "anchorDropdown", "anchorLabel", Loc ["STRING_OPTIONS_WP_ALIGN_DESC"])
		
		window:CreateLineBackground2 (frame9, "editImage", "editImage", Loc ["STRING_OPTIONS_WP_EDIT_DESC"])
		
		window:CreateLineBackground2 (frame9, "backgroundDropdown", "wallpapergroupLabel", Loc ["STRING_OPTIONS_WP_GROUP_DESC"])
		
		window:CreateLineBackground2 (frame9, "backgroundDropdown2", "selectwallpaperLabel", Loc ["STRING_OPTIONS_WP_GROUP2_DESC"])

		g:NewLabel (frame9, _, "$parentWallpaperPreviewAnchor", "wallpaperPreviewAnchorLabel", "Preview:", "GameFontNormal")
		
		--128 64
		
		local icon1 = g:NewImage (frame9, nil, 128, 64, "artwork", nil, nil, "$parentIcon1")
		icon1:SetTexture ("Interface\\AddOns\\Details\\images\\icons")
		icon1:SetPoint ("topleft", frame9.wallpaperPreviewAnchorLabel.widget, "bottomleft", 0, -5)
		icon1:SetDrawLayer ("artwork", 1)
		icon1:SetTexCoord (0.337890625, 0.5859375, 0.59375, 0.716796875-0.0009765625) --173 304 300 367
		
		local icon2 = g:NewImage (frame9, nil, 128, 64, "artwork", nil, nil, "$parentIcon2")
		icon2:SetTexture ("Interface\\AddOns\\Details\\images\\icons")
		icon2:SetPoint ("left", icon1.widget, "right")
		icon2:SetDrawLayer ("artwork", 1)
		icon2:SetTexCoord (0.337890625, 0.5859375, 0.59375, 0.716796875-0.0009765625) --173 304 300 367
		
		local icon3 = g:NewImage (frame9, nil, 128, 64, "artwork", nil, nil, "$parentIcon3")
		icon3:SetTexture ("Interface\\AddOns\\Details\\images\\icons")
		icon3:SetPoint ("top", icon1.widget, "bottom")
		icon3:SetDrawLayer ("artwork", 1)
		icon3:SetTexCoord (0.337890625, 0.5859375, 0.59375+0.0009765625, 0.716796875) --173 304 300 367
		
		local icon4 = g:NewImage (frame9, nil, 128, 64, "artwork", nil, nil, "$parentIcon4")
		icon4:SetTexture ("Interface\\AddOns\\Details\\images\\icons")
		icon4:SetPoint ("left", icon3.widget, "right")
		icon4:SetDrawLayer ("artwork", 1)
		icon4:SetTexCoord (0.337890625, 0.5859375, 0.59375+0.0009765625, 0.716796875) --173 304 300 367
		
		icon1:SetVertexColor (.15, .15, .15, 1)
		icon2:SetVertexColor (.15, .15, .15, 1)
		icon3:SetVertexColor (.15, .15, .15, 1)
		icon4:SetVertexColor (.15, .15, .15, 1)
		
		local preview = frame9:CreateTexture (nil, "overlay")
		preview:SetDrawLayer ("artwork", 3)
		preview:SetSize (256, 128)
		preview:SetPoint ("topleft", frame9.wallpaperPreviewAnchorLabel.widget, "bottomleft", 0, -5)
		
		local w, h = 20, 20
		
		local L1 = frame9:CreateTexture (nil, "overlay")
		L1:SetPoint ("topleft", preview, "topleft")
		L1:SetTexture ("Interface\\AddOns\\Details\\images\\icons")
		L1:SetTexCoord (0.13671875+0.0009765625, 0.234375, 0.29296875, 0.1953125+0.0009765625)
		L1:SetSize (w, h)
		L1:SetDrawLayer ("overlay", 2)
		L1:SetVertexColor (1, 1, 1, .8)
		
		local L2 = frame9:CreateTexture (nil, "overlay")
		L2:SetPoint ("bottomleft", preview, "bottomleft")
		L2:SetTexture ("Interface\\AddOns\\Details\\images\\icons")
		L2:SetTexCoord (0.13671875+0.0009765625, 0.234375, 0.1953125+0.0009765625, 0.29296875)
		L2:SetSize (w, h)
		L2:SetDrawLayer ("overlay", 2)
		L2:SetVertexColor (1, 1, 1, .8)
		
		local L3 = frame9:CreateTexture (nil, "overlay")
		L3:SetPoint ("bottomright", preview, "bottomright", 0, 0)
		L3:SetTexture ("Interface\\AddOns\\Details\\images\\icons")
		L3:SetTexCoord (0.234375, 0.13671875-0.0009765625, 0.1953125+0.0009765625, 0.29296875)
		L3:SetSize (w, h)
		L3:SetDrawLayer ("overlay", 5)
		L3:SetVertexColor (1, 1, 1, .8)
		
		local L4 = frame9:CreateTexture (nil, "overlay")
		L4:SetPoint ("topright", preview, "topright", 0, 0)
		L4:SetTexture ("Interface\\AddOns\\Details\\images\\icons")
		L4:SetTexCoord (0.234375, 0.13671875-0.0009765625, 0.29296875, 0.1953125+0.0009765625)
		L4:SetSize (w, h)
		L4:SetDrawLayer ("overlay", 5)
		L4:SetVertexColor (1, 1, 1, .8)
		
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

			frame9.wallpaperCurrentLabel1text.text = w.texture or "-- -- --"
			frame9.wallpaperCurrentLabel2text.text = a
			frame9.wallpaperCurrentLabel3text.text = red
			frame9.wallpaperCurrentLabel4text.text = green
			frame9.wallpaperCurrentLabel5text.text = blue
			frame9.wallpaperCurrentLabel6text.text = t
			frame9.wallpaperCurrentLabel7text.text = b
			frame9.wallpaperCurrentLabel8text.text = l
			frame9.wallpaperCurrentLabel9text.text = r
		end
		
	--current settings
		g:NewLabel (frame9, _, "$parentWallpaperCurrentAnchor", "wallpaperCurrentAnchorLabel", "Current:", "GameFontNormal")
		
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel1", "wallpaperCurrentLabel1", Loc ["STRING_OPTIONS_WALLPAPER_FILE"], "GameFontHighlightLeft")
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel2", "wallpaperCurrentLabel2", Loc ["STRING_OPTIONS_WALLPAPER_ALPHA"], "GameFontHighlightLeft")
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel3", "wallpaperCurrentLabel3", Loc ["STRING_OPTIONS_WALLPAPER_RED"], "GameFontHighlightLeft")
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel4", "wallpaperCurrentLabel4", Loc ["STRING_OPTIONS_WALLPAPER_GREEN"], "GameFontHighlightLeft")
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel5", "wallpaperCurrentLabel5", Loc ["STRING_OPTIONS_WALLPAPER_BLUE"], "GameFontHighlightLeft")
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel6", "wallpaperCurrentLabel6", Loc ["STRING_OPTIONS_WALLPAPER_CTOP"], "GameFontHighlightLeft")
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel7", "wallpaperCurrentLabel7", Loc ["STRING_OPTIONS_WALLPAPER_CBOTTOM"], "GameFontHighlightLeft")
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel8", "wallpaperCurrentLabel8", Loc ["STRING_OPTIONS_WALLPAPER_CLEFT"], "GameFontHighlightLeft")
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel9", "wallpaperCurrentLabel9", Loc ["STRING_OPTIONS_WALLPAPER_CRIGHT"], "GameFontHighlightLeft")
		
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel1text", "wallpaperCurrentLabel1text", "", "GameFontHighlightSmall")
		frame9.wallpaperCurrentLabel1text:SetPoint ("left", frame9.wallpaperCurrentLabel1, "right", 2, 0)
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel2text", "wallpaperCurrentLabel2text", "", "GameFontHighlightSmall")
		frame9.wallpaperCurrentLabel2text:SetPoint ("left", frame9.wallpaperCurrentLabel2, "right", 2, 0)
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel3text", "wallpaperCurrentLabel3text", "", "GameFontHighlightSmall")
		frame9.wallpaperCurrentLabel3text:SetPoint ("left", frame9.wallpaperCurrentLabel3, "right", 2, 0)
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel4text", "wallpaperCurrentLabel4text", "", "GameFontHighlightSmall")
		frame9.wallpaperCurrentLabel4text:SetPoint ("left", frame9.wallpaperCurrentLabel4, "right", 2, 0)
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel5text", "wallpaperCurrentLabel5text", "", "GameFontHighlightSmall")
		frame9.wallpaperCurrentLabel5text:SetPoint ("left", frame9.wallpaperCurrentLabel5, "right", 2, 0)
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel6text", "wallpaperCurrentLabel6text", "", "GameFontHighlightSmall")
		frame9.wallpaperCurrentLabel6text:SetPoint ("left", frame9.wallpaperCurrentLabel6, "right", 2, 0)
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel7text", "wallpaperCurrentLabel7text", "", "GameFontHighlightSmall")
		frame9.wallpaperCurrentLabel7text:SetPoint ("left", frame9.wallpaperCurrentLabel7, "right", 2, 0)
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel8text", "wallpaperCurrentLabel8text", "", "GameFontHighlightSmall")
		frame9.wallpaperCurrentLabel8text:SetPoint ("left", frame9.wallpaperCurrentLabel8, "right", 2, 0)
		g:NewLabel (frame9, _, "$parentWallpaperCurrentLabel9text", "wallpaperCurrentLabel9text", "", "GameFontHighlightSmall")
		frame9.wallpaperCurrentLabel9text:SetPoint ("left", frame9.wallpaperCurrentLabel9, "right", 2, 0)
	
	--> Load Wallpaper
	
		g:NewLabel (frame9, _, "$parentWallpaperLoadTitleAnchor", "WallpaperLoadTitleAnchor", Loc ["STRING_OPTIONS_WALLPAPER_LOAD_TITLE"], "GameFontNormal")
	
		local load_image = function()
			if (not DetailsLoadWallpaperImage) then
				
				local f = CreateFrame ("frame", "DetailsLoadWallpaperImage", UIParent)
				f:SetPoint ("center", UIParent, "center")
				f:SetFrameStrata ("FULLSCREEN")
				f:SetSize (512, 150)
				f:EnableMouse (true)
				f:SetMovable (true)
				f:SetScript ("OnMouseDown", function() f:StartMoving() end)
				f:SetScript ("OnMouseUp", function() f:StopMovingOrSizing() end)
				
				local bg = f:CreateTexture (nil, "background")
				bg:SetAllPoints()
				bg:SetTexture ([[Interface\AddOns\Details\images\welcome]])
				
				tinsert (UISpecialFrames, "DetailsLoadWallpaperImage")
				
				local t = f:CreateFontString (nil, "overlay", "GameFontNormal")
				t:SetText (Loc ["STRING_OPTIONS_WALLPAPER_LOAD_EXCLAMATION"])
				t:SetPoint ("topleft", f, "topleft", 15, -15)
				t:SetJustifyH ("left")
				f.t = t
				
				local filename = f:CreateFontString (nil, "overlay", "GameFontHighlightLeft")
				filename:SetPoint ("topleft", f, "topleft", 15, -120)
				filename:SetText (Loc ["STRING_OPTIONS_WALLPAPER_LOAD_FILENAME"])
				
				local editbox = g:NewTextEntry (f, nil, "$parentFileName", "FileName", 160, 20, function() end)
				editbox:SetPoint ("left", filename, "right", 2, 0)
				editbox.tooltip = Loc ["STRING_OPTIONS_WALLPAPER_LOAD_FILENAME_DESC"]
				
				local close = CreateFrame ("button", "DetailsLoadWallpaperImageOkey", f, "UIPanelCloseButton")
				close:SetSize (32, 32)
				close:SetPoint ("topright", f, "topright", -3, -1)

				local okey = CreateFrame ("button", "DetailsLoadWallpaperImageOkey", f, "OptionsButtonTemplate")
				okey:SetPoint ("left", editbox.widget, "right", 2, 0)
				okey:SetText (Loc ["STRING_OPTIONS_WALLPAPER_LOAD_OKEY"])
				okey:SetScript ("OnClick", function() 
					local text = editbox:GetText()
					if (text == "") then
						return
					end
					
					local instance = _G.DetailsOptionsWindow.instance
					local path = "Interface\\" .. text
					editbox:ClearFocus()
					instance:InstanceWallpaper (path, "all", 0.50, {0, 1, 0, 1}, 256, 256, {1, 1, 1, 1})
					_detalhes:OpenOptionsWindow (instance)
					window:update_wallpaper_info()
				end)
				
				local throubleshoot = CreateFrame ("button", "DetailsLoadWallpaperImageOkey", f, "OptionsButtonTemplate")
				throubleshoot:SetPoint ("left", okey, "right", 2, 0)
				throubleshoot:SetText (Loc ["STRING_OPTIONS_WALLPAPER_LOAD_TROUBLESHOOT"])
				throubleshoot:SetScript ("OnClick", function() 
					if (t:GetText() == Loc ["STRING_OPTIONS_WALLPAPER_LOAD_EXCLAMATION"]) then
						t:SetText (Loc ["STRING_OPTIONS_WALLPAPER_LOAD_TROUBLESHOOT_TEXT"])
					else
						DetailsLoadWallpaperImage.t:SetText (Loc ["STRING_OPTIONS_WALLPAPER_LOAD_EXCLAMATION"])
					end
				end)
			end
			
			DetailsLoadWallpaperImage.t:SetText (Loc ["STRING_OPTIONS_WALLPAPER_LOAD_EXCLAMATION"])
			DetailsLoadWallpaperImage:Show()
		end
		
		g:NewButton (frame9, _, "$parentLoadImage", "LoadImage", 200, 18, load_image, nil, nil, nil, Loc ["STRING_OPTIONS_WALLPAPER_LOAD"])
		frame9.LoadImage:InstallCustomTexture()
		window:CreateLineBackground2 (frame9, "LoadImage", "LoadImage", Loc ["STRING_OPTIONS_WALLPAPER_LOAD_DESC"])
		
	--> Anchors
	
--		/script local f=CreateFrame("frame",nil,UIParent);f:SetSize(256,256);local t=f:CreateTexture(nil,"overlay");t:SetAllPoints();t:SetTexture([[Interface\wallpaper]]);f:SetPoint("center",UIParent,"center")
	
		frame9.backgroundDropdown:SetPoint ("left", frame9.wallpapergroupLabel, "right", 2, 0)
		frame9.backgroundDropdown2:SetPoint ("left", frame9.selectwallpaperLabel, "right", 2, 0)
		
		--general anchor
		g:NewLabel (frame9, _, "$parentWallpaperAnchor", "WallpaperAnchorLabel", Loc ["STRING_OPTIONS_WALLPAPER_ANCHOR"], "GameFontNormal")
		
		local x = window.left_start_at
		
		titulo_wallpaper:SetPoint (x, -30)
		titulo_wallpaper_desc:SetPoint (x, -50)
		
		local left_side = {
			{"WallpaperAnchorLabel", 1, true},
			{"enablewallpaperLabel", 2},
			{"wallpapergroupLabel", 3},
			{"selectwallpaperLabel", 4},
			{"anchorLabel", 5},
			{"editImage", 6},
			{"wallpaperCurrentAnchorLabel", 7, true},
			{"wallpaperCurrentLabel1", 8},
			{"wallpaperCurrentLabel2", 9, false},
			{"wallpaperCurrentLabel3", 10, false},
			{"wallpaperCurrentLabel4", 11, false},
			{"wallpaperCurrentLabel5", 12, false},
			{"wallpaperCurrentLabel6", 13, false},
			{"wallpaperCurrentLabel7", 14, false},
			{"wallpaperCurrentLabel8", 15, false},
			{"wallpaperCurrentLabel9", 16, false},
		}
		
		window:arrange_menu (frame9, left_side, x, -90)
		
		local right_side = {
			{"wallpaperPreviewAnchorLabel", 1, true},
		}
		window:arrange_menu (frame9, right_side, window.right_start_at, -90)
	
		local right_side2 = {
			{"WallpaperLoadTitleAnchor", 1, true},
			{"LoadImage", 2},
		}
		window:arrange_menu (frame9, right_side2, window.right_start_at, -250)
		
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

		frame10.memorySlider.thumb:SetSize (40, 12)
		frame10.memorySlider.thumb:SetTexture ([[Interface\Buttons\UI-Listbox-Highlight2]])
		frame10.memorySlider.thumb:SetVertexColor (.2, .2, .2, .9)
		local t = _detalhes.memory_threshold
		frame10.memorySlider:SetValue (1)
		frame10.memorySlider:SetValue (2)
		frame10.memorySlider:SetValue (t)
		
		window:CreateLineBackground2 (frame10, "memorySlider", "memoryLabel", Loc ["STRING_OPTIONS_MEMORYT_DESC"])
		
	--------------- Max Segments Saved
		g:NewLabel (frame10, _, "$parentLabelSegmentsSave", "segmentsSaveLabel", Loc ["STRING_OPTIONS_SEGMENTSSAVE"], "GameFontHighlightLeft")
		--
		
		frame10.segmentsSliderToSave:SetPoint ("left", frame10.segmentsSaveLabel, "right", 2, 0)
		frame10.segmentsSliderToSave:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.segments_amount_to_save = math.floor (amount)
		end)
		
		window:CreateLineBackground2 (frame10, "segmentsSliderToSave", "segmentsSaveLabel", Loc ["STRING_OPTIONS_SEGMENTSSAVE_DESC"])
	
	--------------- Panic Mode
		g:NewLabel (frame10, _, "$parentPanicModeLabel", "panicModeLabel", Loc ["STRING_OPTIONS_PANIMODE"], "GameFontHighlightLeft")
		--
		g:NewSwitch (frame10, _, "$parentPanicModeSlider", "panicModeSlider", 60, 20, _, _, _detalhes.segments_panic_mode)
		frame10.panicModeSlider:SetPoint ("left", frame10.panicModeLabel, "right", 2, 0)
		frame10.panicModeSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.segments_panic_mode = value
		end
		
		window:CreateLineBackground2 (frame10, "panicModeSlider", "panicModeLabel", Loc ["STRING_OPTIONS_PANIMODE_DESC"])
		
	--------------- Animate Rows
		
		
	--------------- Animate scroll bar
		g:NewLabel (frame10, _, "$parentAnimateScrollLabel", "animatescrollLabel", Loc ["STRING_OPTIONS_ANIMATESCROLL"], "GameFontHighlightLeft")
		
		--
		g:NewSwitch (frame10, _, "$parentClearAnimateScrollSlider", "animatescrollSlider", 60, 20, _, _, _detalhes.animate_scroll) -- ltext, rtext, defaultv
		frame10.animatescrollSlider:SetPoint ("left", frame10.animatescrollLabel, "right", 2, 0)
		frame10.animatescrollSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.animate_scroll = value
		end
		
		window:CreateLineBackground2 (frame10, "animatescrollSlider", "animatescrollLabel", Loc ["STRING_OPTIONS_ANIMATESCROLL_DESC"])
		
	--------------- Update Speed
	
		
	--------------- Erase Trash
		g:NewLabel (frame10, _, "$parentEraseTrash", "eraseTrashLabel", Loc ["STRING_OPTIONS_CLEANUP"], "GameFontHighlightLeft")
		
		--
		g:NewSwitch (frame10, _, "$parentRemoveTrashSlider", "removeTrashSlider", 60, 20, _, _, _detalhes.trash_auto_remove)
		frame10.removeTrashSlider:SetPoint ("left", frame10.eraseTrashLabel, "right")
		frame10.removeTrashSlider.OnSwitch = function (self, _, amount)
			_detalhes.trash_auto_remove = amount
		end
		
		window:CreateLineBackground2 (frame10, "removeTrashSlider", "eraseTrashLabel", Loc ["STRING_OPTIONS_CLEANUP_DESC"])

	--> performance profiles
	
		--enabled func
		local function unlock_profile (settings)
			frame10.animateSlider:Enable()
			frame10.animateLabel:SetTextColor (1, 1, 1, 1)
			frame10.animateSlider:SetValue (settings.use_row_animations)
			
			frame10.updatespeedSlider:Enable()
			frame10.updatespeedLabel:SetTextColor (1, 1, 1, 1)
			frame10.updatespeedSlider:SetValue (settings.update_speed)
			
			frame10.damageCaptureSlider:Enable()
			frame10.damageCaptureSlider:SetValue (settings.damage)
			
			frame10.healCaptureSlider:Enable()
			frame10.healCaptureSlider:SetValue (settings.heal)
			
			frame10.energyCaptureSlider:Enable()
			frame10.energyCaptureSlider:SetValue (settings.energy)
			
			frame10.miscCaptureSlider:Enable()
			frame10.miscCaptureSlider:SetValue (settings.miscdata)
			
			frame10.auraCaptureSlider:Enable()
			frame10.auraCaptureSlider:SetValue (settings.aura)

			frame10.damageCaptureLabel:SetTextColor (1, 1, 1, 1)
			frame10.healCaptureLabel:SetTextColor (1, 1, 1, 1)
			frame10.energyCaptureLabel:SetTextColor (1, 1, 1, 1)
			frame10.miscCaptureLabel:SetTextColor (1, 1, 1, 1)
			frame10.auraCaptureLabel:SetTextColor (1, 1, 1, 1)
		end
		
		--disable func
		local function lock_profile()
			frame10.animateSlider:Disable()
			frame10.animateLabel:SetTextColor (.4, .4, .4, 1)
			
			frame10.updatespeedSlider:Disable()
			frame10.updatespeedLabel:SetTextColor (.4, .4, .4, 1)
			
			frame10.damageCaptureSlider:Disable()
			frame10.healCaptureSlider:Disable()
			frame10.energyCaptureSlider:Disable()
			frame10.miscCaptureSlider:Disable()
			frame10.auraCaptureSlider:Disable()
			
			frame10.damageCaptureLabel:SetTextColor (.4, .4, .4, 1)
			frame10.healCaptureLabel:SetTextColor (.4, .4, .4, 1)
			frame10.energyCaptureLabel:SetTextColor (.4, .4, .4, 1)
			frame10.miscCaptureLabel:SetTextColor (.4, .4, .4, 1)
			frame10.auraCaptureLabel:SetTextColor (.4, .4, .4, 1)
		end
	
		local editing = nil
		local modify_setting = function (config, value)
			
		end
	
		g:NewLabel (frame10, _, "$parentPerformanceProfilesAnchor", "PerformanceProfilesAnchorLabel", Loc ["STRING_OPTIONS_PERFORMANCEPROFILES_ANCHOR"], "GameFontNormal")
		
		--type dropdown
		g:NewLabel (frame10, _, "$parentProfileTypeLabel", "ProfileTypeLabel", Loc ["STRING_OPTIONS_PERFORMANCE_TYPES"], "GameFontHighlightLeft")
		local OnSelectProfileType = function (_, _, selected)
			--enable enable button
			frame10.ProfileTypeEnabledSlider:Enable()
			frame10.ProfileTypeEnabledLabel:SetTextColor (1, 1, 1, 1)
			
			editing = _detalhes.performance_profiles [selected]
			
			if (editing.enabled) then
				frame10.ProfileTypeEnabledSlider:SetValue (true)
				unlock_profile (editing)
			else
				frame10.ProfileTypeEnabledSlider:SetValue (false)
				lock_profile()
			end
		end
		
		local PerformanceProfileOptions = {
			{value = "RaidFinder", label = Loc ["STRING_OPTIONS_PERFORMANCE_RF"], onclick = OnSelectProfileType, icon = [[Interface\PvPRankBadges\PvPRank15]], texcoord = {0, 1, 0, 1}},
			{value = "Raid15", label = Loc ["STRING_OPTIONS_PERFORMANCE_RAID15"], onclick = OnSelectProfileType, icon = [[Interface\PvPRankBadges\PvPRank15]], iconcolor = {1, .8, 0, 1}, texcoord = {0, 1, 0, 1}},
			{value = "Raid30", label = Loc ["STRING_OPTIONS_PERFORMANCE_RAID30"], onclick = OnSelectProfileType, icon = [[Interface\PvPRankBadges\PvPRank15]], iconcolor = {1, .8, 0, 1}, texcoord = {0, 1, 0, 1}},
			{value = "Mythic", label = Loc ["STRING_OPTIONS_PERFORMANCE_MYTHIC"], onclick = OnSelectProfileType, icon = [[Interface\PvPRankBadges\PvPRank15]], iconcolor = {1, .4, 0, 1}, texcoord = {0, 1, 0, 1}},
			{value = "Battleground15", label = Loc ["STRING_OPTIONS_PERFORMANCE_BG15"], onclick = OnSelectProfileType, icon = [[Interface\PvPRankBadges\PvPRank07]], texcoord = {0, 1, 0, 1}},
			{value = "Battleground40", label = Loc ["STRING_OPTIONS_PERFORMANCE_BG40"], onclick = OnSelectProfileType, icon = [[Interface\PvPRankBadges\PvPRank07]], texcoord = {0, 1, 0, 1}},
			{value = "Arena", label = Loc ["STRING_OPTIONS_PERFORMANCE_ARENA"], onclick = OnSelectProfileType, icon = [[Interface\PvPRankBadges\PvPRank12]], texcoord = {0, 1, 0, 1}},
			{value = "Dungeon", label = Loc ["STRING_OPTIONS_PERFORMANCE_DUNGEON"], onclick = OnSelectProfileType, icon = [[Interface\PvPRankBadges\PvPRank01]], texcoord = {0, 1, 0, 1}},
		}
		
		local BuildPerformanceProfileMenu = function()
			return PerformanceProfileOptions
		end
		
		local d = g:NewDropDown (frame10, _, "$parentProfileTypeDropdown", "ProfileTypeDropdown", 160, 20, BuildPerformanceProfileMenu, 0)
		d.onenter_backdrop = dropdown_backdrop_onenter
		d.onleave_backdrop = dropdown_backdrop_onleave
		d:SetBackdrop (dropdown_backdrop)
		d:SetBackdropColor (unpack (dropdown_backdrop_onleave))
		
		frame10.ProfileTypeDropdown:SetPoint ("left", frame10.ProfileTypeLabel, "right", 2)
		
		window:CreateLineBackground2 (frame10, "ProfileTypeDropdown", "ProfileTypeLabel", Loc ["STRING_OPTIONS_PERFORMANCE_TYPES_DESC"])

		--enabled slider
		g:NewLabel (frame10, _, "$parenttProfileTypeEnabledLabel", "ProfileTypeEnabledLabel", Loc ["STRING_OPTIONS_PERFORMANCE_ENABLE"], "GameFontHighlightLeft")
		g:NewSwitch (frame10, _, "$parentProfileTypeEnabledSlider", "ProfileTypeEnabledSlider", 60, 20, _, _, false)
		frame10.ProfileTypeEnabledSlider:SetPoint ("left", frame10.ProfileTypeEnabledLabel, "right", 2)
		frame10.ProfileTypeEnabledSlider.OnSwitch = function (self, _, value)
			if (editing)  then
				editing.enabled = value
				if (value) then
					unlock_profile (editing)
				else
					lock_profile()
				end
			end
		end
		
		frame10.ProfileTypeEnabledSlider:Disable()
		frame10.ProfileTypeEnabledLabel:SetTextColor (.4, .4, .4, 1)		
		
		--window:CreateLineBackground2 (frame10, "ProfileTypeEnabledSlider", "ProfileTypeEnabledLabel", Loc ["STRING_OPTIONS_PERFORMANCE_ENABLE_DESC"])
		
		--animate bars
		g:NewLabel (frame10, _, "$parentAnimateLabel", "animateLabel", Loc ["STRING_OPTIONS_ANIMATEBARS"], "GameFontHighlightLeft")

		g:NewSwitch (frame10, _, "$parentAnimateSlider", "animateSlider", 60, 20, _, _, _detalhes.use_row_animations) -- ltext, rtext, defaultv
		frame10.animateSlider:SetPoint ("left",frame10.animateLabel, "right", 2, 0)
		frame10.animateSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue (false, true)
			if (editing)  then
				editing.use_row_animations = value
				_detalhes:CheckForPerformanceProfile()
			end
		end
		
		--window:CreateLineBackground2 (frame10, "animateSlider", "animateLabel", Loc ["STRING_OPTIONS_ANIMATEBARS_DESC"])
		
		--update speed
		local s = g:NewSlider (frame10, _, "$parentSliderUpdateSpeed", "updatespeedSlider", SLIDER_WIDTH, 20, 0.050, 3, 0.050, _detalhes.update_speed, true)
		s:SetBackdrop (slider_backdrop)
		s:SetBackdropColor (unpack (slider_backdrop_color))
		
		g:NewLabel (frame10, _, "$parentUpdateSpeedLabel", "updatespeedLabel", Loc ["STRING_OPTIONS_WINDOWSPEED"], "GameFontHighlightLeft")
		--
		frame10.updatespeedSlider:SetPoint ("left", frame10.updatespeedLabel, "right", 2, -1)
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
			if (editing)  then
				editing.update_speed = amount
				_detalhes:CheckForPerformanceProfile()
			end
			--_detalhes:CancelTimer (_detalhes.atualizador)
			--_detalhes.update_speed = amount
			--_detalhes.atualizador = _detalhes:ScheduleRepeatingTimer ("AtualizaGumpPrincipal", _detalhes.update_speed, -1)
			updateColor (self, amount)
		end)
		updateColor (frame10.updatespeedSlider, _detalhes.update_speed)
		
		--window:CreateLineBackground2 (frame10, "updatespeedSlider", "updatespeedLabel", Loc ["STRING_OPTIONS_WINDOWSPEED_DESC"])
		
		-- captures
		g:NewLabel (frame10, _, "$parentCaptureDamageLabel", "damageCaptureLabel", Loc ["STRING_OPTIONS_CDAMAGE"], "GameFontHighlightLeft")
		g:NewLabel (frame10, _, "$parentCaptureHealLabel", "healCaptureLabel", Loc ["STRING_OPTIONS_CHEAL"], "GameFontHighlightLeft")
		g:NewLabel (frame10, _, "$parentCaptureEnergyLabel", "energyCaptureLabel", Loc ["STRING_OPTIONS_CENERGY"], "GameFontHighlightLeft")
		g:NewLabel (frame10, _, "$parentCaptureMiscLabel", "miscCaptureLabel", Loc ["STRING_OPTIONS_CMISC"], "GameFontHighlightLeft")
		g:NewLabel (frame10, _, "$parentCaptureAuraLabel", "auraCaptureLabel", Loc ["STRING_OPTIONS_CAURAS"], "GameFontHighlightLeft")

		-- damage
		g:NewSwitch (frame10, _, "$parentCaptureDamageSlider", "damageCaptureSlider", 60, 20, _, _, false)
		frame10.damageCaptureSlider:SetPoint ("left", frame10.damageCaptureLabel, "right", 2)
		frame10.damageCaptureSlider.OnSwitch = function (self, _, value)
			if (editing)  then
				editing.damage = value
				_detalhes:CheckForPerformanceProfile()
			end
		end
		
		--window:CreateLineBackground2 (frame10, "damageCaptureSlider", "damageCaptureLabel", Loc ["STRING_OPTIONS_CDAMAGE_DESC"])
		
		--heal
		g:NewSwitch (frame10, _, "$parentCaptureHealSlider", "healCaptureSlider", 60, 20, _, _, false)
		frame10.healCaptureSlider:SetPoint ("left", frame10.healCaptureLabel, "right", 2)
		frame10.healCaptureSlider.OnSwitch = function (self, _, value)
			if (editing)  then
				editing.heal = value
				_detalhes:CheckForPerformanceProfile()
			end
		end
		
		--window:CreateLineBackground2 (frame10, "healCaptureSlider", "healCaptureLabel", Loc ["STRING_OPTIONS_CHEAL_DESC"])
		
		--energy
		g:NewSwitch (frame10, _, "$parentCaptureEnergySlider", "energyCaptureSlider", 60, 20, _, _, false)
		frame10.energyCaptureSlider:SetPoint ("left", frame10.energyCaptureLabel, "right", 2)

		frame10.energyCaptureSlider.OnSwitch = function (self, _, value)
			if (editing)  then
				editing.energy = value
				_detalhes:CheckForPerformanceProfile()
			end
		end
		
		--window:CreateLineBackground2 (frame10, "energyCaptureSlider", "energyCaptureLabel", Loc ["STRING_OPTIONS_CENERGY_DESC"])
		
		--misc
		g:NewSwitch (frame10, _, "$parentCaptureMiscSlider", "miscCaptureSlider", 60, 20, _, _, false)
		frame10.miscCaptureSlider:SetPoint ("left", frame10.miscCaptureLabel, "right", 2)
		frame10.miscCaptureSlider.OnSwitch = function (self, _, value)
			if (editing)  then
				editing.miscdata = value
				_detalhes:CheckForPerformanceProfile()
			end
		end
		
		--window:CreateLineBackground2 (frame10, "miscCaptureSlider", "miscCaptureLabel", Loc ["STRING_OPTIONS_CMISC_DESC"])
		
		--aura
		g:NewSwitch (frame10, _, "$parentCaptureAuraSlider", "auraCaptureSlider", 60, 20, _, _, false)
		frame10.auraCaptureSlider:SetPoint ("left", frame10.auraCaptureLabel, "right", 2)
		frame10.auraCaptureSlider.OnSwitch = function (self, _, value)
			if (editing)  then
				editing.aura = value
				_detalhes:CheckForPerformanceProfile()
			end
		end
		
		--window:CreateLineBackground2 (frame10, "auraCaptureSlider", "auraCaptureLabel", Loc ["STRING_OPTIONS_CAURAS_DESC"])
		
		lock_profile()
		
	--> Anchors
	
		--general anchor
		g:NewLabel (frame10, _, "$parentPerformanceAnchor", "PerformanceAnchorLabel", Loc ["STRING_OPTIONS_PERFORMANCE_ANCHOR"], "GameFontNormal")
		
		local x = window.left_start_at
		
		titulo_performance_general:SetPoint (x, -30)
		titulo_performance_general_desc:SetPoint (x, -50)
		
		local left_side = {
			{"PerformanceProfilesAnchorLabel", 1, true},
			{"ProfileTypeLabel", 2},
			{"ProfileTypeEnabledLabel", 3},
			{"animateLabel", 4},
			{"updatespeedLabel", 5},
			{"damageCaptureLabel", 6},
			{"healCaptureLabel", 7},
			{"energyCaptureLabel", 8},
			{"miscCaptureLabel", 9},
			{"auraCaptureLabel", 10},
		}
		
		window:arrange_menu (frame10, left_side, window.left_start_at, -90)
		
		local right_side = {
			{"PerformanceAnchorLabel", 1, true},
			{"memoryLabel", 2},
			{"segmentsSaveLabel", 3},
			{"panicModeLabel", 4},
			{"eraseTrashLabel", 5},
		}
		
		window:arrange_menu (frame10, right_side, window.right_start_at, -90)

end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Performance - Captures ~11
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function window:CreateFrame11()

	local frame11 = window.options [11][1]

	local label = g:NewLabel (frame11, _, "$parentMovedWarningLabel", "MovedWarningLabel", "This sectiong has been moved to Combat, under General Settings bracket.", "GameFontNormal")
	local image = g:NewImage (frame11, [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]])
	
	label:SetPoint ("center", frame11, "center", 32, 0)
	image:SetPoint ("right", label, "left", -7, 0)
	
	
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Advanced Plugins Config ~12
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
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
	g:NewLabel (frame4, _, "$parentToolbarPluginsLabel", "toolbarLabel", Loc ["STRING_OPTIONS_PLUGINS_TOOLBAR_ANCHOR"], "GameFontNormal", 16)
	frame4.toolbarLabel:SetPoint ("topleft", frame4, "topleft", 10, y)
	
	y = y - 30
	
	do
		local descbar = frame4:CreateTexture (nil, "artwork")
		descbar:SetTexture (.3, .3, .3, .8)
		descbar:SetPoint ("topleft", frame4, "topleft", 5, y+3)
		descbar:SetSize (650, 20)
		g:NewLabel (frame4, _, "$parentDescNameLabel", "descNameLabel", Loc ["STRING_OPTIONS_PLUGINS_NAME"], "GameFontNormal", 12)
		frame4.descNameLabel:SetPoint ("topleft", frame4, "topleft", 15, y)
		g:NewLabel (frame4, _, "$parentDescAuthorLabel", "descAuthorLabel", Loc ["STRING_OPTIONS_PLUGINS_AUTHOR"], "GameFontNormal", 12)
		frame4.descAuthorLabel:SetPoint ("topleft", frame4, "topleft", 180, y)
		g:NewLabel (frame4, _, "$parentDescVersionLabel", "descVersionLabel", Loc ["STRING_OPTIONS_PLUGINS_VERSION"], "GameFontNormal", 12)
		frame4.descVersionLabel:SetPoint ("topleft", frame4, "topleft", 290, y)
		g:NewLabel (frame4, _, "$parentDescEnabledLabel", "descEnabledLabel", Loc ["STRING_OPTIONS_PLUGINS_ENABLED"], "GameFontNormal", 12)
		frame4.descEnabledLabel:SetPoint ("topleft", frame4, "topleft", 400, y)
	end
	
	y = y - 30
	
	local i = 1
	local allplugins_toolbar = _detalhes.ToolBar.NameTable
	for absName, pluginObject in pairs (allplugins_toolbar) do 
	
		local bframe = CreateFrame ("frame", "OptionsPluginToolbarBG", frame4)
		bframe:SetSize (640, 20)
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
	g:NewLabel (frame4, _, "$parentRaidPluginsLabel", "raidLabel", Loc ["STRING_OPTIONS_PLUGINS_RAID_ANCHOR"], "GameFontNormal", 16)
	frame4.raidLabel:SetPoint ("topleft", frame4, "topleft", 10, y)
	
	y = y - 30
	
	do
		local descbar = frame4:CreateTexture (nil, "artwork")
		descbar:SetTexture (.3, .3, .3, .8)
		descbar:SetPoint ("topleft", frame4, "topleft", 5, y+3)
		descbar:SetSize (650, 20)
		g:NewLabel (frame4, _, "$parentDescNameLabel2", "descNameLabel", Loc ["STRING_OPTIONS_PLUGINS_NAME"], "GameFontNormal", 12)
		frame4.descNameLabel:SetPoint ("topleft", frame4, "topleft", 15, y)
		g:NewLabel (frame4, _, "$parentDescAuthorLabel2", "descAuthorLabel", Loc ["STRING_OPTIONS_PLUGINS_AUTHOR"], "GameFontNormal", 12)
		frame4.descAuthorLabel:SetPoint ("topleft", frame4, "topleft", 180, y)
		g:NewLabel (frame4, _, "$parentDescVersionLabel2", "descVersionLabel", Loc ["STRING_OPTIONS_PLUGINS_VERSION"], "GameFontNormal", 12)
		frame4.descVersionLabel:SetPoint ("topleft", frame4, "topleft", 290, y)
		g:NewLabel (frame4, _, "$parentDescEnabledLabel2", "descEnabledLabel", Loc ["STRING_OPTIONS_PLUGINS_ENABLED"], "GameFontNormal", 12)
		frame4.descEnabledLabel:SetPoint ("topleft", frame4, "topleft", 400, y)
	end
	
	y = y - 30
	
	local i = 1
	local allplugins_raid = _detalhes.RaidTables.NameTable
	for absName, pluginObject in pairs (allplugins_raid) do 

		local bframe = CreateFrame ("frame", "OptionsPluginRaidBG", frame4)
		bframe:SetSize (640, 20)
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
	g:NewLabel (frame4, _, "$parentSoloPluginsLabel", "soloLabel", Loc ["STRING_OPTIONS_PLUGINS_SOLO_ANCHOR"], "GameFontNormal", 16)
	frame4.soloLabel:SetPoint ("topleft", frame4, "topleft", 10, y)
	
	y = y - 30
	
	do
		local descbar = frame4:CreateTexture (nil, "artwork")
		descbar:SetTexture (.3, .3, .3, .8)
		descbar:SetPoint ("topleft", frame4, "topleft", 5, y+3)
		descbar:SetSize (650, 20)
		g:NewLabel (frame4, _, "$parentDescNameLabel3", "descNameLabel", Loc ["STRING_OPTIONS_PLUGINS_NAME"], "GameFontNormal", 12)
		frame4.descNameLabel:SetPoint ("topleft", frame4, "topleft", 15, y)
		g:NewLabel (frame4, _, "$parentDescAuthorLabel3", "descAuthorLabel", Loc ["STRING_OPTIONS_PLUGINS_AUTHOR"], "GameFontNormal", 12)
		frame4.descAuthorLabel:SetPoint ("topleft", frame4, "topleft", 180, y)
		g:NewLabel (frame4, _, "$parentDescVersionLabel3", "descVersionLabel", Loc ["STRING_OPTIONS_PLUGINS_VERSION"], "GameFontNormal", 12)
		frame4.descVersionLabel:SetPoint ("topleft", frame4, "topleft", 290, y)
		g:NewLabel (frame4, _, "$parentDescEnabledLabel3", "descEnabledLabel", Loc ["STRING_OPTIONS_PLUGINS_ENABLED"], "GameFontNormal", 12)
		frame4.descEnabledLabel:SetPoint ("topleft", frame4, "topleft", 400, y)
	end
	
	y = y - 30
	
	local i = 1
	local allplugins_solo = _detalhes.SoloTables.NameTable
	for absName, pluginObject in pairs (allplugins_solo) do 
	
		local bframe = CreateFrame ("frame", "OptionsPluginSoloBG", frame4)
		bframe:SetSize (640, 20)
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
		local step = 5 -- 100/quantidade de menus
		
		function _detalhes:create_options_panels()
		
			window ["CreateFrame" .. panel_index]()

			if (panel_index == 20) then
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
		
		for i = 1, 20 do
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
	["BACKGROUND"] = "Background",
	["LOW"] = "Low",
	["MEDIUM"] = "Medium",
	["HIGH"] = "High",
	["DIALOG"] = "Dialog"
}

function _detalhes:DelayUpdateWindowControls (editing_instance)
	_G.DetailsOptionsWindow1LockButton.MyObject:SetClickFunction (_detalhes.lock_instance_function, editing_instance.baseframe.lock_button)
	if (editing_instance.baseframe.isLocked) then
		_G.DetailsOptionsWindow1LockButton.MyObject:SetText (Loc ["STRING_OPTIONS_WC_UNLOCK"])
	else
		_G.DetailsOptionsWindow1LockButton.MyObject:SetText (Loc ["STRING_OPTIONS_WC_LOCK"])
	end
end

function window:update_all (editing_instance)

	--> window 1
	_G.DetailsOptionsWindow1RealmNameSlider.MyObject:SetValue (_detalhes.remove_realm_from_name)
	_G.DetailsOptionsWindow1Slider.MyObject:SetValue (_detalhes.segments_amount) --segments
	_G.DetailsOptionsWindow1SegmentsLockedSlider.MyObject:SetValue (_detalhes.instances_segments_locked) --locked segments
	
	_G.DetailsOptionsWindow1UseScrollSlider.MyObject:SetValue (_detalhes.use_scroll)
	
	_G.DetailsOptionsWindow1SliderMaxInstances.MyObject:SetValue (_detalhes.instances_amount)
	_G.DetailsOptionsWindow1AbbreviateDropdown.MyObject:Select (_detalhes.ps_abbreviation)
	_G.DetailsOptionsWindow1SliderUpdateSpeed.MyObject:SetValue (_detalhes.update_speed)
	_G.DetailsOptionsWindow1AnimateSlider.MyObject:SetValue (_detalhes.use_row_animations)

	_G.DetailsOptionsWindow1WindowControlsAnchor:SetText (string.format (Loc ["STRING_OPTIONS_WC_ANCHOR"], editing_instance.meu_id))
	
	if (not editing_instance.baseframe) then
		_detalhes:ScheduleTimer ("DelayUpdateWindowControls", 1, editing_instance)
	else
		_G.DetailsOptionsWindow1LockButton.MyObject:SetClickFunction (_detalhes.lock_instance_function, editing_instance.baseframe.lock_button)
		if (editing_instance.baseframe.isLocked) then
			_G.DetailsOptionsWindow1LockButton.MyObject:SetText (Loc ["STRING_OPTIONS_WC_UNLOCK"])
		else
			_G.DetailsOptionsWindow1LockButton.MyObject:SetText (Loc ["STRING_OPTIONS_WC_LOCK"])
		end
	end
	
	_G.DetailsOptionsWindow1BreakSnapButton.MyObject:Disable()
	
	for side, have_snap in pairs (editing_instance.snap) do 
		if (have_snap) then
			_G.DetailsOptionsWindow1BreakSnapButton.MyObject:Enable()
			_G.DetailsOptionsWindow1BreakSnapButton.MyObject:SetClickFunction (editing_instance.Desagrupar, editing_instance, -1)
			break
		end
	end

	if (editing_instance.ativa) then
		_G.DetailsOptionsWindow1CloseButton.MyObject:SetText (Loc ["STRING_OPTIONS_WC_CLOSE"])
		_G.DetailsOptionsWindow1CloseButton.MyObject:SetClickFunction (_detalhes.close_instancia_func, editing_instance.baseframe.cabecalho.fechar)
	else
		_G.DetailsOptionsWindow1CloseButton.MyObject:SetText (Loc ["STRING_OPTIONS_WC_REOPEN"])
		_G.DetailsOptionsWindow1CloseButton.MyObject:SetClickFunction (function() _detalhes:CriarInstancia (_, editing_instance.meu_id) end)
	end
	
	--> window 2
	_G.DetailsOptionsWindow2FragsPvpSlider.MyObject:SetValue (_detalhes.only_pvp_frags)
	_G.DetailsOptionsWindow2TTDropdown.MyObject:Select (_detalhes.time_type)
	
	_G.DetailsOptionsWindow2OverallDataRaidBossSlider.MyObject:SetValue (bit.band (_detalhes.overall_flag, 0x1) ~= 0)
	_G.DetailsOptionsWindow2OverallDataRaidCleaupSlider.MyObject:SetValue (bit.band (_detalhes.overall_flag, 0x2) ~= 0)
	_G.DetailsOptionsWindow2OverallDataDungeonBossSlider.MyObject:SetValue (bit.band (_detalhes.overall_flag, 0x4) ~= 0)
	_G.DetailsOptionsWindow2OverallDataDungeonCleaupSlider.MyObject:SetValue (bit.band (_detalhes.overall_flag, 0x8) ~= 0)
	_G.DetailsOptionsWindow2OverallDataAllSlider.MyObject:SetValue (bit.band (_detalhes.overall_flag, 0x10) ~= 0)
	
	_G.DetailsOptionsWindow2OverallNewBossSlider.MyObject:SetValue (_detalhes.overall_clear_newboss)
	_G.DetailsOptionsWindow2OverallNewChallengeSlider.MyObject:SetValue (_detalhes.overall_clear_newchallenge)
	
	_G.DetailsOptionsWindow2CaptureDamageSlider.MyObject:SetValue (_detalhes.capture_real ["damage"])
	_G.DetailsOptionsWindow2CaptureHealSlider.MyObject:SetValue (_detalhes.capture_real ["heal"])
	_G.DetailsOptionsWindow2CaptureEnergySlider.MyObject:SetValue (_detalhes.capture_real ["energy"])
	_G.DetailsOptionsWindow2CaptureMiscSlider.MyObject:SetValue (_detalhes.capture_real ["miscdata"])
	_G.DetailsOptionsWindow2CaptureAuraSlider.MyObject:SetValue (_detalhes.capture_real ["aura"])
	_G.DetailsOptionsWindow2CloudAuraSlider.MyObject:SetValue (_detalhes.cloud_capture)
	
	--> window 3
	
	local skin = editing_instance.skin
	local frame3 = _G.DetailsOptionsWindow3
	
	_G.DetailsOptionsWindow3SkinDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow3SkinDropdown.MyObject:Select (skin)
	
	local skin_object = _detalhes:GetSkin (skin)
	local skin_name_formated = skin:gsub (" ", "")
	
	--> hide all
	for name, _ in pairs (_detalhes.skins) do
		local name = name:gsub (" ", "")
		for index, t in ipairs (frame3.ExtraOptions [name] or {}) do
			t[1]:Hide()
			t[2]:Hide()
		end
	end
	frame3.SkinExtraOptionsAnchor:Hide()
	
	--> create or show options if necessary
	if (skin_object.skin_options and not skin_object.options_created) then
		skin_object.options_created = true

		frame3.ExtraOptions [skin_name_formated] = {}
		
		for index, widget in ipairs (skin_object.skin_options) do 
			local type = widget.type
			
			if (type == "button") then
				local button = g:NewButton (frame3, _, "$parent" .. skin_name_formated .. "Button" .. index, skin_name_formated .. "Button" .. index, 160, 18, widget.func, nil, nil, nil, widget.text)
				button:InstallCustomTexture()

				local label = g:NewLabel (frame3, _, "$parent" .. skin_name_formated .. "ButtonLabel" .. index, skin_name_formated .. "ButtonLabel" .. index, "", "GameFontHighlightLeft")
				label:SetPoint ("left", button, "left")
				
				local desc = window:CreateLineBackground2 (frame3, skin_name_formated .. "Button" .. index, skin_name_formated .. "ButtonLabel" .. index, widget.desc)
				desc:SetWidth (1)
				
				tinsert (frame3.ExtraOptions [skin_name_formated], {button, label})
				
				button:SetPoint (window.right_start_at, window.top_start_at + (index * 1 * 25 * -1))
			end
		end
		
		frame3.SkinExtraOptionsAnchor:Show()
		
	elseif (skin_object.skin_options) then
		for index, t in ipairs (frame3.ExtraOptions [skin_name_formated]) do
			t[1]:Show()
			t[2]:Show()
		end
		frame3.SkinExtraOptionsAnchor:Show()
	end
	
	--> window 4
	_G.DetailsOptionsWindow4BarSpacementSizeSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4BarSpacementSizeSlider.MyObject:SetValue (editing_instance.row_info.space.between)
	
	_G.DetailsOptionsWindow4BarStartSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4BarStartSlider.MyObject:SetValue (editing_instance.row_info.start_after_icon)
	
	_G.DetailsOptionsWindow4BackdropBorderTextureDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4BackdropEnabledSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4BackdropSizeHeight.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4BackdropBorderTextureDropdown.MyObject:Select (editing_instance.row_info.backdrop.texture)
	_G.DetailsOptionsWindow4BackdropEnabledSlider.MyObject:SetValue (editing_instance.row_info.backdrop.enabled)
	_G.DetailsOptionsWindow4BackdropSizeHeight.MyObject:SetValue (editing_instance.row_info.backdrop.size)
	_G.DetailsOptionsWindow4BackdropColorPick.MyObject:SetColor (unpack (editing_instance.row_info.backdrop.color))
	
	--> window 5
	
	_G.DetailsOptionsWindow5PercentDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow5PercentDropdown.MyObject:Select (editing_instance.row_info.percent_type)
	
	_G.DetailsOptionsWindow5CutomRightTextSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow5CutomRightTextSlider.MyObject:SetValue (editing_instance.row_info.textR_enable_custom_text)
	
	local text = editing_instance.row_info.textR_custom_text
	--text = text:gsub ("|", "||")
	_G.DetailsOptionsWindow5CutomRightTextEntry.MyObject:SetText (text)
	
	--> window 6
	_G.DetailsOptionsWindow6BackdropDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6BackdropDropdown.MyObject:Select (editing_instance.backdrop_texture)
	
	local r, g, b = unpack (editing_instance.statusbar_info.overlay)
	_G.DetailsOptionsWindow6StatusbarColorPick.MyObject:SetColor (r, g, b, editing_instance.statusbar_info.alpha)
	
	_G.DetailsOptionsWindow6StrataDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6StrataDropdown.MyObject:Select (strata [editing_instance.strata] or "Low")
	
	_G.DetailsOptionsWindow6StretchAlwaysOnTopSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6StretchAlwaysOnTopSlider.MyObject:SetValue (editing_instance.grab_on_top)
	
	_G.DetailsOptionsWindow6InstanceMicroDisplaysSideSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6InstanceMicroDisplaysSideSlider.MyObject:SetValue (editing_instance.micro_displays_side)

	--> window 7

	_G.DetailsOptionsWindow7AutoHideLeftMenuSwitch.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7AutoHideLeftMenuSwitch.MyObject:SetValue (editing_instance.auto_hide_menu.left)
	
	_G.DetailsOptionsWindow7MenuAnchorSideSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7MenuAnchorSideSlider.MyObject:SetValue (editing_instance.menu_anchor.side)
	
	_G.DetailsOptionsWindow7:update_icon_buttons (editing_instance)
	
	_G.DetailsOptionsWindow7PluginIconsDirectionSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7PluginIconsDirectionSlider.MyObject:SetValue (editing_instance.plugins_grow_direction)	
	
	_G.DetailsOptionsWindow7DesaturateMenuSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7DesaturateMenuSlider.MyObject:SetValue (editing_instance.desaturated_menu)
	
	_G.DetailsOptionsWindow7HideIconSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7HideIconSlider.MyObject:SetValue (editing_instance.hide_icon)
	
	_G.DetailsOptionsWindow7MenuIconSizeSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7MenuIconSizeSlider.MyObject:SetValue (editing_instance.menu_icons_size)	
	
	_G.DetailsOptionsWindow7MenuAnchorXSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7MenuAnchorYSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow7:update_menuanchor_xy (editing_instance)

	--> window 8
	
	_G.DetailsOptionsWindow8MenuAnchorXSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow8MenuAnchorYSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow8:update_menuanchor_xy (editing_instance)
	
	_G.DetailsOptionsWindow8DesaturateMenuSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow8DesaturateMenuSlider.MyObject:SetValue (editing_instance.desaturated_menu2)
	
	_G.DetailsOptionsWindow8MenuIconSizeSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow8MenuIconSizeSlider.MyObject:SetValue (editing_instance.menu2_icons_size)

	_G.DetailsOptionsWindow8:update_icon_buttons (editing_instance)
	
	_G.DetailsOptionsWindow8AutoHideRightMenuSwitch.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow8AutoHideRightMenuSwitch.MyObject:SetValue (editing_instance.auto_hide_menu.right)
	
	_G.DetailsOptionsWindow8InstanceTextFontDropdown.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow8InstanceTextSizeSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow8InstanceTexShadowtSwitch.MyObject:SetFixedParameter (editing_instance)
	
	_G.DetailsOptionsWindow8InstanceTextColorPick.MyObject:SetColor (unpack (editing_instance.instancebutton_config.textcolor))
	_G.DetailsOptionsWindow8InstanceTextSizeSlider.MyObject:SetValue (editing_instance.instancebutton_config.textsize)
	_G.DetailsOptionsWindow8InstanceTextFontDropdown.MyObject:Select (editing_instance.instancebutton_config.textfont)
	_G.DetailsOptionsWindow8InstanceTexShadowtSwitch.MyObject:SetValue (editing_instance.instancebutton_config.textshadow)
	
	--instanceTextColorLabel

	
	--> window 10	
	_G.DetailsOptionsWindow10SliderMemory.MyObject:SetValue (_detalhes.memory_threshold)
	_G.DetailsOptionsWindow10PanicModeSlider.MyObject:SetValue (_detalhes.segments_panic_mode)
	_G.DetailsOptionsWindow10ClearAnimateScrollSlider.MyObject:SetValue (_detalhes.animate_scroll)
	_G.DetailsOptionsWindow10SliderSegmentsSave.MyObject:SetValue (_detalhes.segments_amount_to_save)
	
	--> window 11

	
	--> window 13
	_G.DetailsOptionsWindow13SelectProfileDropdown.MyObject:Select (_detalhes:GetCurrentProfileName())
	_G.DetailsOptionsWindow13SelectProfileDropdown.MyObject:SetFixedParameter (editing_instance)
	
	_G.DetailsOptionsWindow13PosAndSizeSlider.MyObject:SetValue (_detalhes.profile_save_pos)

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
	_G.DetailsOptionsWindow14AttributeFontDropdown.MyObject:Select (editing_instance.attribute_text.text_face)
	_G.DetailsOptionsWindow14AttributeTextSizeSlider.MyObject:SetValue (tonumber (editing_instance.attribute_text.text_size))
	_G.DetailsOptionsWindow14AttributeTextColorPick.MyObject:SetColor (unpack (editing_instance.attribute_text.text_color))
	_G.DetailsOptionsWindow14AttributeShadowSwitch.MyObject:SetValue (editing_instance.attribute_text.shadow)

	_G.DetailsOptionsWindow14AttributeSideSwitch.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow14AttributeSideSwitch.MyObject:SetValue (editing_instance.attribute_text.side)
	
	--> window 16
	_G.DetailsOptionsWindow16UserTimeCapturesFillPanel.MyObject:Refresh()
	
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
	
	--> window 18
	--auto switch
	
	local switch_tank_in_combat = editing_instance.switch_tank_in_combat
	if (switch_tank_in_combat) then
		if (switch_tank_in_combat [1] == "raid") then
			local plugin_object = _detalhes:GetPlugin (switch_tank_in_combat[2])
			if (plugin_object) then
				_G.DetailsOptionsWindow18AutoSwitchTankCombatDropdown.MyObject:Select (plugin_object.__name)
			else
				_G.DetailsOptionsWindow18AutoSwitchTankCombatDropdown.MyObject:Select (1, true)
			end
		else
			_G.DetailsOptionsWindow18AutoSwitchTankCombatDropdown.MyObject:Select (switch_tank_in_combat[3]+1, true)
		end
	else
		_G.DetailsOptionsWindow18AutoSwitchTankCombatDropdown.MyObject:Select (1, true)
	end
	
	local switch_tank = editing_instance.switch_tank
	if (switch_tank) then
		if (switch_tank [1] == "raid") then
			local plugin_object = _detalhes:GetPlugin (switch_tank[2])
			if (plugin_object) then
				_G.DetailsOptionsWindow18AutoSwitchTankNoCombatDropdown.MyObject:Select (plugin_object.__name)
			else
				_G.DetailsOptionsWindow18AutoSwitchTankNoCombatDropdown.MyObject:Select (1, true)
			end
		else
			_G.DetailsOptionsWindow18AutoSwitchTankNoCombatDropdown.MyObject:Select (switch_tank[3]+1, true)
		end
	else
		_G.DetailsOptionsWindow18AutoSwitchTankNoCombatDropdown.MyObject:Select (1, true)
	end
	
	local switch_healer_in_combat = editing_instance.switch_healer_in_combat
	if (switch_healer_in_combat) then
		if (switch_healer_in_combat [1] == "raid") then
			local plugin_object = _detalhes:GetPlugin (switch_healer_in_combat[2])
			if (plugin_object) then
				_G.DetailsOptionsWindow18AutoSwitchHealCombatDropdown.MyObject:Select (plugin_object.__name)
			else
				_G.DetailsOptionsWindow18AutoSwitchHealCombatDropdown.MyObject:Select (1, true)
			end
		else
			_G.DetailsOptionsWindow18AutoSwitchHealCombatDropdown.MyObject:Select (switch_healer_in_combat[3]+1, true)
		end
	else
		_G.DetailsOptionsWindow18AutoSwitchHealCombatDropdown.MyObject:Select (1, true)
	end
	
	local switch_healer = editing_instance.switch_healer
	if (switch_healer) then
		if (switch_healer [1] == "raid") then
			local plugin_object = _detalhes:GetPlugin (switch_healer[2])
			if (plugin_object) then
				_G.DetailsOptionsWindow18AutoSwitchHealNoCombatDropdown.MyObject:Select (plugin_object.__name)
			else
				_G.DetailsOptionsWindow18AutoSwitchHealNoCombatDropdown.MyObject:Select (1, true)
			end
		else
			_G.DetailsOptionsWindow18AutoSwitchHealNoCombatDropdown.MyObject:Select (switch_healer[3]+1, true)
		end
	else
		_G.DetailsOptionsWindow18AutoSwitchHealNoCombatDropdown.MyObject:Select (1, true)
	end
	
	local switch_damager_in_combat = editing_instance.switch_damager_in_combat
	if (switch_damager_in_combat) then
		if (switch_damager_in_combat [1] == "raid") then
			local plugin_object = _detalhes:GetPlugin (switch_damager_in_combat[2])
			if (plugin_object) then
				_G.DetailsOptionsWindow18AutoSwitchDamageCombatDropdown.MyObject:Select (plugin_object.__name)
			else
				_G.DetailsOptionsWindow18AutoSwitchDamageCombatDropdown.MyObject:Select (1, true)
			end
		else
			_G.DetailsOptionsWindow18AutoSwitchDamageCombatDropdown.MyObject:Select (switch_damager_in_combat[3]+1, true)
		end
	else
		_G.DetailsOptionsWindow18AutoSwitchDamageCombatDropdown.MyObject:Select (1, true)
	end
	
	local switch_damager = editing_instance.switch_damager
	if (switch_damager) then
		if (switch_damager [1] == "raid") then
			local plugin_object = _detalhes:GetPlugin (switch_damager[2])
			if (plugin_object) then
				_G.DetailsOptionsWindow18AutoSwitchDamageNoCombatDropdown.MyObject:Select (plugin_object.__name)
			else
				_G.DetailsOptionsWindow18AutoSwitchDamageNoCombatDropdown.MyObject:Select (1, true)
			end
		else
			_G.DetailsOptionsWindow18AutoSwitchDamageNoCombatDropdown.MyObject:Select (switch_damager[3]+1, true)
		end
	else
		_G.DetailsOptionsWindow18AutoSwitchDamageNoCombatDropdown.MyObject:Select (1, true)
	end
	
	local switch_all_roles_after_wipe = editing_instance.switch_all_roles_after_wipe
	if (switch_all_roles_after_wipe) then
		if (switch_all_roles_after_wipe [1] == "raid") then
			local plugin_object = _detalhes:GetPlugin (switch_all_roles_after_wipe[2])
			if (plugin_object) then
				_G.DetailsOptionsWindow18AutoSwitchWipeDropdown.MyObject:Select (plugin_object.__name)
			else
				_G.DetailsOptionsWindow18AutoSwitchWipeDropdown.MyObject:Select (1, true)
			end
		else
			_G.DetailsOptionsWindow18AutoSwitchWipeDropdown.MyObject:Select (switch_all_roles_after_wipe[3]+1, true)
		end
	else
		_G.DetailsOptionsWindow18AutoSwitchWipeDropdown.MyObject:Select (1, true)
	end
	
	local autoswitch = editing_instance.switch_all_roles_in_combat
	if (autoswitch) then
		if (autoswitch [1] == "raid") then
			local plugin_object = _detalhes:GetPlugin (autoswitch[2])
			if (plugin_object) then
				_G.DetailsOptionsWindow18AutoSwitchDropdown.MyObject:Select (plugin_object.__name)
			else
				_G.DetailsOptionsWindow18AutoSwitchDropdown.MyObject:Select (1, true)
			end
		else
			_G.DetailsOptionsWindow18AutoSwitchDropdown.MyObject:Select (autoswitch[3]+1, true)
		end
	else
		_G.DetailsOptionsWindow18AutoSwitchDropdown.MyObject:Select (1, true)
	end
	
	_G.DetailsOptionsWindow18AutoCurrentSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow18AutoCurrentSlider.MyObject:SetValue (editing_instance.auto_current)	
	
	_G.DetailsOptionsWindow18TotalBarSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow18TotalBarSlider.MyObject:SetValue (editing_instance.total_bar.enabled)
	
	_G.DetailsOptionsWindow18TotalBarColorPick.MyObject:SetColor (unpack (editing_instance.total_bar.color))
	
	_G.DetailsOptionsWindow18TotalBarOnlyInGroupSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow18TotalBarOnlyInGroupSlider.MyObject:SetValue (editing_instance.total_bar.only_in_group)
	_G.DetailsOptionsWindow18TotalBarIconTexture.MyObject:SetTexture (editing_instance.total_bar.icon)
	
	--> window 19
	_G.DetailsOptionsWindow19MinimapSlider.MyObject:SetValue (not _detalhes.minimap.hide)
	_G.DetailsOptionsWindow19MinimapActionDropdown.MyObject:Select (_detalhes.minimap.onclick_what_todo)
	_G.DetailsOptionsWindow19HotcornerSlider.MyObject:SetValue (not _detalhes.hotcorner_topleft.hide)
	_G.DetailsOptionsWindow19HotcornerActionDropdown.MyObject:Select (_detalhes.hotcorner_topleft.onclick_what_todo)
	_G.DetailsOptionsWindow19HotcornerQuickClickSlider.MyObject:SetValue (_detalhes.hotcorner_topleft.topleft_quickclick)
	_G.DetailsOptionsWindow19QuickClickDropdown.MyObject:Select (_detalhes.hotcorner_topleft.quickclick_what_todo)
	_G.DetailsOptionsWindow19BrokerTextDropdown.MyObject:Select (_detalhes.minimap.text_type)
	
	
	--> window 20
	_G.DetailsOptionsWindow20TooltipTextColorPick.MyObject:SetColor (unpack (_detalhes.tooltip.fontcolor))
	_G.DetailsOptionsWindow20TooltipTextSizeSlider.MyObject:SetValue (_detalhes.tooltip.fontsize)
	_G.DetailsOptionsWindow20TooltipFontDropdown.MyObject:Select (_detalhes.tooltip.fontface)
	_G.DetailsOptionsWindow20TooltipShadowSwitch.MyObject:SetValue (_detalhes.tooltip.fontshadow)
	_G.DetailsOptionsWindow20TooltipBackgroundColorPick.MyObject:SetColor (unpack (_detalhes.tooltip.background))
	_G.DetailsOptionsWindow20TooltipAbbreviateDropdown.MyObject:Select (_detalhes.tooltip.abbreviation, true)
	_G.DetailsOptionsWindow20TooltipMaximizeDropdown.MyObject:Select (_detalhes.tooltip.maximize_method, true)
	_G.DetailsOptionsWindow20TooltipShowAmountSlider.MyObject:SetValue (_detalhes.tooltip.show_amount)
	
	_G.DetailsOptionsWindow20TooltipAnchorDropdown.MyObject:Select (_detalhes.tooltip.anchored_to)
	_G.DetailsOptionsWindow20TooltipAnchorSideDropdown.MyObject:Select (_detalhes.tooltip.anchor_point)
	_G.DetailsOptionsWindow20TooltipRelativeSideDropdown.MyObject:Select (_detalhes.tooltip.anchor_relative)
	_G.DetailsOptionsWindow20TooltipOffsetXSlider.MyObject:SetValue (_detalhes.tooltip.anchor_offset[1])
	_G.DetailsOptionsWindow20TooltipOffsetYSlider.MyObject:SetValue (_detalhes.tooltip.anchor_offset[2])
	
	----------



	
	_G.DetailsOptionsWindow6SideBarsSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6SideBarsSlider.MyObject:SetValue (editing_instance.show_sidebars)
	

	
	_G.DetailsOptionsWindow6StatusbarSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6StatusbarSlider.MyObject:SetValue (editing_instance.show_statusbar)
	
	_G.DetailsOptionsWindow6StretchAnchorSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6StretchAnchorSlider.MyObject:SetValue (editing_instance.stretch_button_side)
	

	
	_G.DetailsOptionsWindow6InstanceToolbarSideSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow6InstanceToolbarSideSlider.MyObject:SetValue (editing_instance.toolbar_side)
	
	_G.DetailsOptionsWindow4BarSortDirectionSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4BarSortDirectionSlider.MyObject:SetValue (editing_instance.bars_sort_direction)
	
	_G.DetailsOptionsWindow4BarGrowDirectionSlider.MyObject:SetFixedParameter (editing_instance)
	_G.DetailsOptionsWindow4BarGrowDirectionSlider.MyObject:SetValue (editing_instance.bars_grow_direction)



----------------------------------------------------------------	



	--instanceOverlayColorLabel

	--closeOverlayColorLabel
	

	
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
		GameCooltip:Reset()
		--_detalhes:CooltipPreset (1)
		GameCooltip:AddLine ("editing window:", editing_instance.meu_id)
		GameCooltip:ShowCooltip (_G.DetailsOptionsWindowInstanceSelectDropdown, "tooltip")
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

