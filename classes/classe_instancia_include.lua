
local _detalhes = 		_G._detalhes
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

function _detalhes:ResetInstanceConfig()
	for key, value in pairs (table_deepcopy (_detalhes.instance_defaults)) do 
		self [key] = value
	end
end

function _detalhes:LoadInstanceConfig()
	for key, value in pairs (_detalhes.instance_defaults) do 
		if (self [key] == nil) then
			if (type (value) == "table") then
				self [key] = table_deepcopy (_detalhes.instance_defaults [key])
			else
				self [key] = value
			end
		end
	end
end

_detalhes.instance_defaults = {

	--skin
		skin = "Default Skin",
	--baseframe backdrop color
		bg_alpha = 0.7,
		bg_r = 0.0941,
		bg_g = 0.0941,
		bg_b = 0.0941,
	--auto current
		auto_current = true,
	--show sidebars
		show_sidebars = true,
	--show bottom statusbar
		show_statusbar = true,
	--blackwhiite icons
		desaturated_menu = false,
	--hide main window attribute icon
		hide_icon = false,
	--anchor side of main window toolbar (1 = top 2 = bottom)
		toolbar_side = 1,
	--stretch button anchor side (1 = top 2 = bottom)
		stretch_button_side = 1,
	--where plugins icon will be placed on main window toolbar (1 = left 2 = right)
		plugins_grow_direction = 2,
	--grow direction of main window bars (1 = top to bottom 2 = bottom to top)
		bars_grow_direction = 1,
	--sort direction is the direction of results on bars (1 = top to bottom 2 = bottom to top)
		bars_sort_direction = 1,
	--reset button info
		resetbutton_info = {text_color = {1, 0.82, 0, 1}, text_face = "Friz Quadrata TT", text_size = 12, color_overlay = {1, 1, 1, 1}, always_small = false},
	--instance button info
		instancebutton_info = {text_color = {1, 0.82, 0, 1}, text_face = "Friz Quadrata TT", text_size = 12, color_overlay = {1, 1, 1, 1}},
	--close button info
		closebutton_info = {color_overlay = {1, 1, 1, 1}},
	--menu anchor store the anchor point of main menu
		menu_anchor = {5, 1},
	--instance button anchor store the anchor point of instance and delete button
		instance_button_anchor = {-27, 1},
	--row info
		row_info = {
			--if true the texture of the bars will have the color of his actor class
				texture_class_colors = true,
			--if texture class color are false, this color will be used
				fixed_texture_color = {0, 0, 0},
			--left text class color
				textL_class_colors = false,
			--right text class color
				textR_class_colors = false,
			--if text class color are false, this color will be used
				fixed_text_color = {1, 1, 1},
			--left text outline effect
				textL_outline = true,
			--right text outline effect
				textR_outline = false,
			--bar height
				height = 14,
			--font size
				font_size = 10,
			--font face (name)
				font_face = "Arial Narrow",
			--font face (file)
				font_face_file = SharedMedia:Fetch ("font", "Arial Narrow"),
			--bar texture
				texture = "Details D'ictum",
			--bar texture name
				texture_file = [[Interface\AddOns\Details\images\bar4]],
			--bar texture on mouse over
				texture_highlight = [[Interface\FriendsFrame\UI-FriendsList-Highlight]],
			--bar background texture
				texture_background = "Details D'ictum",
			--bar background file
				texture_background_file = [[Interface\AddOns\Details\images\bar4]],
			--bar background class color
				texture_background_class_color = true,
			--fixed texture color for background texture
				fixed_texture_background_color = {0, 0, 0, 0},
			--space between bars
				space = {left = 3, right = -5, between = 1}
				
		},
	--instance window color
		color = {1, 1, 1, 1},
	--hide in combat
		hide_in_combat = false,
		hide_in_combat_alpha = 0,
	--wallpaper
		wallpaper = {
			enabled = false,
			texture = nil,
			anchor = "all",
			alpha = 0.5,
			texcoord = {0, 1, 0, 1},
			width = 0,
			height = 0,
			overlay = {1, 1, 1, 1}
		},
	--tooltip amounts
	tooltip = {
			["n_abilities"] = 3, 
			["n_enemies"] = 3
		}
}