local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ("Details_Threat")

local _GetNumSubgroupMembers = GetNumSubgroupMembers --> wow api
local _GetNumGroupMembers = GetNumGroupMembers --> wow api
local _UnitIsFriend = UnitIsFriend --> wow api
local _UnitName = UnitName --> wow api
local _UnitDetailedThreatSituation = UnitDetailedThreatSituation
local _IsInRaid = IsInRaid --> wow api
local _IsInGroup = IsInGroup --> wow api
local _UnitGroupRolesAssigned = UnitGroupRolesAssigned --> wow api

local _ipairs = ipairs --> lua api
local _table_sort = table.sort --> lua api
local _cstr = string.format --> lua api
local _unpack = unpack

--> Create the plugin Object
local ThreatMeter = _detalhes:NewPluginObject ("Details_Threat")
--> Main Frame
local ThreatMeterFrame = ThreatMeter.Frame

local function CreatePluginFrames (data)
	
	--> catch Details! main object
	local _detalhes = _G._detalhes
	local DetailsFrameWork = _detalhes.gump

	--> data
	ThreatMeter.data = data or {}
	
	--> defaults
	ThreatMeter.RowWidth = 294
	ThreatMeter.RowHeight = 14
	--> amount of row wich can be displayed
	ThreatMeter.CanShow = 0
	--> all rows already created
	ThreatMeter.Rows = {}
	--> current shown rows
	ThreatMeter.ShownRows = {}
	-->
	ThreatMeter.Actived = false
	
	--> window reference
	local instance
	local player
	
	function _detalhes:FadeOnShow()
		DetailsFrameWork:Fade (ThreatMeterFrame.titleIcon, "ALPHAANIM", 0.05)
		DetailsFrameWork:Fade (ThreatMeterFrame.titleText, "ALPHAANIM", 0.05)
		DetailsFrameWork:Fade (ThreatMeterFrame.titleText2, "IN", 0.5)
	end
	
	--> OnEvent Table
	function ThreatMeter:OnDetailsEvent (event)
	
		if (event == "HIDE") then --> plugin hidded, disabled
			ThreatMeterFrame:SetScript ("OnUpdate", nil) 
			ThreatMeter.Actived = false
			ThreatMeter:Cancel()
		
		elseif (event == "SHOW") then
			instance = _detalhes.RaidTables.instancia
			
			ThreatMeter.RowWidth = instance.baseframe:GetWidth()-6
			
			ThreatMeter:UpdateContainers()
			ThreatMeter:UpdateRows()
			
			ThreatMeter:SizeChanged()
			
			player = UnitName ("player")
			ThreatMeterFrame:RegisterEvent ("PLAYER_TARGET_CHANGED")
			ThreatMeter.Actived = false
			_detalhes:ScheduleTimer ("FadeOnShow", 3)

			if (ThreatMeter:IsInCombat()) then
				ThreatMeter.Actived = true
				ThreatMeter:Start()
			else
				DetailsFrameWork:Fade (ThreatMeterFrame.titleIcon, 0)
				DetailsFrameWork:Fade (ThreatMeterFrame.titleText, 0)
				DetailsFrameWork:Fade (ThreatMeterFrame.titleText2, 0)
			end
			
		elseif (event == "REFRESH") then --> requested a refresh window
			-->

		elseif (event == "COMBAT_PLAYER_ENTER") then --> combat started
			--print ("ENTER COMBAT - nova tabela")
			if (IsInGroup() or IsInRaid()) then
				DetailsFrameWork:Fade (ThreatMeterFrame.titleIcon, 1)
				DetailsFrameWork:Fade (ThreatMeterFrame.titleText, 1)
				DetailsFrameWork:Fade (ThreatMeterFrame.titleText2, 1)
			end
			ThreatMeter.Actived = true
			ThreatMeter:Start()

		elseif (event == "COMBAT_PLAYER_LEAVE") then --> combat ended
			DetailsFrameWork:Fade (ThreatMeterFrame.titleIcon, "alpha", 0.05)
			DetailsFrameWork:Fade (ThreatMeterFrame.titleText, "alpha", 0.05)
			DetailsFrameWork:Fade (ThreatMeterFrame.titleText2, 1)
			ThreatMeter:End()
			ThreatMeter.Actived = false
		
		elseif (event == "DETAILS_INSTANCE_ENDRESIZE" or event == "DETAILS_INSTANCE_SIZECHANGED") then
			ThreatMeter:SizeChanged()
		
		elseif (event == "DETAILS_INSTANCE_STARTSTRETCH") then
			ThreatMeterFrame:SetFrameStrata ("TOOLTIP")
			ThreatMeterFrame:SetFrameLevel (instance.baseframe:GetFrameLevel()+1)
		
		elseif (event == "DETAILS_INSTANCE_ENDSTRETCH") then
			ThreatMeterFrame:SetFrameStrata ("MEDIUM")
			
		elseif (event == "PLUGIN_DISABLED") then
			
		elseif (event == "PLUGIN_ENABLED") then
			
		end
	end
	
	ThreatMeterFrame:SetWidth (300)
	ThreatMeterFrame:SetHeight (100)
	
	--[[
	ThreatMeterFrame:SetBackdrop ({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
		tile = true, tileSize = 16,
		insets = {left = 1, right = 1, top = 0, bottom = 1},})
	ThreatMeterFrame:SetBackdropColor (.3, .3, .3, .3)
	--]]
	
	local icon1 = DetailsFrameWork:NewImage (ThreatMeterFrame, nil, nil, "titleIcon", 64, 64, [[Interface\HELPFRAME\HelpIcon-ItemRestoration]])
	icon1:SetPoint (10, -10)
	local title = DetailsFrameWork:NewLabel (ThreatMeterFrame, nil, nil, "titleText", "Tiny Threat", "CoreAbilityFont", 26)
	title:SetPoint ("left", icon1, "right", 2)
	title.color = "white"
	DetailsFrameWork:Fade (icon1, 1)
	DetailsFrameWork:Fade (title, 1)
	local title2 = DetailsFrameWork:NewLabel (ThreatMeterFrame, nil, nil, "titleText2", "A (very) small threat meter.", "GameFontHighlightSmall", 9)
	title2:SetPoint ("bottomright", title, "bottomright", 0, -10)

	function ThreatMeter:UpdateContainers()
		for _, row in _ipairs (ThreatMeter.Rows) do 
			row:SetContainer (instance.baseframe)
		end
	end
	
	function ThreatMeter:UpdateRows()
		for _, row in _ipairs (ThreatMeter.Rows) do
			row.width = ThreatMeter.RowWidth
		end
	end
	
	function ThreatMeter:HideBars()
		for _, row in _ipairs (ThreatMeter.Rows) do 
			row:Hide()
		end
	end
	
	local target = nil
	local timer = 0
	local interval = 1.0
	
	local RoleIconCoord = {
		["TANK"] = {0, 0.28125, 0.328125, 0.625},
		["HEALER"] = {0.3125, 0.59375, 0, 0.296875},
		["DAMAGER"] = {0.3125, 0.59375, 0.328125, 0.625}
	}
	
	function ThreatMeter:SizeChanged()

		local w, h = instance:GetSize()
		ThreatMeterFrame:SetWidth (w)
		ThreatMeterFrame:SetHeight (h)
		
		ThreatMeter.CanShow = math.floor ( h / (ThreatMeter.RowHeight+1))

		for i = #ThreatMeter.Rows+1, ThreatMeter.CanShow do
			ThreatMeter:NewRow (i)
		end

		ThreatMeter.ShownRows = {}
		
		for i = 1, ThreatMeter.CanShow do
			ThreatMeter.ShownRows [#ThreatMeter.ShownRows+1] = ThreatMeter.Rows[i]
			if (_detalhes.in_combat) then
				ThreatMeter.Rows[i]:Show()
			end
			ThreatMeter.Rows[i].width = w-5
		end
		
		for i = #ThreatMeter.ShownRows+1, #ThreatMeter.Rows do
			ThreatMeter.Rows [i]:Hide()
		end
		
	end
	
	function ThreatMeter:NewRow (i)
		local newrow = DetailsFrameWork:NewBar (ThreatMeterFrame, _, "DetailsThreatRow"..i, _, 300, 14)
		newrow:SetPoint (3, -((i-1)*15))
		newrow.lefttext = "bar " .. i
		newrow.color = "skyblue"
		newrow.fontsize = 9.9
		newrow.fontface = "GameFontHighlightSmall"
		newrow:SetIcon ("Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES", RoleIconCoord ["DAMAGER"])
		ThreatMeter.Rows [#ThreatMeter.Rows+1] = newrow
		newrow:Hide()
		return newrow
	end
	
	local sort = function (table1, table2)
		if (table1[2] > table2[2]) then
			return true
		else
			return false
		end
	end
	--[[
						local percent = threat_actor [2]
						if (percentagem >= 50) then
							thisRow:SetColor ( percent/100, 1, 0, 1)
						else
							thisRow:SetColor ( 1, percent/100, 0, 1)
						end	
--]]
	local Threater = function()
		
		local threat_table = {}
		
		if (target) then
			if (_IsInRaid()) then
				for i = 1, _GetNumGroupMembers(), 1 do
					local isTanking, status, threatpct, rawthreatpct, threatvalue = _UnitDetailedThreatSituation ("raid"..i, "target")
					if (status) then
						threat_table [#threat_table+1] = {_UnitName ("raid"..i), threatpct, isTanking}
					end
				end
			elseif (_IsInGroup()) then
				for i = 1, _GetNumGroupMembers()-1, 1 do
					local isTanking, status, threatpct, rawthreatpct, threatvalue = _UnitDetailedThreatSituation ("party"..i, "target")
					if (status) then
						threat_table [#threat_table+1] = {_UnitName ("party"..i), threatpct, isTanking}
					end
				end
			end
			
			_table_sort (threat_table, sort)
			
			local lastIndex = 0
			local shownMe = false
			
			for index = 1, #ThreatMeter.ShownRows do
				local thisRow = ThreatMeter.ShownRows [index]
				local threat_actor = threat_table [index]
				
				if (threat_actor) then
					local role = _UnitGroupRolesAssigned (threat_actor [1])
					thisRow.icon:SetTexCoord (_unpack (RoleIconCoord [role]))
					thisRow:SetLeftText (threat_actor [1])
					thisRow:SetRightText (_cstr ("%.1f", threat_actor [2]).."%")
					thisRow:SetValue (threat_actor [2])
					
					if (index == 1) then
						thisRow:SetColor (threat_actor [2]*0.01, math.abs (threat_actor [2]-100)*0.01, 0, 1)
					else
						thisRow:SetColor (threat_actor [2]*0.01, math.abs (threat_actor [2]-100)*0.01, 0, .3)
						local percent = threat_actor [2]
						if (percent >= 50) then
							thisRow:SetColor ( 1, math.abs (percent - 100)/100, 0, 1)
						else
							thisRow:SetColor ( percent/100, 1, 0, 1)
						end
					end
					
					if (not thisRow.statusbar:IsShown()) then
						thisRow:Show()
					end
					if (threat_actor [1] == player) then
						shownMe = true
					end
				else
					thisRow:Hide()
				end
			end
			
			if (not shownMe) then
				--> show my self into last bar
				local isTanking, status, threatpct, rawthreatpct, threatvalue = _UnitDetailedThreatSituation ("player", "target")
				if (threatpct and threatpct > 0.1) then
					local thisRow = ThreatMeter.ShownRows [#ThreatMeter.ShownRows]
					thisRow:SetLeftText (player)
					local role = _UnitGroupRolesAssigned (player)
					thisRow.icon:SetTexCoord (_unpack (RoleIconCoord [role]))
					thisRow:SetRightText (_cstr ("%.1f", threatpct).."%")
					thisRow:SetValue (threatpct)
					thisRow:SetColor (threatpct*0.01, math.abs (threatpct-100)*0.01, 0, .3)
				end
			end
		
		else
			--print ("nao tem target")
		end
		
	end
	
	function ThreatMeter:TargetChanged()
		if (not ThreatMeter.Actived) then
			return
		end
		local NewTarget = _UnitName ("target")
		if (NewTarget and not _UnitIsFriend ("player", "target")) then
			target = NewTarget
			Threater()
		else
			ThreatMeter:HideBars()
		end
	end
	
	local OnUpdate = function (self, elapsed)
		timer = timer + elapsed
		if (timer > interval) then
			timer = 0
			--if (_IsInRaid() or _IsInGroup()) then
				--print ("aqui")
				Threater()
			--end
		end
	end

	function ThreatMeter:Start()
		ThreatMeter:HideBars()
		if (ThreatMeter.Actived) then
			if (_IsInRaid() or _IsInGroup()) then	
				--print ("Iniciando analizador de Threat")
				ThreatMeterFrame:SetScript ("OnUpdate", OnUpdate)
			end
		end
	end
	
	function ThreatMeter:End()
		--print ("=== COMBAT LEAVE ===")
		ThreatMeter:HideBars()
		ThreatMeterFrame:SetScript ("OnEvent", nil)
	end
	
	function ThreatMeter:Cancel()
		ThreatMeter:HideBars()
	end
	
end

function ThreatMeter:OnEvent (_, event, ...)

	if (event == "PLAYER_TARGET_CHANGED") then
		ThreatMeter:TargetChanged()
		
	elseif (event == "ADDON_LOADED") then
		local AddonName = select (1, ...)
		if (AddonName == "Details_TinyThreat") then
			
			if (_G._detalhes) then
				
				--> create widgets
				CreatePluginFrames (data)

				local MINIMAL_DETAILS_VERSION_REQUIRED = 1
				
				--> Install
				local install = _G._detalhes:InstallPlugin ("TANK", Loc ["STRING_PLUGIN_NAME"], "Interface\\Icons\\Ability_Paladin_ShieldofVengeance", ThreatMeter, "DETAILS_PLUGIN_TINY_THREAT", MINIMAL_DETAILS_VERSION_REQUIRED, "Details! Team", "v1.02")
				if (type (install) == "table" and install.error) then
					print (install.error)
				end
				
				--> Register needed events
				_G._detalhes:RegisterEvent (ThreatMeter, "COMBAT_PLAYER_ENTER")
				_G._detalhes:RegisterEvent (ThreatMeter, "COMBAT_PLAYER_LEAVE")
				_G._detalhes:RegisterEvent (ThreatMeter, "DETAILS_INSTANCE_ENDRESIZE")
				_G._detalhes:RegisterEvent (ThreatMeter, "DETAILS_INSTANCE_SIZECHANGED")
				_G._detalhes:RegisterEvent (ThreatMeter, "DETAILS_INSTANCE_STARTSTRETCH")
				_G._detalhes:RegisterEvent (ThreatMeter, "DETAILS_INSTANCE_ENDSTRETCH")
				
				ThreatMeterFrame:RegisterEvent ("PLAYER_TARGET_CHANGED")
				
			end
		end

	elseif (event == "PLAYER_LOGOUT") then
		_detalhes_databaseThreat = ThreatMeter.data

	end
end
