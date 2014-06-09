--File Revision: 1
--Last Modification: 05/12/07/2013
-- Change Log:
	-- 05/12/07/2013: This file has been introduced.


local _detalhes = _G._detalhes
local _

	--> install skin function:
	function _detalhes:InstallSkin (skin_name, skin_table)
		if (not skin_name) then
			return false -- sem nome
		elseif (_detalhes.skins [skin_name]) then
			return false -- ja existe
		end
		
		if (not skin_table.file) then
			return false -- sem arquivo
		end
		
		skin_table.author = skin_table.author or ""
		skin_table.version = skin_table.version or ""
		skin_table.site = skin_table.site or ""
		skin_table.desc = skin_table.desc or ""
		
		_detalhes.skins [skin_name] = skin_table
		return true
	end
	
	function _detalhes:GetSkin (skin_name)
		return _detalhes.skins [skin_name]
	end

	--> install default skins:
	_detalhes:InstallSkin ("Default Skin", {
		file = [[Interface\AddOns\Details\images\skins\default_skin]], 
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "default skin for Details!", 
		
		can_change_alpha_head = false, 
		icon_anchor_main = {-1, 1}, 
		icon_anchor_plugins = {-9, -7}, 
		icon_plugins_size = {19, 19},
		
		-- the four anchors:
		icon_point_anchor = {-37, 0},
		left_corner_anchor = {-107, 0},
		right_corner_anchor = {96, 0},

		icon_point_anchor_bottom = {-37, 0},
		left_corner_anchor_bottom = {-107, 0},
		right_corner_anchor_bottom = {96, 0},
		
		micro_frames = {left = "DETAILS_STATUSBAR_PLUGIN_PATTRIBUTE"},
		
		instance_cprops = {
		
			hide_icon = false,
			menu_anchor = {5, -1, side = 1},
			menu_anchor_down = {5, -1},
			menu2_anchor = {37, 10},
			menu2_anchor_down = {22, -6},
			menu_icons_size = 1,
			plugins_grow_direction = 2,
			bg_alpha = 0.7,
			
		--rows
			row_info = {
				texture = "Details D'ictum",
				texture_class_colors = true,
				alpha = 1, 
				texture_background_class_color = false,
				texture_background = "Details Serenity",
				fixed_texture_background_color = {0.619607, 0.619607, 0.619607, 0.116164},
				space = {left = 3, right = -5, between = 2},
				backdrop = {enabled = false, size = 6, color = {0, 0, 0, 0.305214}, texture = "Details BarBorder 2"}
			},
			
		--instance button			
			instancebutton_config = {size = {22, 14}, anchor = {-2, -1}, textcolor = {.8, .6, .0, 0.8}, textsize = 10, textfont = "Friz Quadrata TT", 
			normal_texture = [[Interface\AddOns\Details\images\skins\default_skin]], 
			normal_texcoord = {0.0087890625, 0.0322265625, 0.4140625, 0.4296875}, 
			highlight_texture = [[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]], 
			pushed_texture = [[Interface\AddOns\Details\images\skins\default_skin]], 
			pushed_texcoord = {0.0673828125, 0.0908203125, 0.4140625, 0.4296875}
			},
		--reset button
			resetbutton_config = {size = {22, 14}, anchor = {1, 0}, 
			normal_texture = [[Interface\AddOns\Details\images\skins\default_skin]], 
			normal_texcoord = {0.0380859375, 0.0615234375, 0.4140625, 0.4296875},
			highlight_texture = [[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]], 
			pushed_texture = [[Interface\AddOns\Details\images\skins\default_skin]], 
			pushed_texcoord = {0.0966796875, 0.1201171875, 0.4140625, 0.4296875}
			},
		--close button
			closebutton_config = {size = {32, 32}},
		}
		
	})

	_detalhes:InstallSkin ("Minimalistic", {
		file = [[Interface\AddOns\Details\images\skins\classic_skin]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "classic skin.", 
		
		micro_frames = {color = {1, 1, 1, 1}, font = "Friz Quadrata TT", size = 10},
		
		can_change_alpha_head = true, 
		icon_anchor_main = {-1, -5}, 
		icon_anchor_plugins = {-7, -13}, 
		icon_plugins_size = {19, 18},
		
		--anchors:
		icon_point_anchor = {-37, 0},
		left_corner_anchor = {-107, 0},
		right_corner_anchor = {96, 0},

		icon_point_anchor_bottom = {-37, 12},
		left_corner_anchor_bottom = {-107, 0},
		right_corner_anchor_bottom = {96, 0},
		
		--overwrites
		instance_cprops = {
			hide_icon = true,
			
			menu_anchor = {-55, -1, side = 2},
			menu_anchor_down = {-55, -1},
			menu2_anchor = {32, 2},
			menu2_anchor_down = {32, 2},
			
			menu_icons_size = 0.8,
			plugins_grow_direction = 1,
			
			instancebutton_config = {size = {20, 16}, anchor = {5, 0}, textcolor = {.8, .6, .0, 0.8}, textsize = 10, textfont = "Friz Quadrata TT", highlight_texture = [[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]]},
			resetbutton_config = {size = {8, 16}, anchor = {1, 0}},
			closebutton_config = {size = {17, 17}},
			
			show_sidebars = false,
			show_statusbar = false,
			color = {.3, .3, .3, 1},
			bg_alpha = 0.2,
			
			row_info = {
				texture = "Blizzard Character Skills Bar",
				font_face = "Arial Narrow",
			},
			attribute_text = {enabled = true, side = 1, text_size = 11, anchor = {-18, 3}, text_color = {1, 1, 1, 1}, text_face = "Arial Narrow"},			
		},
		
		callback = function (skin, instance, just_updating)
			--none
		end,
		
	})

	_detalhes:InstallSkin ("Flat Color", {
		file = [[Interface\AddOns\Details\images\skins\flat_skin]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "a simple skin with opaque colors.", 
		
		micro_frames = {color = {1, 1, 1, 1}, font = "Friz Quadrata TT", size = 10, left = "DETAILS_STATUSBAR_PLUGIN_PATTRIBUTE"},
		
		can_change_alpha_head = true, 
		
		icon_anchor_main = {-1, -5}, 
		icon_anchor_plugins = {-7, -13}, 
		icon_plugins_size = {19, 18},
		
		-- the four anchors:
		icon_point_anchor = {-37, 0},
		left_corner_anchor = {-107, 0},
		right_corner_anchor = {96, 0},

		icon_point_anchor_bottom = {-37, 12},
		left_corner_anchor_bottom = {-107, 0},
		right_corner_anchor_bottom = {96, 0},
		
		instance_cprops = {
		
			row_info = {
				textL_outline = false,
				textR_outline = false,
				texture = "Blizzard Character Skills Bar",
				texture_background = "Details Serenity",
				texture_background_class_color = false,
				fixed_texture_background_color = {0, 0, 0, .2},
			},
		
			menu_anchor = {2, -2, side = 1},
			menu_anchor_down = {2, -4},
			menu2_anchor = {32, 2},
			menu2_anchor_down = {32, 2},
		
			instancebutton_config = {size = {20, 16}, anchor = {5, 1}, textcolor = {.9, .9, .9, 1}, textsize = 10, textfont = "Friz Quadrata TT", highlight_texture = [[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]]},
			resetbutton_config = {size = {8, 16}, anchor = {1, -1}},
		
			bg_alpha = 0.3,
		
		}
	})
	
	-- 0.00048828125
	--reset 19 514 83 530
	--close 
	
	_detalhes:InstallSkin ("Simply Gray", {
		file = [[Interface\AddOns\Details\images\skins\simplygray_skin]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "skin with uniform gray color.", 
		
		--general
		can_change_alpha_head = true, 

		--icon anchors
		icon_anchor_main = {-1, -5},
		icon_anchor_plugins = {-7, -13},
		icon_plugins_size = {19, 18},
		
		--micro frames
		micro_frames = {color = {.7, .7, .7, 1}, font = "Arial Narrow", size = 11, left = "DETAILS_STATUSBAR_PLUGIN_PATTRIBUTE"},

		-- the four anchors (for when the toolbar is on the top side)
		icon_point_anchor = {-37, 0},
		left_corner_anchor = {-107, 0},
		right_corner_anchor = {96, 0},
		
		-- the four anchors (for when the toolbar is on the bottom side)
		icon_point_anchor_bottom = {-37, 12},
		left_corner_anchor_bottom = {-107, 0},
		right_corner_anchor_bottom = {96, 0},

		--[[ callback function execute after all changes on the window, first argument is this skin table, second is the instance where the skin was applied --]]
		callback = function (self, instance) end,
		--[[ control_script is a OnUpdate script, it start right after all changes on the window and also after the callback --]]
		--[[ control_script_on_start run before the control_script, use it to reset values if needed --]]
		control_script_on_start = nil,
		control_script = nil,
		
		--instance overwrites
		--[[ when a skin is selected, all customized properties of the window is reseted and then the overwrites are applied]]
		--[[ for the complete cprop list see the file classe_instancia_include.lua]]
		instance_cprops = {
			row_info = {
				textL_outline = true,
				textR_outline = true,
				texture = "Details Serenity",
				icon_file = [[Interface\AddOns\Details\images\classes_small_alpha]],
				start_after_icon = false,
				texture_background = "Details Serenity",
				texture_background_class_color = false,
				fixed_texture_background_color = {0, 0, 0, .2},
			},

			instancebutton_config = {size = {20, 16}, anchor = {5, 0}, textcolor = {.7, .7, .7, 1}, textsize = 10, textfont = "Friz Quadrata TT", highlight_texture = [[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]]},
			resetbutton_config = {size = {8, 16}, anchor = {1, 0}},
			closebutton_config = {size = {22, 22}},
			
			menu_anchor = {-19, -1, side = 1},
			menu_anchor_down = {-58, 0},
			menu2_anchor = {32, 5},
			menu2_anchor_down = {32, 2},
			
			hide_icon = true,
			bg_alpha = 0.3,
			wallpaper = {
				enabled = true,
				width = 244.0000362689358,
				height = 96.00000674770899,
				texcoord = {0.001000000014901161, 0.3424842834472656, 1, 0.5739999771118164},
				overlay = {0, 0, 0, 0.498038113117218},
				anchor = "all",
				alpha = 0.4980392451398075,
				texture = "Interface\\Glues\\CREDITS\\Fellwood5",
			},
		}
		
	})
	
	--[[
	
	--> install default skins:
	_detalhes:InstallSkin ("Imperial Skin", {
		file = "Interface\\AddOns\\Details\\images\\skins\\imperial_skin", 
		author = "Details!", 
		version = "1.1", 
		site = "unknown", 
		desc = "default skin for Details!", 
		
		can_change_alpha_head = true, 
		icon_anchor_main = {-1, -5}, 
		icon_anchor_plugins = {-7, -13}, 
		icon_plugins_size = {19, 18},
		
		-- the four anchors:
		icon_point_anchor = {-37, 0},
		left_corner_anchor = {-107, 0},
		close_button_anchor = {5, -7},
		right_corner_anchor = {96, 0},

		icon_point_anchor_bottom = {-37, 0},
		left_corner_anchor_bottom = {-107, 0},
		close_button_anchor_bottom = {5, 6},
		right_corner_anchor_bottom = {96, 0},
		
		instance_cprops = {
			menu_anchor = {5, 1},
			hide_icon = true,
		},
		
		--> control scripts for aninations
		--> on skin change we need create the widgets
		control_script_on_start = function (skin, instance)
			
			if (not instance.baseframe.imperial_skin_texture1) then
				local texture1 = instance.baseframe:CreateTexture (nil, "artwork")
				texture1:SetTexture ("Interface\\AddOns\\Details\\images\\skins\\imperial_skin")
				texture1:SetTexCoord (0, 0.99951171875, 0.61474609375, 0.63623046875)
				texture1:SetHeight (17)
				instance.baseframe.imperial_skin_texture1 = texture1
				texture1:SetPoint ("bottomleft", instance.baseframe.cabecalho.ball, "bottomleft", 108, 1)
				texture1:SetPoint ("bottomright", instance.baseframe.cabecalho.ball_r, "bottomright", -98, 1)
			end
			
			--> custom parameters for animations
			instance.imperial_skin_tick_time = 2
			instance.imperial_skin_tick_elapsed = 0
			instance.imperial_skin_texture_step = 0
			
			if (instance.hide_icon) then
				instance.baseframe.cabecalho.ball:SetDrawLayer ("background")
			else
				instance.baseframe.cabecalho.ball:SetDrawLayer ("overlay")
			end
			
		end,
		
		--> do the animation
		control_script = function (frame, elapsed) 
		
			--frame.instance = instance where this skin is applied.
			--frame.skin = this skin table.
		
			frame.instance.imperial_skin_tick_elapsed = frame.instance.imperial_skin_tick_elapsed + elapsed

			if (frame.instance.imperial_skin_tick_elapsed > frame.instance.imperial_skin_tick_time) then
				
				frame.instance.imperial_skin_tick_elapsed = 0
				local step = frame.instance.imperial_skin_texture_step
				step = step + 1

				local firstpoint = step * 0.00048828125
				local secondpoint = (firstpoint + 0.99951171875) - 1
				
				--print (math.floor (step/2))
				
				frame.instance.baseframe.imperial_skin_texture1:SetTexCoord (firstpoint, secondpoint, 0.61474609375, 0.63623046875)
				
				if (step == 2047) then
					step = 0
				end
				
				frame.instance.imperial_skin_texture_step = step
				
				--> this is bad, we need a event handler on options panel for sending appearance changes events
				if (frame.instance.hide_icon) then
					frame.instance.baseframe.cabecalho.ball:SetDrawLayer ("background")
				else
					frame.instance.baseframe.cabecalho.ball:SetDrawLayer ("overlay")
				end
				if (frame.instance.toolbar_side == 1) then
					frame.instance.baseframe.imperial_skin_texture1:SetPoint ("bottomleft", frame.instance.baseframe.cabecalho.ball, "bottomleft", 108, 1)
					frame.instance.baseframe.imperial_skin_texture1:SetPoint ("bottomright", frame.instance.baseframe.cabecalho.ball_r, "bottomright", -98, 1)
				else
					frame.instance.baseframe.imperial_skin_texture1:SetPoint ("bottomleft", frame.instance.baseframe.cabecalho.ball, "bottomleft", 108, 106)
					frame.instance.baseframe.imperial_skin_texture1:SetPoint ("bottomright", frame.instance.baseframe.cabecalho.ball_r, "bottomright", -98, 106)
				end

			end
		
		end,
		
	})
	--]]
	
	--[[
	local f = CreateFrame ("frame",nil, UIParent)
	f:SetPoint ("center", UIParent, "center")
	f:SetSize (200, 200)
	local t = f:CreateTexture (nil, "overlay")
	t:SetPoint ("center", f, "center")
	t:SetSize (200, 200)
	t:SetTexture ("Interface\ARCHEOLOGY\ARCH-RACE-ORC")
	
	local t2 = f:CreateTexture (nil, "overlay")
	t2:SetPoint ("center", f, "center")
	t2:SetSize (200, 200)
	t2:SetTexture ("Interface\ARCHEOLOGY\ARCH-RACE-ORC")
	
	t:SetTexCoord (.4, 1, 0, 1)
	t2:SetTexCoord (0, .4, 0, 1)
	--]]
	
	local align_right_chat = function()
	
		if (not RightChatPanel or not RightChatPanel:IsShown()) then
			_detalhes:Msg ("Right Chat Panel isn't shown.")
			return
		end
		
		local wight, height = RightChatPanel:GetSize()
	
		local instance1 = _detalhes.tabela_instancias [1]
		local instance2 = _detalhes.tabela_instancias [2]
		if (not instance2) then
			instance2 = _detalhes:CriarInstancia()
			instance2:ChangeSkin ("ElvUI Frame Style")
		elseif (not instance2.ativa) then
			instance2:AtivarInstancia()
			instance2:ChangeSkin ("ElvUI Frame Style")
		end
	
		instance1.baseframe:ClearAllPoints()
		instance2.baseframe:ClearAllPoints()

		instance1.baseframe:SetSize (wight/2 - 4, height-20-21-8)
		instance2.baseframe:SetSize (wight/2 - 4, height-20-21-8)
		
		instance1.baseframe:SetPoint ("bottomleft", RightChatDataPanel, "topleft", 1, 1)
		instance2.baseframe:SetPoint ("bottomright", RightChatToggleButton, "topright", -1, 1)
	
		instance1:SaveMainWindowPosition()
		instance2:SaveMainWindowPosition()
	
	end
	

	
	_detalhes:InstallSkin ("ElvUI Frame Style", {
		file = [[Interface\AddOns\Details\images\skins\elvui]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "skin based on ElvUI addon.", 
		
		--general
		can_change_alpha_head = true, 

		--icon anchors
		icon_anchor_main = {-4, -5},
		icon_anchor_plugins = {-7, -13},
		icon_plugins_size = {19, 18},
		
		--micro frames
		micro_frames = {color = {0.525490, 0.525490, 0.525490, 1}, font = "Arial Narrow", size = 11},
		
		-- the four anchors (for when the toolbar is on the top side)
		icon_point_anchor = {-35, -0.5},
		left_corner_anchor = {-107, 0},
		right_corner_anchor = {96, 0},
		
		-- the four anchors (for when the toolbar is on the bottom side)
		icon_point_anchor_bottom = {-37, 12},
		left_corner_anchor_bottom = {-107, 0},
		right_corner_anchor_bottom = {96, 0},

		--[[ callback function execute after all changes on the window, first argument is this skin table, second is the instance where the skin was applied --]]
		callback = function (self, instance) end,
		--[[ control_script is a OnUpdate script, it start right after all changes on the window and also after the callback --]]
		--[[ control_script_on_start run before the control_script, use it to reset values if needed --]]
		control_script_on_start = nil,
		control_script = nil,
		
		--instance overwrites
		--[[ when a skin is selected, all customized properties of the window is reseted and then the overwrites are applied]]
		--[[ for the complete cprop list see the file classe_instancia_include.lua]]
		instance_cprops = {

			instancebutton_config = {size = {20, 16}, anchor = {5, 0}, textcolor = {.7, .7, .7, 1}, textsize = 10, textfont = "Friz Quadrata TT", highlight_texture = [[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]]},
			resetbutton_config = {size = {8, 16}, anchor = {1, 0}},
			closebutton_config = {size = {17, 17}},

			menu_icons_size = 0.85,
			menu_anchor = {-58, 0, side = 2},
			menu_anchor_down = {-58, 0},
			menu2_anchor = {32, 2},
			menu2_anchor_down = {32, 2},
			plugins_grow_direction = 1,
			
			attribute_text = {enabled = true, anchor = {-20, 4}, text_face = "Friz Quadrata TT", text_size = 10, text_color = {1, 1, 1, .7}, side = 1, shadow = true},
			
			hide_icon = true,
			desaturated_menu = true,
			desaturated_menu2 = true,
			
			bg_alpha = 0.51,
			bg_r = 0.3294,
			bg_g = 0.3294,
			bg_b = 0.3294,
			show_statusbar = false,
			
			row_info = {
					texture = "Details Serenity",
					texture_class_colors = true, 
					alpha = 1, 
					texture_background_class_color = false,
					texture_background = "Details D'ictum",
					fixed_texture_color = {0, 0, 0},
					fixed_texture_background_color = {0, 0, 0, 0.471},
					space = {left = 1, right = -2, between = 1},
					backdrop = {enabled = true, size = 4, color = {0, 0, 0, 1}, texture = "Details BarBorder 2"}
			},
			wallpaper = {
				overlay = {0, 0,	0},
				width = 227.1267691385938,
				texcoord = {0.001000000014901161, 0.1710000038146973, 0.001000000014901161, 0.3539316177368164},
				enabled = true,
				anchor = "all",
				height = 89.00001440917025,
				alpha = 0.8,
				texture = "Interface\\Glues\\CREDITS\\Badlands3",
			}
		},
		
		skin_options = {
			{type = "button", label = "", text = "Align Within Right Chat", func = align_right_chat, desc = "Move and resize the windows #1 and #2 placing over the right chat window.\nThis process doesn't lock nor snap the two windows."}
		}
	})
	
	--alpha = 0.4980392451398075,
	