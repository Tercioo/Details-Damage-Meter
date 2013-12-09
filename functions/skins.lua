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
		icon_plugins_size = {19, 19}
	})

	_detalhes:InstallSkin ("Flat Color", {
		file = [[Interface\AddOns\Details\images\skins\flat_skin]],
		author = "Details!", 
		version = "1.0", 
		site = "unknown", 
		desc = "a flat skin", 
		can_change_alpha_head = true, 
		icon_anchor_main = {-1, -5}, 
		icon_anchor_plugins = {-7, -13}, 
		icon_plugins_size = {19, 18}
	})
	