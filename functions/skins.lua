--File Revision: 1
--Last Modification: 05/12/07/2013
-- Change Log:
	-- 05/12/07/2013: This file has been introduced.


local _detalhes = _G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
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
	
	local reset_tooltip = function()
		_detalhes:SetTooltipBackdrop ("Blizzard Tooltip", 16, {1, 1, 1, 1})
		_detalhes:DelayOptionsRefresh()
	end
	local set_tooltip_elvui1 = function()
		_detalhes:SetTooltipBackdrop ("Blizzard Tooltip", 16, {0, 0, 0, 1})
		_detalhes:DelayOptionsRefresh()
	end
	local set_tooltip_elvui2 = function()
		_detalhes:SetTooltipBackdrop ("Blizzard Tooltip", 16, {1, 1, 1, 0})
		_detalhes:DelayOptionsRefresh()
	end
	
	--> install wow interface skin:
	_detalhes:InstallSkin ("WoW Interface", {
		file = [[Interface\AddOns\Details\images\skins\default_skin]], 
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "This was the first skin made for Details!, inspired in the standard wow interface", 
		
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
		
		micro_frames = {left = "DETAILS_STATUSBAR_PLUGIN_THREAT"},
		
		instance_cprops = {
			["hide_in_combat_type"] = 1,
			["color"] = {
				1,
				1,
				1,
				1,
			},
			["menu_anchor"] = {
				13,
				2,
				["side"] = 2,
			},
			["bg_r"] = 0.0941,
			["color_buttons"] = {
				1,
				1,
				1,
				1,
			},
			["bars_sort_direction"] = 1,
			["attribute_text"] = {
				["enabled"] = true,
				["shadow"] = false,
				["side"] = 1,
				["text_size"] = 10,
				["anchor"] = {
					5,
					3,
				},
				["text_color"] = {
					0.823529411764706,
					0.549019607843137,
					0,
					1,
				},
				["text_face"] = "Friz Quadrata TT",
			},
			["menu_alpha"] = {
				["enabled"] = false,
				["onenter"] = 1,
				["iconstoo"] = true,
				["ignorebars"] = false,
				["onleave"] = 1,
			},
			["total_bar"] = {
				["enabled"] = false,
				["only_in_group"] = true,
				["icon"] = "Interface\\ICONS\\INV_Sigil_Thorim",
				["color"] = {
					1,
					1,
					1,
				},
			},
			["hide_out_of_combat"] = false,
			["strata"] = "LOW",
			["micro_displays_side"] = 2,
			["row_show_animation"] = {
				["anim"] = "Fade",
				["options"] = {
				},
			},
			["hide_in_combat_alpha"] = 0,
			["plugins_grow_direction"] = 1,
			["menu_icons"] = {
				true,
				true,
				true,
				true,
				true, -- [5]
				true, -- [6]
			},
			["desaturated_menu"] = false,
			["show_sidebars"] = true,
			["statusbar_info"] = {
				["alpha"] = 1,
				["overlay"] = {
					1,
					1,
					1,
				},
			},
			["window_scale"] = 1,
			["auto_hide_menu"] = {
				["left"] = false,
				["right"] = false,
			},
			["grab_on_top"] = false,
			["hide_icon"] = false,
			["row_info"] = {
				["textR_outline"] = false,
				["textL_outline"] = true,
				["icon_file"] = "Interface\\AddOns\\Details\\images\\classes_small",
				["fixed_texture_color"] = {
					0,
					0,
					0,
				},
				["texture_background_file"] = "Interface\\AddOns\\Details\\images\\bar4",
				["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
				["textR_enable_custom_text"] = false,
				["texture_background_class_color"] = false,
				["textL_enable_custom_text"] = false,
				["textL_show_number"] = true,
				["space"] = {
					["right"] = -5,
					["left"] = 3,
					["between"] = 2,
				},
				["fixed_texture_background_color"] = {
					0.619607,
					0.619607,
					0.619607,
					0.116164,
				},
				["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
				["start_after_icon"] = true,
				["font_face_file"] = "Fonts\\ARIALN.TTF",
				["fixed_text_color"] = {
					1,
					1,
					1,
				},
				["backdrop"] = {
					["enabled"] = false,
					["size"] = 6,
					["color"] = {
						0,
						0,
						0,
						0.305214,
					},
					["texture"] = "Details BarBorder 2",
				},
				["textL_class_colors"] = false,
				["textL_custom_text"] = "{data1}. {data3}{data2}",
				["textR_class_colors"] = false,
				["alpha"] = 1,
				["no_icon"] = false,
				["font_size"] = 10,
				["texture_background"] = "Details Serenity",
				["font_face"] = "Arial Narrow",
				["texture_class_colors"] = true,
				["height"] = 14,
				["texture_file"] = "Interface\\AddOns\\Details\\images\\bar4",
				["texture"] = "Details Serenity",
				["percent_type"] = 1,
			},
			["menu_anchor_down"] = {
				["side"] = 2,
				-14,
				-3,
			},
			["toolbar_side"] = 1,
			["bg_g"] = 0.0941,
			["bars_grow_direction"] = 1,
			["hide_in_combat"] = false,
			["backdrop_texture"] = "Details Ground",
			["show_statusbar"] = true,
			["menu_icons_size"] = 1,
			["stretch_button_side"] = 1,
			["bg_alpha"] = 0.699999988079071,
			["bg_b"] = 0.0941,
		},
		
		skin_options = {
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_RESET_TOOLTIP"], func = reset_tooltip, desc = Loc ["STRING_OPTIONS_SKIN_RESET_TOOLTIP_DESC"]},
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3"], func = set_tooltip_elvui2, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3_DESC"]},
		}
	})

	_detalhes:InstallSkin ("Minimalistic", {
		file = [[Interface\AddOns\Details\images\skins\classic_skin_v1]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "Simple skin with soft gray color and half transparent frames.", --\n
		
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
			
			menu_icons_size = 0.85,
			menu_anchor = {16, 1, side = 2},
			menu_anchor_down = {16, -2},
			
			["menu_icons"] = {true, true, true, true, true, true, ["shadow"] = true, ["space"] = -3},
			
			plugins_grow_direction = 1,
			
			show_sidebars = false,
			show_statusbar = false,
			color = {.3, .3, .3, 0.80},
			bg_alpha = 0.2,
			
			row_info = {
				texture = "BantoBar", --"Details Serenity"
				font_face = "Accidental Presidency",
				texture_background_class_color = false,
				texture_background = "Details Serenity",
				font_size = 11,
				fixed_texture_background_color = {0, 0, 0, 0.3186},
				icon_file = [[Interface\AddOns\Details\images\classes_small_alpha]],
				start_after_icon = false,
			},
			attribute_text = {enabled = true, side = 1, text_size = 11, anchor = {-18, 5}, text_color = {1, 1, 1, 1}, text_face = "Arial Narrow"},			
		},
		
		callback = function (skin, instance, just_updating)
			--none
		end,
		
		skin_options = {
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_RESET_TOOLTIP"], func = reset_tooltip, desc = Loc ["STRING_OPTIONS_SKIN_RESET_TOOLTIP_DESC"]},
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3"], func = set_tooltip_elvui2, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3_DESC"]},
		}
		
	})
	
	_detalhes:InstallSkin ("Minimalistic v2", {
		file = [[Interface\AddOns\Details\images\skins\classic_skin]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "Same as the first Minimalistic, but this one is more darker and less transparent.", 
		
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
			
			menu_icons_size = 0.90,
			menu_anchor = {16, 2, side = 2},
			menu_anchor_down = {16, -2},
			
			plugins_grow_direction = 1,
			
			show_sidebars = false,
			show_statusbar = false,
			color = {0.3058, 0.3058, 0.3058, 0.8838}, --0.9350
			bg_alpha = 0.3181, --0.4399
			
			row_info = {
				texture = "BantoBar", --"Details Serenity"
				font_face = "Arial Narrow",
				texture_background_class_color = false,
				texture_background = "Details Serenity",
				fixed_texture_background_color = {0, 0, 0, 0.3186},
				icon_file = [[Interface\AddOns\Details\images\classes_small_alpha]],
				start_after_icon = false,
			},
			attribute_text = {enabled = true, side = 1, text_size = 11, anchor = {-18, 5}, text_color = {1, 1, 1, 1}, text_face = "Arial Narrow"},			
		},
		
		callback = function (skin, instance, just_updating)
			--none
		end,
		
		skin_options = {
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_RESET_TOOLTIP"], func = reset_tooltip, desc = Loc ["STRING_OPTIONS_SKIN_RESET_TOOLTIP_DESC"]},
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3"], func = set_tooltip_elvui2, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3_DESC"]},
		}
		
	})

	local dark_serenity = function()
		local instance = _G.DetailsOptionsWindow.instance
		if (instance) then
			--> black color
			instance:InstanceColor (0, 0, 0, 1)
			--> flip wallpaper
			local wtexc = instance.wallpaper.texcoord
			wtexc[1], wtexc[2], wtexc[3], wtexc[4] = 0.04800000, 0.29800001, 0.75599998, 0.63099998
			--> reload skin
			instance:ChangeSkin()
		end
	end
	
	_detalhes:InstallSkin ("Serenity", {
		file = [[Interface\AddOns\Details\images\skins\flat_skin]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "White with a gradient wallpaper, this skin fits on almost all interfaces.\n\nFor ElvUI interfaces, change the window color to black to get an compatible visual.", 
		
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
			["menu_icons_size"] = 0.899999,
			["color"] = {
				0.294117647058824, -- [1]
				0.505882352941176, -- [2]
				1, -- [3]
				0.919999957084656, -- [4]
			},
			["menu_anchor"] = {
				15, -- [1]
				1, -- [2]
				["side"] = 2,
			},
			["bg_r"] = 0.388235294117647,
			["skin"] = "Serenity",
			["following"] = {
				["enabled"] = false,
				["bar_color"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
				},
				["text_color"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
				},
			},
			["color_buttons"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["bars_sort_direction"] = 1,
			["instance_button_anchor"] = {
				-27, -- [1]
				1, -- [2]
			},
			["attribute_text"] = {
				["enabled"] = true,
				["shadow"] = false,
				["side"] = 1,
				["text_color"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
					0.7, -- [4]
				},
				["custom_text"] = "{name}",
				["text_face"] = "Accidental Presidency",
				["anchor"] = {
					-18, -- [1]
					4, -- [2]
				},
				["enable_custom_text"] = false,
				["text_size"] = 12,
			},
			["menu_alpha"] = {
				["enabled"] = false,
				["onenter"] = 1,
				["iconstoo"] = true,
				["ignorebars"] = false,
				["onleave"] = 1,
			},
			["total_bar"] = {
				["enabled"] = false,
				["only_in_group"] = true,
				["icon"] = "Interface\\ICONS\\INV_Sigil_Thorim",
				["color"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
				},
			},
			["show_sidebars"] = false,
			["strata"] = "LOW",
			["grab_on_top"] = false,
			["bg_alpha"] = 0.0799999982118607,
			["plugins_grow_direction"] = 1,
			["menu_icons"] = {
				true, -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				["space"] = -4,
				["shadow"] = false,
			},
			["auto_hide_menu"] = {
				["left"] = false,
				["right"] = false,
			},
			["menu_anchor_down"] = {
				15, -- [1]
				-3, -- [2]
			},
			["window_scale"] = 1,
			["bars_grow_direction"] = 1,
			["row_info"] = {
				["textR_outline"] = false,
				["textL_outline"] = false,
				["percent_type"] = 1,
				["icon_file"] = "Interface\\AddOns\\Details\\images\\classes_small_alpha",
				["textL_show_number"] = true,
				["texture"] = "Details Serenity",
				["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
				["textR_enable_custom_text"] = false,
				["texture_background_class_color"] = false,
				["textL_enable_custom_text"] = false,
				["fixed_text_color"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
				},
				["space"] = {
					["right"] = 0,
					["left"] = 0,
					["between"] = 0,
				},
				["fixed_texture_background_color"] = {
					0, -- [1]
					0, -- [2]
					0, -- [3]
					0.441646844148636, -- [4]
				},
				["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
				["start_after_icon"] = false,
				["font_face_file"] = "Interface\\Addons\\Details\\fonts\\Accidental Presidency.ttf",
				["backdrop"] = {
					["enabled"] = false,
					["size"] = 1,
					["color"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
						1, -- [4]
					},
					["texture"] = "Details BarBorder 2",
				},
				["textL_class_colors"] = false,
				["font_size"] = 10,
				["textL_custom_text"] = "{data1}. {data3}{data2}",
				["textR_class_colors"] = false,
				["alpha"] = 1,
				["no_icon"] = false,
				["models"] = {
					["upper_model"] = "Spells\\AcidBreath_SuperGreen.M2",
					["lower_model"] = "World\\EXPANSION02\\DOODADS\\Coldarra\\COLDARRALOCUS.m2",
					["upper_alpha"] = 0.5,
					["lower_enabled"] = false,
					["lower_alpha"] = 0.1,
					["upper_enabled"] = false,
				},
				["texture_background"] = "Details D'ictum",
				["font_face"] = "Accidental Presidency",
				["texture_class_colors"] = true,
				["height"] = 15,
				["texture_file"] = "Interface\\AddOns\\Details\\images\\bar_serenity",
				["texture_background_file"] = "Interface\\AddOns\\Details\\images\\bar4",
				["fixed_texture_color"] = {
					0, -- [1]
					0, -- [2]
					0, -- [3]
				},
			},
			["hide_icon"] = true,
			["statusbar_info"] = {
				["alpha"] = 0.919999957084656,
				["overlay"] = {
					0.294117647058824, -- [1]
					0.505882352941176, -- [2]
					1, -- [3]
				},
			},
			["backdrop_texture"] = "Details Ground",
			["auto_current"] = true,
			["toolbar_side"] = 1,
			["bg_g"] = 0.784313725490196,
			["show_statusbar"] = false,
			["wallpaper"] = {
				["enabled"] = false,
				["texture"] = "Interface\\AddOns\\Details\\images\\skins\\elvui",
				["texcoord"] = {
					0.0478515625, -- [1]
					0.2978515625, -- [2]
					0.630859375, -- [3]
					0.755859375, -- [4]
				},
				["overlay"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
				},
				["anchor"] = "all",
				["height"] = 128,
				["alpha"] = 0.8,
				["width"] = 256,
			},
			["stretch_button_side"] = 1,
			["micro_displays_side"] = 2,
			["desaturated_menu"] = false,
			["bg_b"] = 1,
 		},
		
		skin_options = {
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_RESET_TOOLTIP"], func = reset_tooltip, desc = Loc ["STRING_OPTIONS_SKIN_RESET_TOOLTIP_DESC"]},
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3"], func = set_tooltip_elvui2, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3_DESC"]},
			{type = "button", name = "Serenity Dark Side", func = dark_serenity, desc = "Flip the colors showing the dark side of Serenity."},
		}
	})
	
	-- 0.00048828125
	--reset 19 514 83 530
	--close 
	
	_detalhes:InstallSkin ("Forced Square", {
		file = [[Interface\AddOns\Details\images\skins\simplygray_skin]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "Very clean skin without textures and only with a black contour.", 
		
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
			["hide_in_combat_type"] = 1,
			["color"] = {
				0,
				0,
				0,
				1,
			},
			["menu_anchor"] = {
				14,
				2,
				["side"] = 2,
			},
			["bg_r"] = 0,
			["following"] = {
				["enabled"] = false,
				["bar_color"] = {
					1,
					1,
					1,
				},
				["text_color"] = {
					1,
					1,
					1,
				},
			},
			["color_buttons"] = {
				1,
				1,
				1,
				1,
			},
			["bars_sort_direction"] = 1,
			["instance_button_anchor"] = {
				-27,
				1,
			},
			["name"] = "new simple gray 2",
			["attribute_text"] = {
				["enabled"] = true,
				["shadow"] = true,
				["side"] = 1,
				["text_color"] = {
					0.768627450980392,
					0.768627450980392,
					0.768627450980392,
					1,
				},
				["custom_text"] = "{name}",
				["text_face"] = "FORCED SQUARE",
				["anchor"] = {
					-16,
					5,
				},
				["text_size"] = 12,
				["enable_custom_text"] = false,
			},
			["switch_damager_in_combat"] = false,
			["menu_alpha"] = {
				["enabled"] = false,
				["onleave"] = 1,
				["ignorebars"] = false,
				["iconstoo"] = true,
				["onenter"] = 1,
			},
			["total_bar"] = {
				["enabled"] = false,
				["only_in_group"] = true,
				["icon"] = "Interface\\ICONS\\INV_Sigil_Thorim",
				["color"] = {
					1,
					1,
					1,
				},
			},
			["micro_displays_side"] = 2,
			["plugins_grow_direction"] = 1,
			["menu_icons"] = {
				true,
				true,
				true,
				true,
				true, -- [5]
				true, -- [6]
				["space"] = -4,
				["shadow"] = true,
			},
			["desaturated_menu"] = false,
			["show_sidebars"] = true,
			["statusbar_info"] = {
				["alpha"] = 1,
				["overlay"] = {
					0,
					0,
					0,
				},
			},
			["window_scale"] = 1,
			["auto_hide_menu"] = {
				["left"] = false,
				["right"] = false,
			},
			["hide_icon"] = true,
			["row_info"] = {
				["textR_outline"] = false,
				["textL_outline"] = false,
				["fixed_texture_color"] = {
					0,
					0,
					0,
				},
				["icon_file"] = "Interface\\AddOns\\Details\\images\\classes_small_alpha",
				["textL_show_number"] = true,
				["texture"] = "Skyline",
				["texture_background_file"] = "Interface\\AddOns\\Details\\images\\bar4",
				["textR_enable_custom_text"] = false,
				["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
				["textL_enable_custom_text"] = false,
				["fixed_text_color"] = {
					1,
					1,
					1,
				},
				["space"] = {
					["right"] = -10,
					["left"] = 5,
					["between"] = 1,
				},
				["fixed_texture_background_color"] = {
					0,
					0,
					0,
					0.2,
				},
				["texture_background_class_color"] = false,
				["start_after_icon"] = false,
				["font_face_file"] = "Interface\\Addons\\Details\\fonts\\FORCED SQUARE.ttf",
				["backdrop"] = {
					["enabled"] = false,
					["size"] = 12,
					["color"] = {
						1,
						1,
						1,
						1,
					},
					["texture"] = "Details BarBorder 2",
				},
				["textL_class_colors"] = false,
				["models"] = {
					["upper_model"] = "Spells\\AcidBreath_SuperGreen.M2",
					["lower_model"] = "World\\EXPANSION02\\DOODADS\\Coldarra\\COLDARRALOCUS.m2",
					["upper_alpha"] = 0.5,
					["lower_enabled"] = false,
					["lower_alpha"] = 0.1,
					["upper_enabled"] = false,
				},
				["textL_custom_text"] = "{data1}. {data3}{data2}",
				["textR_class_colors"] = false,
				["alpha"] = 1,
				["no_icon"] = false,
				["font_size"] = 10,
				["texture_background"] = "Details Serenity",
				["font_face"] = "FORCED SQUARE",
				["texture_class_colors"] = true,
				["height"] = 14,
				["texture_file"] = "Interface\\AddOns\\Details\\images\\bar4",
				["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
				["percent_type"] = 1,
			},
			["menu_anchor_down"] = {
				-20,
				-3,
			},
			["toolbar_side"] = 1,
			["bg_g"] = 0,
			["bars_grow_direction"] = 1,
			["backdrop_texture"] = "Details Ground",
			["show_statusbar"] = false,
			["menu_icons_size"] = 0.899999976158142,
			["wallpaper"] = {
				["enabled"] = false,
				["width"] = 265.999943487933,
				["texcoord"] = {
					0.342000007629395,
					0.00100000001490116,
					1,
					0.573999977111816,
				},
				["overlay"] = {
					0,
					0,
					0,
					0.807841360569,
				},
				["anchor"] = "all",
				["height"] = 226.000007591173,
				["alpha"] = 0.807843208312988,
				["texture"] = "Interface\\Glues\\CREDITS\\Fellwood5",
			},
			["bg_alpha"] = 0.0491309501230717,
			["bg_b"] = 0,
		},
		
		skin_options = {
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_RESET_TOOLTIP"], func = reset_tooltip, desc = Loc ["STRING_OPTIONS_SKIN_RESET_TOOLTIP_DESC"]},
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3"], func = set_tooltip_elvui2, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3_DESC"]},
		}
		
	})
	
	--[[
	
	--> install imperial skin:
	_detalhes:InstallSkin ("Imperial Skin", {
		file = "Interface\\AddOns\\Details\\images\\skins\\imperial_skin", 
		author = "Details!", 
		version = "1.1", 
		site = "unknown", 
		desc = "imperial skin for Details!", 
		
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
		local instance3 = _detalhes.tabela_instancias [3]

		if (not instance2) then
			instance2 = _detalhes:CriarInstancia()
			instance2:ChangeSkin (instance1.skin)
		elseif (not instance2.ativa) then
			instance2:AtivarInstancia()
			instance2:ChangeSkin (instance1.skin)
		end
		
		if (instance3) then
			instance3:ShutDown()
		end
	
		instance1:UngroupInstance()
		instance2:UngroupInstance()
	
		instance1.baseframe:ClearAllPoints()
		instance2.baseframe:ClearAllPoints()

		local statusbar_enabled1 = instance1.show_statusbar
		local statusbar_enabled2 = instance2.show_statusbar
		
		_detalhes.move_janela_func (instance1.baseframe, true, instance1)
		_detalhes.move_janela_func (instance1.baseframe, false, instance1)
		_detalhes.move_janela_func (instance2.baseframe, true, instance2)
		_detalhes.move_janela_func (instance2.baseframe, false, instance2)
		
		instance1.baseframe:SetSize (wight/2 - 4, height-20-21-8 - (statusbar_enabled1 and 14 or 0))
		instance2.baseframe:SetSize (wight/2 - 4, height-20-21-8 - (statusbar_enabled2 and 14 or 0))
		
		table.wipe (instance1.snap); table.wipe (instance2.snap)
		instance1.snap [3] = 2; instance2.snap [1] = 1;
		instance1.horizontalSnap = true; instance2.horizontalSnap = true
		
		instance1.baseframe:SetPoint ("bottomleft", RightChatDataPanel, "topleft", 1, 1 + (statusbar_enabled1 and 14 or 0))
		instance2.baseframe:SetPoint ("bottomright", RightChatToggleButton, "topright", -1, 1 + (statusbar_enabled2 and 14 or 0))
	
		instance1:LockInstance (true)
		instance2:LockInstance (true)
	
		instance1:SaveMainWindowPosition()
		instance2:SaveMainWindowPosition()

	end
	

	
	_detalhes:InstallSkin ("ElvUI Frame Style", {
		file = [[Interface\AddOns\Details\images\skins\elvui]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "This skin is based on ElvUI's addons, relying with black and transparent frames.", 
		
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

			menu_icons_size = 0.90,
			menu_anchor = {16, 2, side = 2},
			menu_anchor_down = {16, -2},
			plugins_grow_direction = 1,
			menu_icons = {shadow = true},
			
			attribute_text = {enabled = true, anchor = {-20, 5}, text_face = "Accidental Presidency", text_size = 12, text_color = {1, 1, 1, .7}, side = 1, shadow = true},
			
			hide_icon = true,
			desaturated_menu = false,
			
			bg_alpha = 0.51,
			bg_r = 0.3294,
			bg_g = 0.3294,
			bg_b = 0.3294,
			show_statusbar = false,
			
			row_info = {
					texture = "Skyline",
					texture_class_colors = true, 
					alpha = 0.80, 
					texture_background_class_color = false,
					texture_background = "Details D'ictum",
					fixed_texture_color = {0, 0, 0},
					fixed_texture_background_color = {0, 0, 0, 0.471},
					space = {left = 1, right = -2, between = 0},
					backdrop = {enabled = true, size = 4, color = {0, 0, 0, 1}, texture = "Details BarBorder 2"},
					icon_file = [[Interface\AddOns\Details\images\classes_small_alpha]],
					start_after_icon = false,
			},

			wallpaper = {
				overlay = {1, 1,	1},
				width = 256,
				texcoord = {49/1024, 305/1024, 774/1024, 646/1024},
				enabled = true,
				anchor = "all",
				height = 128,
				alpha = 0.8,
				texture = [[Interface\AddOns\Details\images\skins\elvui]],
			}
		},
		
		skin_options = {
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON1"], func = align_right_chat, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON1_DESC"]},
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON2"], func = set_tooltip_elvui1, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON2_DESC"]},
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3"], func = set_tooltip_elvui2, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3_DESC"]},
		}
	})
	
	_detalhes:InstallSkin ("ElvUI Style II", {
		file = [[Interface\AddOns\Details\images\skins\elvui_opaque]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "This skin is based on ElvUI's addons, with an opaque title bar.", 
		
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
			["show_statusbar"] = false,
			["color"] = {1,1,1,1},
			["menu_anchor"] = {17, 2, ["side"] = 2},
			["bg_r"] = 0.517647058823529,
			["following"] = {
				["enabled"] = false,
				["bar_color"] = {1,1,1},
				["text_color"] = {1,1,1},
			},
			["color_buttons"] = {1,1,1,1},
			["bars_sort_direction"] = 1,
			["instance_button_anchor"] = {-27,1},
			["row_info"] = {
				["textR_outline"] = false,
				["textL_outline"] = false,
				["textL_enable_custom_text"] = false,
				["icon_file"] = "Interface\\AddOns\\Details\\images\\classes_small_alpha",
				["texture_background_file"] = "Interface\\AddOns\\Details\\images\\BantoBar",
				["start_after_icon"] = false,
				["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
				["textR_enable_custom_text"] = false,
				["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
				["percent_type"] = 1,
				["fixed_text_color"] = {0.905882352941177,0.905882352941177,0.905882352941177,1},
				["space"] = {
					["right"] = -2,
					["left"] = 1,
					["between"] = 1,
				},
				["texture"] = "Skyline",
				["texture_background_class_color"] = false,
				["fixed_texture_background_color"] = {0,0,0,0.295484036207199},
				["font_face_file"] = "Fonts\\ARIALN.TTF",
				["alpha"] = 1,
				["textR_class_colors"] = false,
				["models"] = {
				["upper_model"] = "Spells\\AcidBreath_SuperGreen.M2",
				["lower_model"] = "World\\EXPANSION02\\DOODADS\\Coldarra\\COLDARRALOCUS.m2",
				["upper_alpha"] = 0.5,
				["lower_enabled"] = false,
				["lower_alpha"] = 0.1,
				["upper_enabled"] = false,
			},
				["backdrop"] = {
					["enabled"] = false,
					["size"] = 5,
					["color"] = {0, 0, 0, 1},
					["texture"] = "Details BarBorder 1",
				},
				["texture_background"] = "BantoBar",
				["textL_custom_text"] = "{data1}. {data3}{data2}",
				["no_icon"] = false,
				["font_size"] = 10,
				["textL_class_colors"] = false,
				["font_face"] = "Arial Narrow",
				["texture_class_colors"] = true,
				["height"] = 14,
				["texture_file"] = "Interface\\AddOns\\Details\\images\\bar_skyline",
				["textL_show_number"] = true,
				["fixed_texture_color"] = {0.862745098039216,0.862745098039216,0.862745098039216,1},
			},
			["bars_grow_direction"] = 1,
			["menu_alpha"] = {
				["enabled"] = false,
				["onleave"] = 1,
				["ignorebars"] = false,
				["iconstoo"] = true,
				["onenter"] = 1,
			},
			["total_bar"] = {
				["enabled"] = false,
				["only_in_group"] = true,
				["icon"] = "Interface\\ICONS\\INV_Sigil_Thorim",
				["color"] = {1,1,1},
			},
			["plugins_grow_direction"] = 1,
			["strata"] = "LOW",
			["show_sidebars"] = true,
			["hide_in_combat_alpha"] = 0,
			["menu_icons"] = {true,true,true,true,true, true, ["space"] = -4, ["shadow"] = true},
			["desaturated_menu"] = false,
			["auto_hide_menu"] = {
				["left"] = false,
				["right"] = false,
			},
			["window_scale"] = 1.00999999046326,
			["grab_on_top"] = false,
			["menu_anchor_down"] = {16, -2},
			["statusbar_info"] = {
				["alpha"] = 1,
				["overlay"] = {1,1,1},
			},
			["hide_icon"] = true,
			["micro_displays_side"] = 2,
			["bg_alpha"] = 0.659999966621399,
			["auto_current"] = true,
			["toolbar_side"] = 1,
			["bg_g"] = 0.517647058823529,
			["backdrop_texture"] = "Details Ground",
			["hide_in_combat"] = false,
			["skin"] = "ElvUI Style II",
			["menu_icons_size"] = 0.850000023841858,
			["wallpaper"] = {
				["enabled"] = true,
				["width"] = 265.999979475717,
				["texcoord"] = {0.0480000019073486,0.298000011444092,0.630999984741211,0.755999984741211},
				["overlay"] = {0.999997794628143,0.999997794628143,0.999997794628143,0.799998223781586},
				["anchor"] = "all",
				["height"] = 226.000007591173,
				["alpha"] = 0.800000071525574,
				["texture"] = "Interface\\AddOns\\Details\\images\\skins\\elvui",
			},
			["stretch_button_side"] = 1,
			["attribute_text"] = {
				["enabled"] = true,
				["shadow"] = true,
				["side"] = 1,
				["enable_custom_text"] = false,
				["custom_text"] = "{name}",
				["text_face"] = "Accidental Presidency",
				["anchor"] = {-18,5},
				["text_color"] = {1,1,1,0.7},
				["text_size"] = 12,
			},
			["bg_b"] = 0.517647058823529,
		},
		
		skin_options = {
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON1"], func = align_right_chat, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON1_DESC"]},
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON2"], func = set_tooltip_elvui1, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON2_DESC"]},
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3"], func = set_tooltip_elvui2, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3_DESC"]},
		}
	})	
	
	--alpha = 0.4980392451398075,
	