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
		close_button_anchor = {5, -6},
		right_corner_anchor = {96, 0},

		icon_point_anchor_bottom = {-37, 0},
		left_corner_anchor_bottom = {-107, 0},
		close_button_anchor_bottom = {5, 6},
		right_corner_anchor_bottom = {96, 0},
		
		instance_cprops = {
			menu_anchor = {5, 1},
		}
		
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

		--instance overwrites
		--[[ when a skin is selected, all customized properties of the window is reseted and then the overwrites are applied]]
		--[[ for the complete cprop list see the file classe_instancia_include.lua]]
		instance_cprops = {
			resetbutton_info = {text_color = {0.7, 0.7, 0.7, 1}, text_face = "Friz Quadrata TT", text_size = 12, color_overlay = {.5, .5, .5, 1}},
			instancebutton_info = {text_color = {.7, .7, .7, 1}, text_face = "Friz Quadrata TT", text_size = 12, color_overlay = {.5, .5, .5, 1}},
			menu_anchor = {-18, 1},
			instance_button_anchor = {-27, 3},
			hide_icon = true,
		}
		
	})
	