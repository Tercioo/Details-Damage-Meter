
local _UnitAura = UnitAura

local flask_list = {
	[156064] = true, --Greater Draenic Agility Flask
	[156070] = true, --Draenic Intellect Flask
	[156071] = true, --Draenic Strength Flask
	[156073] = true, --Draenic Agility Flask
	[156077] = true, --Draenic Stamina Flask
	[156079] = true, --Greater Draenic Intellect Flask
	[156080] = true, --Greater Draenic Strength Flask
	[156084] = true, --Greater Draenic Stamina Flask
}

-- 175790, --shiftness potion (70% speed)
-- 175817, --living action potion (remove stun)
-- 156445, --rejuvenation potion (restore 70k hp)
-- 156436, --mana potion
-- 156432, --channeled mana potion

local pre_potions_list = {
	[156426] = true, --draenic intellect potion
	[156430] = true, --draenic armor potion
	[156423] = true, --draenic agility potion
	[156428] = true, --draenic strength potion
	[175821] = true, --draenic pure rage potion
}

local food_list = {
	[160600] = true, --
	[160724] = true, --
	[160726] = true, --
	[160793] = true, --
	[160832] = true, --
	[160839] = true, --
	[160883] = true, --
	[160889] = true, --
	[160893] = true, --
	[160897] = true, --
	[160900] = true, --
	[160902] = true, --
	[175218] = true, --
	[175219] = true, --
	[175220] = true, --
	[175222] = true, --
	[175223] = true, --
}



--> localization
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ("Details")
--> create the plugin object
	local DetailsRaidCheck = _detalhes:NewPluginObject ("DetailsRaidCheck", DETAILSPLUGIN_ALWAYSENABLED)
	tinsert (UISpecialFrames, "DetailsRaidCheck")
	DetailsRaidCheck:SetPluginDescription (Loc ["STRING_RAIDCHECK_PLUGIN_DESC"])
	
	
	local CreatePluginFrames = function()
	
		DetailsRaidCheck.usedprepot_table = {}
		DetailsRaidCheck.haveflask_table = {}
		DetailsRaidCheck.havefood_table = {}
		
		DetailsRaidCheck.on_raid = false
		DetailsRaidCheck.tracking_buffs = false
		
		local empty_table = {}
		
		function DetailsRaidCheck:OnDetailsEvent (event, ...)
			
			if (event == "ZONE_TYPE_CHANGED") then
			
				DetailsRaidCheck:CheckZone (...)

			elseif (event == "COMBAT_PLAYER_LEAVE") then
				
				if (DetailsRaidCheck.on_raid) then
				
					--> GET PRE POTION LIST
					table.wipe (DetailsRaidCheck.usedprepot_table or empty_table)
					DetailsRaidCheck.usedprepot_table = DetailsRaidCheck:FormatTable (DetailsRaidCheck.last_combat_pre_pot_used or "")
					
					DetailsRaidCheck:StartTrackBuffs()
				end
			
			elseif (event == "COMBAT_PLAYER_ENTER") then
				
				if (DetailsRaidCheck.on_raid) then
				
					DetailsRaidCheck:StopTrackBuffs()
					
				end
				
			elseif (event == "DETAILS_STARTED") then

				DetailsRaidCheck:CheckZone()
				
			elseif (event == "PLUGIN_DISABLED") then
			
				DetailsRaidCheck.on_raid = false
				DetailsRaidCheck.tracking_buffs = false
				
				DetailsRaidCheck:StopTrackBuffs()
				--> HIDE ICON
			
			elseif (event == "PLUGIN_ENABLED") then

				DetailsRaidCheck:CheckZone()
				
			end
			
		end
		
		DetailsRaidCheck.ToolbarButton = _detalhes.ToolBar:NewPluginToolbarButton (DetailsRaidCheck.empty_function, [[Interface\AddOns\Details_RaidCheck\icon]], Loc ["STRING_RAIDCHECK_PLUGIN_NAME"], "", 16, 16, "RAIDCHECK_PLUGIN_BUTTON")
		DetailsRaidCheck.ToolbarButton.shadow = true --> loads icon_shadow.tga when the instance is showing icons with shadows
		DetailsRaidCheck:ShowToolbarIcon (DetailsRaidCheck.ToolbarButton, "star")
		
		local show_panel = CreateFrame ("frame", nil, UIParent)
		show_panel:SetSize (400, 300)
		show_panel:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})
		show_panel:SetPoint ("bottom", DetailsRaidCheck.ToolbarButton, "top", 0, 10)
		
		local food_str = show_panel:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		food_str:SetPoint ("topleft", show_panel, "topleft", 15, -20)
		
		local flask_str = show_panel:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		flask_str:SetPoint ("topleft", show_panel, "topleft", 150, -20)
		
		local prepot_str = show_panel:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		prepot_str:SetPoint ("topleft", show_panel, "topleft", 285, -20)
		
		show_panel:Hide()
		
		--> overwrite the default scripts
		DetailsRaidCheck.ToolbarButton:SetScript ("OnClick", function (self, button)
			
		end)
		
		local update_panel = function (self)
		
			local s, f = "No Food:\n\n", "No Flask:\n\n"
			
			for i = 1, GetNumGroupMembers(), 1 do
			
				local name = UnitName ("raid" .. i)
				
				if (not DetailsRaidCheck.havefood_table [name]) then
					s = s .. name .. "\n"
				end
				
				if (not DetailsRaidCheck.haveflask_table [name]) then
					f = f .. name .. "\n"
				end
				
			end
			
			food_str:SetText (s)
			flask_str:SetText (f)

		end
		
		DetailsRaidCheck.ToolbarButton:SetScript ("OnEnter", function (self)
			show_panel:Show()
			show_panel:SetScript ("OnUpdate", update_panel)
		end)
		
		DetailsRaidCheck.ToolbarButton:SetScript ("OnLeave", function (self)
			show_panel:Hide()
			show_panel:SetScript ("OnUpdate", nil)
		end)
		
		function DetailsRaidCheck:CheckZone (...)
			zone_type = select (1, ...)
			
			if (not zone_type) then
				zone_type = select (2, GetInstanceInfo())
			end
			
			if (zone_type == "raid") then
			
				DetailsRaidCheck.on_raid = true
				
				if (not DetailsRaidCheck.in_combat) then
					DetailsRaidCheck:StartTrackBuffs()
					
				end
			else
				DetailsRaidCheck.on_raid = false
				
				if (DetailsRaidCheck.tracking_buffs) then
					DetailsRaidCheck:StopTrackBuffs()
					
				end
			end
		end
		
		function DetailsRaidCheck:BuffTrackTick()
			
			for player_name, have in pairs (DetailsRaidCheck.haveflask_table) do
				DetailsRaidCheck.haveflask_table [player_name] = nil
			end
			for player_name, have in pairs (DetailsRaidCheck.havefood_table) do
				DetailsRaidCheck.havefood_table [player_name] = nil
			end
			
			for i = 1, GetNumGroupMembers(), 1 do
				local name = UnitName ("raid" .. i)
				for buffIndex = 1, 41 do
					local bname, _, _, _, _, _, _, _, _, _, spellid  = _UnitAura ("raid" .. i, buffIndex, nil, "HELPFUL")
					
					if (bname and flask_list [spellid]) then
						DetailsRaidCheck.haveflask_table [name] = true
					end
					
					if (bname and food_list [spellid]) then
						DetailsRaidCheck.havefood_table [name] = true
					end
				end
			end
			
		end
		
		function DetailsRaidCheck:FormatTable (t)

			for k, v in ipairs ({strsplit ( "|c", t )}) do
				tinsert (DetailsRaidCheck.usedprepot_table, "|c" .. v)
			end

		end
		
--		DETAILS_PLUGIN_RAIDCHECK
--		/run vardump (DETAILS_PLUGIN_RAIDCHECK.havefood_table)
--		DETAILS_PLUGIN_RAIDCHECK.tracking_buffs
--		/run DETAILS_PLUGIN_RAIDCHECK:StartTrackBuffs()
--		/run DETAILS_PLUGIN_RAIDCHECK:StopTrackBuffs()
		
		function DetailsRaidCheck:StartTrackBuffs()
			
			if (not DetailsRaidCheck.tracking_buffs) then
				DetailsRaidCheck.tracking_buffs = true
				
				table.wipe (DetailsRaidCheck.haveflask_table)
				table.wipe (DetailsRaidCheck.havefood_table)
				
				if (DetailsRaidCheck.tracking_buffs_process) then
					DetailsRaidCheck:CancelTimer (DetailsRaidCheck.tracking_buffs_process)
				end
				
				DetailsRaidCheck.tracking_buffs_process = DetailsRaidCheck:ScheduleRepeatingTimer ("BuffTrackTick", 1)
			end
			
		end
		
		function DetailsRaidCheck:StopTrackBuffs()
			
			if (DetailsRaidCheck.tracking_buffs) then
				DetailsRaidCheck.tracking_buffs = false
				
				if (DetailsRaidCheck.tracking_buffs_process) then
					DetailsRaidCheck:CancelTimer (DetailsRaidCheck.tracking_buffs_process)
				end
			else
				if (DetailsRaidCheck.tracking_buffs_process) then
					DetailsRaidCheck:CancelTimer (DetailsRaidCheck.tracking_buffs_process)
				end
			end
			
		end

	end
	
	function DetailsRaidCheck:OnEvent (_, event, ...)

		if (event == "ADDON_LOADED") then
			local AddonName = select (1, ...)
			if (AddonName == "Details_RaidCheck") then
				
				if (_G._detalhes) then

					--> create widgets
					CreatePluginFrames()

					--> core version required
					local MINIMAL_DETAILS_VERSION_REQUIRED = 20
					
					local default_settings = {
						pre_pot_healers = false, --do not report pre pot for healers
						pre_pot_tanks = false, --do not report pre pot for tanks
						show_icon = 5, --when show the icon
					}
					
					--> install
					local install, saveddata, is_enabled = _G._detalhes:InstallPlugin ("TOOLBAR", Loc ["STRING_RAIDCHECK_PLUGIN_NAME"], [[Interface\AddOns\Details_RaidCheck\icon]], DetailsRaidCheck, "DETAILS_PLUGIN_RAIDCHECK", MINIMAL_DETAILS_VERSION_REQUIRED, "Details! Team", "v1.0", default_settings)
					if (type (install) == "table" and install.error) then
						return print (install.error)
					end
					
					--> register needed events
					
					_G._detalhes:RegisterEvent (DetailsRaidCheck, "COMBAT_PLAYER_LEAVE")
					_G._detalhes:RegisterEvent (DetailsRaidCheck, "COMBAT_PLAYER_ENTER")
					_G._detalhes:RegisterEvent (DetailsRaidCheck, "ZONE_TYPE_CHANGED")
					
				end
			end
		end
	end	