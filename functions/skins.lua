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
		close_button_anchor = {5, -7},
		right_corner_anchor = {96, 0},

		icon_point_anchor_bottom = {-37, 0},
		left_corner_anchor_bottom = {-107, 0},
		close_button_anchor_bottom = {5, 6},
		right_corner_anchor_bottom = {96, 0},
		
		instance_cprops = {
			menu_anchor = {5, 1},
			plugins_grow_direction = 2,
		}
		
	})

	_detalhes:InstallSkin ("Minimalistic", {
		file = [[Interface\AddOns\Details\images\skins\classic_skin]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "classic skin", 
		
		micro_frames = {color = {1, 1, 1, 1}, font = "Friz Quadrata TT", size = 10},
		
		can_change_alpha_head = true, 
		icon_anchor_main = {-1, -5}, 
		icon_anchor_plugins = {-7, -13}, 
		icon_plugins_size = {19, 18},
		
		-- the four anchors:
		icon_point_anchor = {-37, 0},
		left_corner_anchor = {-107, 0},
		close_button_anchor = {4, -3},
		right_corner_anchor = {96, 0},

		icon_point_anchor_bottom = {-37, 12},
		left_corner_anchor_bottom = {-107, 0},
		close_button_anchor_bottom = {5, 3},
		right_corner_anchor_bottom = {96, 0},
		
		close_button_size = {24, 24},
		
		--reset button
		reset_button_coords = {0.01904296875, 0.0673828125, 0.50244140625, 0.51708984375},
		reset_button_small_coords = {0.11669921875, 0.13720703125, 0.50244140625, 0.51708984375},
		
		--instance button
		instance_button_coords = {0.01904296875, 0.04736328125, 0.48388671875, 0.49853515625},
		
		--overwrites
		instance_cprops = {
			hide_icon = true,
			menu_anchor = {-81, 1, side = 2},
			instance_button_anchor = {-12, 3},
			instancebutton_info = {text_color = {.8, .6, .0, 0.8}, text_face = "Friz Quadrata TT", text_size = 10, color_overlay = {1, 1, 1, 1}},
			resetbutton_info = {text_color = {.8, .8, .8, 0.8}, text_color_small = {0, 0, 0, 0}, text_face = "Friz Quadrata TT", text_size = 12, color_overlay = {1, 1, 1, 1}, always_small = true},
			show_sidebars = false,
			show_statusbar = false,
			color = {.3, .3, .3, 1},
			bg_alpha = 0.2,
			plugins_grow_direction = 1,
			row_info = {
				texture = "Blizzard Character Skills Bar",
				font_face = "Arial Narrow",
			},
			attribute_text = {enabled = true, side = 1, text_size = 12, anchor = {-18, 4}, text_color = {1, 1, 1, 1}, text_face = "Arial Narrow"},			
		},
		
		callback = function (skin)
			DetailsResetButton2Text2:SetText ("")
		end,
		
	})
	
	_detalhes:InstallSkin ("Flat Color", {
		file = [[Interface\AddOns\Details\images\skins\flat_skin]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "a flat skin", 
		
		micro_frames = {color = {1, 1, 1, 1}, font = "Friz Quadrata TT", size = 10},
		
		can_change_alpha_head = true, 
		icon_anchor_main = {-1, -5}, 
		icon_anchor_plugins = {-7, -13}, 
		icon_plugins_size = {19, 18},
		
		-- the four anchors:
		icon_point_anchor = {-37, 0},
		left_corner_anchor = {-107, 0},
		close_button_anchor = {5, -6},
		right_corner_anchor = {96, 0},

		icon_point_anchor_bottom = {-37, 12},
		left_corner_anchor_bottom = {-107, 0},
		close_button_anchor_bottom = {5, 6},
		right_corner_anchor_bottom = {96, 0},
		
		close_button_size = {32, 32},
		
	})
	
	-- 0.00048828125
	--reset 19 514 83 530
	--close 
	
	_detalhes:InstallSkin ("Simply Gray", {
		file = [[Interface\AddOns\Details\images\skins\simplygray_skin]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "a flat skin", 
		
		--general
		can_change_alpha_head = true, 

		--icon anchors
		icon_anchor_main = {-1, -5},
		icon_anchor_plugins = {-7, -13},
		icon_plugins_size = {19, 18},
		
		--micro frames
		micro_frames = {color = {.7, .7, .7, 1}, font = "Arial Narrow", size = 11},
		
		--reset button
		reset_button_coords = {0.01904296875, 0.0673828125, 0.50244140625, 0.51708984375},
		reset_button_small_coords = {0.11669921875, 0.13720703125, 0.50244140625, 0.51708984375},
		
		--instance button
		instance_button_coords = {0.01904296875, 0.04736328125, 0.48388671875, 0.49853515625},
		
		--close button
		close_button_coords = {0.01904296875, 0.03369140625, 0.52197265625, 0.53662109375},
		close_button_size = {18, 18},
		
		-- the four anchors (for when the toolbar is on the top side)
		icon_point_anchor = {-37, 0},
		left_corner_anchor = {-107, 0},
		close_button_anchor = {-2, 0},
		right_corner_anchor = {96, 0},
		
		-- the four anchors (for when the toolbar is on the bottom side)
		icon_point_anchor_bottom = {-37, 12},
		left_corner_anchor_bottom = {-107, 0},
		close_button_anchor_bottom = {-2, 0},
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
			resetbutton_info = {text_color = {0.7, 0.7, 0.7, 1}, text_face = "Friz Quadrata TT", text_size = 12, color_overlay = {1, 1, 1, 1}},
			instancebutton_info = {text_color = {.7, .7, .7, 1}, text_face = "Friz Quadrata TT", text_size = 12, color_overlay = {1, 1, 1, 1}},
			menu_anchor = {-18, 1},
			instance_button_anchor = {-27, 3},
			hide_icon = true,
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
	
	
	_detalhes:InstallSkin ("ElvUI Frame Style", {
		file = [[Interface\AddOns\Details\images\skins\elvui]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "a flat skin", 
		
		--general
		can_change_alpha_head = true, 

		--icon anchors
		icon_anchor_main = {-1, -5},
		icon_anchor_plugins = {-7, -13},
		icon_plugins_size = {19, 18},
		
		--micro frames
		micro_frames = {color = {.7, .7, .7, 1}, font = "Arial Narrow", size = 11},
		
		--reset button
		reset_button_coords = {0.01904296875, 0.0673828125, 0.50244140625, 0.51708984375},
		--reset_button_small_coords = {0.11669921875, 0.13720703125, 0.50244140625, 0.51708984375},
		reset_button_small_coords = {0.1162109375, 0.13671875, 0.50390625, 0.5146484375+0.00048828125+0.00048828125}, -- 119 516 140 527
		reset_button_small_size = {22, 12},
		--instance button
		--instance_button_coords = {0.01904296875, 0.04736328125, 0.48388671875, 0.49853515625},
		instance_button_coords = {0.0185546875, 0.046875+0.00048828125, 0.4833984375, 0.498046875+0.00048828125},--19 495 48 510
		instance_button_size = 12,
		--0.00048828125
		
		--close button
		close_button_coords = {0.01904296875, 0.03369140625, 0.52197265625, 0.53662109375},
		close_button_size = {18, 18},
		
		-- the four anchors (for when the toolbar is on the top side)
		icon_point_anchor = {-35, -0.5},
		left_corner_anchor = {-107, 0},
		close_button_anchor = {-2, 0},
		right_corner_anchor = {96, 0},
		
		-- the four anchors (for when the toolbar is on the bottom side)
		icon_point_anchor_bottom = {-37, 12},
		left_corner_anchor_bottom = {-107, 0},
		close_button_anchor_bottom = {-2, 0},
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
			resetbutton_info = {text_color = {0.7, 0.7, 0.7, 1}, text_color_small = {0, 0, 0, 0}, text_face = "Friz Quadrata TT", text_size = 12, color_overlay = {1, 1, 1, 1}},
			instancebutton_info = {text_color = {.7, .7, .7, 1}, text_face = "Friz Quadrata TT", text_size = 12, color_overlay = {1, 1, 1, 1}},
			menu_anchor = {-20, 1},
			instance_button_anchor = {-27, 3},
			hide_icon = true,
			desaturated_menu = true,
			bg_alpha = 0.3,
			row_info = {
					texture = "Details Serenity",
					texture_class_colors = true, 
					alpha = 1, 
					texture_background_class_color = false,
					texture_background = "Details D'ictum",
					fixed_texture_color = {0, 0, 0},
					fixed_texture_background_color = {0, 0, 0, 0.471},
					space = {left = 1, right = -2, between = 0},
			},
			wallpaper = {
				overlay = {0, 0,	0},
				width = 227.1267691385938,
				texcoord = {0.001000000014901161, 0.1710000038146973, 0.001000000014901161, 0.3539316177368164},
				enabled = true,
				anchor = "all",
				height = 89.00001440917025,
				alpha = 0.6,
				texture = "Interface\\Glues\\CREDITS\\Badlands3",
			}
		}
	})
	
	--alpha = 0.4980392451398075,
	